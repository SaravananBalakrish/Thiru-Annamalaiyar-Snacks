//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'category_input.g.dart';

/// CategoryInput
///
/// Properties:
/// * [name] 
@BuiltValue()
abstract class CategoryInput implements Built<CategoryInput, CategoryInputBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  CategoryInput._();

  factory CategoryInput([void updates(CategoryInputBuilder b)]) = _$CategoryInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CategoryInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CategoryInput> get serializer => _$CategoryInputSerializer();
}

class _$CategoryInputSerializer implements PrimitiveSerializer<CategoryInput> {
  @override
  final Iterable<Type> types = const [CategoryInput, _$CategoryInput];

  @override
  final String wireName = r'CategoryInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CategoryInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CategoryInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CategoryInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CategoryInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CategoryInputBuilder();
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

