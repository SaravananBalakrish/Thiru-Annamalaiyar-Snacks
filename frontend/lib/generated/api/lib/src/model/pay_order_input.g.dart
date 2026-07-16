// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pay_order_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PayOrderInput extends PayOrderInput {
  @override
  final String transactionRef;

  factory _$PayOrderInput([void Function(PayOrderInputBuilder)? updates]) =>
      (PayOrderInputBuilder()..update(updates))._build();

  _$PayOrderInput._({required this.transactionRef}) : super._();
  @override
  PayOrderInput rebuild(void Function(PayOrderInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PayOrderInputBuilder toBuilder() => PayOrderInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PayOrderInput && transactionRef == other.transactionRef;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, transactionRef.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PayOrderInput')
          ..add('transactionRef', transactionRef))
        .toString();
  }
}

class PayOrderInputBuilder
    implements Builder<PayOrderInput, PayOrderInputBuilder> {
  _$PayOrderInput? _$v;

  String? _transactionRef;
  String? get transactionRef => _$this._transactionRef;
  set transactionRef(String? transactionRef) =>
      _$this._transactionRef = transactionRef;

  PayOrderInputBuilder() {
    PayOrderInput._defaults(this);
  }

  PayOrderInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _transactionRef = $v.transactionRef;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PayOrderInput other) {
    _$v = other as _$PayOrderInput;
  }

  @override
  void update(void Function(PayOrderInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PayOrderInput build() => _build();

  _$PayOrderInput _build() {
    final _$result = _$v ??
        _$PayOrderInput._(
          transactionRef: BuiltValueNullFieldError.checkNotNull(
              transactionRef, r'PayOrderInput', 'transactionRef'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
