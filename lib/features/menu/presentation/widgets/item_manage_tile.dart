import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/isar_collections/menu_item_collection.dart';
import '../providers/item_provider.dart';

/// ItemManageTile — list row for the admin item management screen.
/// Shows image thumbnail, name, price, availability switch, favorite star,
/// and edit/delete action buttons.
class ItemManageTile extends ConsumerWidget {
  const ItemManageTile({
    super.key,
    required this.item,
    required this.categoryName,
    required this.onEdit,
    required this.onDelete,
    this.animationIndex = 0,
  });

  final MenuItemCollection item;
  final String categoryName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int animationIndex;

  static const _maroon = Color(0xFF8B4049);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.largeBR,
        child: InkWell(
          onTap: onEdit,
          borderRadius: AppRadius.largeBR,
          splashColor: _maroon.withValues(alpha: 0.06),
          highlightColor: _maroon.withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                // ── Thumbnail ─────────────────────────────────────────
                _Thumbnail(imageUrl: item.imageUrl),
                const SizedBox(width: AppSpacing.sm),

                // ── Info ──────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: AppTextStyles.bodySemiBold(context)
                            .copyWith(color: textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            CurrencyFormatter.format(item.basePrice),
                            style:
                                AppTextStyles.captionMedium(context).copyWith(
                              color: _maroon,
                            ),
                          ),
                          if (categoryName.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: _CategoryChip(
                                label: categoryName,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Favorite star ─────────────────────────────────────
                IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    item.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 22,
                    color: item.isFavorite
                        ? const Color(0xFFD4A574)
                        : textSecondary.withValues(alpha: 0.4),
                  ),
                  onPressed: () =>
                      ref.read(itemProvider.notifier).toggleFavorite(item),
                ),

                // ── Available switch ──────────────────────────────────
                Switch.adaptive(
                  value: item.isAvailable,
                  onChanged: (_) =>
                      ref.read(itemProvider.notifier).toggleAvailability(item),
                  activeThumbColor: _maroon,
                  activeTrackColor: _maroon.withValues(alpha: 0.3),
                  inactiveThumbColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.grey.withValues(alpha: 0.15),
                ),

                // ── Delete button ─────────────────────────────────────
                IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.delete_outline_rounded,
                      size: 20, color: AppColors.errorLight),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: animationIndex * 35))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.06, end: 0);
  }
}

// ── Thumbnail ─────────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholder = Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? AppColors.surfaceDark : AppColors.cardLight,
      ),
      child: Icon(
        Icons.restaurant_menu_rounded,
        size: 28,
        color: isDark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.1),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: 60,
            height: 60,
            child: Center(
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2,
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Category Chip ─────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardLight.withValues(alpha: 0.15)
              : AppColors.cardLight,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: AppTextStyles.caption(context).copyWith(
            color:
                isDark ? AppColors.textSecondaryDark : const Color(0xFF6B4B3E),
          ),
        ),
      );
}
