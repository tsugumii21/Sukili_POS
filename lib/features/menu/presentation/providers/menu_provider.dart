import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../../../core/services/isar_service.dart';
import '../../../../shared/isar_collections/category_collection.dart';
import '../../../../shared/isar_collections/menu_item_collection.dart';
import '../../../../shared/providers/store_provider.dart';

/// MenuState holds categories, filtered items, and the active filters.
class MenuState {
  final List<CategoryCollection> categories;
  final List<MenuItemCollection> items;
  final String? selectedCategoryId; // null = "All"
  final String searchQuery;
  final bool isLoading;

  const MenuState({
    this.categories = const [],
    this.items = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.isLoading = true,
  });

  MenuState copyWith({
    List<CategoryCollection>? categories,
    List<MenuItemCollection>? items,
    String? selectedCategoryId,
    bool clearCategory = false,
    String? searchQuery,
    bool? isLoading,
  }) {
    return MenuState(
      categories: categories ?? this.categories,
      items: items ?? this.items,
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// MenuNotifier loads categories and items from Isar and handles
/// real-time filtering by category and search query.
class MenuNotifier extends Notifier<MenuState> {
  @override
  MenuState build() {
    final storeId = ref.watch(currentStoreIdProvider);
    if (storeId.isEmpty) return const MenuState(isLoading: false);

    _loadInitialData(storeId);
    return const MenuState();
  }

  IsarService get _isar => IsarService.instance;

  Future<void> _loadInitialData(String storeId) async {
    final categories = await _isar.isar.categoryCollections
        .filter()
        .storeIdEqualTo(storeId)
        .isActiveEqualTo(true)
        .and()
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .findAll();

    final items = await _loadFilteredItems(storeId, null, '');

    state = state.copyWith(
      categories: categories,
      items: items,
      isLoading: false,
    );
  }

  /// Loads items from Isar, optionally filtered by category and search.
  Future<List<MenuItemCollection>> _loadFilteredItems(
    String storeId,
    String? categoryId,
    String search,
  ) async {
    var query = _isar.isar.menuItemCollections
        .filter()
        .storeIdEqualTo(storeId)
        .isDeletedEqualTo(false);

    if (categoryId != null) {
      query = query.and().categoryIdEqualTo(categoryId);
    }

    final allItems = await query.sortBySortOrder().findAll();

    // Client-side search filtering for responsiveness
    if (search.isEmpty) return allItems;
    final lower = search.toLowerCase();
    return allItems
        .where((item) => item.name.toLowerCase().contains(lower))
        .toList();
  }

  /// Called when the cashier taps a category pill.
  Future<void> selectCategory(String? categoryId) async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId.isEmpty) return;

    state = state.copyWith(isLoading: true);
    final items =
        await _loadFilteredItems(storeId, categoryId, state.searchQuery);
    state = state.copyWith(
      selectedCategoryId: categoryId,
      clearCategory: categoryId == null,
      items: items,
      isLoading: false,
    );
  }

  /// Called as the cashier types in the search bar.
  Future<void> updateSearch(String query) async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId.isEmpty) return;

    final items =
        await _loadFilteredItems(storeId, state.selectedCategoryId, query);
    state = state.copyWith(
      searchQuery: query,
      items: items,
    );
  }
}

/// Provider for the menu browsing state.
final menuProvider = NotifierProvider<MenuNotifier, MenuState>(
  MenuNotifier.new,
);
