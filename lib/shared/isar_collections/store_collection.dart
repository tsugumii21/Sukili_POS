import 'package:isar_community/isar.dart';

part 'store_collection.g.dart';

/// StoreCollection represents a Sukli POS store instance.
@collection
class StoreCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String syncId;

  late String name;
  String? logoUrl;

  /// syncId of the admin UserCollection who owns this store.
  late String ownerId;

  /// Supabase Auth UID of the owner.
  String? supabaseAuthUid;

  late bool isActive;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isSynced;
  late bool isDeleted;
}
