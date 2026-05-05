import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
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

  static final _dateFmt = DateFormat('MMM d, yyyy');

  /// Shows relative time for orders under 24 hours, date otherwise.
  static String _timeLabel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return _dateFmt.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : const Color(0xFFF0E8DC);
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : const Color(0xFF1A1A1A);
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : const Color(0xFF6B6B6B);
    final totalColor =
        isDark ? AppColors.accentDarkLight : const Color(0xFF8B4049);

    final statusColor = _statusColor(order.status);
    final payIcon = _paymentIcon(order.paymentMethod);
    final payLabel = _paymentLabel(order.paymentMethod);
    final timeLabel = _timeLabel(order.orderedAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: isDark
              ? Border.all(color: AppColors.borderDark, width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 40 : 25),
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
              // ── Row 1: order number (primary) + relative time ───────────
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
                  Text(
                    timeLabel,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Divider(
                height: 1,
                color: isDark
                    ? AppColors.borderDark
                    : Colors.black.withAlpha(12),
              ),
              const SizedBox(height: 10),

              // ── Row 2: payment method (left) + total + status (right) ───
              Row(
                children: [
                  // Subtle payment icon + label — no background chip
                  Icon(payIcon, size: 14, color: textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    payLabel,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₱${order.totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: totalColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status badge — aligned with price on the right
                  _StatusChip(status: order.status, color: statusColor),
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
        return Icons.payments_outlined;
      case 'gcash':
        return Icons.smartphone_rounded;
      default:
        return Icons.credit_card_rounded;
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
