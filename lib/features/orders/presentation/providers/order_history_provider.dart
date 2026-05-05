import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../shared/isar_collections/order_collection.dart';
import '../../../../shared/providers/isar_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Filter model
// ─────────────────────────────────────────────────────────────────────────────

class OrderFilter {
  final String searchQuery;
  final String? paymentMethod; // null = all
  final String? status; // null = all
  final DateTime? startDate;
  final DateTime? endDate;

  const OrderFilter({
    this.searchQuery = '',
    this.paymentMethod,
    this.status,
    this.startDate,
    this.endDate,
  });

  bool get isActive =>
      searchQuery.isNotEmpty ||
      paymentMethod != null ||
      status != null ||
      startDate != null ||
      endDate != null;

  OrderFilter copyWith({
    String? searchQuery,
    Object? paymentMethod = _sentinel,
    Object? status = _sentinel,
    Object? startDate = _sentinel,
    Object? endDate = _sentinel,
  }) {
    return OrderFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      paymentMethod: paymentMethod == _sentinel
          ? this.paymentMethod
          : paymentMethod as String?,
      status: status == _sentinel ? this.status : status as String?,
      startDate: startDate == _sentinel
          ? this.startDate
          : startDate as DateTime?,
      endDate:
          endDate == _sentinel ? this.endDate : endDate as DateTime?,
    );
  }

  static const _sentinel = Object();
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class OrderHistoryState {
  final List<OrderCollection> orders;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final OrderFilter filter;

  const OrderHistoryState({
    this.orders = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.filter = const OrderFilter(),
  });

  OrderHistoryState copyWith({
    List<OrderCollection>? orders,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    OrderFilter? filter,
  }) {
    return OrderHistoryState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      filter: filter ?? this.filter,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class OrderHistoryNotifier extends Notifier<OrderHistoryState> {
  static const _pageSize = 20;

  // In-memory cache of all matching orders from Isar (unfiltered by search/
  // payment/status — only filtered by cashier & date range from Isar itself
  // since those are indexed). Secondary filters run in-memory.
  List<OrderCollection> _cached = [];
  int _displayCount = _pageSize;

  @override
  OrderHistoryState build() {
    Future.microtask(_loadAll);
    return const OrderHistoryState(isLoading: true);
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadAll();
  }

  void loadMore() {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    _displayCount += _pageSize;
    _applyAndUpdate();
  }

  void updateSearch(String query) {
    _displayCount = _pageSize;
    state = state.copyWith(filter: state.filter.copyWith(searchQuery: query));
    _applyAndUpdate();
  }

  void applyFilter(OrderFilter newFilter) {
    _displayCount = _pageSize;
    // Merge with current search query so it is preserved
    state = state.copyWith(
      filter: newFilter.copyWith(searchQuery: state.filter.searchQuery),
    );
    _applyAndUpdate();
  }

  void clearFilter() {
    _displayCount = _pageSize;
    state = state.copyWith(
      filter: OrderFilter(searchQuery: state.filter.searchQuery),
    );
    _applyAndUpdate();
  }

  /// Exports a given list of orders to an Excel file.
  /// Returns the saved file path on success, null on failure.
  Future<String?> exportToExcel(
    List<OrderCollection> orders, {
    String sheetLabel = 'Orders',
  }) async {
    try {
      final excel = Excel.createExcel();
      const sheetName = 'Orders';

      // Rename the auto-generated "Sheet1"
      if (excel.tables.keys.contains('Sheet1')) {
        excel.rename('Sheet1', sheetName);
      }

      // Header row
      excel.appendRow(sheetName, [
        TextCellValue('Order #'),
        TextCellValue('Date & Time'),
        TextCellValue('Cashier'),
        TextCellValue('Item Count'),
        TextCellValue('Subtotal'),
        TextCellValue('Discount'),
        TextCellValue('Total'),
        TextCellValue('Tendered'),
        TextCellValue('Change'),
        TextCellValue('Payment'),
        TextCellValue('Status'),
      ]);

      final fmt = DateFormat('yyyy-MM-dd HH:mm');
      for (final o in orders) {
        excel.appendRow(sheetName, [
          TextCellValue(o.orderNumber),
          TextCellValue(fmt.format(o.orderedAt)),
          TextCellValue(o.cashierName),
          IntCellValue(o.orderItemsJson.length),
          DoubleCellValue(o.subtotal),
          DoubleCellValue(o.discountAmount),
          DoubleCellValue(o.totalAmount),
          DoubleCellValue(o.amountTendered),
          DoubleCellValue(o.changeAmount),
          TextCellValue(o.paymentMethod),
          TextCellValue(o.status),
        ]);
      }

      final bytes = excel.save();
      if (bytes == null) return null;

      // Prefer external storage so the user can find it easily; fall back to
      // app-documents directory which is always available.
      Directory? dir = await getExternalStorageDirectory();
      dir ??= await getApplicationDocumentsDirectory();

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file =
          File('${dir.path}/sukli_orders_${sheetLabel}_$timestamp.xlsx');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  // ── Internal helpers ───────────────────────────────────────────────────────

  Future<void> _loadAll() async {
    try {
      final db = ref.read(isarProvider);
      final cashierId =
          ref.read(authProvider).selectedCashier?.syncId;

      List<OrderCollection> fetched;
      if (cashierId != null && cashierId.isNotEmpty) {
        fetched = await db.orderCollections
            .filter()
            .isDeletedEqualTo(false)
            .and()
            .cashierIdEqualTo(cashierId)
            .findAll();
      } else {
        // Fallback: show all (e.g. admin user navigating cashier route)
        fetched = await db.orderCollections
            .filter()
            .isDeletedEqualTo(false)
            .findAll();
      }
      // Sort by orderedAt descending in memory
      fetched.sort((a, b) => b.orderedAt.compareTo(a.orderedAt));

      _cached = fetched;
      _displayCount = _pageSize;
      _applyAndUpdate(isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Applies in-memory search / payment / status / date filters and then
  /// slices the result to [_displayCount] items for display.
  void _applyAndUpdate({bool isLoading = false}) {
    final f = state.filter;

    final filtered = _cached.where((o) {
      // Search by order number
      if (f.searchQuery.isNotEmpty &&
          !o.orderNumber
              .toLowerCase()
              .contains(f.searchQuery.toLowerCase())) {
        return false;
      }
      // Payment method
      if (f.paymentMethod != null && o.paymentMethod != f.paymentMethod) {
        return false;
      }
      // Status
      if (f.status != null && o.status != f.status) return false;

      // Date range — endDate is inclusive (covers the whole day)
      if (f.startDate != null && o.orderedAt.isBefore(f.startDate!)) {
        return false;
      }
      if (f.endDate != null) {
        final endInclusive = DateTime(
          f.endDate!.year,
          f.endDate!.month,
          f.endDate!.day,
          23,
          59,
          59,
        );
        if (o.orderedAt.isAfter(endInclusive)) return false;
      }
      return true;
    }).toList();

    final page = filtered.take(_displayCount).toList();

    state = state.copyWith(
      orders: page,
      isLoading: isLoading,
      isLoadingMore: false,
      hasMore: _displayCount < filtered.length,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: build ordered list for a preset date range (used by export action)
// ─────────────────────────────────────────────────────────────────────────────

/// Returns a subset of [all] matching [start..end] (both inclusive date-wise).
List<OrderCollection> filterByDateRange(
  List<OrderCollection> all,
  DateTime start,
  DateTime end,
) {
  final endInclusive = DateTime(end.year, end.month, end.day, 23, 59, 59);
  return all
      .where((o) =>
          !o.orderedAt.isBefore(start) && !o.orderedAt.isAfter(endInclusive))
      .toList();
}

/// Provider
final orderHistoryProvider =
    NotifierProvider<OrderHistoryNotifier, OrderHistoryState>(
  OrderHistoryNotifier.new,
);
