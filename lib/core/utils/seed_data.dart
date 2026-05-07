import 'dart:convert';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';
import 'pin_helper.dart';
import '../../shared/isar_collections/user_collection.dart';
import '../../shared/isar_collections/category_collection.dart';
import '../../shared/isar_collections/menu_item_collection.dart';

/// SeedData provides initial idempotent data for Sukli POS.
class SeedData {
  static const _uuid = Uuid();

  static Future<void> seedInitialData(Isar isar) async {
    final now = DateTime.now();

    // 1. Seed Users (Admin & Cashiers)
    final existingUsers = await isar.userCollections.count();
    if (existingUsers == 0) {
      await isar.writeTxn(() async {
        final users = [
          UserCollection()
            ..syncId = _uuid.v4()
            ..name = "Juan Dela Cruz"
            ..email = "juan@example.com"
            ..pinHash = PinHelper.hashPin("1234")
            ..role = "cashier"
            ..status = "active"
            ..createdAt = now
            ..updatedAt = now
            ..isSynced = false
            ..isDeleted = false,
          UserCollection()
            ..syncId = _uuid.v4()
            ..name = "Maria Santos"
            ..email = "maria@example.com"
            ..pinHash = PinHelper.hashPin("5678")
            ..role = "cashier"
            ..status = "active"
            ..createdAt = now
            ..updatedAt = now
            ..isSynced = false
            ..isDeleted = false,
          UserCollection()
            ..syncId = _uuid.v4()
            ..name = "Pedro Reyes"
            ..email = "pedro@example.com"
            ..pinHash = PinHelper.hashPin("0000")
            ..role = "cashier"
            ..status = "inactive"
            ..createdAt = now
            ..updatedAt = now
            ..isSynced = false
            ..isDeleted = false,
        ];
        await isar.userCollections.putAll(users);
      });
    }

    // 2. Seed Categories
    final existingCats = await isar.categoryCollections.count();
    if (existingCats == 0) {
      await isar.writeTxn(() async {
        final categories = [
          ('Beverages', '☕', 1),
          ('Food', '🍽️', 2),
          ('Snacks', '🍿', 3),
          ('Desserts', '🍰', 4),
        ].map((data) => CategoryCollection()
          ..syncId = _uuid.v4()
          ..name = data.$1
          ..iconEmoji = data.$2
          ..sortOrder = data.$3
          ..isActive = true
          ..createdAt = now
          ..updatedAt = now
          ..isSynced = false
          ..isDeleted = false).toList();
        
        await isar.categoryCollections.putAll(categories);
        
        // 3. Seed Menu Items (Linked to Category syncId)
        final beveragesId = categories[0].syncId;
        final foodId = categories[1].syncId;
        final dessertsId = categories[3].syncId;

        await isar.menuItemCollections.putAll([
          MenuItemCollection()
            ..syncId = _uuid.v4()
            ..categoryId = beveragesId
            ..name = "Iced Coffee"
            ..basePrice = 65
            ..isAvailable = true
            ..isFavorite = true
            ..trackInventory = false
            ..sortOrder = 1
            ..variantsJson = [
              jsonEncode({"name": "Small", "priceDelta": 0}),
              jsonEncode({"name": "Medium", "priceDelta": 10}),
              jsonEncode({"name": "Large", "priceDelta": 20}),
            ]
            ..createdAt = now
            ..updatedAt = now
            ..isSynced = false
            ..isDeleted = false,
          MenuItemCollection()
            ..syncId = _uuid.v4()
            ..categoryId = foodId
            ..name = "Pork Adobo Rice"
            ..basePrice = 120
            ..isAvailable = true
            ..isFavorite = true
            ..trackInventory = true
            ..stockQuantity = 50
            ..sortOrder = 1
            ..createdAt = now
            ..updatedAt = now
            ..isSynced = false
            ..isDeleted = false,
          MenuItemCollection()
            ..syncId = _uuid.v4()
            ..categoryId = dessertsId
            ..name = "Leche Flan"
            ..basePrice = 55
            ..isAvailable = true
            ..isFavorite = false
            ..trackInventory = true
            ..stockQuantity = 20
            ..sortOrder = 1
            ..createdAt = now
            ..updatedAt = now
            ..isSynced = false
            ..isDeleted = false,
          MenuItemCollection()
            ..syncId = _uuid.v4()
            ..categoryId = foodId
            ..name = "Chicken Fillet Meal"
            ..description = "Crispy chicken fillet served with rice and gravy"
            ..basePrice = 85
            ..isAvailable = true
            ..isFavorite = true
            ..trackInventory = true
            ..stockQuantity = 30
            ..sortOrder = 2
            ..variantsJson = [
              jsonEncode({"name": "Regular", "priceDelta": 0}),
              jsonEncode({"name": "Large", "priceDelta": 20}),
            ]
            ..modifiersJson = [
              jsonEncode({"groupName": "Add-ons", "name": "Extra Rice", "priceDelta": 20}),
              jsonEncode({"groupName": "Add-ons", "name": "Drinks", "priceDelta": 35}),
            ]
            ..createdAt = now
            ..updatedAt = now
            ..isSynced = false
            ..isDeleted = false,
        ]);
      });
    }
  }
}

