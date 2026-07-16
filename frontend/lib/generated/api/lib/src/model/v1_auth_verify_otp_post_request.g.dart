// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v1_auth_verify_otp_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$V1AuthVerifyOtpPostRequest extends V1AuthVerifyOtpPostRequest {
  @override
  final String phone;
  @override
  final String code;

  factory _$V1AuthVerifyOtpPostRequest(
          [void Function(V1AuthVerifyOtpPostRequestBuilder)? updates]) =>
      (V1AuthVerifyOtpPostRequestBuilder()..update(updates))._build();

  _$V1AuthVerifyOtpPostRequest._({required this.phone, required this.code})
      : super._();
  @override
  V1AuthVerifyOtpPostRequest rebuild(
          void Function(V1AuthVerifyOtpPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V1AuthVerifyOtpPostRequestBuilder toBuilder() =>
      V1AuthVerifyOtpPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V1AuthVerifyOtpPostRequest &&
        phone == other.phone &&
        code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V1AuthVerifyOtpPostRequest')
          ..add('phone', phone)
          ..add('code', code))
        .toString();
  }
}

class V1AuthVerifyOtpPostRequestBuilder
    implements
        Builder<V1AuthVerifyOtpPostRequest, V1AuthVerifyOtpPostRequestBuilder> {
  _$V1AuthVerifyOtpPostRequest? _$v;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  V1AuthVerifyOtpPostRequestBuilder() {
    V1AuthVerifyOtpPostRequest._defaults(this);
  }

  V1AuthVerifyOtpPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _phone = $v.phone;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V1AuthVerifyOtpPostRequest other) {
    _$v = other as _$V1AuthVerifyOtpPostRequest;
  }

  @override
  void update(void Function(V1AuthVerifyOtpPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V1AuthVerifyOtpPostRequest build() => _build();

  _$V1AuthVerifyOtpPostRequest _build() {
    final _$result = _$v ??
        _$V1AuthVerifyOtpPostRequest._(
          phone: BuiltValueNullFieldError.checkNotNull(
              phone, r'V1AuthVerifyOtpPostRequest', 'phone'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'V1AuthVerifyOtpPostRequest', 'code'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
