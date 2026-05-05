import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/printer_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/isar_collections/order_collection.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OrderDetailSheet — draggable bottom sheet showing full order breakdown
// ─────────────────────────────────────────────────────────────────────────────

class OrderDetailSheet extends ConsumerWidget {
  const OrderDetailSheet({super.key, required this.order});

  final OrderCollection order;

  static void show(BuildContext context, OrderCollection order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderDetailSheet(order: order),
    );
  }

  static final _dateFmt =
      DateFormat('MMMM dd, yyyy  •  hh:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF2A1215) : const Color(0xFFFAF6F1);
    final cardBg =
        isDark ? const Color(0xFF5D2832) : const Color(0xFFF0E8DC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary =
        isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    const maroon = Color(0xFF8B4049);

    final items = order.orderItemsJson
        .map((raw) => jsonDecode(raw) as Map<String, dynamic>)
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ── Drag handle ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textSecondary.withAlpha(80),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

              // ── Header bar ───────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.orderNumber,
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _dateFmt.format(order.orderedAt),
                            style: GoogleFonts.dmSans(
                                fontSize: 12, color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                    _StatusChipDetail(status: order.status),
                  ],
                ),
              ),
              Divider(
                  height: 1,
                  color: textSecondary.withAlpha(50),
                  indent: 16,
                  endIndent: 16),

              // ── Scrollable body ──────────────────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  children: [
                    // Cashier info
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Cashier',
                      value: order.cashierName,
                      textSecondary: textSecondary,
                      textPrimary: textPrimary,
                    ),
                    const SizedBox(height: 16),

                    // Items section
                    Text(
                      'Items',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < items.length; i++) ...[
                            _ItemRow(
                                item: items[i],
                                textPrimary: textPrimary,
                                textSecondary: textSecondary),
                            if (i < items.length - 1)
                              Divider(
                                  height: 1,
                                  color: textSecondary.withAlpha(40),
                                  indent: 16,
                                  endIndent: 16),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Totals section
                    Text(
                      'Summary',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _SummaryRow(
                              label: 'Subtotal',
                              value: CurrencyFormatter.format(order.subtotal),
                              textPrimary: textPrimary,
                              textSecondary: textSecondary),
                          if (order.discountAmount > 0) ...[
                            const SizedBox(height: 6),
                            _SummaryRow(
                              label: 'Discount${order.discountReason != null ? ' (${order.discountReason})' : ''}',
                              value:
                                  '- ${CurrencyFormatter.format(order.discountAmount)}',
                              textPrimary: const Color(0xFF2E7D32),
                              textSecondary: textSecondary,
                              valueColor: const Color(0xFF2E7D32),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Divider(
                              height: 1,
                              color: textSecondary.withAlpha(40)),
                          const SizedBox(height: 6),
                          _SummaryRow(
                            label: 'Total',
                            value: CurrencyFormatter.format(order.totalAmount),
                            textPrimary: maroon,
                            textSecondary: textSecondary,
                            isBold: true,
                            valueColor: maroon,
                          ),
                          const SizedBox(height: 10),
                          Divider(
                              height: 1,
                              color: textSecondary.withAlpha(40)),
                          const SizedBox(height: 10),
                          _SummaryRow(
                            label: 'Payment',
                            value: _paymentLabel(order.paymentMethod),
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                          const SizedBox(height: 6),
                          _SummaryRow(
                            label: 'Tendered',
                            value: CurrencyFormatter.format(
                                order.amountTendered),
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                          const SizedBox(height: 6),
                          _SummaryRow(
                            label: 'Change',
                            value:
                                CurrencyFormatter.format(order.changeAmount),
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Reprint button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => _onReprint(context, ref),
                        icon: const Icon(Icons.print_rounded, size: 18),
                        label: Text(
                          'Reprint Receipt',
                          style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: maroon,
                          side: const BorderSide(color: maroon, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Future<void> _onReprint(BuildContext context, WidgetRef ref) async {
    final printer = ref.read(printerServiceProvider);
    final success = await printer.printReceipt(order);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Receipt printed.' : 'No printer connected. Receipt saved.',
          style: GoogleFonts.dmSans(),
        ),
        backgroundColor: success
            ? const Color(0xFF2E7D32)
            : const Color(0xFF8B4049),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _paymentLabel(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'gcash':
        return 'GCash';
      default:
        return 'Other';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: textSecondary),
        const SizedBox(width: 8),
        Text('$label: ',
            style: GoogleFonts.dmSans(fontSize: 13, color: textSecondary)),
        Expanded(
          child: Text(value,
              style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textPrimary),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Map<String, dynamic> item;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final name = item['itemName']?.toString() ?? '';
    final variant = item['variantName']?.toString() ?? '';
    final qty = item['quantity'] ?? 0;
    final unitPrice =
        (item['unitPrice'] as num?)?.toDouble() ?? 0.0;
    final subtotal =
        (item['subtotal'] as num?)?.toDouble() ?? 0.0;
    final modifiers = item['modifiers']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary),
                ),
                if (variant.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(variant,
                      style: GoogleFonts.dmSans(
                          fontSize: 11, color: textSecondary)),
                ],
                if (modifiers.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(modifiers,
                      style: GoogleFonts.dmSans(
                          fontSize: 11, color: textSecondary)),
                ],
                const SizedBox(height: 4),
                Text(
                  '₱${unitPrice.toStringAsFixed(2)} × $qty',
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '₱${subtotal.toStringAsFixed(2)}',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
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
    required this.textPrimary,
    required this.textSecondary,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: isBold ? 14 : 13, color: textSecondary)),
        Text(value,
            style: GoogleFonts.dmSans(
              fontSize: isBold ? 15 : 13,
              fontWeight:
                  isBold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? textPrimary,
            )),
      ],
    );
  }
}

class _StatusChipDetail extends StatelessWidget {
  const _StatusChipDetail({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = const Color(0xFF2E7D32);
        break;
      case 'voided':
        color = const Color(0xFFC62828);
        break;
      case 'refunded':
        color = const Color(0xFFE65100);
        break;
      default:
        color = const Color(0xFF546E7A);
    }
    final label = status.isEmpty
        ? status
        : status[0].toUpperCase() + status.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(120), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
