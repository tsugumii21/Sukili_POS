import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/isar_collections/order_collection.dart';

/// RefundType distinguishes between full and partial refunds.
enum RefundType { full, partial }

/// Payload returned by [RefundSheet] on confirm.
class RefundResult {
  const RefundResult({
    required this.reason,
    required this.amount,
    required this.isPartial,
  });

  final String reason;
  final double amount;
  final bool isPartial;
}

/// RefundSheet — A DraggableScrollableSheet bottom sheet for processing
/// a full or partial refund on a completed order.
///
/// Returns a [RefundResult] on confirm, or null if dismissed.
class RefundSheet extends StatefulWidget {
  const RefundSheet({super.key, required this.order});

  final OrderCollection order;

  static Future<RefundResult?> show(
    BuildContext context,
    OrderCollection order,
  ) {
    return showModalBottomSheet<RefundResult?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RefundSheet(order: order),
    );
  }

  @override
  State<RefundSheet> createState() => _RefundSheetState();
}

class _RefundSheetState extends State<RefundSheet> {
  RefundType _type = RefundType.full;
  final _amountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  double get _refundAmount {
    if (_type == RefundType.full) return widget.order.totalAmount;
    return double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      RefundResult(
        reason: _reasonCtrl.text.trim(),
        amount: _refundAmount,
        isPartial: _type == RefundType.partial,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.backgroundLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    const maroon = Color(0xFF8B4049);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
              children: [
                // ── Handle bar ───────────────────────────────────────────
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 16),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: textPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),

                // ── Header ───────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight.withValues(alpha: 0.12),
                        borderRadius: AppRadius.mediumBR,
                      ),
                      child: Icon(Icons.replay_rounded,
                          color: AppColors.warningLight, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Process Refund',
                            style: GoogleFonts.dmSans(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            widget.order.orderNumber,
                            style: GoogleFonts.dmSans(
                              color: textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Order summary card ────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: AppRadius.largeBR,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SummaryPair(
                        label: 'Cashier',
                        value: widget.order.cashierName,
                        textSecondary: textSecondary,
                        textPrimary: textPrimary,
                      ),
                      _SummaryPair(
                        label: 'Payment',
                        value: _capitalize(widget.order.paymentMethod),
                        textSecondary: textSecondary,
                        textPrimary: textPrimary,
                      ),
                      _SummaryPair(
                        label: 'Total',
                        value: CurrencyFormatter.format(
                            widget.order.totalAmount),
                        textSecondary: textSecondary,
                        textPrimary: maroon,
                        bold: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Refund type toggle ────────────────────────────────────
                _SectionLabel(
                    label: 'REFUND TYPE', textSecondary: textSecondary),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    _TypeBtn(
                      label: 'Full Refund',
                      amount:
                          CurrencyFormatter.format(widget.order.totalAmount),
                      selected: _type == RefundType.full,
                      isDark: isDark,
                      maroon: maroon,
                      textPrimary: textPrimary,
                      onTap: () => setState(() => _type = RefundType.full),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _TypeBtn(
                      label: 'Partial Refund',
                      amount: 'Enter amount',
                      selected: _type == RefundType.partial,
                      isDark: isDark,
                      maroon: maroon,
                      textPrimary: textPrimary,
                      onTap: () => setState(() => _type = RefundType.partial),
                    ),
                  ],
                ),

                // ── Partial amount field (animated) ───────────────────────
                AnimatedSize(
                  duration: AppDuration.medium,
                  curve: Curves.easeOut,
                  child: _type == RefundType.partial
                      ? Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel(
                                  label: 'REFUND AMOUNT',
                                  textSecondary: textSecondary),
                              const SizedBox(height: AppSpacing.xs),
                              TextFormField(
                                controller: _amountCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[\d.]'))
                                ],
                                style:
                                    GoogleFonts.dmSans(color: textPrimary),
                                decoration: InputDecoration(
                                  prefixText: '₱ ',
                                  prefixStyle:
                                      GoogleFonts.dmSans(color: maroon),
                                  hintText: '0.00',
                                  hintStyle: GoogleFonts.dmSans(
                                      color: textSecondary),
                                  filled: true,
                                  fillColor: cardBg,
                                  border: OutlineInputBorder(
                                    borderRadius: AppRadius.mediumBR,
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                ),
                                validator: (v) {
                                  if (_type == RefundType.full) return null;
                                  final val = double.tryParse(
                                      (v ?? '').replaceAll(',', ''));
                                  if (val == null || val <= 0) {
                                    return 'Enter a valid amount';
                                  }
                                  if (val > widget.order.totalAmount) {
                                    return 'Cannot exceed order total';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: AppSpacing.md),

                // ── Reason field ──────────────────────────────────────────
                _SectionLabel(
                    label: 'REASON (REQUIRED)',
                    textSecondary: textSecondary),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _reasonCtrl,
                  maxLines: 3,
                  style: GoogleFonts.dmSans(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: 'e.g. Customer received wrong order',
                    hintStyle:
                        GoogleFonts.dmSans(color: textSecondary, fontSize: 14),
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.mediumBR,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Reason is required'
                      : null,
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Summary line ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight.withValues(alpha: 0.08),
                    borderRadius: AppRadius.mediumBR,
                    border: Border.all(
                        color: AppColors.warningLight.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 16, color: AppColors.warningLight),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _type == RefundType.full
                              ? 'Full refund of ${CurrencyFormatter.format(widget.order.totalAmount)} will be processed.'
                              : 'Partial refund — amount will be confirmed after entry.',
                          style: GoogleFonts.dmSans(
                            color: AppColors.warningLight,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Buttons ───────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroon,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.largeBR),
                    ),
                    child: Text(
                      'Continue to Admin Verification',
                      style: GoogleFonts.dmSans(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    style: TextButton.styleFrom(
                      foregroundColor: textSecondary,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.largeBR),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.dmSans(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

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
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SummaryPair extends StatelessWidget {
  const _SummaryPair({
    required this.label,
    required this.value,
    required this.textSecondary,
    required this.textPrimary,
    this.bold = false,
  });
  final String label;
  final String value;
  final Color textSecondary;
  final Color textPrimary;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(
                color: textSecondary, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.dmSans(
            color: textPrimary,
            fontSize: 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TypeBtn extends StatelessWidget {
  const _TypeBtn({
    required this.label,
    required this.amount,
    required this.selected,
    required this.isDark,
    required this.maroon,
    required this.textPrimary,
    required this.onTap,
  });

  final String label;
  final String amount;
  final bool selected;
  final bool isDark;
  final Color maroon;
  final Color textPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unselectedBg = isDark
        ? AppColors.surfaceDarkElevated
        : AppColors.cardLight;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDuration.fast,
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
          decoration: BoxDecoration(
            color: selected ? maroon : unselectedBg,
            borderRadius: AppRadius.mediumBR,
            border: selected
                ? null
                : Border.all(
                    color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  color: selected ? Colors.white : textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                amount,
                style: GoogleFonts.dmSans(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.75)
                      : textPrimary.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
