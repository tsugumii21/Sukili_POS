import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
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
  const RefundSheet({
    super.key,
    required this.order,
    this.scrollController,
  });

  final OrderCollection order;
  final ScrollController? scrollController;

  static Future<RefundResult?> show(
    BuildContext context,
    OrderCollection order,
  ) {
    return showModalBottomSheet<RefundResult?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const [0.62, 0.95],
        builder: (_, scrollCtrl) => RefundSheet(
          order: order,
          scrollController: scrollCtrl,
        ),
      ),
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
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final borderCol = isDark ? AppColors.borderDark : AppColors.primaryLight;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: AppRadius.large),
        boxShadow: AppShadow.level4,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          controller: widget.scrollController,
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
          children: [
            // ── Handle bar ───────────────────────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textSecondary.withValues(alpha: 0.3),
                  borderRadius: AppRadius.pillBR,
                ),
              ),
            ),

            // ── Header ───────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.receipt_long_rounded,
                      color: accent, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Process Refund',
                        style: AppTextStyles.h3(context),
                      ),
                      Text(
                        widget.order.orderNumber,
                        style: AppTextStyles.captionSecondary(context),
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
                    borderRadius: AppRadius.mediumBR,
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
                      Container(width: 1, height: 32, color: borderCol),
                      _SummaryPair(
                        label: 'Payment',
                        value: _capitalize(widget.order.paymentMethod),
                        textSecondary: textSecondary,
                        textPrimary: textPrimary,
                      ),
                      Container(width: 1, height: 32, color: borderCol),
                      _SummaryPair(
                        label: 'Total',
                        value: CurrencyFormatter.format(
                            widget.order.totalAmount),
                        textSecondary: textSecondary,
                        textPrimary: accent,
                        bold: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Refund type toggle ────────────────────────────────────
                _SectionLabel(
                    label: 'REFUND TYPE', textSecondary: textSecondary),
                Row(
                  children: [
                    _TypeBtn(
                      label: 'Full Refund',
                      amount:
                          CurrencyFormatter.format(widget.order.totalAmount),
                      selected: _type == RefundType.full,
                      isDark: isDark,
                      accent: accent,
                      cardBg: cardBg,
                      borderCol: borderCol,
                      textPrimary: textPrimary,
                      onTap: () => setState(() => _type = RefundType.full),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _TypeBtn(
                      label: 'Partial Refund',
                      amount: 'Enter amount',
                      selected: _type == RefundType.partial,
                      isDark: isDark,
                      accent: accent,
                      cardBg: cardBg,
                      borderCol: borderCol,
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
                                    AppTextStyles.body(context).copyWith(color: textPrimary),
                                decoration: InputDecoration(
                                  prefixText: '₱ ',
                                  prefixStyle:
                                      AppTextStyles.bodyMedium(context).copyWith(color: accent),
                                  hintText: '0.00',
                                  hintStyle: AppTextStyles.body(context).copyWith(color: textSecondary),
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
                TextFormField(
                  controller: _reasonCtrl,
                  maxLines: 3,
                  minLines: 2,
                  style: AppTextStyles.body(context).copyWith(color: textPrimary),
                  onChanged: (v) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'e.g. Customer received wrong order',
                    hintStyle:
                        AppTextStyles.body(context).copyWith(color: textSecondary),
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
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.08),
                    borderRadius: AppRadius.mediumBR,
                    border: Border.all(
                        color: accent.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 16, color: accent),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          _type == RefundType.full
                              ? 'Full refund of ${CurrencyFormatter.format(widget.order.totalAmount)} will be processed.'
                              : 'Partial refund — amount will be confirmed after entry.',
                          style: AppTextStyles.caption(context).copyWith(
                            color: accent,
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
                    onPressed: _reasonCtrl.text.trim().isEmpty ? null : _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      disabledBackgroundColor: accent.withValues(alpha: 0.4),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.mediumBR),
                    ),
                    child: Text(
                      'Continue to Admin Verification',
                      style: AppTextStyles.bodyMedium(context).copyWith(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.md),
                  child: Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      style: TextButton.styleFrom(
                        foregroundColor: textSecondary,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.mediumBR),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.bodyMedium(context).copyWith(color: textSecondary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.caption(context).copyWith(
          color: textSecondary,
          letterSpacing: 1.2,
        ),
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
        Text(
          label.toUpperCase(),
          style: AppTextStyles.caption(context).copyWith(color: textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: bold 
            ? AppTextStyles.bodySemiBold(context).copyWith(color: textPrimary)
            : AppTextStyles.bodySemiBold(context).copyWith(color: textPrimary),
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
    required this.accent,
    required this.cardBg,
    required this.borderCol,
    required this.textPrimary,
    required this.onTap,
  });

  final String label;
  final String amount;
  final bool selected;
  final bool isDark;
  final Color accent;
  final Color cardBg;
  final Color borderCol;
  final Color textPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDuration.fast,
          height: 72,
          decoration: BoxDecoration(
            color: selected ? accent : cardBg,
            borderRadius: AppRadius.mediumBR,
            border: selected ? null : Border.all(color: borderCol),
            boxShadow: selected ? AppShadow.level2 : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: selected ? Colors.white : textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                amount,
                style: selected 
                  ? AppTextStyles.captionMedium(context).copyWith(color: Colors.white.withValues(alpha: 0.8))
                  : AppTextStyles.captionSecondary(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
