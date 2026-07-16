//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:e_shop_api/src/date_serializer.dart';
import 'package:e_shop_api/src/model/date.dart';

import 'package:e_shop_api/src/model/cart_add.dart';
import 'package:e_shop_api/src/model/cart_item.dart';
import 'package:e_shop_api/src/model/cart_patch.dart';
import 'package:e_shop_api/src/model/category.dart';
import 'package:e_shop_api/src/model/category_input.dart';
import 'package:e_shop_api/src/model/order.dart';
import 'package:e_shop_api/src/model/order_input.dart';
import 'package:e_shop_api/src/model/order_item.dart';
import 'package:e_shop_api/src/model/pay_order_input.dart';
import 'package:e_shop_api/src/model/product.dart';
import 'package:e_shop_api/src/model/product_input.dart';
import 'package:e_shop_api/src/model/review.dart';
import 'package:e_shop_api/src/model/review_input.dart';
import 'package:e_shop_api/src/model/review_update.dart';
import 'package:e_shop_api/src/model/v1_auth_request_otp_post_request.dart';
import 'package:e_shop_api/src/model/v1_auth_verify_otp_post_request.dart';

part 'serializers.g.dart';

@SerializersFor([
  CartAdd,
  CartItem,
  CartPatch,
  Category,
  CategoryInput,
  Order,
  OrderInput,
  OrderItem,
  PayOrderInput,
  Product,
  ProductInput,
  Review,
  ReviewInput,
  ReviewUpdate,
  V1AuthRequestOtpPostRequest,
  V1AuthVerifyOtpPostRequest,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Review)]),
        () => ListBuilder<Review>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(CartItem)]),
        () => ListBuilder<CartItem>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Product)]),
        () => ListBuilder<Product>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Order)]),
        () => ListBuilder<Order>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Category)]),
        () => ListBuilder<Category>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
