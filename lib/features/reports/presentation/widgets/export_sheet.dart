import 'dart:io';

import 'package:excel/excel.dart' as xl;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../providers/reports_provider.dart';

/// Export bottom sheet — PDF and Excel export options.
class ExportSheet extends StatelessWidget {
  const ExportSheet({super.key, required this.state});
  final ReportState state;

  static Future<void> show(BuildContext context, ReportState state) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.38,
        minChildSize: 0.32,
        maxChildSize: 0.45,
        snap: true,
        builder: (ctx, scrollCtrl) => ExportSheet(state: state),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: AppRadius.large),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: textSecondary.withValues(alpha: 0.3),
                borderRadius: AppRadius.pillBR,
              ),
            ),
          ),
          Text('Export Report', style: AppTextStyles.h3(context)),
          Text(state.periodLabel,
              style: AppTextStyles.captionSecondary(context)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              // PDF
              Expanded(
                child: AppCard(
                  onTap: () => _exportPdf(context),
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg, horizontal: AppSpacing.md),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.errorLight.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.picture_as_pdf_rounded,
                            size: 32, color: AppColors.errorLight),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text('PDF Report',
                          style: AppTextStyles.bodySemiBold(context)),
                      const SizedBox(height: 4),
                      Text('Full report\nwith charts',
                          style: AppTextStyles.captionSecondary(context),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Excel
              Expanded(
                child: AppCard(
                  onTap: () => _exportExcel(context),
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg, horizontal: AppSpacing.md),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.successLight.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.table_chart_rounded,
                            size: 32, color: AppColors.successLight),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Excel File',
                          style: AppTextStyles.bodySemiBold(context)),
                      const SizedBox(height: 4),
                      Text('3 sheets:\nSummary, Orders,\nCashier',
                          style: AppTextStyles.captionSecondary(context),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── PDF Export ──────────────────────────────────────────────────────────────

  Future<void> _exportPdf(BuildContext context) async {
    Navigator.of(context).pop();
    final orders = state.orders;
    final topItems = state.topItems;
    final dateFmt = DateFormat('MMM d, yyyy h:mm a');

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Text('Sukli POS — Sales Report',
              style:
                  pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.Text(
              'Period: ${state.periodLabel}  |  Generated: ${dateFmt.format(DateTime.now())}'),
          pw.SizedBox(height: 16),
          pw.Divider(),
          pw.SizedBox(height: 8),
          // KPIs
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _pdfKpi(
                  'Total Revenue', CurrencyFormatter.format(state.totalSales)),
              _pdfKpi('Total Orders', '${state.totalOrders}'),
              _pdfKpi('Average Order',
                  CurrencyFormatter.format(state.averageOrderValue)),
            ],
          ),
          pw.SizedBox(height: 16),
          // Orders table
          pw.Text('Order Details',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          if (orders.isNotEmpty)
            pw.TableHelper.fromTextArray(
              headers: [
                'Order #',
                'Cashier',
                'Date & Time',
                'Payment',
                'Total'
              ],
              data: orders
                  .map((o) => [
                        o.orderNumber,
                        o.cashierName,
                        dateFmt.format(o.orderedAt),
                        o.paymentMethod.toUpperCase(),
                        CurrencyFormatter.format(o.totalAmount),
                      ])
                  .toList(),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration:
                  pw.BoxDecoration(color: PdfColor.fromHex('#6B2C33')),
              oddRowDecoration:
                  pw.BoxDecoration(color: PdfColor.fromHex('#FAF6F1')),
            )
          else
            pw.Text('No orders in this period.'),
          pw.SizedBox(height: 16),
          // Top items
          if (topItems.isNotEmpty) ...[
            pw.Text('Top Selling Items',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['Rank', 'Item Name', 'Qty Sold', 'Revenue'],
              data: topItems
                  .asMap()
                  .entries
                  .map((e) => [
                        '#${e.key + 1}',
                        e.value.name,
                        '${e.value.qtySold}',
                        CurrencyFormatter.format(e.value.revenue),
                      ])
                  .toList(),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration:
                  pw.BoxDecoration(color: PdfColor.fromHex('#6B2C33')),
            ),
          ],
          pw.SizedBox(height: 24),
          pw.Text('Generated by Sukli POS v1.0',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
        ],
      ),
    );

    final pdfBytes = await doc.save();
    final fileName =
        'sukli-report-${DateFormat('yyyy-MM-dd-HHmmss').format(DateTime.now())}.pdf';
    Directory? downloadsDir;

    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        downloadsDir = await getExternalStorageDirectory();
      }
    } else {
      downloadsDir = await getApplicationDocumentsDirectory();
    }

    if (downloadsDir == null) return;

    final filePath = '${downloadsDir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saved to Downloads/$fileName',
            style: AppTextStyles.bodySemiBold(context)
                .copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.successLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  pw.Widget _pdfKpi(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(value,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  // ── Excel Export ────────────────────────────────────────────────────────────

  Future<void> _exportExcel(BuildContext context) async {
    Navigator.of(context).pop();
    final orders = state.orders;
    final dateFmt = DateFormat('MMM d, yyyy');
    final timeFmt = DateFormat('h:mm a');
    final excel = xl.Excel.createExcel();

    // ── Sheet 1: Summary ──────────────────────────────────────────────────
    final summary = excel['Summary'];
    summary.appendRow([xl.TextCellValue('Sukli POS — Sales Report')]);
    summary.appendRow([
      xl.TextCellValue(
          'Period: ${state.periodLabel}   Generated: ${dateFmt.format(DateTime.now())}')
    ]);
    summary.appendRow([xl.TextCellValue('')]);
    summary.appendRow([xl.TextCellValue('Metric'), xl.TextCellValue('Value')]);
    summary.appendRow([
      xl.TextCellValue('Total Revenue'),
      xl.TextCellValue(CurrencyFormatter.format(state.totalSales)),
    ]);
    summary.appendRow([
      xl.TextCellValue('Total Orders'),
      xl.IntCellValue(state.totalOrders),
    ]);
    summary.appendRow([
      xl.TextCellValue('Average Order'),
      xl.TextCellValue(CurrencyFormatter.format(state.averageOrderValue)),
    ]);
    summary.appendRow([
      xl.TextCellValue('Top Cashier'),
      xl.TextCellValue(state.topCashierName),
    ]);
    summary.appendRow([xl.TextCellValue('')]);
    summary.appendRow([xl.TextCellValue('Payment Breakdown')]);
    summary.appendRow([
      xl.TextCellValue('Method'),
      xl.TextCellValue('Amount'),
      xl.TextCellValue('% of Total'),
    ]);
    for (final p in state.paymentBreakdown) {
      summary.appendRow([
        xl.TextCellValue(p.methodLabel),
        xl.TextCellValue(CurrencyFormatter.format(p.amount)),
        xl.TextCellValue('${p.percentage.toStringAsFixed(1)}%'),
      ]);
    }

    // ── Sheet 2: Orders ───────────────────────────────────────────────────
    final ordersSheet = excel['Orders'];
    ordersSheet.appendRow([
      xl.TextCellValue('Order #'),
      xl.TextCellValue('Cashier'),
      xl.TextCellValue('Date'),
      xl.TextCellValue('Time'),
      xl.TextCellValue('Payment'),
      xl.TextCellValue('Total'),
      xl.TextCellValue('Status'),
    ]);
    for (final o in orders) {
      ordersSheet.appendRow([
        xl.TextCellValue(o.orderNumber),
        xl.TextCellValue(o.cashierName),
        xl.TextCellValue(dateFmt.format(o.orderedAt)),
        xl.TextCellValue(timeFmt.format(o.orderedAt)),
        xl.TextCellValue(o.paymentMethod.toUpperCase()),
        xl.TextCellValue(CurrencyFormatter.format(o.totalAmount)),
        xl.TextCellValue(o.status),
      ]);
    }

    // ── Sheet 3: Cashier Summary ──────────────────────────────────────────
    final cashierSheet = excel['Cashier Summary'];
    cashierSheet.appendRow([
      xl.TextCellValue('Cashier Name'),
      xl.TextCellValue('Total Orders'),
      xl.TextCellValue('Total Revenue'),
      xl.TextCellValue('Avg Order Value'),
      xl.TextCellValue('Most Used Payment'),
    ]);
    // Group by cashier
    final cashierMap = <String, List<dynamic>>{};
    for (final o in orders) {
      cashierMap.putIfAbsent(o.cashierName, () => []);
      cashierMap[o.cashierName]!.add(o);
    }
    final cashierEntries = cashierMap.entries.toList()
      ..sort((a, b) {
        final ra = (a.value as List)
            .fold<double>(0, (s, o) => s + (o.totalAmount as double));
        final rb = (b.value as List)
            .fold<double>(0, (s, o) => s + (o.totalAmount as double));
        return rb.compareTo(ra);
      });
    for (final entry in cashierEntries) {
      final list = entry.value;
      final totalRev =
          list.fold<double>(0, (s, o) => s + (o.totalAmount as double));
      final avgVal = list.isEmpty ? 0.0 : totalRev / list.length;
      // Most used payment
      final payMap = <String, int>{};
      for (final o in list) {
        final m = (o.paymentMethod as String).toUpperCase();
        payMap[m] = (payMap[m] ?? 0) + 1;
      }
      final topPay =
          payMap.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      cashierSheet.appendRow([
        xl.TextCellValue(entry.key),
        xl.IntCellValue(list.length),
        xl.TextCellValue(CurrencyFormatter.format(totalRev)),
        xl.TextCellValue(CurrencyFormatter.format(avgVal)),
        xl.TextCellValue(topPay),
      ]);
    }

    // Remove default Sheet1 if it exists
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    // Save directly to Downloads folder
    final fileName =
        'sukli-report-${DateFormat('yyyy-MM-dd-HHmmss').format(DateTime.now())}.xlsx';
    Directory? downloadsDir;

    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        downloadsDir = await getExternalStorageDirectory();
      }
    } else {
      downloadsDir = await getApplicationDocumentsDirectory();
    }

    if (downloadsDir == null) return;

    final filePath = '${downloadsDir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved to Downloads/$fileName',
              style: AppTextStyles.bodySemiBold(context)
                  .copyWith(color: Colors.white)),
          backgroundColor: AppColors.successLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
