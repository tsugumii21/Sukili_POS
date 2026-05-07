import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../../../core/services/isar_service.dart';
import '../../../../shared/isar_collections/menu_item_collection.dart';
import '../../../../shared/isar_collections/order_collection.dart';
import '../../../../shared/isar_collections/sync_queue_collection.dart';

/// AdminDashboardData holds all metrics and lists for the Admin Dashboard.
class AdminDashboardData {
  final double totalSalesToday;
  final int ordersToday;
  final int lowStockCount;
  final int pendingSyncCount;
  final List<OrderCollection> recentOrders;

  AdminDashboardData({
    required this.totalSalesToday,
    required this.ordersToday,
    required this.lowStockCount,
    required this.pendingSyncCount,
    required this.recentOrders,
  });
}

/// AdminDashboardNotifier manages state for the Admin Dashboard screen.
class AdminDashboardNotifier
    extends Notifier<AsyncValue<AdminDashboardData>> {
  @override
  AsyncValue<AdminDashboardData> build() {
    _init();
    return const AsyncValue.loading();
  }

  IsarService get _isar => IsarService.instance;

  void _init() {
    Future.microtask(() => refreshData());
    _isar.isar.orderCollections.watchLazy().listen((_) => refreshData());
    _isar.isar.menuItemCollections.watchLazy().listen((_) => refreshData());
    _isar.isar.syncQueueCollections.watchLazy().listen((_) => refreshData());
  }

  Future<void> refreshData() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // 1. Today's completed orders
      final todayOrders = await _isar.isar.orderCollections
          .filter()
          .orderedAtBetween(startOfDay, endOfDay)
          .and()
          .statusEqualTo('completed')
          .findAll();

      final salesTotal =
          todayOrders.fold<double>(0, (sum, o) => sum + o.totalAmount);

      // 2. Low-stock items
      final trackedItems = await _isar.isar.menuItemCollections
          .filter()
          .trackInventoryEqualTo(true)
          .and()
          .isDeletedEqualTo(false)
          .findAll();

      final lowStockCount = trackedItems.where((item) {
        final current = item.stockQuantity ?? 0;
        final threshold = item.lowStockThreshold ?? 5.0;
        return current <= threshold;
      }).length;

      // 3. Pending sync queue items
      final pendingItems = await _isar.isar.syncQueueCollections
          .filter()
          .statusEqualTo('pending')
          .findAll();

      // 4. Recent 10 orders (any status)
      final recentOrders = await _isar.isar.orderCollections
          .where()
          .sortByOrderedAtDesc()
          .limit(10)
          .findAll();

      state = AsyncValue.data(AdminDashboardData(
        totalSalesToday: salesTotal,
        ordersToday: todayOrders.length,
        lowStockCount: lowStockCount,
        pendingSyncCount: pendingItems.length,
        recentOrders: recentOrders,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for the Admin Dashboard data.
final adminDashboardProvider =
    NotifierProvider<AdminDashboardNotifier, AsyncValue<AdminDashboardData>>(
  AdminDashboardNotifier.new,
);
