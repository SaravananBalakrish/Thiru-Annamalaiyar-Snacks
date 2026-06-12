// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CategoryInput extends CategoryInput {
  @override
  final String name;

  factory _$CategoryInput([void Function(CategoryInputBuilder)? updates]) =>
      (CategoryInputBuilder()..update(updates))._build();

  _$CategoryInput._({required this.name}) : super._();
  @override
  CategoryInput rebuild(void Function(CategoryInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CategoryInputBuilder toBuilder() => CategoryInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CategoryInput && name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'CategoryInput',
    )..add('name', name)).toString();
  }
}

class CategoryInputBuilder
    implements Builder<CategoryInput, CategoryInputBuilder> {
  _$CategoryInput? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  CategoryInputBuilder() {
    CategoryInput._defaults(this);
  }

  CategoryInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CategoryInput other) {
    _$v = other as _$CategoryInput;
  }

  @override
  void update(void Function(CategoryInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CategoryInput build() => _build();

  _$CategoryInput _build() {
    final _$result =
        _$v ??
        _$CategoryInput._(
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'CategoryInput',
            'name',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
