// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v1_auth_request_otp_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$V1AuthRequestOtpPostRequest extends V1AuthRequestOtpPostRequest {
  @override
  final String phone;

  factory _$V1AuthRequestOtpPostRequest([
    void Function(V1AuthRequestOtpPostRequestBuilder)? updates,
  ]) => (V1AuthRequestOtpPostRequestBuilder()..update(updates))._build();

  _$V1AuthRequestOtpPostRequest._({required this.phone}) : super._();
  @override
  V1AuthRequestOtpPostRequest rebuild(
    void Function(V1AuthRequestOtpPostRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  V1AuthRequestOtpPostRequestBuilder toBuilder() =>
      V1AuthRequestOtpPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V1AuthRequestOtpPostRequest && phone == other.phone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'V1AuthRequestOtpPostRequest',
    )..add('phone', phone)).toString();
  }
}

class V1AuthRequestOtpPostRequestBuilder
    implements
        Builder<
          V1AuthRequestOtpPostRequest,
          V1AuthRequestOtpPostRequestBuilder
        > {
  _$V1AuthRequestOtpPostRequest? _$v;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  V1AuthRequestOtpPostRequestBuilder() {
    V1AuthRequestOtpPostRequest._defaults(this);
  }

  V1AuthRequestOtpPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _phone = $v.phone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V1AuthRequestOtpPostRequest other) {
    _$v = other as _$V1AuthRequestOtpPostRequest;
  }

  @override
  void update(void Function(V1AuthRequestOtpPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V1AuthRequestOtpPostRequest build() => _build();

  _$V1AuthRequestOtpPostRequest _build() {
    final _$result =
        _$v ??
        _$V1AuthRequestOtpPostRequest._(
          phone: BuiltValueNullFieldError.checkNotNull(
            phone,
            r'V1AuthRequestOtpPostRequest',
            'phone',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
