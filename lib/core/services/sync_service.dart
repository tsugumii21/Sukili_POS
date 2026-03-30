import 'dart:async';
import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'isar_service.dart';
import 'supabase_service.dart';
import '../constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/isar_collections/sync_queue_collection.dart';
import '../constants/supabase_constants.dart';

class SyncResult {
  final int successCount;
  final int failedCount;
  final bool wasSkipped;

  const SyncResult({
    this.successCount = 0,
    this.failedCount = 0,
    this.wasSkipped = false,
  });

  factory SyncResult.skipped() => const SyncResult(wasSkipped: true);
}

/// SyncService orchestrates the synchronization between Isar and Supabase.
class SyncService {
  final IsarService _isarService;
  final SupabaseService _supabaseService;
  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncService(this._isarService, this._supabaseService);

  void startPeriodicSync() {
    _syncTimer = Timer.periodic(
      const Duration(seconds: AppConstants.syncIntervalSeconds),
      (_) => syncPendingQueue(),
    );
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
  }

  /// Pushes pending queue items to Supabase using LWW strategy.
  Future<SyncResult> syncPendingQueue() async {
    if (_isSyncing) return SyncResult.skipped();
    _isSyncing = true;

    int success = 0;
    int failed = 0;

    try {
      // 1. Get pending queue items
      final pendingItems = await _isarService.isar.syncQueueCollections
          .filter()
          .statusEqualTo('pending')
          .and()
          .retryCountLessThan(AppConstants.maxSyncRetries)
          .findAll();

      for (final item in pendingItems) {
        try {
          final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;

          if (item.operation == 'delete') {
            await _supabaseService.softDelete(item.tableName, item.recordSyncId);
          } else {
            await _supabaseService.upsertRecord(item.tableName, payload);
          }

          // Mark completed
          item.status = 'completed';
          item.completedAt = DateTime.now();
          success++;
        } catch (e) {
          item.retryCount++;
          item.lastError = e.toString();
          item.lastAttemptAt = DateTime.now();
          if (item.retryCount >= item.maxRetries) {
            item.status = 'failed';
          }
          failed++;
        }

        // Update item in Isar
        await _isarService.isar.writeTxn(() => _isarService.isar.syncQueueCollections.put(item));
      }

      return SyncResult(successCount: success, failedCount: failed);
    } finally {
      _isSyncing = false;
    }
  }

  /// Pulls latest data from Supabase and updates Isar (Server wins on conflict).
  Future<void> pullFromSupabase() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Define tables to pull
    final tables = [
      SupabaseConstants.usersTable,
      SupabaseConstants.categoriesTable,
      SupabaseConstants.menuItemsTable,
    ];

    for (final table in tables) {
      final lastPullKey = 'last_pull_$table';
      final lastPullStr = prefs.getString(lastPullKey) ?? DateTime.fromMillisecondsSinceEpoch(0).toIso8601String();
      final lastPull = DateTime.parse(lastPullStr);

      final remoteRecords = await _supabaseService.fetchUpdatedSince(table, lastPull);
      
      if (remoteRecords.isNotEmpty) {
        // Note: Repository-level sync logic will replace these in future parts
        
        // Update last pull time to the newest record's updatedAt
        final latestRecord = remoteRecords.last;
        await prefs.setString(lastPullKey, latestRecord[SupabaseConstants.updatedAt]);
      }
    }
  }

  /// Adds a record mutation to the sync queue.
  Future<void> enqueue({
    required String tableName,
    required String recordSyncId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final queueItem = SyncQueueCollection()
      ..operationId = const Uuid().v4()
      ..tableName = tableName
      ..recordSyncId = recordSyncId
      ..operation = operation
      ..payloadJson = jsonEncode(payload)
      ..retryCount = 0
      ..maxRetries = AppConstants.maxSyncRetries
      ..status = 'pending'
      ..createdAt = DateTime.now();

    await _isarService.isar.writeTxn(
      () => _isarService.isar.syncQueueCollections.put(queueItem),
    );
  }
}
