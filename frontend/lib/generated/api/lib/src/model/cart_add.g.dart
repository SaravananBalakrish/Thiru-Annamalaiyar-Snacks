// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_add.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CartAdd extends CartAdd {
  @override
  final int productId;
  @override
  final int? quantity;

  factory _$CartAdd([void Function(CartAddBuilder)? updates]) =>
      (CartAddBuilder()..update(updates))._build();

  _$CartAdd._({required this.productId, this.quantity}) : super._();
  @override
  CartAdd rebuild(void Function(CartAddBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CartAddBuilder toBuilder() => CartAddBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CartAdd &&
        productId == other.productId &&
        quantity == other.quantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CartAdd')
          ..add('productId', productId)
          ..add('quantity', quantity))
        .toString();
  }
}

class CartAddBuilder implements Builder<CartAdd, CartAddBuilder> {
  _$CartAdd? _$v;

  int? _productId;
  int? get productId => _$this._productId;
  set productId(int? productId) => _$this._productId = productId;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  CartAddBuilder() {
    CartAdd._defaults(this);
  }

  CartAddBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _productId = $v.productId;
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CartAdd other) {
    _$v = other as _$CartAdd;
  }

  @override
  void update(void Function(CartAddBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CartAdd build() => _build();

  _$CartAdd _build() {
    final _$result =
        _$v ??
        _$CartAdd._(
          productId: BuiltValueNullFieldError.checkNotNull(
            productId,
            r'CartAdd',
            'productId',
          ),
          quantity: quantity,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
