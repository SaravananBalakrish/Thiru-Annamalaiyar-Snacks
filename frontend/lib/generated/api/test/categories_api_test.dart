import 'package:test/test.dart';
import 'package:e_shop_api/e_shop_api.dart';


/// tests for CategoriesApi
void main() {
  final instance = EShopApi().getCategoriesApi();

  group(CategoriesApi, () {
    // List all categories
    //
    //Future<BuiltList<Category>> v1CategoriesGet() async
    test('test v1CategoriesGet', () async {
      // TODO
    });

    // Delete category
    //
    //Future v1CategoriesIdDelete(int id) async
    test('test v1CategoriesIdDelete', () async {
      // TODO
    });

    // Get category by ID
    //
    //Future<Category> v1CategoriesIdGet(int id) async
    test('test v1CategoriesIdGet', () async {
      // TODO
    });

    // Update category
    //
    //Future<Category> v1CategoriesIdPut(int id, CategoryInput categoryInput) async
    test('test v1CategoriesIdPut', () async {
      // TODO
    });

    // Create a category
    //
    //Future<Category> v1CategoriesPost(CategoryInput categoryInput) async
    test('test v1CategoriesPost', () async {
      // TODO
    });

  });
}
