import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../providers/end_of_day_provider.dart';

class EndOfDayScreen extends ConsumerStatefulWidget {
  const EndOfDayScreen({super.key});
  @override
  ConsumerState<EndOfDayScreen> createState() => _EndOfDayScreenState();
}

class _EndOfDayScreenState extends ConsumerState<EndOfDayScreen> {
  final _cashCtrl = TextEditingController();

  @override
  void dispose() {
    _cashCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(endOfDayProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSec = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('End of Day', style: AppTextStyles.h3(context)),
            Text(DateFormat('EEEE, MMM d, yyyy').format(s.reportDate),
                style: AppTextStyles.captionSecondary(context)),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: s.isGenerated
            ? _buildReport(context, s, isDark, accent, textPrimary, textSec)
            : _buildGeneratePrompt(context, s, accent),
      ),
    );
  }

  Widget _buildGeneratePrompt(BuildContext ctx, EndOfDayState s, Color accent) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.summarize_rounded, size: 64, color: accent.withValues(alpha: 0.4)),
            const SizedBox(height: AppSpacing.md),
            Text('Ready to close the day?', style: AppTextStyles.h3(ctx)),
            const SizedBox(height: AppSpacing.xs),
            Text('Generate the end-of-day report to review sales, voids, and reconcile cash.',
                style: AppTextStyles.captionSecondary(ctx), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: s.isLoading ? null : () => ref.read(endOfDayProvider.notifier).generateReport(),
                icon: s.isLoading
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.play_arrow_rounded, color: Colors.white),
                label: Text(s.isLoading ? 'Generating…' : 'Generate Report',
                    style: AppTextStyles.bodySemiBold(ctx).copyWith(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReport(BuildContext ctx, EndOfDayState s, bool isDark, Color accent, Color textPrimary, Color textSec) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            children: [
              _salesOverview(ctx, s, accent, textPrimary, textSec),
              const SizedBox(height: AppSpacing.sm),
              _topItemsSection(ctx, s, accent, textPrimary, textSec),
              const SizedBox(height: AppSpacing.sm),
              _categorySection(ctx, s, accent, textPrimary, textSec),
              const SizedBox(height: AppSpacing.sm),
              _voidsSection(ctx, s, textPrimary, textSec),
              const SizedBox(height: AppSpacing.sm),
              _cashReconSection(ctx, s, isDark, accent, textPrimary, textSec),
            ],
          ),
        ),
        _actionBar(ctx, s, accent),
      ],
    );
  }

  // ── Section 1: Sales Overview ─────────────────────────────────────────
  Widget _salesOverview(BuildContext ctx, EndOfDayState s, Color accent, Color tp, Color ts) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle(ctx, Icons.payments_outlined, 'Sales Overview', accent),
        const SizedBox(height: AppSpacing.sm),
        Row(children: [
          _kpi(ctx, CurrencyFormatter.format(s.totalSales), 'Total Sales', accent),
          _kpi(ctx, '${s.orderCount}', 'Orders', tp),
          _kpi(ctx, CurrencyFormatter.format(s.avgOrderValue), 'Avg Order', tp),
        ]),
        if (s.paymentBreakdown.isNotEmpty) ...[
          Divider(color: ts.withValues(alpha: 0.2), height: AppSpacing.lg),
          Text('Payment Methods', style: AppTextStyles.captionMedium(ctx).copyWith(color: ts)),
          const SizedBox(height: AppSpacing.xs),
          ...s.paymentBreakdown.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  Expanded(child: Text(p.label, style: AppTextStyles.body(ctx))),
                  Text('${p.count}x', style: AppTextStyles.caption(ctx).copyWith(color: ts)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(CurrencyFormatter.format(p.total), style: AppTextStyles.bodySemiBold(ctx)),
                ]),
              )),
        ],
      ]),
    );
  }

  // ── Section 2: Top Items ──────────────────────────────────────────────
  Widget _topItemsSection(BuildContext ctx, EndOfDayState s, Color accent, Color tp, Color ts) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle(ctx, Icons.star_rounded, 'Top Selling Items', accent),
        const SizedBox(height: AppSpacing.sm),
        if (s.topItems.isEmpty)
          _emptyLabel(ctx, 'No items sold today')
        else
          ...s.topItems.asMap().entries.map((e) {
            final i = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: AppRadius.smallBR),
                  alignment: Alignment.center,
                  child: Text('${e.key + 1}', style: AppTextStyles.captionMedium(ctx).copyWith(color: accent)),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text(i.name, style: AppTextStyles.body(ctx), overflow: TextOverflow.ellipsis)),
                Text('×${i.quantity}', style: AppTextStyles.caption(ctx).copyWith(color: ts)),
                const SizedBox(width: AppSpacing.sm),
                Text(CurrencyFormatter.format(i.revenue), style: AppTextStyles.bodySemiBold(ctx)),
              ]),
            );
          }),
      ]),
    );
  }

  // ── Section 3: Category Performance ───────────────────────────────────
  Widget _categorySection(BuildContext ctx, EndOfDayState s, Color accent, Color tp, Color ts) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle(ctx, Icons.category_rounded, 'Category Performance', accent),
        const SizedBox(height: AppSpacing.sm),
        if (s.categoryPerformance.isEmpty)
          _emptyLabel(ctx, 'No category data')
        else
          ...s.categoryPerformance.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Expanded(child: Text(c.categoryName, style: AppTextStyles.body(ctx))),
                  Text('${c.orderCount} orders', style: AppTextStyles.caption(ctx).copyWith(color: ts)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(CurrencyFormatter.format(c.totalRevenue), style: AppTextStyles.bodySemiBold(ctx)),
                ]),
              )),
      ]),
    );
  }

  // ── Section 4: Voids & Refunds ────────────────────────────────────────
  Widget _voidsSection(BuildContext ctx, EndOfDayState s, Color tp, Color ts) {
    final vr = s.voidRefund;
    final hasData = vr.voidCount > 0 || vr.refundCount > 0;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle(ctx, Icons.cancel_outlined, 'Voids & Refunds', AppColors.errorLight),
        const SizedBox(height: AppSpacing.sm),
        if (!hasData)
          _emptyLabel(ctx, 'No voids or refunds today')
        else ...[
          _metricRow(ctx, 'Voided Orders', '${vr.voidCount}', CurrencyFormatter.format(vr.voidTotal), tp, ts),
          _metricRow(ctx, 'Refunded Orders', '${vr.refundCount}', CurrencyFormatter.format(vr.refundTotal), tp, ts),
          Divider(color: ts.withValues(alpha: 0.2), height: AppSpacing.md),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total Loss', style: AppTextStyles.bodySemiBold(ctx).copyWith(color: AppColors.errorLight)),
            Text(CurrencyFormatter.format(vr.totalLoss),
                style: AppTextStyles.bodySemiBold(ctx).copyWith(color: AppColors.errorLight)),
          ]),
        ],
      ]),
    );
  }



  // ── Section 6: Cash Reconciliation ────────────────────────────────────
  Widget _cashReconSection(BuildContext ctx, EndOfDayState s, bool isDark, Color accent, Color tp, Color ts) {
    final recon = s.cashRecon;
    final diff = recon.difference;
    final diffColor = recon.actualCash == null
        ? ts
        : (recon.isMatch ? AppColors.successLight : AppColors.errorLight);

    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle(ctx, Icons.account_balance_wallet_outlined, 'Cash Reconciliation', accent),
        const SizedBox(height: AppSpacing.sm),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Expected Cash', style: AppTextStyles.body(ctx)),
          Text(CurrencyFormatter.format(recon.expectedCash), style: AppTextStyles.bodySemiBold(ctx)),
        ]),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _cashCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.body(ctx),
          decoration: InputDecoration(
            labelText: 'Actual Cash Count',
            labelStyle: AppTextStyles.caption(ctx).copyWith(color: ts),
            prefixText: '₱ ',
            prefixStyle: AppTextStyles.bodySemiBold(ctx).copyWith(color: accent),
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            border: OutlineInputBorder(borderRadius: AppRadius.mediumBR, borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          ),
          onChanged: (v) {
            final amount = double.tryParse(v.replaceAll(',', ''));
            if (amount != null) ref.read(endOfDayProvider.notifier).setActualCash(amount);
          },
        ),
        if (recon.actualCash != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Difference', style: AppTextStyles.bodySemiBold(ctx).copyWith(color: diffColor)),
            Text(
              '${diff >= 0 ? '+' : ''}${CurrencyFormatter.format(diff)}',
              style: AppTextStyles.bodySemiBold(ctx).copyWith(color: diffColor),
            ),
          ]),
        ],
      ]),
    );
  }

  // ── Action Bar ────────────────────────────────────────────────────────
  Widget _actionBar(BuildContext ctx, EndOfDayState s, Color accent) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final barBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: barBg, boxShadow: AppShadow.level3),
      child: Row(children: [
        // Copy
        _actionBtn(ctx, Icons.copy_rounded, 'Copy', () => _copyReport(ctx, s)),
        const SizedBox(width: AppSpacing.xs),
        // Email
        _actionBtn(ctx, Icons.email_outlined, 'Email', () => _emailReport(ctx, s)),
        const SizedBox(width: AppSpacing.xs),
        // Save & Close
        Expanded(
          child: SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: s.isDayClosed ? null : () => _saveAndClose(ctx),
              icon: Icon(s.isDayClosed ? Icons.check_circle : Icons.lock_rounded,
                  color: Colors.white, size: 18),
              label: Text(s.isDayClosed ? 'Day Closed' : 'Save & Close Day',
                  style: AppTextStyles.bodySemiBold(ctx).copyWith(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: s.isDayClosed ? AppColors.successLight : accent,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _actionBtn(BuildContext ctx, IconData icon, String label, VoidCallback onTap) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final ts = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44, width: 56,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: AppRadius.mediumBR,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: ts),
          Text(label, style: AppTextStyles.caption(ctx).copyWith(color: ts, fontSize: 9)),
        ]),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────
  Widget _sectionTitle(BuildContext ctx, IconData icon, String title, Color color) {
    return Row(children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: AppSpacing.xs),
      Text(title, style: AppTextStyles.bodySemiBold(ctx)),
    ]);
  }

  Widget _kpi(BuildContext ctx, String value, String label, Color color) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: AppTextStyles.priceSmall(ctx).copyWith(color: color),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(label, style: AppTextStyles.captionSecondary(ctx)),
      ]),
    );
  }

  Widget _emptyLabel(BuildContext ctx, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Text(text, style: AppTextStyles.captionSecondary(ctx)),
    );
  }

  Widget _metricRow(BuildContext ctx, String label, String count, String amount, Color tp, Color ts) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Expanded(child: Text(label, style: AppTextStyles.body(ctx))),
        Text(count, style: AppTextStyles.caption(ctx).copyWith(color: ts)),
        const SizedBox(width: AppSpacing.sm),
        Text(amount, style: AppTextStyles.bodySemiBold(ctx)),
      ]),
    );
  }
  // ── Copy Report ────────────────────────────────────────────────────────
  void _copyReport(BuildContext ctx, EndOfDayState s) {
    final text = _buildClipboardText(s);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('Report copied to clipboard',
            style: AppTextStyles.bodySemiBold(ctx).copyWith(color: Colors.white)),
        backgroundColor: AppColors.successLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _buildClipboardText(EndOfDayState s) {
    final buf = StringBuffer();
    final dateFmt = DateFormat('EEEE, MMM d, yyyy');
    buf.writeln('═══ SUKLI POS — END OF DAY REPORT ═══');
    buf.writeln('Date: ${dateFmt.format(s.reportDate)}');
    buf.writeln();

    // Sales Overview
    buf.writeln('── Sales Overview ──');
    buf.writeln('Total Sales: ${CurrencyFormatter.format(s.totalSales)}');
    buf.writeln('Orders: ${s.orderCount}');
    buf.writeln('Avg Order: ${CurrencyFormatter.format(s.avgOrderValue)}');
    if (s.paymentBreakdown.isNotEmpty) {
      buf.writeln();
      buf.writeln('Payment Methods:');
      for (final p in s.paymentBreakdown) {
        buf.writeln('  ${p.label}: ${p.count}x — ${CurrencyFormatter.format(p.total)}');
      }
    }
    buf.writeln();

    // Top Selling Items
    buf.writeln('── Top Selling Items ──');
    if (s.topItems.isEmpty) {
      buf.writeln('  No items sold');
    } else {
      for (var i = 0; i < s.topItems.length; i++) {
        final item = s.topItems[i];
        buf.writeln('  ${i + 1}. ${item.name} — ×${item.quantity} — ${CurrencyFormatter.format(item.revenue)}');
      }
    }
    buf.writeln();

    // Category Performance
    buf.writeln('── Category Performance ──');
    if (s.categoryPerformance.isEmpty) {
      buf.writeln('  No category data');
    } else {
      for (final c in s.categoryPerformance) {
        buf.writeln('  ${c.categoryName}: ${c.orderCount} orders — ${CurrencyFormatter.format(c.totalRevenue)}');
      }
    }
    buf.writeln();

    // Voids & Refunds
    buf.writeln('── Voids & Refunds ──');
    buf.writeln('Voids: ${s.voidRefund.voidCount} (${CurrencyFormatter.format(s.voidRefund.voidTotal)})');
    buf.writeln('Refunds: ${s.voidRefund.refundCount} (${CurrencyFormatter.format(s.voidRefund.refundTotal)})');
    buf.writeln('Total Loss: ${CurrencyFormatter.format(s.voidRefund.totalLoss)}');
    buf.writeln();

    // Cash Reconciliation
    buf.writeln('── Cash Reconciliation ──');
    buf.writeln('Expected: ${CurrencyFormatter.format(s.cashRecon.expectedCash)}');
    if (s.cashRecon.actualCash != null) {
      buf.writeln('Actual: ${CurrencyFormatter.format(s.cashRecon.actualCash!)}');
      final diff = s.cashRecon.difference;
      buf.writeln('Difference: ${diff >= 0 ? '+' : ''}${CurrencyFormatter.format(diff)}');
    }
    buf.writeln();
    buf.writeln('Generated by Sukli POS');
    return buf.toString();
  }

  // ── Save & Close ──────────────────────────────────────────────────────
  Future<void> _saveAndClose(BuildContext ctx) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: Text('Close Day?', style: AppTextStyles.h3(c)),
        content: Text('This will mark today as closed. You can still view the report afterwards.',
            style: AppTextStyles.body(c)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Close Day')),
        ],
      ),
    );
    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'eod_closed_${DateFormat('yyyy-MM-dd').format(DateTime.now())}';
    await prefs.setBool(key, true);

    ref.read(endOfDayProvider.notifier).closeDayConfirmed();

    // Export PDF
    await _savePdf(ctx, ref.read(endOfDayProvider));

    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text('Day closed & report saved', style: AppTextStyles.bodySemiBold(ctx).copyWith(color: Colors.white)),
          backgroundColor: AppColors.successLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
        ),
      );
    }
  }

  // ── PDF Generation ────────────────────────────────────────────────────
  Future<String?> _savePdf(BuildContext ctx, EndOfDayState s) async {
    final doc = pw.Document();
    final dateFmt = DateFormat('MMM d, yyyy');

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (c) => [
        pw.Text('Sukli POS — End of Day Report', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text('Date: ${dateFmt.format(s.reportDate)}'),
        pw.SizedBox(height: 12),
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Text('Sales Overview', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround, children: [
          _pKpi('Total Sales', CurrencyFormatter.format(s.totalSales)),
          _pKpi('Orders', '${s.orderCount}'),
          _pKpi('Avg Order', CurrencyFormatter.format(s.avgOrderValue)),
        ]),
        if (s.paymentBreakdown.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Method', 'Count', 'Total'],
            data: s.paymentBreakdown.map((p) => [p.label, '${p.count}', CurrencyFormatter.format(p.total)]).toList(),
          ),
        ],
        pw.SizedBox(height: 12),
        if (s.topItems.isNotEmpty) ...[
          pw.Text('Top Selling Items', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.TableHelper.fromTextArray(
            headers: ['#', 'Item', 'Qty', 'Revenue'],
            data: s.topItems.asMap().entries.map((e) => [
              '${e.key + 1}', e.value.name, '${e.value.quantity}', CurrencyFormatter.format(e.value.revenue),
            ]).toList(),
          ),
          pw.SizedBox(height: 12),
        ],
        pw.Text('Voids & Refunds', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text('Voids: ${s.voidRefund.voidCount} (${CurrencyFormatter.format(s.voidRefund.voidTotal)})'),
        pw.Text('Refunds: ${s.voidRefund.refundCount} (${CurrencyFormatter.format(s.voidRefund.refundTotal)})'),
        pw.SizedBox(height: 12),
        pw.Text('Cash Reconciliation', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text('Expected: ${CurrencyFormatter.format(s.cashRecon.expectedCash)}'),
        if (s.cashRecon.actualCash != null) ...[
          pw.Text('Actual: ${CurrencyFormatter.format(s.cashRecon.actualCash!)}'),
          pw.Text('Difference: ${CurrencyFormatter.format(s.cashRecon.difference)}'),
        ],
        pw.SizedBox(height: 16),
        pw.Text('Generated by Sukli POS', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
      ],
    ));

    final fileName = 'sukli-eod-${DateFormat('yyyy-MM-dd').format(s.reportDate)}.pdf';
    Directory? dir;
    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) dir = await getExternalStorageDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }
    if (dir == null) return null;

    final path = '${dir.path}/$fileName';
    await File(path).writeAsBytes(await doc.save());
    return path;
  }

  pw.Widget _pKpi(String label, String value) {
    return pw.Column(children: [
      pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 2),
      pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
    ]);
  }

  // ── Email ─────────────────────────────────────────────────────────────
  Future<void> _emailReport(BuildContext ctx, EndOfDayState s) async {
    final path = await _savePdf(ctx, s);
    final subject = Uri.encodeComponent('Sukli POS — EOD Report ${DateFormat('MMM d, yyyy').format(s.reportDate)}');
    final body = Uri.encodeComponent(
        'End of Day Report\nTotal Sales: ${CurrencyFormatter.format(s.totalSales)}\nOrders: ${s.orderCount}');
    final uri = Uri.parse('mailto:?subject=$subject&body=$body');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
    if (ctx.mounted && path != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text('Report saved to Downloads', style: AppTextStyles.bodySemiBold(ctx).copyWith(color: Colors.white)),
          backgroundColor: AppColors.successLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
        ),
      );
    }
  }
}
