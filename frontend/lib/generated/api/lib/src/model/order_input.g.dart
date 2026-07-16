// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OrderInput extends OrderInput {
  @override
  final int userId;
  @override
  final String? paymentMethod;

  factory _$OrderInput([void Function(OrderInputBuilder)? updates]) =>
      (OrderInputBuilder()..update(updates))._build();

  _$OrderInput._({required this.userId, this.paymentMethod}) : super._();
  @override
  OrderInput rebuild(void Function(OrderInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderInputBuilder toBuilder() => OrderInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderInput &&
        userId == other.userId &&
        paymentMethod == other.paymentMethod;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, paymentMethod.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OrderInput')
          ..add('userId', userId)
          ..add('paymentMethod', paymentMethod))
        .toString();
  }
}

class OrderInputBuilder implements Builder<OrderInput, OrderInputBuilder> {
  _$OrderInput? _$v;

  int? _userId;
  int? get userId => _$this._userId;
  set userId(int? userId) => _$this._userId = userId;

  String? _paymentMethod;
  String? get paymentMethod => _$this._paymentMethod;
  set paymentMethod(String? paymentMethod) =>
      _$this._paymentMethod = paymentMethod;

  OrderInputBuilder() {
    OrderInput._defaults(this);
  }

  OrderInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _paymentMethod = $v.paymentMethod;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OrderInput other) {
    _$v = other as _$OrderInput;
  }

  @override
  void update(void Function(OrderInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OrderInput build() => _build();

  _$OrderInput _build() {
    final _$result = _$v ??
        _$OrderInput._(
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'OrderInput', 'userId'),
          paymentMethod: paymentMethod,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
