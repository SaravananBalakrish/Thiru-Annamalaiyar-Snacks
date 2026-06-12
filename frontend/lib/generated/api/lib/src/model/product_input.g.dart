// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProductInput extends ProductInput {
  @override
  final String name;
  @override
  final String? description;
  @override
  final num price;
  @override
  final String? imageUrl;
  @override
  final int? categoryId;

  factory _$ProductInput([void Function(ProductInputBuilder)? updates]) =>
      (ProductInputBuilder()..update(updates))._build();

  _$ProductInput._({
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.categoryId,
  }) : super._();
  @override
  ProductInput rebuild(void Function(ProductInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProductInputBuilder toBuilder() => ProductInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProductInput &&
        name == other.name &&
        description == other.description &&
        price == other.price &&
        imageUrl == other.imageUrl &&
        categoryId == other.categoryId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jc(_$hash, categoryId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProductInput')
          ..add('name', name)
          ..add('description', description)
          ..add('price', price)
          ..add('imageUrl', imageUrl)
          ..add('categoryId', categoryId))
        .toString();
  }
}

class ProductInputBuilder
    implements Builder<ProductInput, ProductInputBuilder> {
  _$ProductInput? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  num? _price;
  num? get price => _$this._price;
  set price(num? price) => _$this._price = price;

  String? _imageUrl;
  String? get imageUrl => _$this._imageUrl;
  set imageUrl(String? imageUrl) => _$this._imageUrl = imageUrl;

  int? _categoryId;
  int? get categoryId => _$this._categoryId;
  set categoryId(int? categoryId) => _$this._categoryId = categoryId;

  ProductInputBuilder() {
    ProductInput._defaults(this);
  }

  ProductInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _price = $v.price;
      _imageUrl = $v.imageUrl;
      _categoryId = $v.categoryId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProductInput other) {
    _$v = other as _$ProductInput;
  }

  @override
  void update(void Function(ProductInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProductInput build() => _build();

  _$ProductInput _build() {
    final _$result =
        _$v ??
        _$ProductInput._(
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'ProductInput',
            'name',
          ),
          description: description,
          price: BuiltValueNullFieldError.checkNotNull(
            price,
            r'ProductInput',
            'price',
          ),
          imageUrl: imageUrl,
          categoryId: categoryId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
