/// SupabaseConstants provides centralized table and column naming.
class SupabaseConstants {
  // Table names
  static const String usersTable = 'users';
  static const String categoriesTable = 'categories';
  static const String menuItemsTable = 'menu_items';
  static const String ordersTable = 'orders';
  // Common columns
  static const String syncId = 'sync_id';
  static const String updatedAt = 'updated_at';
  static const String createdAt = 'created_at';
  static const String isDeleted = 'is_deleted';

  // Users columns
  static const String userName = 'name';
  static const String userEmail = 'email';
  static const String userPinHash = 'pin_hash';
  static const String userRole = 'role';
  static const String userStatus = 'status';
  static const String userAvatarUrl = 'avatar_url';

  // Categories columns
  static const String categoryName = 'name';
  static const String categorySortOrder = 'sort_order';
  static const String categoryIsActive = 'is_active';
  static const String categoryIconEmoji = 'icon_emoji';

  // Menu items columns
  static const String menuItemCategoryId = 'category_id';
  static const String menuItemName = 'name';
  static const String menuItemBasePrice = 'base_price';
  static const String menuItemIsAvailable = 'is_available';
  static const String menuItemVariantsJson = 'variants_json';
  static const String menuItemModifiersJson = 'modifiers_json';

  // Orders columns
  static const String orderNumber = 'order_number';
  static const String orderCashierId = 'cashier_id';
  static const String orderTotalAmount = 'total_amount';
  static const String orderStatus = 'status';
  static const String orderPaymentMethod = 'payment_method';
  static const String orderOrderedAt = 'ordered_at';

  // Roles values
  static const String roleAdmin = 'admin';
  static const String roleCashier = 'cashier';

  // Statuses values
  static const String statusActive = 'active';
  static const String statusInactive = 'inactive';
  static const String orderStatusCompleted = 'completed';
  static const String orderStatusVoided = 'voided';
  static const String orderStatusRefunded = 'refunded';

  // Stores table
  static const String storesTable = 'stores';
  static const String storeName = 'name';
  static const String storeLogoUrl = 'logo_url';
  static const String storeOwnerId = 'owner_id';
  static const String storeAuthUid = 'supabase_auth_uid';
  static const String storeId = 'store_id';

  // Storage bucket
  static const String storageStoreAssets = 'store-assets';
}
