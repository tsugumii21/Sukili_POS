import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../../shared/isar_collections/category_collection.dart';
import '../../../../shared/isar_collections/order_collection.dart';
import '../../../../shared/providers/isar_provider.dart';
import '../../../../shared/providers/store_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

/// Payment method breakdown entry.
class PaymentMethodEntry {
  final String method;
  final int count;
  final double total;

  const PaymentMethodEntry({
    required this.method,
    required this.count,
    required this.total,
  });

  String get label {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'gcash':
        return 'GCash';
      case 'maya':
        return 'Maya';
      case 'card':
        return 'Card';
      default:
        return method;
    }
  }
}

/// Top selling item entry.
class TopSellingItem {
  final String name;
  final int quantity;
  final double revenue;

  const TopSellingItem({
    required this.name,
    required this.quantity,
    required this.revenue,
  });
}

/// Category performance entry.
class CategoryPerformance {
  final String categoryName;
  final double totalRevenue;
  final int orderCount;

  const CategoryPerformance({
    required this.categoryName,
    required this.totalRevenue,
    required this.orderCount,
  });
}

/// Voids & refunds summary.
class VoidRefundSummary {
  final int voidCount;
  final double voidTotal;
  final int refundCount;
  final double refundTotal;

  const VoidRefundSummary({
    this.voidCount = 0,
    this.voidTotal = 0,
    this.refundCount = 0,
    this.refundTotal = 0,
  });

  double get totalLoss => voidTotal + refundTotal;
}

/// Cash reconciliation data.
class CashReconciliation {
  final double expectedCash;
  final double? actualCash;

  const CashReconciliation({
    required this.expectedCash,
    this.actualCash,
  });

  double get difference => actualCash != null ? actualCash! - expectedCash : 0;
  bool get isMatch => difference.abs() < 0.01;
}

// ─────────────────────────────────────────────────────────────────────────────
// End of Day State
// ─────────────────────────────────────────────────────────────────────────────

class EndOfDayState {
  final DateTime reportDate;
  final bool isGenerated;
  final bool isLoading;
  final bool isDayClosed;

  // Section 1 — Sales Overview
  final double totalSales;
  final int orderCount;
  final double avgOrderValue;
  final List<PaymentMethodEntry> paymentBreakdown;

  // Section 2 — Top Selling Items
  final List<TopSellingItem> topItems;

  // Section 3 — Category Performance
  final List<CategoryPerformance> categoryPerformance;

  // Section 4 — Voids & Refunds
  final VoidRefundSummary voidRefund;

  // Section 6 — Cash Reconciliation
  final CashReconciliation cashRecon;

  // Raw orders for PDF export
  final List<OrderCollection> orders;

  const EndOfDayState({
    required this.reportDate,
    this.isGenerated = false,
    this.isLoading = false,
    this.isDayClosed = false,
    this.totalSales = 0,
    this.orderCount = 0,
    this.avgOrderValue = 0,
    this.paymentBreakdown = const [],
    this.topItems = const [],
    this.categoryPerformance = const [],
    this.voidRefund = const VoidRefundSummary(),
    this.cashRecon = const CashReconciliation(expectedCash: 0),
    this.orders = const [],
  });

  EndOfDayState copyWith({
    DateTime? reportDate,
    bool? isGenerated,
    bool? isLoading,
    bool? isDayClosed,
    double? totalSales,
    int? orderCount,
    double? avgOrderValue,
    List<PaymentMethodEntry>? paymentBreakdown,
    List<TopSellingItem>? topItems,
    List<CategoryPerformance>? categoryPerformance,
    VoidRefundSummary? voidRefund,
    CashReconciliation? cashRecon,
    List<OrderCollection>? orders,
  }) {
    return EndOfDayState(
      reportDate: reportDate ?? this.reportDate,
      isGenerated: isGenerated ?? this.isGenerated,
      isLoading: isLoading ?? this.isLoading,
      isDayClosed: isDayClosed ?? this.isDayClosed,
      totalSales: totalSales ?? this.totalSales,
      orderCount: orderCount ?? this.orderCount,
      avgOrderValue: avgOrderValue ?? this.avgOrderValue,
      paymentBreakdown: paymentBreakdown ?? this.paymentBreakdown,
      topItems: topItems ?? this.topItems,
      categoryPerformance: categoryPerformance ?? this.categoryPerformance,
      voidRefund: voidRefund ?? this.voidRefund,
      cashRecon: cashRecon ?? this.cashRecon,
      orders: orders ?? this.orders,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class EndOfDayNotifier extends Notifier<EndOfDayState> {
  @override
  EndOfDayState build() {
    // Watch storeId to reset state if store changes
    ref.watch(currentStoreIdProvider);
    return EndOfDayState(reportDate: DateTime.now());
  }

  Isar get _isar => ref.read(isarProvider);

  /// Generate the full end-of-day report from Isar data.
  Future<void> generateReport() async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId.isEmpty) return;

    state = state.copyWith(isLoading: true);

    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    // ── Fetch today's orders for THIS store ──────────────────────────────────
    final allOrders = await _isar.orderCollections
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .orderedAtBetween(dayStart, dayEnd, includeUpper: false)
        .and()
        .isDeletedEqualTo(false)
        .findAll();

    final completedOrders =
        allOrders.where((o) => o.status == 'completed').toList();
    final voidedOrders = allOrders.where((o) => o.status == 'voided').toList();
    final refundedOrders =
        allOrders.where((o) => o.status == 'refunded').toList();

    // ── Section 1: Sales Overview ─────────────────────────────────────────
    final totalSales =
        completedOrders.fold<double>(0, (s, o) => s + o.totalAmount);
    final orderCount = completedOrders.length;
    final avgOrder = orderCount > 0 ? totalSales / orderCount : 0.0;

    // Payment breakdown
    final paymentMap = <String, _PayAgg>{};
    for (final o in completedOrders) {
      final m = o.paymentMethod.toLowerCase();
      paymentMap.putIfAbsent(m, () => _PayAgg());
      paymentMap[m]!.count++;
      paymentMap[m]!.total += o.totalAmount;
    }
    final paymentBreakdown = paymentMap.entries
        .map((e) => PaymentMethodEntry(
              method: e.key,
              count: e.value.count,
              total: e.value.total,
            ))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    // ── Section 2: Top Selling Items ──────────────────────────────────────
    final revenueMap = <String, double>{};
    final qtyMap = <String, int>{};

    for (final order in completedOrders) {
      for (final jsonStr in order.orderItemsJson) {
        try {
          final parsed = jsonDecode(jsonStr);
          if (parsed is Map<String, dynamic>) {
            final name = parsed['name'] as String? ?? 'Unknown';
            final price = (parsed['totalPrice'] as num?)?.toDouble() ?? 0;
            final qty = (parsed['quantity'] as num?)?.toInt() ?? 1;

            revenueMap[name] = (revenueMap[name] ?? 0) + price;
            qtyMap[name] = (qtyMap[name] ?? 0) + qty;
          }
        } catch (_) {
          // Fallback: try regex parse for older format
          final nameMatch =
              RegExp(r'"name"\s*:\s*"([^"]+)"').firstMatch(jsonStr);
          final priceMatch =
              RegExp(r'"totalPrice"\s*:\s*([\d.]+)').firstMatch(jsonStr);
          final qtyMatch =
              RegExp(r'"quantity"\s*:\s*(\d+)').firstMatch(jsonStr);

          if (nameMatch != null) {
            final name = nameMatch.group(1)!;
            final price = double.tryParse(priceMatch?.group(1) ?? '0') ?? 0;
            final qty = int.tryParse(qtyMatch?.group(1) ?? '1') ?? 1;
            revenueMap[name] = (revenueMap[name] ?? 0) + price;
            qtyMap[name] = (qtyMap[name] ?? 0) + qty;
          }
        }
      }
    }

    final topItems = revenueMap.entries
        .map((e) => TopSellingItem(
              name: e.key,
              quantity: qtyMap[e.key] ?? 0,
              revenue: e.value,
            ))
        .toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

    // ── Section 3: Category Performance for THIS store ────────────────────
    final categories = await _isar.categoryCollections
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .isDeletedEqualTo(false)
        .findAll();

    final catNameMap = <String, String>{};
    for (final c in categories) {
      catNameMap[c.syncId] = c.name;
    }

    final catRevenue = <String, double>{};
    final catOrders = <String, Set<int>>{};

    for (final order in completedOrders) {
      for (final jsonStr in order.orderItemsJson) {
        try {
          final parsed = jsonDecode(jsonStr);
          if (parsed is Map<String, dynamic>) {
            final catId = parsed['categoryId'] as String? ?? '';
            final price = (parsed['totalPrice'] as num?)?.toDouble() ?? 0;
            if (catId.isNotEmpty) {
              final catName = catNameMap[catId] ?? 'Uncategorized';
              catRevenue[catName] = (catRevenue[catName] ?? 0) + price;
              catOrders.putIfAbsent(catName, () => {});
              catOrders[catName]!.add(order.id);
            }
          }
        } catch (_) {
          // skip
        }
      }
    }

    final categoryPerformance = catRevenue.entries
        .map((e) => CategoryPerformance(
              categoryName: e.key,
              totalRevenue: e.value,
              orderCount: catOrders[e.key]?.length ?? 0,
            ))
        .toList()
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    // ── Section 4: Voids & Refunds ────────────────────────────────────────
    final voidTotal = voidedOrders.fold<double>(0, (s, o) => s + o.totalAmount);
    final refundTotal = refundedOrders.fold<double>(
        0, (s, o) => s + (o.refundAmount ?? o.totalAmount));

    final voidRefund = VoidRefundSummary(
      voidCount: voidedOrders.length,
      voidTotal: voidTotal,
      refundCount: refundedOrders.length,
      refundTotal: refundTotal,
    );

    // ── Section 6: Cash Reconciliation ────────────────────────────────────
    final expectedCash = completedOrders
        .where((o) => o.paymentMethod.toLowerCase() == 'cash')
        .fold<double>(0, (s, o) => s + o.totalAmount);

    final cashRecon = CashReconciliation(expectedCash: expectedCash);

    state = state.copyWith(
      isGenerated: true,
      isLoading: false,
      totalSales: totalSales,
      orderCount: orderCount,
      avgOrderValue: avgOrder,
      paymentBreakdown: paymentBreakdown,
      topItems: topItems.take(5).toList(),
      categoryPerformance: categoryPerformance,
      voidRefund: voidRefund,
      cashRecon: cashRecon,
      orders: allOrders,
    );
  }

  /// Update the actual cash entered by the user for reconciliation.
  void setActualCash(double amount) {
    state = state.copyWith(
      cashRecon: CashReconciliation(
        expectedCash: state.cashRecon.expectedCash,
        actualCash: amount,
      ),
    );
  }

  /// Mark the day as closed.
  void closeDayConfirmed() {
    state = state.copyWith(isDayClosed: true);
  }
}

/// Helper for aggregating payment counts.
class _PayAgg {
  int count = 0;
  double total = 0;
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final endOfDayProvider =
    NotifierProvider<EndOfDayNotifier, EndOfDayState>(() => EndOfDayNotifier());
