import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/services/isar_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/utils/pin_helper.dart';
import '../../../../shared/isar_collections/order_collection.dart';
import '../../../../shared/isar_collections/user_collection.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tab enum
// ─────────────────────────────────────────────────────────────────────────────

enum VoidRefundTab { voidOrders, refunds, history }

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a refund details payload stored in [OrderCollection.refundReason].
///
/// To avoid a schema migration, we encode refund metadata as JSON inside the
/// existing [refundReason] String field:
/// {"reason": "...", "amount": 250.0, "isPartial": true, "by": "syncId"}
class RefundMeta {
  final String reason;
  final double amount;
  final bool isPartial;
  final String refundedById;

  const RefundMeta({
    required this.reason,
    required this.amount,
    required this.isPartial,
    required this.refundedById,
  });

  String toJson() => jsonEncode({
        'reason': reason,
        'amount': amount,
        'isPartial': isPartial,
        'by': refundedById,
      });

  static RefundMeta? tryParse(String? raw) {
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return RefundMeta(
        reason: map['reason'] as String? ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
        isPartial: map['isPartial'] as bool? ?? false,
        refundedById: map['by'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}

/// Immutable state for the Void & Refund screen.
class VoidRefundState {
  const VoidRefundState({
    this.tab = VoidRefundTab.voidOrders,
    this.voidableOrders = const [],
    this.refundableOrders = const [],
    this.historyOrders = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final VoidRefundTab tab;

  /// Orders with status == 'completed' (can be voided or refunded).
  final List<OrderCollection> voidableOrders;

  /// Orders with status == 'completed' (eligible for refund).
  final List<OrderCollection> refundableOrders;

  /// Orders that are already voided or refunded.
  final List<OrderCollection> historyOrders;

  final bool isLoading;
  final String? errorMessage;

  VoidRefundState copyWith({
    VoidRefundTab? tab,
    List<OrderCollection>? voidableOrders,
    List<OrderCollection>? refundableOrders,
    List<OrderCollection>? historyOrders,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) =>
      VoidRefundState(
        tab: tab ?? this.tab,
        voidableOrders: voidableOrders ?? this.voidableOrders,
        refundableOrders: refundableOrders ?? this.refundableOrders,
        historyOrders: historyOrders ?? this.historyOrders,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class VoidRefundNotifier extends Notifier<VoidRefundState> {
  @override
  VoidRefundState build() {
    _load();
    _watchOrders();
    return const VoidRefundState(isLoading: true);
  }

  IsarService get _isar => IsarService.instance;
  SyncService get _sync => SyncService.instance;

  void _watchOrders() {
    _isar.isar.orderCollections.watchLazy().listen((_) => _load());
  }

  Future<void> _load() async {
    try {
      // All non-deleted orders sorted newest-first
      final all = await _isar.isar.orderCollections
          .filter()
          .isDeletedEqualTo(false)
          .sortByOrderedAtDesc()
          .findAll();

      final voidable =
          all.where((o) => o.status == 'completed').toList();
      final refundable =
          all.where((o) => o.status == 'completed').toList();
      final history = all
          .where((o) => o.status == 'voided' || o.status == 'refunded')
          .toList();

      state = state.copyWith(
        voidableOrders: voidable,
        refundableOrders: refundable,
        historyOrders: history,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load orders: $e',
      );
    }
  }

  // ── Tab switching ───────────────────────────────────────────────────────────

  void selectTab(VoidRefundTab tab) {
    state = state.copyWith(tab: tab);
  }

  // ── Admin PIN verification ──────────────────────────────────────────────────

  /// Finds the first active admin user and verifies the entered PIN.
  /// Returns the admin's [UserCollection] on success, null on failure.
  Future<UserCollection?> verifyAdminPin(String pin) async {
    try {
      final admins = await _isar.isar.userCollections
          .filter()
          .roleEqualTo(SupabaseConstants.roleAdmin)
          .and()
          .statusEqualTo(SupabaseConstants.statusActive)
          .and()
          .isDeletedEqualTo(false)
          .findAll();

      for (final admin in admins) {
        if (admin.pinHash != null &&
            PinHelper.verifyPin(pin, admin.pinHash!)) {
          return admin;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Void order ──────────────────────────────────────────────────────────────

  /// Marks an order as voided after admin PIN + reason verification.
  /// Persists to Isar first, then enqueues to SyncQueue.
  Future<bool> voidOrder({
    required OrderCollection order,
    required UserCollection admin,
    required String reason,
  }) async {
    try {
      final now = DateTime.now();
      await _isar.isar.writeTxn(() async {
        order.status = SupabaseConstants.orderStatusVoided;
        order.voidReason = reason;
        order.voidedById = admin.syncId;
        order.voidedAt = now;
        order.updatedAt = now;
        order.isSynced = false;
        await _isar.isar.orderCollections.put(order);
      });

      await _sync.addToQueue(
        tableName: SupabaseConstants.ordersTable,
        recordSyncId: order.syncId,
        operation: 'update',
        payload: {
          SupabaseConstants.syncId: order.syncId,
          SupabaseConstants.orderStatus: SupabaseConstants.orderStatusVoided,
          'void_reason': reason,
          'voided_by_id': admin.syncId,
          'voided_at': now.toIso8601String(),
          SupabaseConstants.updatedAt: now.toIso8601String(),
        },
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Void failed: $e');
      return false;
    }
  }

  // ── Refund order ─────────────────────────────────────────────────────────────

  /// Marks an order as refunded after admin PIN verification.
  /// Refund metadata (amount, isPartial, reason) is stored as JSON in
  /// [OrderCollection.refundReason] to avoid a schema migration.
  Future<bool> refundOrder({
    required OrderCollection order,
    required UserCollection admin,
    required String reason,
    required double refundAmount,
    required bool isPartial,
  }) async {
    try {
      final now = DateTime.now();
      final meta = RefundMeta(
        reason: reason,
        amount: refundAmount,
        isPartial: isPartial,
        refundedById: admin.syncId,
      );

      await _isar.isar.writeTxn(() async {
        order.status = SupabaseConstants.orderStatusRefunded;
        order.refundReason = meta.toJson();
        order.voidedById = admin.syncId;
        order.voidedAt = now;
        order.updatedAt = now;
        order.isSynced = false;
        await _isar.isar.orderCollections.put(order);
      });

      await _sync.addToQueue(
        tableName: SupabaseConstants.ordersTable,
        recordSyncId: order.syncId,
        operation: 'update',
        payload: {
          SupabaseConstants.syncId: order.syncId,
          SupabaseConstants.orderStatus: SupabaseConstants.orderStatusRefunded,
          'refund_reason': meta.toJson(),
          'refunded_by_id': admin.syncId,
          'refunded_at': now.toIso8601String(),
          SupabaseConstants.updatedAt: now.toIso8601String(),
        },
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Refund failed: $e');
      return false;
    }
  }

  /// Clears any stored error message.
  void clearError() => state = state.copyWith(clearError: true);
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final voidRefundProvider =
    NotifierProvider<VoidRefundNotifier, VoidRefundState>(
  VoidRefundNotifier.new,
);
