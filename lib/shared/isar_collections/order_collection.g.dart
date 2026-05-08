// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOrderCollectionCollection on Isar {
  IsarCollection<OrderCollection> get orderCollections => this.collection();
}

const OrderCollectionSchema = CollectionSchema(
  name: r'OrderCollection',
  id: -17946153983657778,
  properties: {
    r'amountTendered': PropertySchema(
      id: 0,
      name: r'amountTendered',
      type: IsarType.double,
    ),
    r'cashierId': PropertySchema(
      id: 1,
      name: r'cashierId',
      type: IsarType.string,
    ),
    r'cashierName': PropertySchema(
      id: 2,
      name: r'cashierName',
      type: IsarType.string,
    ),
    r'changeAmount': PropertySchema(
      id: 3,
      name: r'changeAmount',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'discountAmount': PropertySchema(
      id: 5,
      name: r'discountAmount',
      type: IsarType.double,
    ),
    r'discountReason': PropertySchema(
      id: 6,
      name: r'discountReason',
      type: IsarType.string,
    ),
    r'isDeleted': PropertySchema(
      id: 7,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'isPartialRefund': PropertySchema(
      id: 8,
      name: r'isPartialRefund',
      type: IsarType.bool,
    ),
    r'isSynced': PropertySchema(
      id: 9,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'orderItemsJson': PropertySchema(
      id: 10,
      name: r'orderItemsJson',
      type: IsarType.stringList,
    ),
    r'orderNumber': PropertySchema(
      id: 11,
      name: r'orderNumber',
      type: IsarType.string,
    ),
    r'orderedAt': PropertySchema(
      id: 12,
      name: r'orderedAt',
      type: IsarType.dateTime,
    ),
    r'paymentMethod': PropertySchema(
      id: 13,
      name: r'paymentMethod',
      type: IsarType.string,
    ),
    r'paymentReference': PropertySchema(
      id: 14,
      name: r'paymentReference',
      type: IsarType.string,
    ),
    r'refundAmount': PropertySchema(
      id: 15,
      name: r'refundAmount',
      type: IsarType.double,
    ),
    r'refundReason': PropertySchema(
      id: 16,
      name: r'refundReason',
      type: IsarType.string,
    ),
    r'refundedAt': PropertySchema(
      id: 17,
      name: r'refundedAt',
      type: IsarType.dateTime,
    ),
    r'refundedById': PropertySchema(
      id: 18,
      name: r'refundedById',
      type: IsarType.string,
    ),
    r'refundedByName': PropertySchema(
      id: 19,
      name: r'refundedByName',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 20,
      name: r'status',
      type: IsarType.string,
    ),
    r'subtotal': PropertySchema(
      id: 21,
      name: r'subtotal',
      type: IsarType.double,
    ),
    r'syncId': PropertySchema(
      id: 22,
      name: r'syncId',
      type: IsarType.string,
    ),
    r'taxAmount': PropertySchema(
      id: 23,
      name: r'taxAmount',
      type: IsarType.double,
    ),
    r'totalAmount': PropertySchema(
      id: 24,
      name: r'totalAmount',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 25,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'voidReason': PropertySchema(
      id: 26,
      name: r'voidReason',
      type: IsarType.string,
    ),
    r'voidedAt': PropertySchema(
      id: 27,
      name: r'voidedAt',
      type: IsarType.dateTime,
    ),
    r'voidedById': PropertySchema(
      id: 28,
      name: r'voidedById',
      type: IsarType.string,
    ),
    r'voidedByName': PropertySchema(
      id: 29,
      name: r'voidedByName',
      type: IsarType.string,
    )
  },
  estimateSize: _orderCollectionEstimateSize,
  serialize: _orderCollectionSerialize,
  deserialize: _orderCollectionDeserialize,
  deserializeProp: _orderCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'syncId': IndexSchema(
      id: 7538593479801827566,
      name: r'syncId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'syncId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'orderNumber': IndexSchema(
      id: 7506692016205733885,
      name: r'orderNumber',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'orderNumber',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'cashierId': IndexSchema(
      id: -7056910165772930902,
      name: r'cashierId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'cashierId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'paymentMethod': IndexSchema(
      id: 8757296919228604195,
      name: r'paymentMethod',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'paymentMethod',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'orderedAt': IndexSchema(
      id: 3831417329224709269,
      name: r'orderedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'orderedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _orderCollectionGetId,
  getLinks: _orderCollectionGetLinks,
  attach: _orderCollectionAttach,
  version: '3.3.2',
);

int _orderCollectionEstimateSize(
  OrderCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cashierId.length * 3;
  bytesCount += 3 + object.cashierName.length * 3;
  {
    final value = object.discountReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.orderItemsJson.length * 3;
  {
    for (var i = 0; i < object.orderItemsJson.length; i++) {
      final value = object.orderItemsJson[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.orderNumber.length * 3;
  bytesCount += 3 + object.paymentMethod.length * 3;
  {
    final value = object.paymentReference;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.refundReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.refundedById;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.refundedByName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.syncId.length * 3;
  {
    final value = object.voidReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.voidedById;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.voidedByName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _orderCollectionSerialize(
  OrderCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amountTendered);
  writer.writeString(offsets[1], object.cashierId);
  writer.writeString(offsets[2], object.cashierName);
  writer.writeDouble(offsets[3], object.changeAmount);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeDouble(offsets[5], object.discountAmount);
  writer.writeString(offsets[6], object.discountReason);
  writer.writeBool(offsets[7], object.isDeleted);
  writer.writeBool(offsets[8], object.isPartialRefund);
  writer.writeBool(offsets[9], object.isSynced);
  writer.writeStringList(offsets[10], object.orderItemsJson);
  writer.writeString(offsets[11], object.orderNumber);
  writer.writeDateTime(offsets[12], object.orderedAt);
  writer.writeString(offsets[13], object.paymentMethod);
  writer.writeString(offsets[14], object.paymentReference);
  writer.writeDouble(offsets[15], object.refundAmount);
  writer.writeString(offsets[16], object.refundReason);
  writer.writeDateTime(offsets[17], object.refundedAt);
  writer.writeString(offsets[18], object.refundedById);
  writer.writeString(offsets[19], object.refundedByName);
  writer.writeString(offsets[20], object.status);
  writer.writeDouble(offsets[21], object.subtotal);
  writer.writeString(offsets[22], object.syncId);
  writer.writeDouble(offsets[23], object.taxAmount);
  writer.writeDouble(offsets[24], object.totalAmount);
  writer.writeDateTime(offsets[25], object.updatedAt);
  writer.writeString(offsets[26], object.voidReason);
  writer.writeDateTime(offsets[27], object.voidedAt);
  writer.writeString(offsets[28], object.voidedById);
  writer.writeString(offsets[29], object.voidedByName);
}

OrderCollection _orderCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OrderCollection();
  object.amountTendered = reader.readDouble(offsets[0]);
  object.cashierId = reader.readString(offsets[1]);
  object.cashierName = reader.readString(offsets[2]);
  object.changeAmount = reader.readDouble(offsets[3]);
  object.createdAt = reader.readDateTime(offsets[4]);
  object.discountAmount = reader.readDouble(offsets[5]);
  object.discountReason = reader.readStringOrNull(offsets[6]);
  object.id = id;
  object.isDeleted = reader.readBool(offsets[7]);
  object.isPartialRefund = reader.readBool(offsets[8]);
  object.isSynced = reader.readBool(offsets[9]);
  object.orderItemsJson = reader.readStringList(offsets[10]) ?? [];
  object.orderNumber = reader.readString(offsets[11]);
  object.orderedAt = reader.readDateTime(offsets[12]);
  object.paymentMethod = reader.readString(offsets[13]);
  object.paymentReference = reader.readStringOrNull(offsets[14]);
  object.refundAmount = reader.readDoubleOrNull(offsets[15]);
  object.refundReason = reader.readStringOrNull(offsets[16]);
  object.refundedAt = reader.readDateTimeOrNull(offsets[17]);
  object.refundedById = reader.readStringOrNull(offsets[18]);
  object.refundedByName = reader.readStringOrNull(offsets[19]);
  object.status = reader.readString(offsets[20]);
  object.subtotal = reader.readDouble(offsets[21]);
  object.syncId = reader.readString(offsets[22]);
  object.taxAmount = reader.readDouble(offsets[23]);
  object.totalAmount = reader.readDouble(offsets[24]);
  object.updatedAt = reader.readDateTime(offsets[25]);
  object.voidReason = reader.readStringOrNull(offsets[26]);
  object.voidedAt = reader.readDateTimeOrNull(offsets[27]);
  object.voidedById = reader.readStringOrNull(offsets[28]);
  object.voidedByName = reader.readStringOrNull(offsets[29]);
  return object;
}

P _orderCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readStringList(offset) ?? []) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readDoubleOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readDouble(offset)) as P;
    case 22:
      return (reader.readString(offset)) as P;
    case 23:
      return (reader.readDouble(offset)) as P;
    case 24:
      return (reader.readDouble(offset)) as P;
    case 25:
      return (reader.readDateTime(offset)) as P;
    case 26:
      return (reader.readStringOrNull(offset)) as P;
    case 27:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 28:
      return (reader.readStringOrNull(offset)) as P;
    case 29:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _orderCollectionGetId(OrderCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _orderCollectionGetLinks(OrderCollection object) {
  return [];
}

void _orderCollectionAttach(
    IsarCollection<dynamic> col, Id id, OrderCollection object) {
  object.id = id;
}

extension OrderCollectionByIndex on IsarCollection<OrderCollection> {
  Future<OrderCollection?> getBySyncId(String syncId) {
    return getByIndex(r'syncId', [syncId]);
  }

  OrderCollection? getBySyncIdSync(String syncId) {
    return getByIndexSync(r'syncId', [syncId]);
  }

  Future<bool> deleteBySyncId(String syncId) {
    return deleteByIndex(r'syncId', [syncId]);
  }

  bool deleteBySyncIdSync(String syncId) {
    return deleteByIndexSync(r'syncId', [syncId]);
  }

  Future<List<OrderCollection?>> getAllBySyncId(List<String> syncIdValues) {
    final values = syncIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'syncId', values);
  }

  List<OrderCollection?> getAllBySyncIdSync(List<String> syncIdValues) {
    final values = syncIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'syncId', values);
  }

  Future<int> deleteAllBySyncId(List<String> syncIdValues) {
    final values = syncIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'syncId', values);
  }

  int deleteAllBySyncIdSync(List<String> syncIdValues) {
    final values = syncIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'syncId', values);
  }

  Future<Id> putBySyncId(OrderCollection object) {
    return putByIndex(r'syncId', object);
  }

  Id putBySyncIdSync(OrderCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'syncId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySyncId(List<OrderCollection> objects) {
    return putAllByIndex(r'syncId', objects);
  }

  List<Id> putAllBySyncIdSync(List<OrderCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'syncId', objects, saveLinks: saveLinks);
  }

  Future<OrderCollection?> getByOrderNumber(String orderNumber) {
    return getByIndex(r'orderNumber', [orderNumber]);
  }

  OrderCollection? getByOrderNumberSync(String orderNumber) {
    return getByIndexSync(r'orderNumber', [orderNumber]);
  }

  Future<bool> deleteByOrderNumber(String orderNumber) {
    return deleteByIndex(r'orderNumber', [orderNumber]);
  }

  bool deleteByOrderNumberSync(String orderNumber) {
    return deleteByIndexSync(r'orderNumber', [orderNumber]);
  }

  Future<List<OrderCollection?>> getAllByOrderNumber(
      List<String> orderNumberValues) {
    final values = orderNumberValues.map((e) => [e]).toList();
    return getAllByIndex(r'orderNumber', values);
  }

  List<OrderCollection?> getAllByOrderNumberSync(
      List<String> orderNumberValues) {
    final values = orderNumberValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'orderNumber', values);
  }

  Future<int> deleteAllByOrderNumber(List<String> orderNumberValues) {
    final values = orderNumberValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'orderNumber', values);
  }

  int deleteAllByOrderNumberSync(List<String> orderNumberValues) {
    final values = orderNumberValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'orderNumber', values);
  }

  Future<Id> putByOrderNumber(OrderCollection object) {
    return putByIndex(r'orderNumber', object);
  }

  Id putByOrderNumberSync(OrderCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'orderNumber', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOrderNumber(List<OrderCollection> objects) {
    return putAllByIndex(r'orderNumber', objects);
  }

  List<Id> putAllByOrderNumberSync(List<OrderCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'orderNumber', objects, saveLinks: saveLinks);
  }
}

extension OrderCollectionQueryWhereSort
    on QueryBuilder<OrderCollection, OrderCollection, QWhere> {
  QueryBuilder<OrderCollection, OrderCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhere> anyOrderedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'orderedAt'),
      );
    });
  }
}

extension OrderCollectionQueryWhere
    on QueryBuilder<OrderCollection, OrderCollection, QWhereClause> {
  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause>
      syncIdEqualTo(String syncId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncId',
        value: [syncId],
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause>
      syncIdNotEqualTo(String syncId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncId',
              lower: [],
              upper: [syncId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncId',
              lower: [syncId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncId',
              lower: [syncId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncId',
              lower: [],
              upper: [syncId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause>
      orderNumberEqualTo(String orderNumber) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'orderNumber',
        value: [orderNumber],
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause>
      orderNumberNotEqualTo(String orderNumber) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'orderNumber',
              lower: [],
              upper: [orderNumber],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'orderNumber',
              lower: [orderNumber],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'orderNumber',
              lower: [orderNumber],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'orderNumber',
              lower: [],
              upper: [orderNumber],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause>
      cashierIdEqualTo(String cashierId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cashierId',
        value: [cashierId],
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause>
      cashierIdNotEqualTo(String cashierId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cashierId',
              lower: [],
              upper: [cashierId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cashierId',
              lower: [cashierId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cashierId',
              lower: [cashierId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cashierId',
              lower: [],
              upper: [cashierId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause>
      paymentMethodEqualTo(String paymentMethod) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'paymentMethod',
        value: [paymentMethod],
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause>
      paymentMethodNotEqualTo(String paymentMethod) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentMethod',
              lower: [],
              upper: [paymentMethod],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentMethod',
              lower: [paymentMethod],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentMethod',
              lower: [paymentMethod],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentMethod',
              lower: [],
              upper: [paymentMethod],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause>
      statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause>
      statusNotEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause>
      orderedAtEqualTo(DateTime orderedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'orderedAt',
        value: [orderedAt],
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause>
      orderedAtNotEqualTo(DateTime orderedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'orderedAt',
              lower: [],
              upper: [orderedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'orderedAt',
              lower: [orderedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'orderedAt',
              lower: [orderedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'orderedAt',
              lower: [],
              upper: [orderedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause>
      orderedAtGreaterThan(
    DateTime orderedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'orderedAt',
        lower: [orderedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause>
      orderedAtLessThan(
    DateTime orderedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'orderedAt',
        lower: [],
        upper: [orderedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterWhereClause>
      orderedAtBetween(
    DateTime lowerOrderedAt,
    DateTime upperOrderedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'orderedAt',
        lower: [lowerOrderedAt],
        includeLower: includeLower,
        upper: [upperOrderedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension OrderCollectionQueryFilter
    on QueryBuilder<OrderCollection, OrderCollection, QFilterCondition> {
  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      amountTenderedEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amountTendered',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      amountTenderedGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amountTendered',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      amountTenderedLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amountTendered',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      amountTenderedBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amountTendered',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cashierId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cashierId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cashierId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cashierId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cashierId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cashierId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cashierId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cashierId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cashierId',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cashierId',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cashierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cashierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cashierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cashierName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cashierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cashierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cashierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cashierName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cashierName',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      cashierNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cashierName',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      changeAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'changeAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      changeAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'changeAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      changeAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'changeAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      changeAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'changeAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      discountAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'discountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      discountAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'discountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      discountAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'discountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      discountAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'discountAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      discountReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'discountReason',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      discountReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'discountReason',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      discountReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'discountReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      discountReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'discountReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      discountReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'discountReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      discountReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'discountReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      discountReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'discountReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      discountReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'discountReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      discountReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'discountReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      discountReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'discountReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      discountReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'discountReason',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      discountReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'discountReason',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      isPartialRefundEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPartialRefund',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderItemsJsonElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orderItemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderItemsJsonElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'orderItemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderItemsJsonElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'orderItemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderItemsJsonElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'orderItemsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderItemsJsonElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'orderItemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderItemsJsonElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'orderItemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderItemsJsonElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'orderItemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderItemsJsonElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'orderItemsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderItemsJsonElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orderItemsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderItemsJsonElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'orderItemsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderItemsJsonLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'orderItemsJson',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderItemsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'orderItemsJson',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderItemsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'orderItemsJson',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderItemsJsonLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'orderItemsJson',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderItemsJsonLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'orderItemsJson',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderItemsJsonLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'orderItemsJson',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orderNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'orderNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'orderNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'orderNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'orderNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'orderNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'orderNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'orderNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orderNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'orderNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orderedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'orderedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'orderedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      orderedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'orderedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentMethodEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentMethodGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentMethodLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentMethodBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentMethod',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentMethodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentMethodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentMethodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentMethodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'paymentMethod',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentMethodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentMethodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'paymentMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentReferenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'paymentReference',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentReferenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'paymentReference',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentReferenceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentReferenceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentReferenceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentReferenceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentReference',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentReferenceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'paymentReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentReferenceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'paymentReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentReferenceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'paymentReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentReferenceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'paymentReference',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentReferenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentReference',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      paymentReferenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'paymentReference',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'refundAmount',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'refundAmount',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'refundAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'refundAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'refundAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'refundAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'refundReason',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'refundReason',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'refundReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'refundReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'refundReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'refundReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'refundReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'refundReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'refundReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'refundReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'refundReason',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'refundReason',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'refundedAt',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'refundedAt',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'refundedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'refundedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'refundedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'refundedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'refundedById',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'refundedById',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'refundedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'refundedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'refundedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'refundedById',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'refundedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'refundedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'refundedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'refundedById',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'refundedById',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'refundedById',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'refundedByName',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'refundedByName',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'refundedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'refundedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'refundedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'refundedByName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'refundedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'refundedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'refundedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'refundedByName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'refundedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      refundedByNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'refundedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      subtotalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      subtotalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      subtotalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      subtotalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subtotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      syncIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      syncIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      syncIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      syncIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      syncIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      syncIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      syncIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      syncIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      syncIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncId',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      syncIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncId',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      taxAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taxAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      taxAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taxAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      taxAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taxAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      taxAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taxAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      totalAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      totalAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      totalAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      totalAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'voidReason',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'voidReason',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voidReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'voidReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'voidReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'voidReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'voidReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'voidReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'voidReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'voidReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voidReason',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'voidReason',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'voidedAt',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'voidedAt',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voidedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'voidedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'voidedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'voidedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'voidedById',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'voidedById',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voidedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'voidedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'voidedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'voidedById',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'voidedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'voidedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'voidedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'voidedById',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voidedById',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'voidedById',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'voidedByName',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'voidedByName',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voidedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'voidedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'voidedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'voidedByName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'voidedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'voidedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'voidedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'voidedByName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voidedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterFilterCondition>
      voidedByNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'voidedByName',
        value: '',
      ));
    });
  }
}

extension OrderCollectionQueryObject
    on QueryBuilder<OrderCollection, OrderCollection, QFilterCondition> {}

extension OrderCollectionQueryLinks
    on QueryBuilder<OrderCollection, OrderCollection, QFilterCondition> {}

extension OrderCollectionQuerySortBy
    on QueryBuilder<OrderCollection, OrderCollection, QSortBy> {
  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByAmountTendered() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountTendered', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByAmountTenderedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountTendered', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByCashierId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashierId', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByCashierIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashierId', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByCashierName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashierName', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByCashierNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashierName', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByChangeAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAmount', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByChangeAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAmount', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountAmount', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByDiscountAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountAmount', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByDiscountReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountReason', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByDiscountReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountReason', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByIsPartialRefund() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPartialRefund', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByIsPartialRefundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPartialRefund', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByOrderNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderNumber', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByOrderNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderNumber', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByOrderedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderedAt', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByOrderedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderedAt', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByPaymentReference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentReference', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByPaymentReferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentReference', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByRefundAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundAmount', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByRefundAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundAmount', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByRefundReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundReason', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByRefundReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundReason', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByRefundedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundedAt', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByRefundedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundedAt', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByRefundedById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundedById', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByRefundedByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundedById', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByRefundedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundedByName', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByRefundedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundedByName', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortBySubtotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy> sortBySyncId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncId', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortBySyncIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncId', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByTaxAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taxAmount', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByTaxAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taxAmount', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByVoidReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voidReason', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByVoidReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voidReason', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByVoidedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voidedAt', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByVoidedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voidedAt', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByVoidedById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voidedById', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByVoidedByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voidedById', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByVoidedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voidedByName', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      sortByVoidedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voidedByName', Sort.desc);
    });
  }
}

extension OrderCollectionQuerySortThenBy
    on QueryBuilder<OrderCollection, OrderCollection, QSortThenBy> {
  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByAmountTendered() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountTendered', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByAmountTenderedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountTendered', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByCashierId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashierId', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByCashierIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashierId', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByCashierName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashierName', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByCashierNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashierName', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByChangeAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAmount', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByChangeAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAmount', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountAmount', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByDiscountAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountAmount', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByDiscountReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountReason', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByDiscountReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountReason', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByIsPartialRefund() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPartialRefund', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByIsPartialRefundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPartialRefund', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByOrderNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderNumber', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByOrderNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderNumber', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByOrderedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderedAt', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByOrderedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderedAt', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByPaymentReference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentReference', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByPaymentReferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentReference', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByRefundAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundAmount', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByRefundAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundAmount', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByRefundReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundReason', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByRefundReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundReason', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByRefundedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundedAt', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByRefundedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundedAt', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByRefundedById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundedById', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByRefundedByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundedById', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByRefundedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundedByName', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByRefundedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refundedByName', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenBySubtotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy> thenBySyncId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncId', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenBySyncIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncId', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByTaxAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taxAmount', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByTaxAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taxAmount', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByVoidReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voidReason', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByVoidReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voidReason', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByVoidedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voidedAt', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByVoidedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voidedAt', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByVoidedById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voidedById', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByVoidedByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voidedById', Sort.desc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByVoidedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voidedByName', Sort.asc);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QAfterSortBy>
      thenByVoidedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voidedByName', Sort.desc);
    });
  }
}

extension OrderCollectionQueryWhereDistinct
    on QueryBuilder<OrderCollection, OrderCollection, QDistinct> {
  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByAmountTendered() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amountTendered');
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct> distinctByCashierId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cashierId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByCashierName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cashierName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByChangeAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'changeAmount');
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'discountAmount');
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByDiscountReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'discountReason',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByIsPartialRefund() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPartialRefund');
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByOrderItemsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orderItemsJson');
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByOrderNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orderNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByOrderedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orderedAt');
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByPaymentMethod({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentMethod',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByPaymentReference({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentReference',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByRefundAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'refundAmount');
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByRefundReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'refundReason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByRefundedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'refundedAt');
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByRefundedById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'refundedById', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByRefundedByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'refundedByName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subtotal');
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct> distinctBySyncId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByTaxAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taxAmount');
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAmount');
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByVoidReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'voidReason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByVoidedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'voidedAt');
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByVoidedById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'voidedById', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OrderCollection, OrderCollection, QDistinct>
      distinctByVoidedByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'voidedByName', caseSensitive: caseSensitive);
    });
  }
}

extension OrderCollectionQueryProperty
    on QueryBuilder<OrderCollection, OrderCollection, QQueryProperty> {
  QueryBuilder<OrderCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OrderCollection, double, QQueryOperations>
      amountTenderedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amountTendered');
    });
  }

  QueryBuilder<OrderCollection, String, QQueryOperations> cashierIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cashierId');
    });
  }

  QueryBuilder<OrderCollection, String, QQueryOperations>
      cashierNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cashierName');
    });
  }

  QueryBuilder<OrderCollection, double, QQueryOperations>
      changeAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'changeAmount');
    });
  }

  QueryBuilder<OrderCollection, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<OrderCollection, double, QQueryOperations>
      discountAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'discountAmount');
    });
  }

  QueryBuilder<OrderCollection, String?, QQueryOperations>
      discountReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'discountReason');
    });
  }

  QueryBuilder<OrderCollection, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<OrderCollection, bool, QQueryOperations>
      isPartialRefundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPartialRefund');
    });
  }

  QueryBuilder<OrderCollection, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<OrderCollection, List<String>, QQueryOperations>
      orderItemsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orderItemsJson');
    });
  }

  QueryBuilder<OrderCollection, String, QQueryOperations>
      orderNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orderNumber');
    });
  }

  QueryBuilder<OrderCollection, DateTime, QQueryOperations>
      orderedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orderedAt');
    });
  }

  QueryBuilder<OrderCollection, String, QQueryOperations>
      paymentMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentMethod');
    });
  }

  QueryBuilder<OrderCollection, String?, QQueryOperations>
      paymentReferenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentReference');
    });
  }

  QueryBuilder<OrderCollection, double?, QQueryOperations>
      refundAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'refundAmount');
    });
  }

  QueryBuilder<OrderCollection, String?, QQueryOperations>
      refundReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'refundReason');
    });
  }

  QueryBuilder<OrderCollection, DateTime?, QQueryOperations>
      refundedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'refundedAt');
    });
  }

  QueryBuilder<OrderCollection, String?, QQueryOperations>
      refundedByIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'refundedById');
    });
  }

  QueryBuilder<OrderCollection, String?, QQueryOperations>
      refundedByNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'refundedByName');
    });
  }

  QueryBuilder<OrderCollection, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<OrderCollection, double, QQueryOperations> subtotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subtotal');
    });
  }

  QueryBuilder<OrderCollection, String, QQueryOperations> syncIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncId');
    });
  }

  QueryBuilder<OrderCollection, double, QQueryOperations> taxAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taxAmount');
    });
  }

  QueryBuilder<OrderCollection, double, QQueryOperations>
      totalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAmount');
    });
  }

  QueryBuilder<OrderCollection, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<OrderCollection, String?, QQueryOperations>
      voidReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'voidReason');
    });
  }

  QueryBuilder<OrderCollection, DateTime?, QQueryOperations>
      voidedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'voidedAt');
    });
  }

  QueryBuilder<OrderCollection, String?, QQueryOperations>
      voidedByIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'voidedById');
    });
  }

  QueryBuilder<OrderCollection, String?, QQueryOperations>
      voidedByNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'voidedByName');
    });
  }
}
