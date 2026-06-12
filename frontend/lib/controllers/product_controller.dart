import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'order_controller.dart';

class ProductController extends ChangeNotifier {
  final OrderController? orderController;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  ProductController({this.orderController});

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await ApiService.fetchProducts();
      if (orderController != null) {
        await orderController!.loadOrders(_products);
      }
    } catch (e) {
      _error = 'Failed to load products: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Product> getProductsByCategory(String category) {
    if (category == 'All') return _products;
    return _products.where((p) => p.category == category).toList();
  }

  List<String> getCategories() {
    final categories = _products.map((p) => p.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }
}
