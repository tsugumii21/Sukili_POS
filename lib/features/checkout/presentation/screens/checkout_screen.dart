import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../orders/domain/entities/cart_item.dart';
import '../../../orders/domain/entities/order_state.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../providers/checkout_provider.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/payment_method_card.dart';

/// CheckoutScreen — review cart, select payment method, enter cash amount,
/// and complete the order. Saves to Isar + enqueues Supabase sync on success.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    // Reset any leftover checkout state from a previous session.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(checkoutProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderProvider);
    final checkout = ref.watch(checkoutProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final maroon = isDark ? AppColors.primaryDark : AppColors.secondaryLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    // Guard: if cart becomes empty (all items deleted) pop back automatically.
    if (order.isEmpty && checkout.completedOrder == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.pop();
      });
    }

    final isCash = checkout.selectedMethod == PaymentMethod.cash;
    final isNonCash =
        checkout.selectedMethod != null && !isCash;
    final change =
        isCash && checkout.amountEntered > 0 && checkout.amountEntered >= order.total
            ? checkout.amountEntered - order.total
            : 0.0;
    final isValidPayment = checkout.isPaymentValid(order.total);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.dmSans(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Scrollable upper area ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order total card
                  _SummaryCard(
                    order: order,
                    cardBg: cardBg,
                    maroon: maroon,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  )
                      .animate()
                      .fadeIn(duration: 350.ms)
                      .slideY(
                        begin: -0.08,
                        end: 0,
                        duration: 350.ms,
                        curve: Curves.easeOut,
                      ),

                  const SizedBox(height: AppSpacing.md),

                  // Section label
                  _SectionLabel(label: 'ITEMS', textSecondary: textSecondary),
                  const SizedBox(height: 6),

                  // Cart item tiles
                  ...order.items.asMap().entries.map((entry) {
                    return _CartItemTile(
                      cartItem: entry.value,
                      isDark: isDark,
                      cardBg: cardBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      maroon: maroon,
                    ).animate().fadeIn(
                          duration: 300.ms,
                          delay: (40 * entry.key).ms,
                        );
                  }),

                  const SizedBox(height: AppSpacing.md),

                  // Payment method
                  _SectionLabel(
                    label: 'PAYMENT METHOD',
                    textSecondary: textSecondary,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: PaymentMethod.values.map((method) {
                      return Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          child: PaymentMethodCard(
                            method: method,
                            isSelected:
                                checkout.selectedMethod == method,
                            onTap: () => ref
                                .read(checkoutProvider.notifier)
                                .selectMethod(method),
                          ),
                        ),
                      );
                    }).toList(),
                  ).animate().fadeIn(duration: 350.ms, delay: 120.ms),

                  // GCash / Other confirmation note
                  if (isNonCash) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _NonCashNote(
                      method: checkout.selectedMethod!,
                      total: order.total,
                      cardBg: cardBg,
                      textSecondary: textSecondary,
                    ).animate().fadeIn(duration: 200.ms),
                  ],
                ],
              ),
            ),
          ),

          // ── Cash input section (animated in/out) ────────────────────────
          AnimatedSize(
            duration: AppDuration.medium,
            curve: AppCurve.standard,
            child: isCash
                ? _CashInputSection(
                    checkout: checkout,
                    change: change,
                    surface: surface,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onDigit: (d) =>
                        ref.read(checkoutProvider.notifier).appendDigit(d),
                    onDelete: () =>
                        ref.read(checkoutProvider.notifier).deleteDigit(),
                  )
                : const SizedBox.shrink(),
          ),

          // ── Bottom action bar ────────────────────────────────────────────
          _BottomActionBar(
            surface: surface,
            maroon: maroon,
            textPrimary: textPrimary,
            isValidPayment: isValidPayment,
            isProcessing: checkout.isProcessing,
            errorMessage: checkout.errorMessage,
            onComplete: () => _handleCompletePayment(context),
            onCancel: () => _showCancelDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCompletePayment(BuildContext context) async {
    final saved =
        await ref.read(checkoutProvider.notifier).processPayment();
    if (saved != null && context.mounted) {
      context.go(RouteConstants.paymentSuccess);
    }
  }

  void _showCancelDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maroon = isDark ? AppColors.primaryDark : AppColors.secondaryLight;
    final dialogBg =
        isDark ? AppColors.surfaceDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Cancel Order?',
          style: GoogleFonts.dmSans(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Text(
          'All items in your cart will be removed. This cannot be undone.',
          style: GoogleFonts.dmSans(color: textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep Order',
              style: GoogleFonts.dmSans(
                color: maroon,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(orderProvider.notifier).clearCart();
              ref.read(checkoutProvider.notifier).reset();
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorLight,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.mediumBR,
              ),
              elevation: 0,
            ),
            child: Text(
              'Cancel Order',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.textSecondary});
  final String label;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.dmSans(
        color: textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      ),
    );
  }
}

/// Compact order total card shown at the top of the checkout screen.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.order,
    required this.cardBg,
    required this.maroon,
    required this.textPrimary,
    required this.textSecondary,
  });

  final OrderState order;
  final Color cardBg, maroon, textPrimary, textSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.largeBR,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.items.length} line item${order.items.length == 1 ? '' : 's'}',
                style: GoogleFonts.dmSans(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${order.itemCount} unit${order.itemCount == 1 ? '' : 's'}',
                style: GoogleFonts.dmSans(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.format(order.total),
            style: GoogleFonts.dmSans(
              color: maroon,
              fontSize: 38,
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total to Pay',
            style: GoogleFonts.dmSans(
              color: textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: textSecondary.withValues(alpha: 0.15)),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Subtotal',
            value: CurrencyFormatter.format(order.total),
            labelColor: textSecondary,
            valueColor: textPrimary,
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'Discount',
            value: '−₱0.00',
            labelColor: textSecondary,
            valueColor: textSecondary,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
  });

  final String label, value;
  final Color labelColor, valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            color: labelColor,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Compact cart item tile with quantity stepper and delete button.
class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({
    required this.cartItem,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.maroon,
  });

  final CartItem cartItem;
  final bool isDark;
  final Color cardBg, textPrimary, textSecondary, maroon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.mediumBR,
      ),
      child: Row(
        children: [
          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.itemName,
                  style: GoogleFonts.dmSans(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (cartItem.variantName != null)
                  Text(
                    cartItem.variantName!,
                    style: GoogleFonts.dmSans(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
                if (cartItem.modifiers.isNotEmpty)
                  Text(
                    cartItem.modifiers.join(' · '),
                    style: GoogleFonts.dmSans(
                      color: textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (cartItem.notes != null && cartItem.notes!.isNotEmpty)
                  Text(
                    '📝 ${cartItem.notes}',
                    style: GoogleFonts.dmSans(
                      color: textSecondary,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.format(cartItem.subtotal),
                  style: GoogleFonts.dmSans(
                    color: maroon,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Controls column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Delete button
              GestureDetector(
                onTap: () => ref
                    .read(orderProvider.notifier)
                    .removeItem(cartItem.cartKey),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.errorLight,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Quantity stepper
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StepBtn(
                    icon: Icons.remove_rounded,
                    onTap: () => ref
                        .read(orderProvider.notifier)
                        .updateQuantity(cartItem.cartKey, cartItem.quantity - 1),
                    isDark: isDark,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${cartItem.quantity}',
                      style: GoogleFonts.dmSans(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _StepBtn(
                    icon: Icons.add_rounded,
                    onTap: () => ref
                        .read(orderProvider.notifier)
                        .updateQuantity(cartItem.cartKey, cartItem.quantity + 1),
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF8B4049)),
      ),
    );
  }
}

/// Confirmation note shown for GCash / Other payment methods.
class _NonCashNote extends StatelessWidget {
  const _NonCashNote({
    required this.method,
    required this.total,
    required this.cardBg,
    required this.textSecondary,
  });

  final PaymentMethod method;
  final double total;
  final Color cardBg, textSecondary;

  @override
  Widget build(BuildContext context) {
    final isGCash = method == PaymentMethod.gcash;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.mediumBR,
      ),
      child: Row(
        children: [
          Icon(
            isGCash
                ? Icons.account_balance_wallet_rounded
                : Icons.payment_rounded,
            color: isGCash
                ? const Color(0xFF1565C0)
                : const Color(0xFF7B1FA2),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tap "Complete Payment" to confirm '
              '${method.label} payment of '
              '${CurrencyFormatter.format(total)}',
              style: GoogleFonts.dmSans(
                color: textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cash amount display + numeric keypad + change row — fixed at bottom.
class _CashInputSection extends StatelessWidget {
  const _CashInputSection({
    required this.checkout,
    required this.change,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.onDigit,
    required this.onDelete,
  });

  final CheckoutState checkout;
  final double change;
  final Color surface, textPrimary, textSecondary;
  final void Function(String) onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: Column(
        children: [
          // Amount display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enter Amount',
                style: GoogleFonts.dmSans(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AnimatedSwitcher(
                duration: AppDuration.fast,
                child: Text(
                  checkout.amountDisplay.isEmpty
                      ? '₱0'
                      : '₱${checkout.amountDisplay}',
                  key: ValueKey(checkout.amountDisplay),
                  style: GoogleFonts.dmSans(
                    color: textPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Keypad
          NumericKeypad(onDigit: onDigit, onDelete: onDelete),

          // Change display
          AnimatedSize(
            duration: AppDuration.fast,
            child: change > 0
                ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 4, bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          AppColors.successLight.withValues(alpha: 0.12),
                      borderRadius: AppRadius.mediumBR,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Change',
                          style: GoogleFonts.dmSans(
                            color: AppColors.successLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(change),
                          style: GoogleFonts.dmSans(
                            color: AppColors.successLight,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(height: 4),
          ),
        ],
      ),
    );
  }
}

/// Sticky bottom bar with error message, Complete Payment button, and Cancel.
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.surface,
    required this.maroon,
    required this.textPrimary,
    required this.isValidPayment,
    required this.isProcessing,
    required this.errorMessage,
    required this.onComplete,
    required this.onCancel,
  });

  final Color surface, maroon, textPrimary;
  final bool isValidPayment, isProcessing;
  final String? errorMessage;
  final VoidCallback onComplete, onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        boxShadow: AppShadow.level2,
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                errorMessage!,
                style: GoogleFonts.dmSans(
                  color: AppColors.errorLight,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Complete Payment
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed:
                  isValidPayment && !isProcessing ? onComplete : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: maroon,
                disabledBackgroundColor: maroon.withValues(alpha: 0.3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.largeBR,
                ),
                elevation: 0,
              ),
              child: isProcessing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Complete Payment',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),

          // Cancel Order
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: isProcessing ? null : onCancel,
              child: Text(
                'Cancel Order',
                style: GoogleFonts.dmSans(
                  color: AppColors.errorLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
