import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/isar_collections/menu_item_collection.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/category_provider.dart';
import '../providers/item_provider.dart';

/// ItemFormScreen — 4-step form for creating or editing a menu item.
///
/// Step 1 — Category   : Pick top-level → sub-category; inline "Create New"
/// Step 2 — Basic Info : Name, description, image from gallery
/// Step 3 — Pricing    : Base price, variant groups, add-on modifiers
/// Step 4 — Availability : Available for sale toggle
class ItemFormScreen extends ConsumerStatefulWidget {
  const ItemFormScreen({super.key, this.item});

  /// If non-null, the form opens in edit mode pre-filled from this item.
  final MenuItemCollection? item;

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {

  // ── Page controller ───────────────────────────────────────────────────────
  final _pageCtrl = PageController();
  int _step = 0;
  static const _totalSteps = 4;

  // ── Step 1 — Category ─────────────────────────────────────────────────────
  String? _topCategoryId;
  String? _subCategoryId;

  // ── Step 2 — Basic Info ───────────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _step2Key = GlobalKey<FormState>();
  String? _imageUrl; // saved URL (from Supabase or edit prefill)
  File? _localImageFile; // picked from gallery, not yet uploaded

  // ── Step 3 — Pricing ──────────────────────────────────────────────────────
  final _priceCtrl = TextEditingController();
  final List<VariantGroupDraft> _variantGroups = [];
  final List<ModifierDraft> _modifiers = [];

  // ── Step 4 — Availability ─────────────────────────────────────────────────
  bool _isAvailable = true;
  bool _isFavorite = false;

  bool _isSaving = false;
  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    _prefillIfEdit();
  }

  void _prefillIfEdit() {
    final item = widget.item;
    if (item == null) return;

    _nameCtrl.text = item.name;
    _descCtrl.text = item.description ?? '';
    _imageUrl = item.imageUrl;
    _priceCtrl.text = item.basePrice.toStringAsFixed(2);
    _isAvailable = item.isAvailable;
    _isFavorite = item.isFavorite;

    // Resolve top/sub category from item.categoryId
    // (done after first frame when categoryProvider is available)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveCategories(item.categoryId);
    });

    // Parse variant groups
    for (final g in item.variantGroupsJson) {
      try {
        _variantGroups
            .add(VariantGroupDraft.fromJson(jsonDecode(g) as Map<String, dynamic>));
      } catch (_) {}
    }

    // Parse modifiers
    for (final m in item.modifiersJson) {
      try {
        _modifiers.add(
            ModifierDraft.fromJson(jsonDecode(m) as Map<String, dynamic>));
      } catch (_) {}
    }
  }

  void _resolveCategories(String categoryId) {
    if (!mounted) return;
    final cats = ref.read(categoryProvider).asData?.value ?? [];
    final allCats = cats.map((c) => c.category).toList();

    final cat = allCats.where((c) => c.syncId == categoryId).firstOrNull;
    if (cat == null) return;

    if (cat.parentId != null) {
      // It's a sub-category
      setState(() {
        _topCategoryId = cat.parentId;
        _subCategoryId = cat.syncId;
      });
    } else {
      // It's a top-level category
      setState(() {
        _topCategoryId = cat.syncId;
        _subCategoryId = null;
      });
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _next() {
    if (_step == 0) {
      // Require at least a top-level category
      if (_topCategoryId == null) {
        _showError('Please select or create a category.');
        return;
      }
    }
    if (_step == 1) {
      if (!_step2Key.currentState!.validate()) return;
    }
    if (_step < _totalSteps - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _step++);
    }
  }

  void _prev() {
    if (_step > 0) {
      _pageCtrl.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _step--);
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final price =
        double.tryParse(_priceCtrl.text.replaceAll(',', '')) ?? 0;
    if (price < 0) {
      _showError('Price cannot be negative.');
      return;
    }
    // Determine effective categoryId (sub if selected, else top)
    final effectiveCategoryId = _subCategoryId ?? _topCategoryId;
    if (effectiveCategoryId == null) {
      _showError('Please select a category.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Upload image if a new local file was picked
      String? finalImageUrl = _imageUrl;
      if (_localImageFile != null) {
        final bytes = await _localImageFile!.readAsBytes();
        final name = _localImageFile!.path.split('/').last;
        finalImageUrl =
            await SupabaseService.instance.uploadMenuImage(bytes, name);
        if (finalImageUrl == null && mounted) {
          _showError(
              'Image upload failed. Check your Supabase "menu-items" bucket.');
          setState(() => _isSaving = false);
          return;
        }
      }

      if (_isEdit) {
        await ref.read(itemProvider.notifier).updateItem(
              item: widget.item!,
              name: _nameCtrl.text,
              categoryId: effectiveCategoryId,
              basePrice: price,
              description: _descCtrl.text,
              imageUrl: finalImageUrl,
              isAvailable: _isAvailable,
              isFavorite: _isFavorite,
              variantGroups: List.from(_variantGroups),
              modifiers: List.from(_modifiers),
            );
      } else {
        await ref.read(itemProvider.notifier).createItem(
              name: _nameCtrl.text,
              categoryId: effectiveCategoryId,
              basePrice: price,
              description: _descCtrl.text,
              imageUrl: finalImageUrl,
              isAvailable: _isAvailable,
              isFavorite: _isFavorite,
              variantGroups: List.from(_variantGroups),
              modifiers: List.from(_modifiers),
            );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _showError('Error saving item: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.errorLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final stepLabels = ['Category', 'Basic Info', 'Pricing', 'Availability'];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Edit Item' : 'New Item',
          style: AppTextStyles.bodySemiBold(context),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StepIndicator(
                current: _step,
                total: _totalSteps,
                labels: stepLabels),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1Category(
                    selectedTopId: _topCategoryId,
                    selectedSubId: _subCategoryId,
                    onTopChanged: (id) =>
                        setState(() {
                          _topCategoryId = id;
                          _subCategoryId = null;
                        }),
                    onSubChanged: (id) =>
                        setState(() => _subCategoryId = id),
                  ),
                  _Step2BasicInfo(
                    formKey: _step2Key,
                    nameCtrl: _nameCtrl,
                    descCtrl: _descCtrl,
                    imageUrl: _imageUrl,
                    localImageFile: _localImageFile,
                    onImagePicked: (file) =>
                        setState(() {
                          _localImageFile = file;
                          _imageUrl = null;
                        }),
                    onImageRemoved: () =>
                        setState(() {
                          _localImageFile = null;
                          _imageUrl = null;
                        }),
                  ),
                  _Step3Pricing(
                    priceCtrl: _priceCtrl,
                    variantGroups: _variantGroups,
                    modifiers: _modifiers,
                    onChanged: () => setState(() {}),
                  ),
                  _Step4Availability(
                    isAvailable: _isAvailable,
                    isFavorite: _isFavorite,
                    onAvailableChanged: (v) =>
                        setState(() => _isAvailable = v),
                    onFavoriteChanged: (v) =>
                        setState(() => _isFavorite = v),
                  ),
                ],
              ),
            ),
            _BottomNav(
              currentStep: _step,
              totalSteps: _totalSteps,
              isSaving: _isSaving,
              onPrev: _prev,
              onNext: _next,
              onSave: _save,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator(
      {required this.current, required this.total, required this.labels});
  final int current;
  final int total;
  final List<String> labels;

  static const _maroon = Color(0xFF8B4049);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: Row(
        children: List.generate(total, (i) {
          final isActive = i == current;
          final isDone = i < current;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < total - 1 ? 8 : 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? _maroon
                              : isDone
                                  ? _maroon.withValues(alpha: 0.3)
                                  : (isDark
                                      ? AppColors.cardDark
                                      : AppColors.cardLight),
                          border: Border.all(
                            color: isActive || isDone
                                ? _maroon
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 14)
                              : Text(
                                  '${i + 1}',
                                  style: GoogleFonts.dmSans(
                                    color: isActive
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      if (i < total - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: isDone
                                ? _maroon.withValues(alpha: 0.4)
                                : (isDark
                                    ? AppColors.cardDark
                                    : AppColors.cardLight),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (i < labels.length)
                    Text(
                      labels[i],
                      style: GoogleFonts.dmSans(
                        color: isActive
                            ? _maroon
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                        fontSize: 10,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Step 1 — Category ─────────────────────────────────────────────────────────

class _Step1Category extends ConsumerWidget {
  const _Step1Category({
    required this.selectedTopId,
    required this.selectedSubId,
    required this.onTopChanged,
    required this.onSubChanged,
  });

  final String? selectedTopId;
  final String? selectedSubId;
  final ValueChanged<String?> onTopChanged;
  final ValueChanged<String?> onSubChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;

    final catsAsync = ref.watch(categoryProvider);
    final allCats = catsAsync.asData?.value ?? [];

    final topLevelCats =
        allCats.where((c) => c.category.parentId == null).toList();
    final subCats = selectedTopId == null
        ? <CategoryWithCount>[]
        : allCats
            .where((c) => c.category.parentId == selectedTopId)
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top-level category ─────────────────────────────────────
          _SectionLabel(
              label: 'Main Category',
              sub: 'e.g. Beverages, Food',
              context: context),
          const SizedBox(height: AppSpacing.sm),
          _CategoryGrid(
            cats: topLevelCats,
            selectedId: selectedTopId,
            isDark: isDark,
            cardBg: cardBg,
            textPrimary: textPrimary,
            onSelect: (id) => onTopChanged(id),
            onCreateNew: () async {
              final name = await _showCreateCategoryDialog(
                  context, ref, null);
              if (name != null && context.mounted) {
                final newId =
                    await _createCategory(context, ref, name, null);
                if (newId != null) onTopChanged(newId);
              }
            },
          ),

          // ── Sub-category ───────────────────────────────────────────
          if (selectedTopId != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _SectionLabel(
                label: 'Sub-category',
                sub: 'e.g. Coffee, Tea, Juice  (optional)',
                context: context),
            const SizedBox(height: AppSpacing.sm),
            _CategoryGrid(
              cats: subCats,
              selectedId: selectedSubId,
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              emptyText: 'No sub-categories yet.',
              allowNone: true,
              noneLabel: 'None (use main)',
              onSelect: (id) => onSubChanged(id),
              onCreateNew: () async {
                final name = await _showCreateCategoryDialog(
                    context, ref, selectedTopId);
                if (name != null && context.mounted) {
                  final newId = await _createCategory(
                      context, ref, name, selectedTopId);
                  if (newId != null) onSubChanged(newId);
                }
              },
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Future<String?> _showCreateCategoryDialog(
      BuildContext context, WidgetRef ref, String? parentId) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            parentId == null ? 'New Category' : 'New Sub-category',
            style: AppTextStyles.bodySemiBold(context),
          ),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            style: GoogleFonts.dmSans(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
            decoration: InputDecoration(
              hintText:
                  parentId == null ? 'e.g. Beverages' : 'e.g. Coffee',
              hintStyle: GoogleFonts.dmSans(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () {
                if (ctrl.text.trim().isNotEmpty) {
                  Navigator.pop(context, ctrl.text.trim());
                }
              },
              child: Text('Create',
                  style: GoogleFonts.dmSans(
                      color: const Color(0xFF8B4049),
                      fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _createCategory(BuildContext context, WidgetRef ref,
      String name, String? parentId) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final syncId = await ref
          .read(categoryProvider.notifier)
          .createCategoryAndReturnId(name: name, parentId: parentId);
      return syncId;
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Failed to create category: $e'),
        backgroundColor: AppColors.errorLight,
      ));
      return null;
    }
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.cats,
    required this.selectedId,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.onSelect,
    required this.onCreateNew,
    this.emptyText,
    this.allowNone = false,
    this.noneLabel,
  });

  final List<CategoryWithCount> cats;
  final String? selectedId;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final ValueChanged<String?> onSelect;
  final VoidCallback onCreateNew;
  final String? emptyText;
  final bool allowNone;
  final String? noneLabel;

  @override
  Widget build(BuildContext context) {
    final items = [
      if (allowNone)
        _CatChip(
          label: noneLabel ?? 'None',
          emoji: null,
          isSelected: selectedId == null,
          isDark: isDark,
          cardBg: cardBg,
          textPrimary: textPrimary,
          onTap: () => onSelect(null),
        ),
      ...cats.map((c) => _CatChip(
            label: c.category.name,
            emoji: c.category.iconEmoji,
            isSelected: selectedId == c.category.syncId,
            isDark: isDark,
            cardBg: cardBg,
            textPrimary: textPrimary,
            onTap: () => onSelect(c.category.syncId),
          )),
      _CatChip(
        label: '+ New',
        emoji: null,
        isSelected: false,
        isDark: isDark,
        cardBg: cardBg,
        textPrimary: textPrimary,
        isCreate: true,
        onTap: onCreateNew,
      ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items,
    );
  }
}

class _CatChip extends StatelessWidget {
  const _CatChip({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.onTap,
    this.isCreate = false,
  });

  final String label;
  final String? emoji;
  final bool isSelected;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final VoidCallback onTap;
  final bool isCreate;

  static const _maroon = Color(0xFF8B4049);

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    Border? border;

    if (isSelected) {
      bg = _maroon;
      textColor = Colors.white;
    } else if (isCreate) {
      bg = Colors.transparent;
      textColor = _maroon;
      border = Border.all(
          color: _maroon.withValues(alpha: 0.5), width: 1.5);
    } else {
      bg = cardBg;
      textColor = textPrimary;
      border = Border.all(
          color: Colors.black.withValues(alpha: 0.06), width: 1);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: border,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _maroon.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!,
                  style: GoogleFonts.dmSans(fontSize: 16)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.dmSans(
                color: textColor,
                fontSize: 14,
                fontWeight: isSelected || isCreate
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 2 — Basic Info ───────────────────────────────────────────────────────

class _Step2BasicInfo extends StatelessWidget {
  const _Step2BasicInfo({
    required this.formKey,
    required this.nameCtrl,
    required this.descCtrl,
    required this.imageUrl,
    required this.localImageFile,
    required this.onImagePicked,
    required this.onImageRemoved,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final String? imageUrl;
  final File? localImageFile;
  final ValueChanged<File?> onImagePicked;
  final VoidCallback onImageRemoved;

  static const int _maxImageBytes = 15 * 1024 * 1024; // 15 MB

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (picked == null) return;

      final bytes = await picked.length();
      if (bytes > _maxImageBytes) {
        messenger.showSnackBar(SnackBar(
          content: Text(
            'Image is too large (${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB). '
            'Maximum allowed size is 15 MB.',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.errorLight,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        return;
      }

      onImagePicked(File(picked.path));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Could not open gallery: $e'),
        backgroundColor: AppColors.errorLight,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final hintColor = textPrimary.withValues(alpha: 0.35);
    final hasImage = localImageFile != null || (imageUrl?.isNotEmpty == true);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image picker ────────────────────────────────────────────
            _SectionLabel(
                label: 'Item Photo', sub: 'Pick from gallery', context: context),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: () => _pickImage(context),
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.07),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: hasImage
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          localImageFile != null
                              ? Image.file(localImageFile!,
                                  fit: BoxFit.cover)
                              : Image.network(imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _imagePlaceholder(
                                          isDark, hintColor)),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: onImageRemoved,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => _pickImage(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('Change',
                                    style: GoogleFonts.dmSans(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ],
                      )
                    : _imagePlaceholder(isDark, hintColor),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Name ────────────────────────────────────────────────────
            AppTextField(
              controller: nameCtrl,
              label: 'Item Name',
              hint: 'e.g. Spanish Latte',
              prefixIcon: Icon(Icons.lunch_dining_outlined,
                  color: textPrimary.withValues(alpha: 0.4), size: 20),
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Name is required';
                if (v.trim().length < 2) return 'Name too short';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Description ─────────────────────────────────────────────
            AppTextField(
              controller: descCtrl,
              label: 'Description (optional)',
              hint: 'Short description…',
              maxLines: 2,
              prefixIcon: Icon(Icons.notes_rounded,
                  color: textPrimary.withValues(alpha: 0.4), size: 20),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(bool isDark, Color hintColor) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: 40, color: hintColor),
          const SizedBox(height: 8),
          Text(
            'Tap to add photo from gallery',
            style:
                GoogleFonts.dmSans(color: hintColor, fontSize: 13),
          ),
        ],
      );
}

// ── Step 3 — Pricing & Options ────────────────────────────────────────────────

class _Step3Pricing extends StatefulWidget {
  const _Step3Pricing({
    required this.priceCtrl,
    required this.variantGroups,
    required this.modifiers,
    required this.onChanged,
  });
  final TextEditingController priceCtrl;
  final List<VariantGroupDraft> variantGroups;
  final List<ModifierDraft> modifiers;
  final VoidCallback onChanged;

  @override
  State<_Step3Pricing> createState() => _Step3PricingState();
}

class _Step3PricingState extends State<_Step3Pricing> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Base price ─────────────────────────────────────────────
          AppTextField(
            controller: widget.priceCtrl,
            label: 'Base Price (₱)',
            hint: '0.00',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icon(Icons.attach_money_rounded,
                color: textPrimary.withValues(alpha: 0.4), size: 20),
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Variant groups ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _SectionLabel(
                    label: 'Option Groups',
                    sub: 'e.g. Size, Temperature',
                    context: context),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    widget.variantGroups.add(VariantGroupDraft(
                        groupName: '', options: []));
                  });
                  widget.onChanged();
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text('Add Group',
                    style:
                        GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8B4049)),
              ),
            ],
          ),
          Text(
            'Customer picks ONE option from each group. '
            'The option\'s price is added to the base price.',
            style: GoogleFonts.dmSans(
                color: textPrimary.withValues(alpha: 0.5),
                fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...List.generate(widget.variantGroups.length, (gi) {
            return _VariantGroupEditor(
              key: ValueKey('group_$gi'),
              draft: widget.variantGroups[gi],
              onChanged: (g) {
                setState(() => widget.variantGroups[gi] = g);
                widget.onChanged();
              },
              onDelete: () {
                setState(() => widget.variantGroups.removeAt(gi));
                widget.onChanged();
              },
            );
          }),

          const SizedBox(height: AppSpacing.lg),

          // ── Add-on modifiers ───────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _SectionLabel(
                    label: 'Add-ons',
                    sub: 'Optional extras with price',
                    context: context),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    final gName = widget.modifiers.isNotEmpty
                        ? widget.modifiers.last.groupName
                        : 'Add-ons';
                    widget.modifiers.add(ModifierDraft(
                        groupName: gName, name: '', priceDelta: 0));
                  });
                  widget.onChanged();
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text('Add',
                    style:
                        GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8B4049)),
              ),
            ],
          ),
          ...List.generate(widget.modifiers.length, (i) {
            return _ModifierRow(
              key: ValueKey('mod_$i'),
              draft: widget.modifiers[i],
              onChanged: (m) {
                setState(() => widget.modifiers[i] = m);
                widget.onChanged();
              },
              onDelete: () {
                setState(() => widget.modifiers.removeAt(i));
                widget.onChanged();
              },
            );
          }),
          if (widget.modifiers.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'No add-ons yet.',
                style: GoogleFonts.dmSans(
                    color: textPrimary.withValues(alpha: 0.35),
                    fontSize: 13),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _VariantGroupEditor extends StatefulWidget {
  const _VariantGroupEditor({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onDelete,
  });
  final VariantGroupDraft draft;
  final ValueChanged<VariantGroupDraft> onChanged;
  final VoidCallback onDelete;

  @override
  State<_VariantGroupEditor> createState() => _VariantGroupEditorState();
}

class _VariantGroupEditorState extends State<_VariantGroupEditor> {
  late final TextEditingController _groupNameCtrl;

  @override
  void initState() {
    super.initState();
    _groupNameCtrl = TextEditingController(text: widget.draft.groupName);
  }

  @override
  void dispose() {
    _groupNameCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(VariantGroupDraft(
      groupName: _groupNameCtrl.text,
      options: List.from(widget.draft.options),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group name header
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _groupNameCtrl,
                  onChanged: (_) => _notify(),
                  style: GoogleFonts.dmSans(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: 'Group name (e.g. Size, Temperature)',
                    hintStyle: GoogleFonts.dmSans(
                        color: textPrimary.withValues(alpha: 0.35),
                        fontSize: 13),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 4),
                    isDense: true,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.errorLight),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                onPressed: widget.onDelete,
              ),
            ],
          ),
          const Divider(height: 12),

          // Options list
          ...List.generate(widget.draft.options.length, (oi) {
            return _VariantOptionRow(
              key: ValueKey('opt_$oi'),
              opt: widget.draft.options[oi],
              onChanged: (o) {
                final newOpts =
                    List<VariantOptionDraft>.from(widget.draft.options);
                newOpts[oi] = o;
                widget.onChanged(VariantGroupDraft(
                    groupName: _groupNameCtrl.text, options: newOpts));
              },
              onDelete: () {
                final newOpts =
                    List<VariantOptionDraft>.from(widget.draft.options)
                      ..removeAt(oi);
                widget.onChanged(VariantGroupDraft(
                    groupName: _groupNameCtrl.text, options: newOpts));
                setState(() {});
              },
            );
          }),

          // Add option button
          TextButton.icon(
            onPressed: () {
              final newOpts =
                  List<VariantOptionDraft>.from(widget.draft.options)
                    ..add(VariantOptionDraft(name: '', priceDelta: 0));
              widget.onChanged(VariantGroupDraft(
                  groupName: _groupNameCtrl.text, options: newOpts));
              setState(() {});
            },
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text('Add Option',
                style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF8B4049),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

class _VariantOptionRow extends StatefulWidget {
  const _VariantOptionRow({
    super.key,
    required this.opt,
    required this.onChanged,
    required this.onDelete,
  });
  final VariantOptionDraft opt;
  final ValueChanged<VariantOptionDraft> onChanged;
  final VoidCallback onDelete;

  @override
  State<_VariantOptionRow> createState() => _VariantOptionRowState();
}

class _VariantOptionRowState extends State<_VariantOptionRow> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.opt.name);
    _priceCtrl = TextEditingController(
        text: widget.opt.priceDelta == 0
            ? ''
            : widget.opt.priceDelta.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _notify() => widget.onChanged(VariantOptionDraft(
        name: _nameCtrl.text,
        priceDelta: double.tryParse(_priceCtrl.text) ?? 0,
      ));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const SizedBox(width: 4),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _nameCtrl,
              onChanged: (_) => _notify(),
              style: GoogleFonts.dmSans(color: textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Option name (e.g. Small)',
                hintStyle: GoogleFonts.dmSans(
                    color: textPrimary.withValues(alpha: 0.35),
                    fontSize: 12),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: TextField(
              controller: _priceCtrl,
              onChanged: (_) => _notify(),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
              style: GoogleFonts.dmSans(color: textPrimary, fontSize: 13),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: '₱ 0',
                hintStyle: GoogleFonts.dmSans(
                    color: textPrimary.withValues(alpha: 0.35),
                    fontSize: 12),
                border: InputBorder.none,
                isDense: true,
                prefixText: '+₱ ',
                prefixStyle: GoogleFonts.dmSans(
                    color: textPrimary, fontSize: 13),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded,
                size: 16, color: AppColors.errorLight),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }
}

class _ModifierRow extends StatefulWidget {
  const _ModifierRow(
      {super.key,
      required this.draft,
      required this.onChanged,
      required this.onDelete});
  final ModifierDraft draft;
  final ValueChanged<ModifierDraft> onChanged;
  final VoidCallback onDelete;

  @override
  State<_ModifierRow> createState() => _ModifierRowState();
}

class _ModifierRowState extends State<_ModifierRow> {
  late final TextEditingController _groupCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _groupCtrl = TextEditingController(text: widget.draft.groupName);
    _nameCtrl = TextEditingController(text: widget.draft.name);
    _priceCtrl = TextEditingController(
        text: widget.draft.priceDelta == 0
            ? ''
            : widget.draft.priceDelta.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _groupCtrl.dispose();
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _notify() => widget.onChanged(ModifierDraft(
      groupName:
          _groupCtrl.text.isEmpty ? 'Add-ons' : _groupCtrl.text,
      name: _nameCtrl.text,
      priceDelta: double.tryParse(_priceCtrl.text) ?? 0));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
          color: cardBg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _groupCtrl,
                  onChanged: (_) => _notify(),
                  style: GoogleFonts.dmSans(
                      color: textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: 'Group (e.g. Add-ons)',
                    hintStyle: GoogleFonts.dmSans(
                        color: textPrimary.withValues(alpha: 0.35),
                        fontSize: 12),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded,
                    size: 16, color: AppColors.errorLight),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                onPressed: widget.onDelete,
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _nameCtrl,
                  onChanged: (_) => _notify(),
                  style: GoogleFonts.dmSans(
                      color: textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Add-on name',
                    hintStyle: GoogleFonts.dmSans(
                        color: textPrimary.withValues(alpha: 0.35),
                        fontSize: 12),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _priceCtrl,
                  onChanged: (_) => _notify(),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9.]'))
                  ],
                  style: GoogleFonts.dmSans(
                      color: textPrimary, fontSize: 13),
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: '₱ 0',
                    hintStyle: GoogleFonts.dmSans(
                        color: textPrimary.withValues(alpha: 0.35),
                        fontSize: 12),
                    border: InputBorder.none,
                    isDense: true,
                    prefixText: '+₱ ',
                    prefixStyle: GoogleFonts.dmSans(
                        color: textPrimary, fontSize: 13),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Step 4 — Availability ─────────────────────────────────────────────────────

class _Step4Availability extends StatelessWidget {
  const _Step4Availability({
    required this.isAvailable,
    required this.isFavorite,
    required this.onAvailableChanged,
    required this.onFavoriteChanged,
  });
  final bool isAvailable;
  final bool isFavorite;
  final ValueChanged<bool> onAvailableChanged;
  final ValueChanged<bool> onFavoriteChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ToggleRow(
            label: 'Available for Sale',
            subtitle: 'Customers can order this item.',
            icon: Icons.storefront_rounded,
            value: isAvailable,
            onChanged: onAvailableChanged,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ToggleRow(
            label: 'Mark as Favourite',
            subtitle: 'Shows in Quick Picks on the cashier screen.',
            icon: Icons.star_rounded,
            value: isFavorite,
            onChanged: onFavoriteChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  static const _maroon = Color(0xFF8B4049);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 22,
              color: value
                  ? _maroon
                  : textSecondary.withValues(alpha: 0.5)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.dmSans(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: GoogleFonts.dmSans(
                        color: textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: _maroon,
            activeTrackColor: _maroon.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Navigation ─────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentStep,
    required this.totalSteps,
    required this.isSaving,
    required this.onPrev,
    required this.onNext,
    required this.onSave,
  });
  final int currentStep;
  final int totalSteps;
  final bool isSaving;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final isLastStep = currentStep == totalSteps - 1;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
        child: Row(
          children: [
            if (currentStep > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: onPrev,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B4049),
                    side: BorderSide(
                        color: const Color(0xFF8B4049).withValues(alpha: 0.4)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Previous',
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              flex: 2,
              child: AppPrimaryButton(
                label: isLastStep ? 'Save Item' : 'Next',
                icon: isLastStep
                    ? Icons.check_rounded
                    : Icons.arrow_forward_rounded,
                onPressed: isSaving
                    ? null
                    : (isLastStep ? onSave : onNext),
                isLoading: isSaving,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared Helpers ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(
      {required this.label, this.sub, required this.context});
  final String label;
  final String? sub;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (sub != null)
          Text(
            sub!,
            style: GoogleFonts.dmSans(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontSize: 11,
            ),
          ),
      ],
    );
  }
}
