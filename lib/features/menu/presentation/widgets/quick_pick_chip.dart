import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/isar_collections/menu_item_collection.dart';
import '../../../orders/domain/entities/cart_item.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import 'item_customization_modal.dart';

/// A compact, horizontally-scrollable chip card for the Quick Picks row on the
/// New Order screen.
///
/// Behaviour:
/// - If the item has no variants AND no modifiers → tapping the `+` button
///   adds it directly to the cart at its base price.
/// - If the item has variants or modifiers → opens [ItemCustomizationModal]
///   so the cashier can choose the right configuration.
class QuickPickChip extends ConsumerWidget {
  const QuickPickChip({super.key, required this.item});

  final MenuItemCollection item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : const Color(0xFFF0E8DC);
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    const maroon = Color(0xFF8B4049);

    final hasOptions =
        item.variantsJson.isNotEmpty || item.modifiersJson.isNotEmpty;

    return GestureDetector(
      onTap: () => _onTap(context, ref, hasOptions),
      child: Container(
        width: 148,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Text section ──────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    CurrencyFormatter.format(item.basePrice),
                    style: GoogleFonts.plusJakartaSans(
                      color: maroon,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── Add button ────────────────────────────────────────────────
            _AddButton(
              hasOptions: hasOptions,
              onTap: () => _onTap(context, ref, hasOptions),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref, bool hasOptions) {
    HapticFeedback.lightImpact();
    if (hasOptions) {
      // Delegate to the full customization modal.
      ItemCustomizationModal.show(context, item: item);
    } else {
      // No customization needed — add directly to cart.
      final cartItem = CartItem(
        itemSyncId: item.syncId,
        itemName: item.name,
        variantName: null,
        unitPrice: item.basePrice,
        quantity: 1,
        modifiers: const [],
        notes: null,
      );
      ref.read(orderProvider.notifier).addItem(cartItem);

      // Brief visual confirmation via a small snackbar.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${item.name} added',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            backgroundColor: const Color(0xFF8B4049),
          ),
        );
    }
  }
}

// ── Internal add button ───────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  const _AddButton({required this.hasOptions, required this.onTap});

  final bool hasOptions;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFF8B4049),
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B4049).withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          // Arrow-forward when options are needed; plus when a direct add.
          hasOptions
              ? Icons.arrow_forward_rounded
              : Icons.add_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}
