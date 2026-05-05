import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/isar_collections/menu_item_collection.dart';

/// ItemCard — Displays a single menu item in the grid.
/// Shows image/emoji placeholder, name, price, and availability.
/// [categoryEmoji] is optional; when provided it replaces the icon placeholder
/// with a 40px emoji centered on a gradient background.
class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.categoryEmoji,
  });

  final MenuItemCollection item;
  final VoidCallback onTap;
  /// Optional emoji from the item's category (e.g. "☕").
  final String? categoryEmoji;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final priceColor =
        isDark ? AppColors.accentDarkLight : const Color(0xFF8B4049);
    final accentColor =
        isDark ? AppColors.accentDark : const Color(0xFF8B4049);
    final isUnavailable = !item.isAvailable;

    final variants = _parseVariants(item.variantsJson);
    final hasVariants = variants.isNotEmpty;

    return GestureDetector(
      onTap: isUnavailable ? null : onTap,
      child: Opacity(
        opacity: isUnavailable ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Image / Emoji Placeholder ───────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 80,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDarkElevated
                              : AppColors.backgroundLight,
                        ),
                        child: item.imageUrl != null &&
                                item.imageUrl!.isNotEmpty
                            ? Image.network(
                                item.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildPlaceholder(isDark, accentColor),
                              )
                            : _buildPlaceholder(isDark, accentColor),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Item Name ───────────────────────────────────────────
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // ── Price (moved below name) ─────────────────────────────
                    Text(
                      hasVariants
                          ? 'from ${CurrencyFormatter.format(item.basePrice)}'
                          : CurrencyFormatter.format(item.basePrice),
                      style: GoogleFonts.plusJakartaSans(
                        color: priceColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const Spacer(),
                  ],
                ),
              ),

              // ── Unavailable Overlay ─────────────────────────────────────
              if (isUnavailable)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Unavailable',
                      style: GoogleFonts.inter(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

              // ── Variant badge (filled accent pill) ─────────────────────
              if (hasVariants && !isUnavailable)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentColor.withAlpha(204), // ~80% opacity
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${variants.length} sizes',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the placeholder area.
  /// If [categoryEmoji] is set, renders a 40px emoji on a gradient bg.
  /// Otherwise falls back to the restaurant icon.
  Widget _buildPlaceholder(bool isDark, Color accentColor) {
    if (categoryEmoji != null && categoryEmoji!.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accentColor.withAlpha(77), // 30% opacity
              Colors.transparent,
            ],
          ),
        ),
        child: Center(
          child: Text(
            categoryEmoji!,
            style: const TextStyle(fontSize: 40),
          ),
        ),
      );
    }
    return Center(
      child: Icon(
        Icons.restaurant_menu_rounded,
        color: isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.black.withValues(alpha: 0.1),
        size: 36,
      ),
    );
  }

  List<Map<String, dynamic>> _parseVariants(List<String> json) {
    try {
      return json
          .map((v) => jsonDecode(v) as Map<String, dynamic>)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
