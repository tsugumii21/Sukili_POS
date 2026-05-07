import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/isar_collections/category_collection.dart';
import '../../../../shared/isar_collections/menu_item_collection.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/item_provider.dart';

/// ItemFormScreen — 4-step form for creating or editing a menu item.
///
/// Steps:
///   1. Basic Info  (name, description, category, image URL)
///   2. Pricing & Variants  (base price, variant rows)
///   3. Modifiers  (modifier group rows)
///   4. Inventory  (track inventory toggle, stock qty)
class ItemFormScreen extends ConsumerStatefulWidget {
  const ItemFormScreen({super.key, this.item, required this.categories});

  /// If non-null, the form is in edit mode.
  final MenuItemCollection? item;

  /// Category list passed from the management screen.
  final List<CategoryCollection> categories;

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  // ── Step controller ──────────────────────────────────────────────────────
  final _pageCtrl = PageController();
  int _currentStep = 0;
  static const _totalSteps = 4;

  // ── Step 1 fields ────────────────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  String? _selectedCategoryId;

  // ── Step 2 fields ────────────────────────────────────────────────────────
  final _priceCtrl = TextEditingController();
  final List<VariantDraft> _variants = [];

  // ── Step 3 fields ────────────────────────────────────────────────────────
  final List<ModifierDraft> _modifiers = [];

  // ── Step 4 fields ────────────────────────────────────────────────────────
  bool _trackInventory = false;
  bool _isAvailable = true;
  bool _isFavorite = false;
  final _stockCtrl = TextEditingController();
  final _thresholdCtrl = TextEditingController(text: '5');

  bool _isSaving = false;

  bool get _isEdit => widget.item != null;

  // ── Step form keys ───────────────────────────────────────────────────────
  final _step1Key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _prefillIfEdit();
  }

  void _prefillIfEdit() {
    final item = widget.item;
    if (item == null) {
      if (widget.categories.isNotEmpty) {
        _selectedCategoryId = widget.categories.first.syncId;
      }
      return;
    }
    _nameCtrl.text = item.name;
    _descCtrl.text = item.description ?? '';
    _imageUrlCtrl.text = item.imageUrl ?? '';
    _selectedCategoryId = item.categoryId;
    _priceCtrl.text = item.basePrice.toStringAsFixed(2);
    _trackInventory = item.trackInventory;
    _isAvailable = item.isAvailable;
    _isFavorite = item.isFavorite;
    _stockCtrl.text = item.stockQuantity?.toStringAsFixed(0) ?? '';
    _thresholdCtrl.text = item.lowStockThreshold?.toStringAsFixed(0) ?? '5';

    // Parse variants
    for (final v in item.variantsJson) {
      try {
        _variants.add(VariantDraft.fromJson(jsonDecode(v) as Map<String, dynamic>));
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

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _imageUrlCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _thresholdCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _next() {
    if (_currentStep == 0) {
      if (!_step1Key.currentState!.validate()) return;
    }
    if (_currentStep < _totalSteps - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep++);
    }
  }

  void _prev() {
    if (_currentStep > 0) {
      _pageCtrl.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep--);
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final price = double.tryParse(_priceCtrl.text.replaceAll(',', '')) ?? 0;
    if (price <= 0) {
      _showError('Base price must be greater than 0.');
      return;
    }
    if (_selectedCategoryId == null) {
      _showError('Please select a category.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_isEdit) {
        await ref.read(itemProvider.notifier).updateItem(
              item: widget.item!,
              name: _nameCtrl.text,
              categoryId: _selectedCategoryId!,
              basePrice: price,
              description: _descCtrl.text,
              imageUrl: _imageUrlCtrl.text,
              isAvailable: _isAvailable,
              isFavorite: _isFavorite,
              trackInventory: _trackInventory,
              stockQuantity: _trackInventory
                  ? double.tryParse(_stockCtrl.text)
                  : null,
              lowStockThreshold: _trackInventory
                  ? double.tryParse(_thresholdCtrl.text)
                  : null,
              variants: List.from(_variants),
              modifiers: List.from(_modifiers),
            );
      } else {
        await ref.read(itemProvider.notifier).createItem(
              name: _nameCtrl.text,
              categoryId: _selectedCategoryId!,
              basePrice: price,
              description: _descCtrl.text,
              imageUrl: _imageUrlCtrl.text,
              isAvailable: _isAvailable,
              isFavorite: _isFavorite,
              trackInventory: _trackInventory,
              stockQuantity: _trackInventory
                  ? double.tryParse(_stockCtrl.text)
                  : null,
              lowStockThreshold: _trackInventory
                  ? double.tryParse(_thresholdCtrl.text)
                  : null,
              variants: List.from(_variants),
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

    final stepLabels = ['Basic Info', 'Pricing', 'Modifiers', 'Inventory'];

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
            // ── Step indicator ───────────────────────────────────────
            _StepIndicator(
              current: _currentStep,
              total: _totalSteps,
              labels: stepLabels,
            ),

            // ── PageView ─────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1Basic(
                    formKey: _step1Key,
                    nameCtrl: _nameCtrl,
                    descCtrl: _descCtrl,
                    imageUrlCtrl: _imageUrlCtrl,
                    categories: widget.categories,
                    selectedCategoryId: _selectedCategoryId,
                    onCategoryChanged: (v) =>
                        setState(() => _selectedCategoryId = v),
                  ),
                  _Step2Pricing(
                    priceCtrl: _priceCtrl,
                    variants: _variants,
                    onVariantsChanged: () => setState(() {}),
                  ),
                  _Step3Modifiers(
                    modifiers: _modifiers,
                    onModifiersChanged: () => setState(() {}),
                  ),
                  _Step4Inventory(
                    trackInventory: _trackInventory,
                    isAvailable: _isAvailable,
                    isFavorite: _isFavorite,
                    stockCtrl: _stockCtrl,
                    thresholdCtrl: _thresholdCtrl,
                    onTrackChanged: (v) =>
                        setState(() => _trackInventory = v),
                    onAvailableChanged: (v) =>
                        setState(() => _isAvailable = v),
                    onFavoriteChanged: (v) =>
                        setState(() => _isFavorite = v),
                  ),
                ],
              ),
            ),

            // ── Bottom nav buttons ────────────────────────────────────
            _BottomNav(
              currentStep: _currentStep,
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
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

// ── Step 1: Basic Info ────────────────────────────────────────────────────────

class _Step1Basic extends StatelessWidget {
  const _Step1Basic({
    required this.formKey,
    required this.nameCtrl,
    required this.descCtrl,
    required this.imageUrlCtrl,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final TextEditingController imageUrlCtrl;
  final List<CategoryCollection> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: nameCtrl,
              label: 'Item Name',
              hint: 'e.g. Iced Coffee',
              prefixIcon: Icon(Icons.lunch_dining_outlined,
                  color: textPrimary.withValues(alpha: 0.4), size: 20),
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Name is required';
                if (v.trim().length < 2) return 'Name is too short';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: descCtrl,
              label: 'Description (optional)',
              hint: 'Short description…',
              maxLines: 2,
              prefixIcon: Icon(Icons.notes_rounded,
                  color: textPrimary.withValues(alpha: 0.4), size: 20),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Category dropdown ────────────────────────────────────
            _SectionHeader(label: 'Category', context: context),
            const SizedBox(height: AppSpacing.xs),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategoryId,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 4),
                  borderRadius: BorderRadius.circular(16),
                  hint: Text('Select category',
                      style: GoogleFonts.dmSans(
                          color: textPrimary.withValues(alpha: 0.4),
                          fontSize: 15)),
                  dropdownColor: cardBg,
                  style: GoogleFonts.dmSans(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(
                            value: c.syncId,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: onCategoryChanged,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Image URL field ──────────────────────────────────────
            AppTextField(
              controller: imageUrlCtrl,
              label: 'Image URL (optional)',
              hint: 'https://…',
              keyboardType: TextInputType.url,
              prefixIcon: Icon(Icons.image_outlined,
                  color: textPrimary.withValues(alpha: 0.4), size: 20),
              textInputAction: TextInputAction.done,
            ),

            // Preview if URL is set
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: imageUrlCtrl,
              builder: (_, val, __) {
                if (val.text.trim().isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      val.text.trim(),
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.errorLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text('Invalid image URL',
                              style: GoogleFonts.dmSans(
                                  color: AppColors.errorLight, fontSize: 12)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

// ── Step 2: Pricing & Variants ────────────────────────────────────────────────

class _Step2Pricing extends StatefulWidget {
  const _Step2Pricing({
    required this.priceCtrl,
    required this.variants,
    required this.onVariantsChanged,
  });
  final TextEditingController priceCtrl;
  final List<VariantDraft> variants;
  final VoidCallback onVariantsChanged;

  @override
  State<_Step2Pricing> createState() => _Step2PricingState();
}

class _Step2PricingState extends State<_Step2Pricing> {
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icon(Icons.attach_money_rounded,
                color: textPrimary.withValues(alpha: 0.4), size: 20),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Variants section ───────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _SectionHeader(
                    label: 'Variants (optional)', context: context),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    widget.variants.add(VariantDraft(name: '', priceDelta: 0));
                  });
                  widget.onVariantsChanged();
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text('Add',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF8B4049),
                ),
              ),
            ],
          ),
          Text(
            'Variants let customers choose size/type. Price delta is added to base price.',
            style: GoogleFonts.dmSans(
              color: textPrimary.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          ...List.generate(widget.variants.length, (i) {
            return _VariantRow(
              key: ValueKey('variant_$i'),
              draft: widget.variants[i],
              onChanged: (v) {
                setState(() => widget.variants[i] = v);
                widget.onVariantsChanged();
              },
              onDelete: () {
                setState(() => widget.variants.removeAt(i));
                widget.onVariantsChanged();
              },
            );
          }),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _VariantRow extends StatefulWidget {
  const _VariantRow({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onDelete,
  });
  final VariantDraft draft;
  final ValueChanged<VariantDraft> onChanged;
  final VoidCallback onDelete;

  @override
  State<_VariantRow> createState() => _VariantRowState();
}

class _VariantRowState extends State<_VariantRow> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.draft.name);
    _priceCtrl = TextEditingController(
        text: widget.draft.priceDelta == 0
            ? ''
            : widget.draft.priceDelta.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(VariantDraft(
      name: _nameCtrl.text,
      priceDelta: double.tryParse(_priceCtrl.text) ?? 0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _nameCtrl,
              onChanged: (_) => _notify(),
              style: GoogleFonts.dmSans(color: textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Name (e.g. Small)',
                hintStyle: GoogleFonts.dmSans(
                    color: textPrimary.withValues(alpha: 0.35), fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _priceCtrl,
              onChanged: (_) => _notify(),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
              style: GoogleFonts.dmSans(color: textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: '+₱ delta',
                hintStyle: GoogleFonts.dmSans(
                    color: textPrimary.withValues(alpha: 0.35), fontSize: 13),
                border: InputBorder.none,
                prefixText: '+₱ ',
                prefixStyle:
                    GoogleFonts.dmSans(color: textPrimary, fontSize: 14),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded,
                size: 18, color: AppColors.errorLight),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }
}

// ── Step 3: Modifiers ─────────────────────────────────────────────────────────

class _Step3Modifiers extends StatefulWidget {
  const _Step3Modifiers({
    required this.modifiers,
    required this.onModifiersChanged,
  });
  final List<ModifierDraft> modifiers;
  final VoidCallback onModifiersChanged;

  @override
  State<_Step3Modifiers> createState() => _Step3ModifiersState();
}

class _Step3ModifiersState extends State<_Step3Modifiers> {
  void _addModifier() {
    // Use the last group name if available, else default
    final groupName = widget.modifiers.isNotEmpty
        ? widget.modifiers.last.groupName
        : 'Add-ons';
    setState(() {
      widget.modifiers
          .add(ModifierDraft(groupName: groupName, name: '', priceDelta: 0));
    });
    widget.onModifiersChanged();
  }

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
          Row(
            children: [
              Expanded(
                child: _SectionHeader(
                    label: 'Modifier Add-ons (optional)', context: context),
              ),
              TextButton.icon(
                onPressed: _addModifier,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text('Add',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8B4049)),
              ),
            ],
          ),
          Text(
            'Modifiers are optional add-ons grouped by name (e.g. "Add-ons: Extra Rice +₱20").',
            style: GoogleFonts.dmSans(
              color: textPrimary.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...List.generate(widget.modifiers.length, (i) {
            return _ModifierRow(
              key: ValueKey('modifier_$i'),
              draft: widget.modifiers[i],
              onChanged: (m) {
                setState(() => widget.modifiers[i] = m);
                widget.onModifiersChanged();
              },
              onDelete: () {
                setState(() => widget.modifiers.removeAt(i));
                widget.onModifiersChanged();
              },
            );
          }),
          if (widget.modifiers.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: Center(
                child: Text(
                  'No modifiers yet. Tap "Add" to add one.',
                  style: GoogleFonts.dmSans(
                    color: textPrimary.withValues(alpha: 0.35),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _ModifierRow extends StatefulWidget {
  const _ModifierRow({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onDelete,
  });
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

  void _notify() {
    widget.onChanged(ModifierDraft(
      groupName: _groupCtrl.text.isEmpty ? 'Add-ons' : _groupCtrl.text,
      name: _nameCtrl.text,
      priceDelta: double.tryParse(_priceCtrl.text) ?? 0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
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
                    hintText: 'Group name (e.g. Add-ons)',
                    hintStyle: GoogleFonts.dmSans(
                        color: textPrimary.withValues(alpha: 0.35),
                        fontSize: 12),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    isDense: true,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded,
                    size: 18, color: AppColors.errorLight),
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
                  style:
                      GoogleFonts.dmSans(color: textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Modifier name',
                    hintStyle: GoogleFonts.dmSans(
                        color: textPrimary.withValues(alpha: 0.35),
                        fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _priceCtrl,
                  onChanged: (_) => _notify(),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                  ],
                  style:
                      GoogleFonts.dmSans(color: textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: '+₱ price',
                    hintStyle: GoogleFonts.dmSans(
                        color: textPrimary.withValues(alpha: 0.35),
                        fontSize: 13),
                    border: InputBorder.none,
                    prefixText: '+₱ ',
                    prefixStyle: GoogleFonts.dmSans(
                        color: textPrimary, fontSize: 14),
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

// ── Step 4: Inventory ─────────────────────────────────────────────────────────

class _Step4Inventory extends StatelessWidget {
  const _Step4Inventory({
    required this.trackInventory,
    required this.isAvailable,
    required this.isFavorite,
    required this.stockCtrl,
    required this.thresholdCtrl,
    required this.onTrackChanged,
    required this.onAvailableChanged,
    required this.onFavoriteChanged,
  });

  final bool trackInventory;
  final bool isAvailable;
  final bool isFavorite;
  final TextEditingController stockCtrl;
  final TextEditingController thresholdCtrl;
  final ValueChanged<bool> onTrackChanged;
  final ValueChanged<bool> onAvailableChanged;
  final ValueChanged<bool> onFavoriteChanged;

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
          // ── Available toggle ───────────────────────────────────────
          _ToggleRow(
            label: 'Available for Sale',
            subtitle: 'Customers can order this item.',
            icon: Icons.storefront_rounded,
            value: isAvailable,
            onChanged: onAvailableChanged,
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Favorite toggle ────────────────────────────────────────
          _ToggleRow(
            label: 'Mark as Favourite',
            subtitle: 'Shows in Quick Picks on the cashier screen.',
            icon: Icons.star_rounded,
            value: isFavorite,
            onChanged: onFavoriteChanged,
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Track inventory toggle ─────────────────────────────────
          _ToggleRow(
            label: 'Track Inventory',
            subtitle: 'Enable stock level tracking and low-stock alerts.',
            icon: Icons.inventory_2_outlined,
            value: trackInventory,
            onChanged: onTrackChanged,
            isDark: isDark,
          ),

          // ── Stock fields (only when tracking) ─────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: trackInventory
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Column(
                      children: [
                        AppTextField(
                          controller: stockCtrl,
                          label: 'Initial Stock Quantity',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icon(Icons.numbers_rounded,
                              color: textPrimary.withValues(alpha: 0.4),
                              size: 20),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: thresholdCtrl,
                          label: 'Low Stock Threshold',
                          hint: '5',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icon(Icons.warning_amber_rounded,
                              color: AppColors.warningLight, size: 20),
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
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
    required this.isDark,
  });
  final String label;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  static const _maroon = Color(0xFF8B4049);

  @override
  Widget build(BuildContext context) {
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
              color: value ? _maroon : textSecondary.withValues(alpha: 0.5)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.dmSans(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    )),
                Text(subtitle,
                    style: GoogleFonts.dmSans(
                      color: textSecondary,
                      fontSize: 11,
                    )),
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

  static const _maroon = Color(0xFF8B4049);

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
                    foregroundColor: _maroon,
                    side: BorderSide(color: _maroon.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Previous',
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
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
                onPressed: isSaving ? null : (isLastStep ? onSave : onNext),
                isLoading: isSaving,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.context});
  final String label;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return Text(
      label,
      style: GoogleFonts.dmSans(
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}
