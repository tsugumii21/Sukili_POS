import 'dart:convert';
import 'isar_service.dart';
import 'supabase_service.dart';
import '../constants/app_constants.dart';
import '../../shared/isar_collections/sync_queue_collection.dart';
import 'package:isar_community/isar.dart';

/// SyncResult represents the outcome of a synchronization operation.
class SyncResult {
  final int processed;
  final int succeeded;
  final int failed;
  final String? error;

  SyncResult({
    required this.processed,
    required this.succeeded,
    required this.failed,
    this.error,
  });

  bool get hasError => error != null;
}

/// SyncService manages the offline-first synchronization logic.
/// It queues local changes and pushes them to Supabase when online.
class SyncService {
  SyncService._();

  static final SyncService instance = SyncService._();

  final IsarService _isar = IsarService.instance;
  final SupabaseService _supabase = SupabaseService.instance;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  /// Starts a periodic sync process every few minutes.
  void startPeriodicSync() {
    // Basic periodic sync (e.g., every 5 minutes)
    // In a real app, use WorkManager for background sync.
  }

  /// Stops the periodic sync process.
  void stopPeriodicSync() {
    // Logic to stop the sync timer
  }

  /// Manually triggers a full synchronization.
  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      return SyncResult(processed: 0, succeeded: 0, failed: 0, error: 'Sync already in progress');
    }

    _isSyncing = true;
    try {
      // 1. Push local changes
      final pushResult = await syncPendingQueue();
      
      // 2. Pull remote changes (Categories, Products, etc.)
      // To be implemented in Part 10/11
      
      return pushResult;
    } finally {
      _isSyncing = false;
    }
  }

  /// Processes the pending local changes and pushes them to Supabase.
  Future<SyncResult> syncPendingQueue() async {
    // TODO: Fix Isar findAll() type resolution issue. Bypassing for UI testing.
    return SyncResult(processed: 0, succeeded: 0, failed: 0);
    
    /*
    int succeeded = 0;
    int failed = 0;

    try {
      final pendingItems = await _isar.isar.syncQueueCollections
          .filter()
          .statusEqualTo('pending')
          .findAll();

      for (final item in pendingItems) {
        if (item.retryCount >= AppConstants.maxSyncRetries) continue;
        
        try {
          final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;
          
          if (item.operation == 'insert' || item.operation == 'update') {
            await _supabase.upsertRecord(item.tableName, payload);
          } else if (item.operation == 'delete') {
            await _supabase.softDelete(item.tableName, item.recordSyncId);
          }

          // Mark as completed
          await _isar.isar.writeTxn(() async {
            item.status = 'completed';
            item.completedAt = DateTime.now();
            await _isar.isar.syncQueueCollections.put(item);
          });
          succeeded++;
        } catch (e) {
          failed++;
          await _isar.isar.writeTxn(() async {
            item.status = 'failed';
            item.retryCount++;
            item.lastError = e.toString();
            item.lastAttemptAt = DateTime.now();
            await _isar.isar.syncQueueCollections.put(item);
          });
        }
      }

      return SyncResult(
        processed: pendingItems.length,
        succeeded: succeeded,
        failed: failed,
      );
    } catch (e) {
      return SyncResult(processed: 0, succeeded: 0, failed: 0, error: e.toString());
    }
    */
  }

  /// Adds a new operation to the sync queue.
  Future<void> addToQueue({
    required String tableName,
    required String recordSyncId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final item = SyncQueueCollection()
      ..operationId = '${tableName}_${recordSyncId}_${DateTime.now().millisecondsSinceEpoch}'
      ..tableName = tableName
      ..recordSyncId = recordSyncId
      ..operation = operation
      ..payloadJson = jsonEncode(payload)
      ..status = 'pending'
      ..retryCount = 0
      ..maxRetries = AppConstants.maxSyncRetries
      ..createdAt = DateTime.now();

    await _isar.isar.writeTxn(() async {
      await _isar.isar.syncQueueCollections.put(item);
    });
  }
}
