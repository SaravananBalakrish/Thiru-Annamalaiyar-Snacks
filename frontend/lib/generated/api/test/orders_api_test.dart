import 'package:test/test.dart';
import 'package:e_shop_api/e_shop_api.dart';


/// tests for OrdersApi
void main() {
  final instance = EShopApi().getOrdersApi();

  group(OrdersApi, () {
    // List all orders (optionally filter by userId)
    //
    //Future<BuiltList<Order>> v1OrdersGet({ int userId }) async
    test('test v1OrdersGet', () async {
      // TODO
    });

    // Get order details by ID
    //
    //Future<Order> v1OrdersIdGet(int id) async
    test('test v1OrdersIdGet', () async {
      // TODO
    });

    // Confirm UPI/digital payment for an order using transaction reference
    //
    //Future<Order> v1OrdersIdPayPost(int id, PayOrderInput payOrderInput) async
    test('test v1OrdersIdPayPost', () async {
      // TODO
    });

    // Place an order (checkout the current cart)
    //
    //Future<Order> v1OrdersPost(OrderInput orderInput) async
    test('test v1OrdersPost', () async {
      // TODO
    });

  });
}
