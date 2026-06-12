// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_patch.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CartPatch extends CartPatch {
  @override
  final int quantity;

  factory _$CartPatch([void Function(CartPatchBuilder)? updates]) =>
      (CartPatchBuilder()..update(updates))._build();

  _$CartPatch._({required this.quantity}) : super._();
  @override
  CartPatch rebuild(void Function(CartPatchBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CartPatchBuilder toBuilder() => CartPatchBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CartPatch && quantity == other.quantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'CartPatch',
    )..add('quantity', quantity)).toString();
  }
}

class CartPatchBuilder implements Builder<CartPatch, CartPatchBuilder> {
  _$CartPatch? _$v;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  CartPatchBuilder() {
    CartPatch._defaults(this);
  }

  CartPatchBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CartPatch other) {
    _$v = other as _$CartPatch;
  }

  @override
  void update(void Function(CartPatchBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CartPatch build() => _build();

  _$CartPatch _build() {
    final _$result =
        _$v ??
        _$CartPatch._(
          quantity: BuiltValueNullFieldError.checkNotNull(
            quantity,
            r'CartPatch',
            'quantity',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
