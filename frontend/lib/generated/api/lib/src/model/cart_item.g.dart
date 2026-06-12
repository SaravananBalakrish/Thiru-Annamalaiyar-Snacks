// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CartItem extends CartItem {
  @override
  final int? id;
  @override
  final int? quantity;
  @override
  final Product? product;

  factory _$CartItem([void Function(CartItemBuilder)? updates]) =>
      (CartItemBuilder()..update(updates))._build();

  _$CartItem._({this.id, this.quantity, this.product}) : super._();
  @override
  CartItem rebuild(void Function(CartItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CartItemBuilder toBuilder() => CartItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CartItem &&
        id == other.id &&
        quantity == other.quantity &&
        product == other.product;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, product.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CartItem')
          ..add('id', id)
          ..add('quantity', quantity)
          ..add('product', product))
        .toString();
  }
}

class CartItemBuilder implements Builder<CartItem, CartItemBuilder> {
  _$CartItem? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  ProductBuilder? _product;
  ProductBuilder get product => _$this._product ??= ProductBuilder();
  set product(ProductBuilder? product) => _$this._product = product;

  CartItemBuilder() {
    CartItem._defaults(this);
  }

  CartItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _quantity = $v.quantity;
      _product = $v.product?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CartItem other) {
    _$v = other as _$CartItem;
  }

  @override
  void update(void Function(CartItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CartItem build() => _build();

  _$CartItem _build() {
    _$CartItem _$result;
    try {
      _$result =
          _$v ??
          _$CartItem._(id: id, quantity: quantity, product: _product?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'product';
        _product?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'CartItem',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
