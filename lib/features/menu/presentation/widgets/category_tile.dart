import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/category_provider.dart';

/// CategoryTile displays a single category row in the management list.
/// Shows emoji avatar, name, item count, active badge, edit/delete actions,
/// and a drag handle for ReorderableListView.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.item,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  final CategoryWithCount item;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const _maroon = Color(0xFF8B4049);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final category = item.category;
    final hasEmoji =
        category.iconEmoji != null && category.iconEmoji!.isNotEmpty;
    final initial =
        category.name.isNotEmpty ? category.name[0].toUpperCase() : '?';
    final isActive = category.isActive;

    return Container(
      key: ValueKey(category.syncId),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            // ── Drag handle ────────────────────────────────────────────
            ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_handle_rounded,
                color: textSecondary.withValues(alpha: 0.5),
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // ── Emoji / Initial avatar ──────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _maroon.withValues(alpha: isDark ? 0.2 : 0.1),
                border: Border.all(
                  color: _maroon.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: hasEmoji
                    ? Text(
                        category.iconEmoji!,
                        style: const TextStyle(fontSize: 20),
                      )
                    : Text(
                        initial,
                        style: GoogleFonts.dmSans(
                          color: _maroon,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // ── Name + item count ───────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.dmSans(
                            color: textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!isActive) ...[
                        const SizedBox(width: 6),
                        _Badge(label: 'Inactive', color: AppColors.errorLight),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.itemCount} item${item.itemCount == 1 ? '' : 's'}',
                    style: GoogleFonts.dmSans(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),

            // ── Edit button ─────────────────────────────────────────────
            _IconBtn(
              icon: Icons.edit_outlined,
              color: _maroon,
              onPressed: onEdit,
            ),

            // ── Delete button ───────────────────────────────────────────
            _IconBtn(
              icon: Icons.delete_outline_rounded,
              color: AppColors.errorLight,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      );
}

class _IconBtn extends StatelessWidget {
  const _IconBtn(
      {required this.icon, required this.color, required this.onPressed});
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(icon, size: 20),
        color: color,
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
        tooltip: '',
      );
}
