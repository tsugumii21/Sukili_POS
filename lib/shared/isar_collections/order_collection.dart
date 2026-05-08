import 'package:isar_community/isar.dart';

part 'order_collection.g.dart';

@collection
class OrderCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String syncId;

  @Index(unique: true)
  late String orderNumber;

  @Index()
  late String cashierId;
  late String cashierName;

  List<String> orderItemsJson = [];

  late double subtotal;
  late double discountAmount;
  String? discountReason;
  late double taxAmount;
  late double totalAmount;
  late double amountTendered;
  late double changeAmount;

  @Index()
  late String paymentMethod;
  String? paymentReference;

  @Index()
  late String status; // 'completed', 'voided', 'refunded'
  String? voidReason;
  String? refundReason;
  String? voidedById;
  DateTime? voidedAt;
  String? voidedByName;
  bool isPartialRefund = false;
  double? refundAmount;
  DateTime? refundedAt;
  String? refundedById;
  String? refundedByName;

  @Index()
  late DateTime orderedAt;

  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isSynced;
  late bool isDeleted;
}
