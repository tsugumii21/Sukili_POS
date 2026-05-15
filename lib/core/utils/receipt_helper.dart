import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../shared/isar_collections/order_collection.dart';
import '../../shared/isar_collections/store_collection.dart';

class ReceiptHelper {
  /// Generates a PDF receipt for the given order and store.
  static Future<Uint8List> generateReceiptPdf({
    required OrderCollection order,
    required StoreCollection store,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final currencyFormat = NumberFormat.currency(symbol: 'P', decimalDigits: 2);

    // Load logo if available
    pw.ImageProvider? logoImage;
    if (store.logoUrl != null && store.logoUrl!.isNotEmpty) {
      try {
        logoImage = await networkImage(store.logoUrl!);
      } catch (_) {
        // Fallback to no logo if download fails
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          80 * PdfPageFormat.mm, // Standard thermal paper width
          double.infinity,
          marginAll: 5 * PdfPageFormat.mm,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // --- Store Info ---
              if (logoImage != null)
                pw.Container(
                  height: 40,
                  width: 40,
                  child: pw.Image(logoImage),
                ),
              pw.SizedBox(height: 4),
              pw.Text(
                store.name.toUpperCase(),
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // --- Order Metadata ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('OR#: ${order.orderNumber}',
                      style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(dateFormat.format(order.orderedAt),
                      style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('Cashier: ${order.cashierName}',
                    style: const pw.TextStyle(fontSize: 8)),
              ),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // --- Items Table ---
              pw.SizedBox(height: 4),
              _buildItemsTable(order.orderItemsJson, currencyFormat),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // --- Totals ---
              pw.SizedBox(height: 4),
              _buildTotalRow('Subtotal', order.subtotal, currencyFormat),
              if (order.discountAmount > 0)
                _buildTotalRow(
                  'Discount (${order.discountReason ?? 'Discount'})',
                  -order.discountAmount,
                  currencyFormat,
                  isDiscount: true,
                ),
              pw.Divider(thickness: 0.5),
              _buildTotalRow('TOTAL', order.totalAmount, currencyFormat,
                  isBold: true, fontSize: 12),
              pw.SizedBox(height: 4),
              _buildTotalRow('Tendered', order.amountTendered, currencyFormat),
              _buildTotalRow('Change', order.changeAmount, currencyFormat),
              pw.SizedBox(height: 8),

              // --- Footer ---
              pw.Text(
                'Payment Method: ${order.paymentMethod.toUpperCase()}',
                style:
                    pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Thank you for shopping at ${store.name}!',
                style: pw.TextStyle(fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'This serves as your Official Receipt.',
                style: pw.TextStyle(fontSize: 7),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildItemsTable(
      List<String> itemsJson, NumberFormat currency) {
    final List<Map<String, dynamic>> items =
        itemsJson.map((j) => jsonDecode(j) as Map<String, dynamic>).toList();

    return pw.Column(
      children: items.map((item) {
        final name = item['name'] ?? 'Unknown';
        final qty = (item['quantity'] as num).toInt();
        final price = (item['price'] as num).toDouble();
        final total = (item['totalPrice'] as num).toDouble();

        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(name,
                  style: pw.TextStyle(
                      fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('$qty x ${currency.format(price)}',
                      style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(currency.format(total),
                      style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildTotalRow(
    String label,
    double amount,
    NumberFormat currency, {
    bool isBold = false,
    double fontSize = 9,
    bool isDiscount = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            currency.format(amount),
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isDiscount ? PdfColors.grey700 : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Directly prints the receipt to a thermal printer or system dialog.
  static Future<void> printReceipt({
    required OrderCollection order,
    required StoreCollection store,
  }) async {
    final pdfBytes = await generateReceiptPdf(order: order, store: store);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Receipt_${order.orderNumber}',
    );
  }
}
