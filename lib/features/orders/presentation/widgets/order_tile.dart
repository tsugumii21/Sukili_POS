import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../shared/isar_collections/order_collection.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OrderTile — single card in the order history list
// ─────────────────────────────────────────────────────────────────────────────

class OrderTile extends StatelessWidget {
  const OrderTile({
    super.key,
    required this.order,
    required this.onTap,
  });

  final OrderCollection order;
  final VoidCallback onTap;

  static final _dateFmt = DateFormat('MMM dd, yyyy');
  static final _timeFmt = DateFormat('hh:mm a');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg =
        isDark ? const Color(0xFF5D2832) : const Color(0xFFF0E8DC);
    final textPrimary =
        isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary =
        isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    const maroon = Color(0xFF8B4049);

    final statusColor = _statusColor(order.status);
    final payIcon = _paymentIcon(order.paymentMethod);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 60 : 25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: order number + status chip ──────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.orderNumber,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(status: order.status, color: statusColor),
                ],
              ),
              const SizedBox(height: 6),

              // ── Row 2: date/time + cashier ──────────────────────────────
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 13, color: textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${_dateFmt.format(order.orderedAt)}  •  ${_timeFmt.format(order.orderedAt)}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person_outline_rounded,
                      size: 13, color: textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.cashierName,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // ── Row 3: items count + payment icon + total ───────────────
              Row(
                children: [
                  Icon(Icons.receipt_long_rounded,
                      size: 14, color: textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${order.orderItemsJson.length} item${order.orderItemsJson.length == 1 ? '' : 's'}',
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: textSecondary),
                  ),
                  const SizedBox(width: 10),
                  Icon(payIcon,
                      size: 14,
                      color: _paymentIconColor(
                          order.paymentMethod, isDark)),
                  const SizedBox(width: 4),
                  Text(
                    _paymentLabel(order.paymentMethod),
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: textSecondary),
                  ),
                  const Spacer(),
                  Text(
                    '₱${order.totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: maroon,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF2E7D32);
      case 'voided':
        return const Color(0xFFC62828);
      case 'refunded':
        return const Color(0xFFE65100);
      default:
        return const Color(0xFF546E7A);
    }
  }

  IconData _paymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.payments_rounded;
      case 'gcash':
        return Icons.smartphone_rounded;
      default:
        return Icons.credit_card_rounded;
    }
  }

  Color _paymentIconColor(String method, bool isDark) {
    switch (method.toLowerCase()) {
      case 'cash':
        return const Color(0xFF2E7D32);
      case 'gcash':
        return const Color(0xFF1565C0);
      default:
        return const Color(0xFF6A1B9A);
    }
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
// Status chip
// ─────────────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.color});

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(120), width: 1),
      ),
      child: Text(
        _label(status),
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  String _label(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
