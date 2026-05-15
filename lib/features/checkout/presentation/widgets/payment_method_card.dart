import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/checkout_provider.dart';

/// Large selectable card for Cash / GCash / Other payment methods.
/// Displays an icon, label, and maroon border + checkmark when selected.
class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maroon = isDark ? AppColors.primaryDark : AppColors.secondaryLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected ? maroon.withValues(alpha: 0.1) : cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? maroon : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? maroon.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _iconColor(isDark).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _icon(method),
                    color: _iconColor(isDark),
                    size: 26,
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: maroon,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              method.label,
              style: AppTextStyles.captionMedium(context).copyWith(
                color: isSelected ? maroon : textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.payments_rounded;
      case PaymentMethod.gcash:
        return Icons.account_balance_wallet_rounded;
      case PaymentMethod.other:
        return Icons.more_horiz_rounded;
    }
  }

  Color _iconColor(bool isDark) =>
      isDark ? AppColors.accentDark : AppColors.accentLight;
}
