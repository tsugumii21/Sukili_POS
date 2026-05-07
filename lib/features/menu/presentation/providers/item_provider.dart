import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/services/isar_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../shared/isar_collections/category_collection.dart';
import '../../../../shared/isar_collections/menu_item_collection.dart';

/// In-memory draft for a single option within a variant group.
/// e.g. {name: "Small", priceDelta: 0} or {name: "Hot", priceDelta: 0}
class VariantOptionDraft {
  String name;
  double priceDelta;

  VariantOptionDraft({required this.name, required this.priceDelta});

  Map<String, dynamic> toJson() => {'name': name, 'priceDelta': priceDelta};

  factory VariantOptionDraft.fromJson(Map<String, dynamic> map) =>
      VariantOptionDraft(
        name: map['name'] as String? ?? '',
        priceDelta: (map['priceDelta'] as num?)?.toDouble() ?? 0,
      );

  VariantOptionDraft copyWith({String? name, double? priceDelta}) =>
      VariantOptionDraft(
          name: name ?? this.name,
          priceDelta: priceDelta ?? this.priceDelta);
}

/// In-memory draft for a named variant group (e.g. "Size", "Temperature").
/// Each group has a set of mutually-exclusive options; selecting one from each
/// group adds its priceDelta to the base price.
class VariantGroupDraft {
  String groupName;
  List<VariantOptionDraft> options;

  VariantGroupDraft({required this.groupName, required this.options});

  Map<String, dynamic> toJson() => {
        'groupName': groupName,
        'options': options.map((o) => o.toJson()).toList(),
      };

  factory VariantGroupDraft.fromJson(Map<String, dynamic> map) =>
      VariantGroupDraft(
        groupName: map['groupName'] as String? ?? '',
        options: (map['options'] as List<dynamic>?)
                ?.map((o) =>
                    VariantOptionDraft.fromJson(o as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

/// Legacy single-option variant (used in old items / backward-compat only).
/// New items use [VariantGroupDraft] via variantGroupsJson.
class VariantDraft {
  String name;
  double priceDelta;

  VariantDraft({required this.name, required this.priceDelta});

  Map<String, dynamic> toJson() => {'name': name, 'priceDelta': priceDelta};

  factory VariantDraft.fromJson(Map<String, dynamic> map) => VariantDraft(
        name: map['name'] as String? ?? '',
        priceDelta: (map['priceDelta'] as num?)?.toDouble() ?? 0,
      );
}

/// In-memory draft for a modifier row during editing.
class ModifierDraft {
  String groupName;
  String name;
  double priceDelta;

  ModifierDraft(
      {required this.groupName, required this.name, required this.priceDelta});

  Map<String, dynamic> toJson() =>
      {'groupName': groupName, 'name': name, 'priceDelta': priceDelta};

  factory ModifierDraft.fromJson(Map<String, dynamic> map) => ModifierDraft(
        groupName: map['groupName'] as String? ?? '',
        name: map['name'] as String? ?? '',
        priceDelta: (map['priceDelta'] as num?)?.toDouble() ?? 0,
      );

  ModifierDraft copyWith(
          {String? groupName, String? name, double? priceDelta}) =>
      ModifierDraft(
        groupName: groupName ?? this.groupName,
        name: name ?? this.name,
        priceDelta: priceDelta ?? this.priceDelta,
      );
}

/// ItemManageState holds the full item list and current filter state.
class ItemManageState {
  final List<CategoryCollection> categories;
  /// All non-deleted items (not filtered by category). Used for tab counts.
  final List<MenuItemCollection> allItems;
  final String? selectedCategoryId; // null = All
  final String searchQuery;

  const ItemManageState({
    this.categories = const [],
    this.allItems = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
  });

  ItemManageState copyWith({
    List<CategoryCollection>? categories,
    List<MenuItemCollection>? allItems,
    String? selectedCategoryId,
    bool clearCategory = false,
    String? searchQuery,
  }) =>
      ItemManageState(
        categories: categories ?? this.categories,
        allItems: allItems ?? this.allItems,
        selectedCategoryId:
            clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
        searchQuery: searchQuery ?? this.searchQuery,
      );

  /// Returns items filtered by category and search query.
  List<MenuItemCollection> get filtered {
    var result = allItems;
    if (selectedCategoryId != null) {
      result = result.where((i) => i.categoryId == selectedCategoryId).toList();
    }
    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((i) => i.name.toLowerCase().contains(q)).toList();
    }
    return result;
  }

  /// Returns item count for a given category syncId.
  int countForCategory(String categoryId) =>
      allItems.where((i) => i.categoryId == categoryId).length;
}

/// ItemNotifier manages CRUD + toggle operations for menu items.
class ItemNotifier extends Notifier<AsyncValue<ItemManageState>> {
  static const _uuid = Uuid();

  @override
  AsyncValue<ItemManageState> build() {
    _init();
    return const AsyncValue.loading();
  }

  IsarService get _isar => IsarService.instance;

  void _init() {
    Future.microtask(_load);
    _isar.isar.menuItemCollections.watchLazy().listen((_) => _load());
    _isar.isar.categoryCollections.watchLazy().listen((_) => _load());
  }

  // ── Load ────────────────────────────────────────────────────────────────────

  Future<void> _load() async {
    try {
      final current = state.asData?.value;
      final catId = current?.selectedCategoryId;
      final search = current?.searchQuery ?? '';

      // Load categories (active, non-deleted, sorted)
      final categories = await _isar.isar.categoryCollections
          .filter()
          .isActiveEqualTo(true)
          .and()
          .isDeletedEqualTo(false)
          .sortBySortOrder()
          .findAll();

      // Load ALL non-deleted items for tab count accuracy
      final allItems = await _isar.isar.menuItemCollections
          .filter()
          .isDeletedEqualTo(false)
          .sortBySortOrder()
          .findAll();

      state = AsyncValue.data(ItemManageState(
        categories: categories,
        allItems: allItems,
        selectedCategoryId: catId,
        searchQuery: search,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _load();

  // ── Filter ───────────────────────────────────────────────────────────────

  void selectCategory(String? categoryId) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(
      selectedCategoryId: categoryId,
      clearCategory: categoryId == null,
    ));
  }

  void setSearch(String query) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(searchQuery: query));
  }

  // ── Toggle Availability ──────────────────────────────────────────────────

  Future<void> toggleAvailability(MenuItemCollection item) async {
    item
      ..isAvailable = !item.isAvailable
      ..updatedAt = DateTime.now()
      ..isSynced = false;
    await _isar.isar.writeTxn(() async {
      await _isar.isar.menuItemCollections.put(item);
    });
    await SyncService.instance.addToQueue(
      tableName: SupabaseConstants.menuItemsTable,
      recordSyncId: item.syncId,
      operation: 'update',
      payload: _toPayload(item),
    );
  }

  // ── Toggle Favorite ──────────────────────────────────────────────────────

  Future<void> toggleFavorite(MenuItemCollection item) async {
    item
      ..isFavorite = !item.isFavorite
      ..updatedAt = DateTime.now()
      ..isSynced = false;
    await _isar.isar.writeTxn(() async {
      await _isar.isar.menuItemCollections.put(item);
    });
    await SyncService.instance.addToQueue(
      tableName: SupabaseConstants.menuItemsTable,
      recordSyncId: item.syncId,
      operation: 'update',
      payload: _toPayload(item),
    );
  }

  // ── Create ───────────────────────────────────────────────────────────────

  Future<void> createItem({
    required String name,
    required String categoryId,
    required double basePrice,
    String? description,
    String? imageUrl,
    bool isAvailable = true,
    bool isFavorite = false,
    List<VariantGroupDraft> variantGroups = const [],
    List<ModifierDraft> modifiers = const [],
  }) async {
    final now = DateTime.now();
    final syncId = _uuid.v4();

    // Next sortOrder
    final current = state.asData?.value.allItems ?? [];
    final nextOrder = current.isEmpty
        ? 1
        : current.map((i) => i.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

    final item = MenuItemCollection()
      ..syncId = syncId
      ..categoryId = categoryId
      ..name = name.trim()
      ..description =
          description?.trim().isNotEmpty == true ? description!.trim() : null
      ..basePrice = basePrice
      ..imageUrl =
          imageUrl?.trim().isNotEmpty == true ? imageUrl!.trim() : null
      ..isAvailable = isAvailable
      ..isFavorite = isFavorite
      ..trackInventory = false
      ..sortOrder = nextOrder
      ..variantsJson = []
      ..variantGroupsJson =
          variantGroups.map((g) => jsonEncode(g.toJson())).toList()
      ..modifiersJson =
          modifiers.map((m) => jsonEncode(m.toJson())).toList()
      ..createdAt = now
      ..updatedAt = now
      ..isSynced = false
      ..isDeleted = false;

    await _isar.isar.writeTxn(() async {
      await _isar.isar.menuItemCollections.put(item);
    });
    await SyncService.instance.addToQueue(
      tableName: SupabaseConstants.menuItemsTable,
      recordSyncId: syncId,
      operation: 'insert',
      payload: _toPayload(item),
    );
  }

  // ── Update ───────────────────────────────────────────────────────────────

  Future<void> updateItem({
    required MenuItemCollection item,
    required String name,
    required String categoryId,
    required double basePrice,
    String? description,
    String? imageUrl,
    required bool isAvailable,
    required bool isFavorite,
    required List<VariantGroupDraft> variantGroups,
    required List<ModifierDraft> modifiers,
  }) async {
    item
      ..name = name.trim()
      ..categoryId = categoryId
      ..basePrice = basePrice
      ..description =
          description?.trim().isNotEmpty == true ? description!.trim() : null
      ..imageUrl =
          imageUrl?.trim().isNotEmpty == true ? imageUrl!.trim() : null
      ..isAvailable = isAvailable
      ..isFavorite = isFavorite
      ..variantsJson = []
      ..variantGroupsJson =
          variantGroups.map((g) => jsonEncode(g.toJson())).toList()
      ..modifiersJson = modifiers.map((m) => jsonEncode(m.toJson())).toList()
      ..updatedAt = DateTime.now()
      ..isSynced = false;

    await _isar.isar.writeTxn(() async {
      await _isar.isar.menuItemCollections.put(item);
    });
    await SyncService.instance.addToQueue(
      tableName: SupabaseConstants.menuItemsTable,
      recordSyncId: item.syncId,
      operation: 'update',
      payload: _toPayload(item),
    );
  }

  // ── Soft Delete ──────────────────────────────────────────────────────────

  Future<void> softDelete(MenuItemCollection item) async {
    item
      ..isDeleted = true
      ..updatedAt = DateTime.now()
      ..isSynced = false;
    await _isar.isar.writeTxn(() async {
      await _isar.isar.menuItemCollections.put(item);
    });
    await SyncService.instance.addToQueue(
      tableName: SupabaseConstants.menuItemsTable,
      recordSyncId: item.syncId,
      operation: 'delete',
      payload: _toPayload(item),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _toPayload(MenuItemCollection i) => {
        'sync_id': i.syncId,
        'category_id': i.categoryId,
        'name': i.name,
        'description': i.description,
        'base_price': i.basePrice,
        'image_url': i.imageUrl,
        'is_available': i.isAvailable,
        'is_favorite': i.isFavorite,
        'track_inventory': i.trackInventory,
        'stock_quantity': i.stockQuantity,
        'low_stock_threshold': i.lowStockThreshold,
        'sort_order': i.sortOrder,
        'variants_json': i.variantsJson,
        'variant_groups_json': i.variantGroupsJson,
        'modifiers_json': i.modifiersJson,
        'is_deleted': i.isDeleted,
        'created_at': i.createdAt.toIso8601String(),
        'updated_at': i.updatedAt.toIso8601String(),
      };
}

/// Provider for menu item management.
final itemProvider =
    NotifierProvider<ItemNotifier, AsyncValue<ItemManageState>>(
  ItemNotifier.new,
);
