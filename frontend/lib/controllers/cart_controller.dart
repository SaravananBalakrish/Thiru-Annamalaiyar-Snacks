import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../utils/error_handler_mixin.dart';

class CartController extends ChangeNotifier with ErrorHandlerMixin {
  Map<int, int> _items = {}; // productId: quantity

  CartController() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await runSafe(() async {
      final token = await StorageService.getToken();
      if (token != null) {
        _items = await ApiService.fetchCart();
      } else {
        final stored = await StorageService.getCart();
        _items = stored.map((key, value) => MapEntry(int.parse(key), value));
      }
    });
  }

  Future<void> syncWithServer() async {
    await runSafe(() async {
      _items = await ApiService.fetchCart();
    });
  }

  Future<void> _saveToStorage() async {
    await StorageService.saveCart(_items.map((key, value) => MapEntry(key.toString(), value)));
  }

  Map<int, int> get items => _items;

  int get totalCount => _items.values.fold(0, (sum, qty) => sum + qty);

  double getTotalPrice(List<Product> products) {
    double total = 0;
    _items.forEach((id, qty) {
      final product = products.firstWhere((p) => p.id == id,
          orElse: () => Product(
              id: id,
              name: 'Unknown',
              emoji: '',
              price: 0,
              unit: '',
              category: '',
              desc: '',
              tags: []));
      total += product.price * qty;
    });
    return total;
  }

  void addItem(int productId) async {
    await runSafe(() async {
      _items[productId] = (_items[productId] ?? 0) + 1;
      notifyListeners();
      
      final token = await StorageService.getToken();
      if (token != null) {
        await ApiService.addToCart(productId, 1);
      } else {
        await _saveToStorage();
      }
    });
  }

  void removeItem(int productId) async {
    if (_items.containsKey(productId)) {
      await runSafe(() async {
        final token = await StorageService.getToken();
        if (_items[productId]! > 1) {
          _items[productId] = _items[productId]! - 1;
          if (token != null) {
            await ApiService.updateCartItem(productId, _items[productId]!);
          }
        } else {
          _items.remove(productId);
          if (token != null) {
            await ApiService.removeFromCart(productId);
          }
        }
        if (token == null) {
          await _saveToStorage();
        }
        notifyListeners();
      });
    }
  }

  void clearCart() {
    _items.clear();
    _saveToStorage();
    notifyListeners();
  }
}
