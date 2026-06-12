import 'package:test/test.dart';
import 'package:e_shop_api/e_shop_api.dart';


/// tests for ProductsApi
void main() {
  final instance = EShopApi().getProductsApi();

  group(ProductsApi, () {
    // List all products
    //
    //Future<BuiltList<Product>> v1ProductsGet() async
    test('test v1ProductsGet', () async {
      // TODO
    });

    // Delete a product
    //
    //Future v1ProductsIdDelete(int id) async
    test('test v1ProductsIdDelete', () async {
      // TODO
    });

    // Get a product by ID
    //
    //Future<Product> v1ProductsIdGet(int id) async
    test('test v1ProductsIdGet', () async {
      // TODO
    });

    // Update a product
    //
    //Future<Product> v1ProductsIdPut(int id, ProductInput productInput) async
    test('test v1ProductsIdPut', () async {
      // TODO
    });

    // Create a new product
    //
    //Future<Product> v1ProductsPost(ProductInput productInput) async
    test('test v1ProductsPost', () async {
      // TODO
    });

  });
}
