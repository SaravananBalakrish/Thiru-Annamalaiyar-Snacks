//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v1_auth_request_otp_post_request.g.dart';

/// V1AuthRequestOtpPostRequest
///
/// Properties:
/// * [phone] - Phone number (e.g., +918681020301 or 8681020301)
@BuiltValue()
abstract class V1AuthRequestOtpPostRequest implements Built<V1AuthRequestOtpPostRequest, V1AuthRequestOtpPostRequestBuilder> {
  /// Phone number (e.g., +918681020301 or 8681020301)
  @BuiltValueField(wireName: r'phone')
  String get phone;

  V1AuthRequestOtpPostRequest._();

  factory V1AuthRequestOtpPostRequest([void updates(V1AuthRequestOtpPostRequestBuilder b)]) = _$V1AuthRequestOtpPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V1AuthRequestOtpPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V1AuthRequestOtpPostRequest> get serializer => _$V1AuthRequestOtpPostRequestSerializer();
}

class _$V1AuthRequestOtpPostRequestSerializer implements PrimitiveSerializer<V1AuthRequestOtpPostRequest> {
  @override
  final Iterable<Type> types = const [V1AuthRequestOtpPostRequest, _$V1AuthRequestOtpPostRequest];

  @override
  final String wireName = r'V1AuthRequestOtpPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V1AuthRequestOtpPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    V1AuthRequestOtpPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V1AuthRequestOtpPostRequestBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V1AuthRequestOtpPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V1AuthRequestOtpPostRequestBuilder();
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

