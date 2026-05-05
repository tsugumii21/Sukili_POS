import 'dart:convert';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../utils/currency_formatter.dart';
import '../../shared/isar_collections/order_collection.dart';

/// Abstract contract for thermal receipt printing.
abstract class PrinterService {
  /// Generates ESC/POS bytes for the given order receipt.
  Future<List<int>> buildReceiptBytes(OrderCollection order);

  /// Attempts to deliver the receipt to a connected thermal printer.
  /// Returns [true] if printing succeeded, [false] if no printer was found
  /// or the operation failed (caller should show a "no printer" snackbar).
  Future<bool> printReceipt(OrderCollection order);
}

/// Concrete implementation using [esc_pos_utils_plus] for byte generation.
///
/// Actual Bluetooth/USB delivery requires a platform plugin such as
/// `print_bluetooth_thermal` or `flutter_blue_plus` wired in a future part.
/// Until then, [printReceipt] always returns `false` so the UI gracefully
/// shows the "No printer connected. Receipt saved." snackbar.
class ThermalPrinterService implements PrinterService {
  ThermalPrinterService._();
  static final ThermalPrinterService instance = ThermalPrinterService._();

  static final _dateFormat = DateFormat('MMM dd, yyyy  hh:mm a');

  @override
  Future<List<int>> buildReceiptBytes(OrderCollection order) async {
    final profile = await CapabilityProfile.load();
    final gen = Generator(PaperSize.mm80, profile);
    final bytes = <int>[];

    final dateStr = _dateFormat.format(order.orderedAt);

    // ── Header ────────────────────────────────────────────────────────────
    bytes.addAll(gen.text(
      AppConstants.appName,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    ));
    bytes.addAll(gen.text(
      'OFFICIAL RECEIPT',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    ));
    bytes.addAll(gen.hr());
    bytes.addAll(gen.text(
      dateStr,
      styles: const PosStyles(align: PosAlign.center),
    ));
    bytes.addAll(gen.text('Order: ${order.orderNumber}'));
    bytes.addAll(gen.text('Cashier: ${order.cashierName}'));
    bytes.addAll(gen.hr());

    // ── Items ─────────────────────────────────────────────────────────────
    for (final jsonStr in order.orderItemsJson) {
      final item = jsonDecode(jsonStr) as Map<String, dynamic>;
      final name = (item['itemName'] as String?) ?? '';
      final qty = (item['quantity'] as int?) ?? 1;
      final variant = item['variantName'] as String?;
      final subtotal = ((item['subtotal'] as num?) ?? 0).toDouble();

      final label = variant != null ? '$name ($variant)' : name;
      final truncated =
          label.length > 22 ? '${label.substring(0, 19)}...' : label;

      bytes.addAll(gen.row([
        PosColumn(text: '$truncated x$qty', width: 8),
        PosColumn(
          text: CurrencyFormatter.format(subtotal),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]));
    }

    bytes.addAll(gen.hr());

    // ── Totals ────────────────────────────────────────────────────────────
    bytes.addAll(gen.row([
      PosColumn(text: 'Subtotal', width: 7),
      PosColumn(
        text: CurrencyFormatter.format(order.subtotal),
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]));

    if (order.discountAmount > 0) {
      bytes.addAll(gen.row([
        PosColumn(text: 'Discount', width: 7),
        PosColumn(
          text: '-${CurrencyFormatter.format(order.discountAmount)}',
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]));
    }

    bytes.addAll(gen.row([
      PosColumn(
        text: 'TOTAL',
        width: 7,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: CurrencyFormatter.format(order.totalAmount),
        width: 5,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]));

    bytes.addAll(gen.hr());

    // ── Payment ───────────────────────────────────────────────────────────
    bytes.addAll(
      gen.text('Payment: ${order.paymentMethod.toUpperCase()}'),
    );
    bytes.addAll(gen.row([
      PosColumn(text: 'Amount Tendered', width: 7),
      PosColumn(
        text: CurrencyFormatter.format(order.amountTendered),
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]));

    if (order.changeAmount > 0) {
      bytes.addAll(gen.row([
        PosColumn(text: 'Change', width: 7),
        PosColumn(
          text: CurrencyFormatter.format(order.changeAmount),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]));
    }

    bytes.addAll(gen.hr());

    // ── Footer ────────────────────────────────────────────────────────────
    bytes.addAll(gen.text(
      'Thank you for your order!',
      styles: const PosStyles(align: PosAlign.center),
    ));
    bytes.addAll(gen.text(
      'Powered by Sukli POS',
      styles: const PosStyles(align: PosAlign.center),
    ));
    bytes.addAll(gen.feed(3));
    bytes.addAll(gen.cut());

    return bytes;
  }

  @override
  Future<bool> printReceipt(OrderCollection order) async {
    try {
      // Receipt bytes are generated and ready — wire a Bluetooth/USB plugin
      // (e.g. print_bluetooth_thermal) here to deliver them to a printer.
      await buildReceiptBytes(order);
      return false; // no printer plugin connected yet
    } catch (_) {
      return false;
    }
  }
}

/// Riverpod provider exposing the singleton [ThermalPrinterService].
final printerServiceProvider = Provider<PrinterService>(
  (_) => ThermalPrinterService.instance,
);
