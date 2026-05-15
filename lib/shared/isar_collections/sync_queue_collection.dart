import 'package:isar_community/isar.dart';

part 'sync_queue_collection.g.dart';

@collection
class SyncQueueCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String operationId;

  @Index()
  late String tableName;

  late String recordSyncId;
  late String operation; // 'insert', 'update', 'delete'
  late String payloadJson;
  late int retryCount;
  late int maxRetries;

  @Index()
  late String status; // 'pending', 'in_progress', 'failed', 'completed'

  String? lastError;

  @Index()
  late DateTime createdAt;

  DateTime? lastAttemptAt;
  DateTime? completedAt;
}
