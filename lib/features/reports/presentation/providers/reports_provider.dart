import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';

import '../../../../shared/isar_collections/order_collection.dart';
import '../../../../shared/providers/isar_provider.dart';
import '../../../../shared/providers/store_provider.dart';

export 'reports_provider.dart';

enum ReportPeriod { day, week, month, year, custom }

// ── Data models for chart sections ────────────────────────────────────────────

class PaymentBreakdownItem {
  final String method;
  final double amount;
  final double percentage;

  const PaymentBreakdownItem({
    required this.method,
    required this.amount,
    required this.percentage,
  });

  String get methodLabel {
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
        return 'Other';
    }
  }
}

class TopItem {
  final String name;
  final int qtySold;
  final double revenue;

  const TopItem({
    required this.name,
    required this.qtySold,
    required this.revenue,
  });
}

// ── ReportState ────────────────────────────────────────────────────────────────

class ReportState {
  final ReportPeriod period;
  final DateTime? customStart;
  final DateTime? customEnd;
  final List<OrderCollection> orders;

  const ReportState({
    required this.period,
    this.customStart,
    this.customEnd,
    this.orders = const [],
  });

  ReportState copyWith({
    ReportPeriod? period,
    DateTime? customStart,
    DateTime? customEnd,
    List<OrderCollection>? orders,
  }) {
    return ReportState(
      period: period ?? this.period,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
      orders: orders ?? this.orders,
    );
  }

  // ── KPI getters ──────────────────────────────────────────────────────────

  double get totalSales => orders.fold(0, (sum, o) => sum + o.totalAmount);
  int get totalOrders => orders.length;
  double get averageOrderValue =>
      totalOrders == 0 ? 0 : totalSales / totalOrders;

  /// Returns the cashier name with the most orders, or '—' if none.
  String get topCashierName {
    if (orders.isEmpty) return '—';
    final counts = <String, int>{};
    for (final o in orders) {
      counts[o.cashierName] = (counts[o.cashierName] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  // ── Payment breakdown ────────────────────────────────────────────────────

  List<PaymentBreakdownItem> get paymentBreakdown {
    if (orders.isEmpty) return [];
    final totals = <String, double>{};
    for (final o in orders) {
      final method = o.paymentMethod.toLowerCase();
      totals[method] = (totals[method] ?? 0) + o.totalAmount;
    }
    final grandTotal = totals.values.fold(0.0, (a, b) => a + b);
    if (grandTotal == 0) return [];
    return totals.entries
        .map((e) => PaymentBreakdownItem(
              method: e.key,
              amount: e.value,
              percentage: (e.value / grandTotal) * 100,
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  // ── Top items ────────────────────────────────────────────────────────────

  /// Parses orderItemsJson and returns top 5 items by revenue.
  List<TopItem> get topItems {
    if (orders.isEmpty) return [];
    final revenue = <String, double>{};
    final qty = <String, int>{};

    for (final order in orders) {
      for (final json in order.orderItemsJson) {
        // Each entry is a JSON-like "name:qty:price" or full JSON.
        try {
          final nameMatch = RegExp(r'"name"\s*:\s*"([^"]+)"').firstMatch(json);
          final priceMatch =
              RegExp(r'"totalPrice"\s*:\s*([\d.]+)').firstMatch(json);
          final qtyMatch = RegExp(r'"quantity"\s*:\s*(\d+)').firstMatch(json);

          if (nameMatch == null) continue;
          final name = nameMatch.group(1)!;
          final price = double.tryParse(priceMatch?.group(1) ?? '0') ?? 0;
          final count = int.tryParse(qtyMatch?.group(1) ?? '1') ?? 1;

          revenue[name] = (revenue[name] ?? 0) + price;
          qty[name] = (qty[name] ?? 0) + count;
        } catch (_) {
          continue;
        }
      }
    }

    final items = revenue.entries
        .map((e) =>
            TopItem(name: e.key, qtySold: qty[e.key] ?? 0, revenue: e.value))
        .toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    return items.take(5).toList();
  }

  // ── Revenue chart spots ──────────────────────────────────────────────────

  List<FlSpot> get revenueSpots {
    if (orders.isEmpty) return [const FlSpot(0, 0)];

    switch (period) {
      case ReportPeriod.day:
        return _hourlySpots();
      case ReportPeriod.week:
        return _dailySpots(7);
      case ReportPeriod.month:
        return _dailySpots(30);
      case ReportPeriod.year:
        return _monthlySpots();
      case ReportPeriod.custom:
        final start = customStart;
        final end = customEnd;
        if (start == null || end == null) return [const FlSpot(0, 0)];
        final days = end.difference(start).inDays + 1;
        return days <= 31 ? _dailySpots(days) : _monthlySpots();
    }
  }

  List<FlSpot> _hourlySpots() {
    final buckets = List<double>.filled(24, 0);
    final now = DateTime.now();
    for (final o in orders) {
      if (o.orderedAt.year == now.year &&
          o.orderedAt.month == now.month &&
          o.orderedAt.day == now.day) {
        buckets[o.orderedAt.hour] += o.totalAmount;
      }
    }
    return List.generate(24, (i) => FlSpot(i.toDouble(), buckets[i]));
  }

  List<FlSpot> _dailySpots(int days) {
    final buckets = List<double>.filled(days, 0);
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days - 1));
    for (final o in orders) {
      final diff = o.orderedAt.difference(start).inDays;
      if (diff >= 0 && diff < days) {
        buckets[diff] += o.totalAmount;
      }
    }
    return List.generate(days, (i) => FlSpot(i.toDouble(), buckets[i]));
  }

  List<FlSpot> _monthlySpots() {
    final buckets = List<double>.filled(12, 0);
    for (final o in orders) {
      final month = o.orderedAt.month - 1;
      if (month >= 0 && month < 12) {
        buckets[month] += o.totalAmount;
      }
    }
    return List.generate(12, (i) => FlSpot(i.toDouble(), buckets[i]));
  }

  // ── Period label ─────────────────────────────────────────────────────────

  String get periodLabel {
    switch (period) {
      case ReportPeriod.day:
        return 'Today';
      case ReportPeriod.week:
        return 'This Week';
      case ReportPeriod.month:
        return DateFormat('MMMM yyyy').format(DateTime.now());
      case ReportPeriod.year:
        return '${DateTime.now().year}';
      case ReportPeriod.custom:
        if (customStart == null || customEnd == null) return 'Custom';
        final fmt = DateFormat('MMM d');
        final fmtYear = DateFormat('MMM d, yyyy');
        return '${fmt.format(customStart!)} – ${fmtYear.format(customEnd!)}';
    }
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────────

class ReportsNotifier extends Notifier<ReportState> {
  @override
  ReportState build() {
    final storeId = ref.watch(currentStoreIdProvider);
    if (storeId.isEmpty) return const ReportState(period: ReportPeriod.day);

    _loadData(storeId);
    return const ReportState(period: ReportPeriod.day);
  }

  void setPeriod(
    ReportPeriod period, {
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    final storeId = ref.read(currentStoreIdProvider);
    state = state.copyWith(
      period: period,
      customStart: customStart,
      customEnd: customEnd,
    );
    _loadData(storeId);
  }

  Future<void> _loadData(String storeId) async {
    if (storeId.isEmpty) return;

    final isar = ref.read(isarProvider);
    DateTime start;
    DateTime end = DateTime.now();

    switch (state.period) {
      case ReportPeriod.day:
        start = DateTime(end.year, end.month, end.day);
        break;
      case ReportPeriod.week:
        start = end.subtract(const Duration(days: 7));
        break;
      case ReportPeriod.month:
        start = DateTime(end.year, end.month, 1);
        break;
      case ReportPeriod.year:
        start = DateTime(end.year, 1, 1);
        break;
      case ReportPeriod.custom:
        start = state.customStart ?? end.subtract(const Duration(days: 7));
        end = state.customEnd ?? end;
        break;
    }

    final filteredOrders = await isar.orderCollections
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .orderedAtBetween(start, end)
        .and()
        .isDeletedEqualTo(false)
        .findAll();

    state = state.copyWith(orders: filteredOrders);
  }
}

final reportsProvider =
    NotifierProvider<ReportsNotifier, ReportState>(() => ReportsNotifier());
