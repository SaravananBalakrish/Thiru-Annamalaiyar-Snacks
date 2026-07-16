import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

import '../utils/error_handler_mixin.dart';

import '../utils/result.dart';

class OrderController extends ChangeNotifier with ErrorHandlerMixin {
  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  Future<Result<void>> loadOrders(List<Product> availableProducts) async {
    final token = await StorageService.getToken();
    if (token == null) return Result.success(null);

    return await runSafeResult(() async {
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
          city: 'N/A',
          address: 'N/A',
        );
      }).toList();
    });
  }

  Future<Result<dynamic>> placeOrder(String address, String city, String paymentMethod) async {
    return await runSafeResult(() async {
      final response = await ApiService.placeOrder(address, city, paymentMethod);
      return response;
    });
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
