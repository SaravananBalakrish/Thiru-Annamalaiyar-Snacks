//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'cart_patch.g.dart';

/// CartPatch
///
/// Properties:
/// * [quantity] 
@BuiltValue()
abstract class CartPatch implements Built<CartPatch, CartPatchBuilder> {
  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  CartPatch._();

  factory CartPatch([void updates(CartPatchBuilder b)]) = _$CartPatch;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CartPatchBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CartPatch> get serializer => _$CartPatchSerializer();
}

class _$CartPatchSerializer implements PrimitiveSerializer<CartPatch> {
  @override
  final Iterable<Type> types = const [CartPatch, _$CartPatch];

  @override
  final String wireName = r'CartPatch';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CartPatch object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CartPatch object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CartPatchBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  CartPatch deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CartPatchBuilder();
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

