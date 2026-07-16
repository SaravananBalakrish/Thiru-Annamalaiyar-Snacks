import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/error_handler_mixin.dart';
import '../utils/result.dart';
import 'order_controller.dart';

class ProductController extends ChangeNotifier with ErrorHandlerMixin {
  final OrderController? orderController;
  List<Product> _products = [];

  ProductController({this.orderController}) {
    _products = StorageService.getProducts();
  }

  List<Product> get products => _products;
  List<String> _categories = [];

  Future<Result<void>> loadProducts() async {
    return await runSafeResult(() async {
      // Fetch categories explicitly from their separate path
      _categories = await ApiService.fetchCategoryNames();
      _products = await ApiService.fetchProducts();
      
      // Cache the products for offline use
      await StorageService.saveProducts(_products);

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

  List<Product> getRecommendations(List<int> cartProductIds) {
    if (_products.isEmpty) return [];

    // If cart is empty, recommend popular (first few)
    if (cartProductIds.isEmpty) {
      return _products.take(5).toList();
    }

    // Recommend products from same categories as items in cart, but not already in cart
    final cartCategories = _products
        .where((p) => cartProductIds.contains(p.id))
        .map((p) => p.category)
        .toSet();

    final recommendations = _products
        .where((p) => !cartProductIds.contains(p.id) && cartCategories.contains(p.category))
        .toList();

    if (recommendations.length < 5) {
      // Fill with others if not enough category-specific recommendations
      final others = _products
          .where((p) => !cartProductIds.contains(p.id) && !cartCategories.contains(p.category))
          .toList();
      recommendations.addAll(others.take(5 - recommendations.length));
    }

    return recommendations.take(5).toList();
  }
}
