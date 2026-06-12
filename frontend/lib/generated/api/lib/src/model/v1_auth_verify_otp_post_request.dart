//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v1_auth_verify_otp_post_request.g.dart';

/// V1AuthVerifyOtpPostRequest
///
/// Properties:
/// * [phone] - Phone number
/// * [code] - 6-digit OTP code
@BuiltValue()
abstract class V1AuthVerifyOtpPostRequest implements Built<V1AuthVerifyOtpPostRequest, V1AuthVerifyOtpPostRequestBuilder> {
  /// Phone number
  @BuiltValueField(wireName: r'phone')
  String get phone;

  /// 6-digit OTP code
  @BuiltValueField(wireName: r'code')
  String get code;

  V1AuthVerifyOtpPostRequest._();

  factory V1AuthVerifyOtpPostRequest([void updates(V1AuthVerifyOtpPostRequestBuilder b)]) = _$V1AuthVerifyOtpPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V1AuthVerifyOtpPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V1AuthVerifyOtpPostRequest> get serializer => _$V1AuthVerifyOtpPostRequestSerializer();
}

class _$V1AuthVerifyOtpPostRequestSerializer implements PrimitiveSerializer<V1AuthVerifyOtpPostRequest> {
  @override
  final Iterable<Type> types = const [V1AuthVerifyOtpPostRequest, _$V1AuthVerifyOtpPostRequest];

  @override
  final String wireName = r'V1AuthVerifyOtpPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V1AuthVerifyOtpPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    V1AuthVerifyOtpPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V1AuthVerifyOtpPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.phone = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V1AuthVerifyOtpPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V1AuthVerifyOtpPostRequestBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

