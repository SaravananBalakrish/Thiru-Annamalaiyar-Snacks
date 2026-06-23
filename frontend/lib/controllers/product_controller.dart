import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../utils/error_handler_mixin.dart';
import 'order_controller.dart';

class ProductController extends ChangeNotifier with ErrorHandlerMixin {
  final OrderController? orderController;
  List<Product> _products = [];

  ProductController({this.orderController});

  List<Product> get products => _products;
  List<String> _categories = [];

  Future<void> loadProducts() async {
    await runSafe(() async {
      // Fetch categories explicitly from their separate path
      _categories = await ApiService.fetchCategoryNames();
      _products = await ApiService.fetchProducts();
      
      if (orderController != null) {
        await orderController!.loadOrders(_products);
      }
    });
  }

  List<Product> getProductsByCategory(String category) {
    if (category == 'All') return _products;
    return _products.where((p) => p.category == category).toList();
  }

  List<String> getCategories() {
    if (_categories.isEmpty) {
      // Fallback in case categories fetch fails but products succeed
      final fallback = _products.map((p) => p.category).toSet().toList();
      fallback.sort();
      return ['All', ...fallback];
    }
    return ['All', ..._categories];
  }
}
