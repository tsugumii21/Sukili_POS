import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/printer_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/checkout_provider.dart';

/// PaymentSuccessScreen — celebrates a completed payment with an animated
/// checkmark, an order summary card, and print/navigation actions.
class PaymentSuccessScreen extends ConsumerWidget {
  const PaymentSuccessScreen({super.key});

  static const _maroon = Color(0xFF8B4049);
  static const _maroonDeep = Color(0xFF6B2C33);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkout = ref.watch(checkoutProvider);
    final order = checkout.completedOrder;

    // Prevent the system back button from returning to checkout —
    // after payment is done there is nothing to undo.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(RouteConstants.cashierHome);
      },
      child: Scaffold(
        backgroundColor: _maroon,
        body: order == null
            ? _buildFallback(context)
            : _buildSuccess(context, ref, order),
      ),
    );
  }

  // ── Fallback (navigated here without completing a payment) ────────────────

  Widget _buildFallback(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_rounded,
                color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(
              'No order data found.',
              style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.go(RouteConstants.cashierHome),
              child: Text(
                'Back to Home',
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main success layout ───────────────────────────────────────────────────

  Widget _buildSuccess(BuildContext context, WidgetRef ref, dynamic order) {
    return SafeArea(
      child: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.md,
              ),
              child: Column(
                children: [
                  // ── Confetti + checkmark ─────────────────────────────────
                  _buildCheckmarkSection(),
                  const SizedBox(height: AppSpacing.md),

                  // ── Title ────────────────────────────────────────────────
                  Text(
                    'Payment Successful!',
                    style: GoogleFonts.dmSerifDisplay(
                      color: Colors.white,
                      fontSize: 32,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 500.ms)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 400.ms,
                        delay: 500.ms,
                        curve: Curves.easeOut,
                      ),

                  const SizedBox(height: 6),

                  // Order number + timestamp
                  Text(
                    '${order.orderNumber}  •  ${DateFormat('hh:mm a').format(order.orderedAt)}',
                    style: GoogleFonts.dmSans(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 650.ms),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Order summary card ───────────────────────────────────
                  _OrderSummaryCard(order: order)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 750.ms)
                      .slideY(
                        begin: 0.15,
                        end: 0,
                        duration: 500.ms,
                        delay: 750.ms,
                        curve: Curves.easeOut,
                      ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          // ── Fixed bottom buttons ─────────────────────────────────────────
          _buildButtons(context, ref, order)
              .animate()
              .fadeIn(duration: 400.ms, delay: 900.ms)
              .slideY(begin: 0.3, end: 0, duration: 400.ms, delay: 900.ms),
        ],
      ),
    );
  }

  // ── Animated checkmark ────────────────────────────────────────────────────

  Widget _buildCheckmarkSection() {
    return SizedBox(
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Sparkle decorations — staggered scale + fade
          ..._sparklePositions.asMap().entries.map((e) {
            final i = e.key;
            final pos = e.value;
            return Positioned(
              left: pos.dx,
              top: pos.dy,
              child: _Sparkle(color: _sparkleColors[i % _sparkleColors.length])
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    delay: (700 + i * 80).ms,
                    curve: Curves.easeOut,
                  )
                  .fade(
                    begin: 0,
                    end: 1,
                    duration: 200.ms,
                    delay: (700 + i * 80).ms,
                  )
                  .then(delay: 600.ms)
                  .fade(end: 0, duration: 600.ms),
            );
          }),

          // Pulsing outer ring
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
                duration: 1200.ms,
              ),

          // Inner circle + checkmark
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 56,
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.2, 0.2),
                end: const Offset(1, 1),
                duration: 600.ms,
                delay: 200.ms,
                curve: Curves.elasticOut,
              )
              .fade(begin: 0, end: 1, duration: 300.ms, delay: 200.ms),
        ],
      ),
    );
  }

  // ── Bottom buttons ────────────────────────────────────────────────────────

  Widget _buildButtons(BuildContext context, WidgetRef ref, dynamic order) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: _maroonDeep.withValues(alpha: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
              // New Order — primary white button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(checkoutProvider.notifier).reset();
                    // go() resets to cashierHome (base of stack), then
                    // push() adds newOrder on top so the back button works.
                    context.go(RouteConstants.cashierHome);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final router = GoRouter.of(context);
                      router.push(RouteConstants.newOrder);
                    });
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _maroon,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.largeBR,
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
              label: Text(
                'New Order',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Print Receipt — white outlined button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => _onPrintReceipt(context, ref, order),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.largeBR,
                ),
              ),
              icon: const Icon(Icons.print_rounded, size: 20),
              label: Text(
                'Print Receipt',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Back to Home — text button
          TextButton(
            onPressed: () {
              ref.read(checkoutProvider.notifier).reset();
              context.go(RouteConstants.cashierHome);
            },
            child: Text(
              'Back to Home',
              style: GoogleFonts.dmSans(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onPrintReceipt(
    BuildContext context,
    WidgetRef ref,
    dynamic order,
  ) async {
    final printer = ref.read(printerServiceProvider);
    final success = await printer.printReceipt(order);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Receipt printed successfully!'
              : 'No printer connected. Receipt saved.',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w500),
        ),
        backgroundColor:
            success ? AppColors.successLight : AppColors.warningLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(AppSpacing.md),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Sparkle decoration helpers ────────────────────────────────────────────

  static const _sparklePositions = [
    Offset(10, 10),
    Offset(115, 5),
    Offset(130, 80),
    Offset(5, 90),
    Offset(60, 0),
    Offset(80, 120),
  ];

  static const _sparkleColors = [
    Color(0xFFFFD700),
    Color(0xFFFF9800),
    Color(0xFFFFC0CB),
    Color(0xFF90CAF9),
    Color(0xFFA5D6A7),
    Color(0xFFFFD700),
  ];
}

// ── Order Summary Card ────────────────────────────────────────────────────────

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order});
  final dynamic order;

  @override
  Widget build(BuildContext context) {
    final items = (order.orderItemsJson as List<String>)
        .map((j) => jsonDecode(j) as Map<String, dynamic>)
        .toList();

    final paymentLabel = _paymentLabel(order.paymentMethod as String);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.largeBR,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: Color(0xFFF0E8DC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_rounded,
                    color: Color(0xFF8B4049), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.orderNumber as String,
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFF3E2723),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Completed',
                    style: GoogleFonts.dmSans(
                      color: AppColors.successLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cashier row
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 14, color: Color(0xFF5D4037)),
                    const SizedBox(width: 6),
                    Text(
                      order.cashierName as String,
                      style: GoogleFonts.dmSans(
                        color: const Color(0xFF5D4037),
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM dd  hh:mm a')
                          .format(order.orderedAt as DateTime),
                      style: GoogleFonts.dmSans(
                        color: const Color(0xFF5D4037),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),
                const Divider(height: 1, color: Color(0xFFE8D5C4)),
                const SizedBox(height: AppSpacing.sm),

                // Items
                ...items.map((item) {
                  final name = (item['itemName'] as String?) ?? '';
                  final variant = item['variantName'] as String?;
                  final qty = (item['quantity'] as int?) ?? 1;
                  final subtotal =
                      ((item['subtotal'] as num?) ?? 0).toDouble();
                  final mods = (item['modifiers'] as List?)
                      ?.map((e) => e.toString())
                      .toList() ??
                      [];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$name${variant != null ? ' ($variant)' : ''}',
                                style: GoogleFonts.dmSans(
                                  color: const Color(0xFF3E2723),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (mods.isNotEmpty)
                                Text(
                                  mods.join(' · '),
                                  style: GoogleFonts.dmSans(
                                    color: const Color(0xFF5D4037),
                                    fontSize: 11,
                                  ),
                                ),
                              Text(
                                'x$qty',
                                style: GoogleFonts.dmSans(
                                  color: const Color(0xFF5D4037),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(subtotal),
                          style: GoogleFonts.dmSans(
                            color: const Color(0xFF8B4049),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const Divider(height: 1, color: Color(0xFFE8D5C4)),
                const SizedBox(height: AppSpacing.sm),

                // Totals
                _CardRow(
                  label: 'Subtotal',
                  value: CurrencyFormatter.format(order.subtotal as double),
                ),
                if ((order.discountAmount as double) > 0)
                  _CardRow(
                    label: 'Discount',
                    value:
                        '−${CurrencyFormatter.format(order.discountAmount as double)}',
                    valueColor: AppColors.successLight,
                  ),
                _CardRow(
                  label: 'Total',
                  value:
                      CurrencyFormatter.format(order.totalAmount as double),
                  bold: true,
                  valueColor: const Color(0xFF8B4049),
                ),

                const SizedBox(height: AppSpacing.xs),
                const Divider(height: 1, color: Color(0xFFE8D5C4)),
                const SizedBox(height: AppSpacing.sm),

                // Payment
                _CardRow(
                  label: 'Payment',
                  value: paymentLabel,
                ),
                _CardRow(
                  label: 'Amount Paid',
                  value: CurrencyFormatter.format(
                      order.amountTendered as double),
                ),
                if ((order.changeAmount as double) > 0)
                  _CardRow(
                    label: 'Change',
                    value: CurrencyFormatter.format(
                        order.changeAmount as double),
                    valueColor: AppColors.successLight,
                    bold: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _paymentLabel(String method) {
    switch (method) {
      case 'cash':
        return 'Cash';
      case 'gcash':
        return 'GCash';
      case 'other':
        return 'Other';
      default:
        return method.toUpperCase();
    }
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label, value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: const Color(0xFF5D4037),
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.dmSans(
              color: valueColor ?? const Color(0xFF3E2723),
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sparkle decoration widget ─────────────────────────────────────────────────

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6),
        ],
      ),
    );
  }
}
