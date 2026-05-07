import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/isar_collections/order_collection.dart';
import '../../../../shared/isar_collections/sync_queue_collection.dart';
import '../../domain/entities/order_state.dart';

/// Handles persisting completed orders and sync queue entries
/// in a single atomic Isar transaction.
class OrderRepositoryImpl {
  const OrderRepositoryImpl(this._isar);
  final Isar _isar;

  static const _uuid = Uuid();

  /// Saves a completed order to Isar and enqueues it for Supabase sync.
  Future<OrderCollection> saveOrder({
    required OrderState orderState,
    required String cashierId,
    required String cashierName,
    required double amountTendered,
    required String paymentMethod,
    String? paymentReference,
    double discountAmount = 0.0,
    String? discountReason,
  }) async {
    final now = DateTime.now();
    final syncId = _uuid.v4();
    final orderNumber = await _generateOrderNumber(now);

    final itemsJson = orderState.items
        .map((item) => jsonEncode({
              'itemSyncId': item.itemSyncId,
              'itemName': item.itemName,
              'variantName': item.variantName,
              'unitPrice': item.unitPrice,
              'quantity': item.quantity,
              'modifiers': item.modifiers,
              'notes': item.notes,
              'subtotal': item.subtotal,
            }))
        .toList();

    final subtotal = orderState.total;
    final totalAmount = subtotal - discountAmount;
    final change = (amountTendered - totalAmount).clamp(0.0, double.infinity);

    final order = OrderCollection()
      ..syncId = syncId
      ..orderNumber = orderNumber
      ..cashierId = cashierId
      ..cashierName = cashierName
      ..orderItemsJson = itemsJson
      ..subtotal = subtotal
      ..discountAmount = discountAmount
      ..discountReason = discountReason
      ..taxAmount = 0.0
      ..totalAmount = totalAmount
      ..amountTendered = amountTendered
      ..changeAmount = change
      ..paymentMethod = paymentMethod
      ..paymentReference = paymentReference
      ..status = 'completed'
      ..orderedAt = now
      ..createdAt = now
      ..updatedAt = now
      ..isSynced = false
      ..isDeleted = false;

    await _isar.writeTxn(() async {
      // 1. Persist the order
      await _isar.orderCollections.put(order);

      // 2. Enqueue order for Supabase sync
      await _isar.syncQueueCollections.put(
        _buildSyncEntry(
          tableName: 'orders',
          recordSyncId: syncId,
          operation: 'insert',
          payload: _orderPayload(order),
          now: now,
        ),
      );
    });

    return order;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Generates a sequential order number for the current day,
  /// e.g. ORD-20260502-0001.
  Future<String> _generateOrderNumber(DateTime now) async {
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    final count = await _isar.orderCollections
        .where()
        .orderedAtBetween(startOfDay, endOfDay)
        .count();

    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final seq = (count + 1).toString().padLeft(4, '0');
    return '${AppConstants.orderPrefix}-$dateStr-$seq';
  }

  SyncQueueCollection _buildSyncEntry({
    required String tableName,
    required String recordSyncId,
    required String operation,
    required String payload,
    required DateTime now,
  }) {
    return SyncQueueCollection()
      ..operationId = _uuid.v4()
      ..tableName = tableName
      ..recordSyncId = recordSyncId
      ..operation = operation
      ..payloadJson = payload
      ..retryCount = 0
      ..maxRetries = AppConstants.maxSyncRetries
      ..status = 'pending'
      ..createdAt = now;
  }

  String _orderPayload(OrderCollection order) {
    return jsonEncode({
      'sync_id': order.syncId,
      'order_number': order.orderNumber,
      'cashier_id': order.cashierId,
      'cashier_name': order.cashierName,
      'order_items_json': order.orderItemsJson,
      'subtotal': order.subtotal,
      'discount_amount': order.discountAmount,
      'discount_reason': order.discountReason,
      'tax_amount': order.taxAmount,
      'total_amount': order.totalAmount,
      'amount_tendered': order.amountTendered,
      'change_amount': order.changeAmount,
      'payment_method': order.paymentMethod,
      'payment_reference': order.paymentReference,
      'status': order.status,
      'ordered_at': order.orderedAt.toIso8601String(),
      'created_at': order.createdAt.toIso8601String(),
      'updated_at': order.updatedAt.toIso8601String(),
    });
  }
}
