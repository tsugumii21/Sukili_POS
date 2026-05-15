/// CartItem represents a single line-item in the cashier's active order.
/// Each item tracks its source menu item, optional variant/modifiers, and quantity.
class CartItem {
  final String itemSyncId;
  final String itemName;
  final String? variantName;
  final double unitPrice;
  final int quantity;
  final List<String> modifiers;
  final String? notes;

  const CartItem({
    required this.itemSyncId,
    required this.itemName,
    this.variantName,
    required this.unitPrice,
    this.quantity = 1,
    this.modifiers = const [],
    this.notes,
  });

  /// Calculated subtotal for this line-item (unitPrice × quantity).
  double get subtotal => unitPrice * quantity;

  /// Unique key to differentiate items with different variants/modifiers in the cart.
  String get cartKey =>
      '$itemSyncId|${variantName ?? ''}|${modifiers.join(',')}';

  CartItem copyWith({
    String? itemSyncId,
    String? itemName,
    String? variantName,
    double? unitPrice,
    int? quantity,
    List<String>? modifiers,
    String? notes,
  }) {
    return CartItem(
      itemSyncId: itemSyncId ?? this.itemSyncId,
      itemName: itemName ?? this.itemName,
      variantName: variantName ?? this.variantName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      modifiers: modifiers ?? this.modifiers,
      notes: notes ?? this.notes,
    );
  }
}
