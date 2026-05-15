import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/isar_collections/category_collection.dart';
import '../../../../shared/isar_collections/menu_item_collection.dart';
import '../providers/item_provider.dart';
import '../widgets/item_manage_tile.dart';
import 'item_form_screen.dart';

/// ItemManagementScreen — Admin screen for browsing and managing menu items.
///
/// Features:
/// - AppBar with search toggle
/// - Category filter tabs (All + per-category with item count)
/// - Scrollable list of ItemManageTile rows
/// - FAB to add new item
/// - Edit / Delete actions per tile
class ItemManagementScreen extends ConsumerStatefulWidget {
  const ItemManagementScreen({super.key});

  @override
  ConsumerState<ItemManagementScreen> createState() =>
      _ItemManagementScreenState();
}

class _ItemManagementScreenState extends ConsumerState<ItemManagementScreen>
    with SingleTickerProviderStateMixin {
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  static const _maroon = Color(0xFF8B4049);

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openForm({MenuItemCollection? item}) async {
    final stateData = ref.read(itemProvider).asData?.value;
    if (stateData == null) return;
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ItemFormScreen(item: item),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, MenuItemCollection item) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeBR),
        title: Text('Delete Item?', style: AppTextStyles.bodySemiBold(context)),
        content: Text(
          'Are you sure you want to delete "${item.name}"? This cannot be undone.',
          style: AppTextStyles.body(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text('Cancel', style: AppTextStyles.bodySemiBold(context)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text('Delete',
                style: AppTextStyles.bodySemiBold(context)
                    .copyWith(color: AppColors.errorLight)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(itemProvider.notifier).softDelete(item);
      if (mounted) {
        messenger.showSnackBar(SnackBar(
          content: Text('${item.name} deleted',
              style: AppTextStyles.bodySemiBold(context)
                  .copyWith(color: Colors.white)),
          backgroundColor: AppColors.errorLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
        ));
      }
    }
  }

  void _toggleSearch(bool isDark, Color textPrimary) {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchCtrl.clear();
        ref.read(itemProvider.notifier).setSearch('');
      } else {
        Future.delayed(
            const Duration(milliseconds: 80), _searchFocus.requestFocus);
      }
    });
  }

  AppBar _buildAppBar(BuildContext context, bool isDark, Color textPrimary) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: textPrimary, size: 20),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RouteConstants.adminHome);
          }
        },
      ),
      title: _showSearch
          ? TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              onChanged: ref.read(itemProvider.notifier).setSearch,
              style: AppTextStyles.body(context).copyWith(color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Search items…',
                hintStyle: AppTextStyles.body(context)
                    .copyWith(color: textPrimary.withValues(alpha: 0.4)),
                border: InputBorder.none,
              ),
            )
          : Text('Menu Items', style: AppTextStyles.h3(context)),
      actions: [
        IconButton(
          icon: Icon(
            _showSearch ? Icons.close_rounded : Icons.search_rounded,
            color: textPrimary,
          ),
          onPressed: () => _toggleSearch(isDark, textPrimary),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final itemsAsync = ref.watch(itemProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: _buildAppBar(context, isDark, textPrimary),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: _maroon,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('Add Item',
            style: AppTextStyles.bodySemiBold(context)
                .copyWith(color: Colors.white)),
      )
          .animate()
          .slideY(begin: 0.3, end: 0, duration: 400.ms)
          .fadeIn(duration: 400.ms),
      body: itemsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(
          child: Text('Error loading items: $e',
              style: AppTextStyles.body(context)),
        ),
        data: (state) => _buildBody(context, state, isDark, textPrimary),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ItemManageState state,
    bool isDark,
    Color textPrimary,
  ) {
    final categories = state.categories;
    final filtered = state.filtered;

    // Tab count = total (index 0 = All)
    final allCount = state.allItems.length;

    return Column(
      children: [
        // ── Category Tabs ──────────────────────────────────────────
        if (categories.isNotEmpty)
          _CategoryTabsRow(
            categories: categories,
            selectedId: state.selectedCategoryId,
            allCount: allCount,
            countForCategory: state.countForCategory,
            onSelect: ref.read(itemProvider.notifier).selectCategory,
            isDark: isDark,
          ),

        // ── Item List ──────────────────────────────────────────────
        Expanded(
          child: filtered.isEmpty
              ? _EmptyState(
                  hasCategoryFilter: state.selectedCategoryId != null,
                  hasSearch: state.searchQuery.isNotEmpty,
                  onAdd: () => _openForm(),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(itemProvider.notifier).refresh(),
                  color: _maroon,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.sm, AppSpacing.md, 80),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final item = filtered[i];
                      final catName =
                          _categoryName(state.categories, item.categoryId);
                      return ItemManageTile(
                        key: ValueKey(item.syncId),
                        item: item,
                        categoryName: catName,
                        animationIndex: i,
                        onEdit: () => _openForm(item: item),
                        onDelete: () => _confirmDelete(context, item),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  String _categoryName(List<CategoryCollection> cats, String categoryId) {
    try {
      return cats.firstWhere((c) => c.syncId == categoryId).name;
    } catch (_) {
      return '';
    }
  }
}

// ── Category Tabs Row ─────────────────────────────────────────────────────────

class _CategoryTabsRow extends StatelessWidget {
  const _CategoryTabsRow({
    required this.categories,
    required this.selectedId,
    required this.allCount,
    required this.countForCategory,
    required this.onSelect,
    required this.isDark,
  });

  final List<CategoryCollection> categories;
  final String? selectedId;
  final int allCount;
  final int Function(String) countForCategory;
  final ValueChanged<String?> onSelect;
  final bool isDark;

  static const _maroon = Color(0xFF8B4049);

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final unselectedBg = isDark ? AppColors.cardDark : AppColors.cardLight;

    return SizedBox(
      height: 48,
      child: ListView(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
        scrollDirection: Axis.horizontal,
        children: [
          // All tab
          _Tab(
            label: 'All',
            count: allCount,
            isSelected: selectedId == null,
            onTap: () => onSelect(null),
            maroon: _maroon,
            unselectedBg: unselectedBg,
            textPrimary: textPrimary,
          ),
          ...categories.map((cat) {
            final count = countForCategory(cat.syncId);
            return _Tab(
              label: cat.name,
              count: count,
              isSelected: selectedId == cat.syncId,
              onTap: () => onSelect(cat.syncId),
              maroon: _maroon,
              unselectedBg: unselectedBg,
              textPrimary: textPrimary,
            );
          }),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    required this.maroon,
    required this.unselectedBg,
    required this.textPrimary,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color maroon;
  final Color unselectedBg;
  final Color textPrimary;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          decoration: BoxDecoration(
            color: isSelected ? maroon : unselectedBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.captionMedium(context).copyWith(
                  color: isSelected
                      ? Colors.white
                      : textPrimary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : maroon.withValues(alpha: 0.12),
                  borderRadius: AppRadius.pillBR,
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.captionMedium(context).copyWith(
                    color: isSelected ? Colors.white : maroon,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasCategoryFilter,
    required this.hasSearch,
    required this.onAdd,
  });
  final bool hasCategoryFilter;
  final bool hasSearch;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final message = hasSearch
        ? 'No items match your search.'
        : hasCategoryFilter
            ? 'No items in this category yet.'
            : 'No menu items yet.';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant_menu_outlined,
              size: 64, color: textPrimary.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.body(context).copyWith(
              color: textPrimary.withValues(alpha: 0.4),
            ),
          ),
          if (!hasSearch) ...[
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: Text('Add First Item',
                  style: AppTextStyles.bodySemiBold(context)),
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF8B4049)),
            ),
          ],
        ],
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.95, 0.95)),
    );
  }
}
