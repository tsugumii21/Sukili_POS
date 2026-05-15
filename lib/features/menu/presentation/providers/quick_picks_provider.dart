import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../../shared/isar_collections/menu_item_collection.dart';
import '../../../../shared/isar_collections/order_collection.dart';
import '../../../../shared/providers/isar_provider.dart';
import '../../../../shared/providers/store_provider.dart';

/// Analyzes the last [_lookbackOrders] completed orders and returns the
/// most-frequently-ordered [MenuItemCollection] records (top 8), sorted by
/// total quantity sold descending.
///
/// Only returns items that are still available and not deleted, so the list
/// is always actionable on the New Order screen.
class QuickPicksNotifier extends AsyncNotifier<List<MenuItemCollection>> {
  static const int _lookbackOrders = 50;
  static const int _maxResults = 8;

  @override
  Future<List<MenuItemCollection>> build() {
    final storeId = ref.watch(currentStoreIdProvider);
    if (storeId.isEmpty) return Future.value([]);
    return _compute(storeId);
  }

  Future<void> refresh() async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId.isEmpty) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _compute(storeId));
  }

  Future<List<MenuItemCollection>> _compute(String storeId) async {
    final db = ref.read(isarProvider);

    // ── Step 1: Load recent orders for THIS store ───────────────────────────
    final allOrders = await db.orderCollections
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .isDeletedEqualTo(false)
        .findAll();

    if (allOrders.isEmpty) return [];

    // Keep only the most recent N to avoid processing unbounded history.
    allOrders.sort((a, b) => b.orderedAt.compareTo(a.orderedAt));
    final recent = allOrders.take(_lookbackOrders).toList();

    // ── Step 2: Tally item frequency ────────────────────────────────────────
    // Weight by quantity so a line item "3 × Iced Coffee" counts 3 times.
    final counts = <String, int>{};
    for (final order in recent) {
      for (final jsonStr in order.orderItemsJson) {
        try {
          final map = jsonDecode(jsonStr) as Map<String, dynamic>;
          final syncId = map['itemSyncId'] as String?;
          if (syncId == null) continue;
          final qty = (map['quantity'] as num?)?.toInt() ?? 1;
          counts[syncId] = (counts[syncId] ?? 0) + qty;
        } catch (_) {
          // Malformed JSON — skip silently.
        }
      }
    }

    if (counts.isEmpty) return [];

    // ── Step 3: Sort ids by frequency ───────────────────────────────────────
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topIds = sorted.take(_maxResults).map((e) => e.key).toList();

    // ── Step 4: Fetch live MenuItemCollection records for THIS store ─────────
    final allItems = await db.menuItemCollections
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .isAvailableEqualTo(true)
        .and()
        .isDeletedEqualTo(false)
        .findAll();

    final itemMap = {for (final i in allItems) i.syncId: i};

    // Build result in frequency order, dropping any item no longer available.
    final result = <MenuItemCollection>[];
    for (final id in topIds) {
      final item = itemMap[id];
      if (item != null) result.add(item);
    }
    return result;
  }
}

final quickPicksProvider =
    AsyncNotifierProvider<QuickPicksNotifier, List<MenuItemCollection>>(
  QuickPicksNotifier.new,
);
