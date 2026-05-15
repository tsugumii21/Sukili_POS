import 'package:isar_community/isar.dart';

part 'menu_item_collection.g.dart';

@collection
class MenuItemCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String syncId;

  @Index()
  late String categoryId; // syncId of parent

  late String name;
  String? description;
  late double basePrice;
  String? imageUrl;

  @Index()
  late bool isAvailable;

  @Index()
  late bool isFavorite;

  late int sortOrder;

  /// Legacy flat variant format: [{name, priceDelta}].
  /// Kept for backward-compat; new items use variantGroupsJson.
  List<String> variantsJson = [];

  /// New multi-group variant format: [{groupName, options:[{name,priceDelta}]}].
  /// Each entry is a JSON-encoded VariantGroupDraft.
  List<String> variantGroupsJson = [];

  List<String> modifiersJson = [];

  /// syncId of StoreCollection — nullable for migration safety.
  String? storeId;

  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isSynced;
  late bool isDeleted;
}
