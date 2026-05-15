import 'package:isar_community/isar.dart';

part 'user_collection.g.dart';

@collection
class UserCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String syncId; // UUID

  @Index(unique: true)
  late String email; // Admin email

  late String name;

  String? pinHash; // SHA-256

  @Index()
  late String role; // 'cashier' or 'admin'

  @Index()
  late String status; // 'active' or 'inactive'

  String? avatarUrl;

  /// syncId of StoreCollection — nullable for migration safety.
  String? storeId;

  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isSynced;
  late bool isDeleted;
}
