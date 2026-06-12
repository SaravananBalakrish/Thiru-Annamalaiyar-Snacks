// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Order extends Order {
  @override
  final int? id;
  @override
  final int? userId;
  @override
  final String? totalPrice;
  @override
  final DateTime? createdAt;
  @override
  final String? paymentMethod;
  @override
  final String? paymentStatus;
  @override
  final String? transactionRef;
  @override
  final String? upiUri;
  @override
  final String? qrCodeUrl;
  @override
  final BuiltList<OrderItem>? items;

  factory _$Order([void Function(OrderBuilder)? updates]) =>
      (OrderBuilder()..update(updates))._build();

  _$Order._({
    this.id,
    this.userId,
    this.totalPrice,
    this.createdAt,
    this.paymentMethod,
    this.paymentStatus,
    this.transactionRef,
    this.upiUri,
    this.qrCodeUrl,
    this.items,
  }) : super._();
  @override
  Order rebuild(void Function(OrderBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OrderBuilder toBuilder() => OrderBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Order &&
        id == other.id &&
        userId == other.userId &&
        totalPrice == other.totalPrice &&
        createdAt == other.createdAt &&
        paymentMethod == other.paymentMethod &&
        paymentStatus == other.paymentStatus &&
        transactionRef == other.transactionRef &&
        upiUri == other.upiUri &&
        qrCodeUrl == other.qrCodeUrl &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, totalPrice.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, paymentMethod.hashCode);
    _$hash = $jc(_$hash, paymentStatus.hashCode);
    _$hash = $jc(_$hash, transactionRef.hashCode);
    _$hash = $jc(_$hash, upiUri.hashCode);
    _$hash = $jc(_$hash, qrCodeUrl.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Order')
          ..add('id', id)
          ..add('userId', userId)
          ..add('totalPrice', totalPrice)
          ..add('createdAt', createdAt)
          ..add('paymentMethod', paymentMethod)
          ..add('paymentStatus', paymentStatus)
          ..add('transactionRef', transactionRef)
          ..add('upiUri', upiUri)
          ..add('qrCodeUrl', qrCodeUrl)
          ..add('items', items))
        .toString();
  }
}

class OrderBuilder implements Builder<Order, OrderBuilder> {
  _$Order? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  int? _userId;
  int? get userId => _$this._userId;
  set userId(int? userId) => _$this._userId = userId;

  String? _totalPrice;
  String? get totalPrice => _$this._totalPrice;
  set totalPrice(String? totalPrice) => _$this._totalPrice = totalPrice;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _paymentMethod;
  String? get paymentMethod => _$this._paymentMethod;
  set paymentMethod(String? paymentMethod) =>
      _$this._paymentMethod = paymentMethod;

  String? _paymentStatus;
  String? get paymentStatus => _$this._paymentStatus;
  set paymentStatus(String? paymentStatus) =>
      _$this._paymentStatus = paymentStatus;

  String? _transactionRef;
  String? get transactionRef => _$this._transactionRef;
  set transactionRef(String? transactionRef) =>
      _$this._transactionRef = transactionRef;

  String? _upiUri;
  String? get upiUri => _$this._upiUri;
  set upiUri(String? upiUri) => _$this._upiUri = upiUri;

  String? _qrCodeUrl;
  String? get qrCodeUrl => _$this._qrCodeUrl;
  set qrCodeUrl(String? qrCodeUrl) => _$this._qrCodeUrl = qrCodeUrl;

  ListBuilder<OrderItem>? _items;
  ListBuilder<OrderItem> get items =>
      _$this._items ??= ListBuilder<OrderItem>();
  set items(ListBuilder<OrderItem>? items) => _$this._items = items;

  OrderBuilder() {
    Order._defaults(this);
  }

  OrderBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _totalPrice = $v.totalPrice;
      _createdAt = $v.createdAt;
      _paymentMethod = $v.paymentMethod;
      _paymentStatus = $v.paymentStatus;
      _transactionRef = $v.transactionRef;
      _upiUri = $v.upiUri;
      _qrCodeUrl = $v.qrCodeUrl;
      _items = $v.items?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Order other) {
    _$v = other as _$Order;
  }

  @override
  void update(void Function(OrderBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Order build() => _build();

  _$Order _build() {
    _$Order _$result;
    try {
      _$result =
          _$v ??
          _$Order._(
            id: id,
            userId: userId,
            totalPrice: totalPrice,
            createdAt: createdAt,
            paymentMethod: paymentMethod,
            paymentStatus: paymentStatus,
            transactionRef: transactionRef,
            upiUri: upiUri,
            qrCodeUrl: qrCodeUrl,
            items: _items?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        _items?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Order', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
