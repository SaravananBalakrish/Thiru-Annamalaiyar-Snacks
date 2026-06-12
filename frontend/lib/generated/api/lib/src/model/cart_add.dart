//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'cart_add.g.dart';

/// CartAdd
///
/// Properties:
/// * [productId] 
/// * [quantity] 
@BuiltValue()
abstract class CartAdd implements Built<CartAdd, CartAddBuilder> {
  @BuiltValueField(wireName: r'productId')
  int get productId;

  @BuiltValueField(wireName: r'quantity')
  int? get quantity;

  CartAdd._();

  factory CartAdd([void updates(CartAddBuilder b)]) = _$CartAdd;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CartAddBuilder b) => b
      ..quantity = 1;

  @BuiltValueSerializer(custom: true)
  static Serializer<CartAdd> get serializer => _$CartAddSerializer();
}

class _$CartAddSerializer implements PrimitiveSerializer<CartAdd> {
  @override
  final Iterable<Type> types = const [CartAdd, _$CartAdd];

  @override
  final String wireName = r'CartAdd';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CartAdd object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'productId';
    yield serializers.serialize(
      object.productId,
      specifiedType: const FullType(int),
    );
    if (object.quantity != null) {
      yield r'quantity';
      yield serializers.serialize(
        object.quantity,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CartAdd object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CartAddBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'productId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.productId = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.quantity = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CartAdd deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CartAddBuilder();
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

