import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class OrderController extends ChangeNotifier {
  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  Future<void> loadOrders(List<Product> availableProducts) async {
    final token = await StorageService.getToken();
    if (token != null) {
      final apiOrders = await ApiService.fetchOrders();
      _orders = apiOrders.map((o) {
        return OrderModel(
          id: o.id.toString(),
          items: o.items?.map((item) {
            final product = availableProducts.firstWhere(
              (p) => p.id == item.productId,
              orElse: () => Product(
                  id: item.productId ?? 0,
                  name: 'Unknown',
                  emoji: '',
                  price: 0,
                  unit: '',
                  category: '',
                  desc: '',
                  tags: []),
            );
            return OrderItem(product: product, quantity: item.quantity ?? 0);
          }).toList() ?? [],
          totalAmount: double.tryParse(o.totalPrice ?? '0') ?? 0,
          date: o.createdAt ?? DateTime.now(),
          status: _mapStatus(o.paymentStatus),
          city: 'N/A', // API might not return this in the simplified Order model
          address: 'N/A',
        );
      }).toList();
    } else {
      // Load local guest orders if any
      // ...
    }
    notifyListeners();
  }

  OrderStatus _mapStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return OrderStatus.processing;
      case 'pending':
        return OrderStatus.pending;
      default:
        return OrderStatus.pending;
    }
  }

  Future<void> addOrder(OrderModel order) async {
    // This is now handled by placeOrder in ApiService and then reloading
    notifyListeners();
  }
}
