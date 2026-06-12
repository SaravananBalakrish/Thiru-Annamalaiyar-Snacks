// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderItem extends OrderItem {
  @override
  final int? id;
  @override
  final int? orderId;
  @override
  final int? productId;
  @override
  final int? quantity;
  @override
  final String? price;

  factory _$OrderItem([void Function(OrderItemBuilder)? updates]) =>
      (OrderItemBuilder()..update(updates))._build();

  _$OrderItem._({
    this.id,
    this.orderId,
    this.productId,
    this.quantity,
    this.price,
  }) : super._();
  @override
  OrderItem rebuild(void Function(OrderItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderItemBuilder toBuilder() => OrderItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderItem &&
        id == other.id &&
        orderId == other.orderId &&
        productId == other.productId &&
        quantity == other.quantity &&
        price == other.price;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, orderId.hashCode);
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrderItem')
          ..add('id', id)
          ..add('orderId', orderId)
          ..add('productId', productId)
          ..add('quantity', quantity)
          ..add('price', price))
        .toString();
  }
}

class OrderItemBuilder implements Builder<OrderItem, OrderItemBuilder> {
  _$OrderItem? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  int? _orderId;
  int? get orderId => _$this._orderId;
  set orderId(int? orderId) => _$this._orderId = orderId;

  int? _productId;
  int? get productId => _$this._productId;
  set productId(int? productId) => _$this._productId = productId;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  String? _price;
  String? get price => _$this._price;
  set price(String? price) => _$this._price = price;

  OrderItemBuilder() {
    OrderItem._defaults(this);
  }

  OrderItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _orderId = $v.orderId;
      _productId = $v.productId;
      _quantity = $v.quantity;
      _price = $v.price;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderItem other) {
    _$v = other as _$OrderItem;
  }

  @override
  void update(void Function(OrderItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderItem build() => _build();

  _$OrderItem _build() {
    final _$result =
        _$v ??
        _$OrderItem._(
          id: id,
          orderId: orderId,
          productId: productId,
          quantity: quantity,
          price: price,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
