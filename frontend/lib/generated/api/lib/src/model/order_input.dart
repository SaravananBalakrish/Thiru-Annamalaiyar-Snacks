//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_input.g.dart';

/// OrderInput
///
/// Properties:
/// * [userId] 
/// * [paymentMethod] - e.g. \"gpay\", \"phonepe\", \"upi\"
@BuiltValue()
abstract class OrderInput implements Built<OrderInput, OrderInputBuilder> {
  @BuiltValueField(wireName: r'userId')
  int get userId;

  /// e.g. \"gpay\", \"phonepe\", \"upi\"
  @BuiltValueField(wireName: r'paymentMethod')
  String? get paymentMethod;

  OrderInput._();

  factory OrderInput([void updates(OrderInputBuilder b)]) = _$OrderInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderInputBuilder b) => b
      ..paymentMethod = 'upi';

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderInput> get serializer => _$OrderInputSerializer();
}

class _$OrderInputSerializer implements PrimitiveSerializer<OrderInput> {
  @override
  final Iterable<Type> types = const [OrderInput, _$OrderInput];

  @override
  final String wireName = r'OrderInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'userId';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(int),
    );
    if (object.paymentMethod != null) {
      yield r'paymentMethod';
      yield serializers.serialize(
        object.paymentMethod,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OrderInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OrderInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.userId = valueDes;
          break;
        case r'paymentMethod':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.paymentMethod = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrderInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderInputBuilder();
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

