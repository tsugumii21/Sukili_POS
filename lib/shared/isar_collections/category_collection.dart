import 'package:isar_community/isar.dart';

part 'category_collection.g.dart';

@collection
class CategoryCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String syncId;

  /// syncId of the parent category; null = top-level category.
  @Index()
  String? parentId;

  late String name;
  String? description;
  String? iconEmoji;

  @Index()
  late int sortOrder;

  @Index()
  late bool isActive;

  /// syncId of StoreCollection — nullable for migration safety.
  String? storeId;

  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isSynced;
  late bool isDeleted;
}
