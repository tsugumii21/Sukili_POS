import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/category_provider.dart';
import '../widgets/category_tile.dart';

/// CategoryManagementScreen — admin screen for adding, editing,
/// reordering (drag-and-drop), and deleting menu categories.
class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  static const _maroon = Color(0xFF8B4049);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Categories', style: AppTextStyles.bodySemiBold(context)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategorySheet(context, ref),
        backgroundColor: _maroon,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('Add Category',
            style: AppTextStyles.bodySemiBold(context).copyWith(color: Colors.white)),
      ).animate().slideY(begin: 0.3, end: 0, duration: 400.ms).fadeIn(),
      body: categoriesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 48, color: AppColors.errorLight),
                const SizedBox(height: AppSpacing.md),
                Text('Failed to load categories', style: AppTextStyles.body(context)),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => ref.read(categoryProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return _EmptyState(
              onAdd: () => _showCategorySheet(context, ref),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(categoryProvider.notifier).refresh(),
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xxl + 80,
              ),
              itemCount: categories.length,
              onReorder: (oldIndex, newIndex) =>
                  ref.read(categoryProvider.notifier).reorder(oldIndex, newIndex),
              proxyDecorator: (child, index, animation) => Material(
                elevation: 8,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: child,
              ),
              itemBuilder: (_, i) => CategoryTile(
                key: ValueKey(categories[i].category.syncId),
                item: categories[i],
                index: i,
                onEdit: () =>
                    _showCategorySheet(context, ref, existing: categories[i]),
                onDelete: () =>
                    _confirmDelete(context, ref, categories[i]),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Bottom sheet ────────────────────────────────────────────────────────────

  void _showCategorySheet(
    BuildContext context,
    WidgetRef ref, {
    CategoryWithCount? existing,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryFormSheet(
        ref: ref,
        existing: existing,
      ),
    );
  }

  // ── Delete confirmation ─────────────────────────────────────────────────────

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CategoryWithCount item,
  ) async {
    final category = item.category;
    final count = item.itemCount;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          'Delete Category',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          count > 0
              ? 'This category has $count menu item${count == 1 ? '' : 's'}. '
                  'Deleting it will keep the items but they will become '
                  'uncategorised. Continue?'
              : 'Delete "${category.name}"? This cannot be undone.',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text('Cancel', style: GoogleFonts.dmSans()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(
              'Delete',
              style: GoogleFonts.dmSans(
                color: AppColors.errorLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(categoryProvider.notifier).softDelete(category);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${category.name}" deleted.',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
            backgroundColor: AppColors.errorLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
}

// ── Add/Edit Category Bottom Sheet ────────────────────────────────────────────

class _CategoryFormSheet extends StatefulWidget {
  const _CategoryFormSheet({required this.ref, this.existing});
  final WidgetRef ref;
  final CategoryWithCount? existing;

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emojiCtrl;
  late final TextEditingController _descCtrl;
  late bool _isActive;
  bool _isSaving = false;

  static const _maroon = Color(0xFF8B4049);
  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final cat = widget.existing?.category;
    _nameCtrl = TextEditingController(text: cat?.name ?? '');
    _emojiCtrl = TextEditingController(text: cat?.iconEmoji ?? '');
    _descCtrl = TextEditingController(text: cat?.description ?? '');
    _isActive = cat?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emojiCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      if (_isEdit) {
        await widget.ref.read(categoryProvider.notifier).updateCategory(
              category: widget.existing!.category,
              name: _nameCtrl.text,
              iconEmoji: _emojiCtrl.text,
              description: _descCtrl.text,
              isActive: _isActive,
            );
      } else {
        await widget.ref.read(categoryProvider.notifier).createCategory(
              name: _nameCtrl.text,
              iconEmoji: _emojiCtrl.text,
              description: _descCtrl.text,
            );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
            backgroundColor: AppColors.errorLight,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg =
        isDark ? AppColors.surfaceDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Sheet handle ───────────────────────────────────
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: textPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),

                  // ── Title ──────────────────────────────────────────
                  Text(
                    _isEdit ? 'Edit Category' : 'New Category',
                    style: AppTextStyles.h3(context),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Preview avatar ─────────────────────────────────
                  Center(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _emojiCtrl,
                      builder: (_, emojiVal, __) =>
                          ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _nameCtrl,
                        builder: (_, nameVal, __) {
                          final hasEmoji = emojiVal.text.trim().isNotEmpty;
                          final initial = nameVal.text.isNotEmpty
                              ? nameVal.text[0].toUpperCase()
                              : '?';
                          return Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _maroon.withValues(alpha: 0.1),
                              border: Border.all(
                                color: _maroon.withValues(alpha: 0.25),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: hasEmoji
                                  ? Text(emojiVal.text.trim(),
                                      style: GoogleFonts.dmSans(fontSize: 24))
                                  : Text(
                                      initial,
                                      style: GoogleFonts.dmSans(
                                        color: _maroon,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Name field ─────────────────────────────────────
                  AppTextField(
                    controller: _nameCtrl,
                    label: 'Category Name',
                    hint: 'e.g. Beverages',
                    prefixIcon: Icon(Icons.label_outline_rounded,
                        color: textPrimary.withValues(alpha: 0.4), size: 20),
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Name is required';
                      }
                      if (v.trim().length < 2) return 'Name is too short';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Emoji field ────────────────────────────────────
                  AppTextField(
                    controller: _emojiCtrl,
                    label: 'Icon Emoji (optional)',
                    hint: 'e.g. ☕🍽️🍰',
                    prefixIcon: Icon(Icons.emoji_emotions_outlined,
                        color: textPrimary.withValues(alpha: 0.4), size: 20),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Description field ──────────────────────────────
                  AppTextField(
                    controller: _descCtrl,
                    label: 'Description (optional)',
                    hint: 'Short description…',
                    maxLines: 2,
                    prefixIcon: Icon(Icons.notes_rounded,
                        color: textPrimary.withValues(alpha: 0.4), size: 20),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Active toggle (edit only) ──────────────────────
                  if (_isEdit) ...[
                    _ActiveRow(
                      isActive: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      textPrimary: textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // ── Save button ────────────────────────────────────
                  AppPrimaryButton(
                    label: _isEdit ? 'Save Changes' : 'Add Category',
                    icon: _isEdit
                        ? Icons.check_rounded
                        : Icons.add_circle_outline_rounded,
                    onPressed: _isSaving ? null : _save,
                    isLoading: _isSaving,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Active toggle row ─────────────────────────────────────────────────────────

class _ActiveRow extends StatelessWidget {
  const _ActiveRow({
    required this.isActive,
    required this.onChanged,
    required this.textPrimary,
  });
  final bool isActive;
  final ValueChanged<bool> onChanged;
  final Color textPrimary;

  static const _maroon = Color(0xFF8B4049);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;

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
          Icon(
            isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isActive ? AppColors.successLight : AppColors.errorLight,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: GoogleFonts.dmSans(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch.adaptive(
            value: isActive,
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

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              size: 72,
              color: AppColors.textPrimaryLight.withValues(alpha: 0.18),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('No categories yet.',
                style: AppTextStyles.bodySecondary(context),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              label: 'Add First Category',
              icon: Icons.add_rounded,
              onPressed: onAdd,
              width: 220,
            ),
          ],
        ),
      ),
    );
  }
}
