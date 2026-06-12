import 'package:test/test.dart';
import 'package:e_shop_api/e_shop_api.dart';


/// tests for CartApi
void main() {
  final instance = EShopApi().getCartApi();

  group(CartApi, () {
    // List cart items (with product details)
    //
    //Future<BuiltList<CartItem>> v1CartGet() async
    test('test v1CartGet', () async {
      // TODO
    });

    // Remove item from cart
    //
    //Future v1CartIdDelete(int id) async
    test('test v1CartIdDelete', () async {
      // TODO
    });

    // Update cart item quantity
    //
    //Future v1CartIdPatch(int id, CartPatch cartPatch) async
    test('test v1CartIdPatch', () async {
      // TODO
    });

    // Add item to cart (upserts quantity if already present)
    //
    //Future v1CartPost(CartAdd cartAdd) async
    test('test v1CartPost', () async {
      // TODO
    });

  });
}
