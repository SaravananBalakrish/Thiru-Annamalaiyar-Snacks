import 'package:thiru_annamalaiyar_snacks/models/product.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class OrderItem {
  final Product product;
  final int quantity;

  OrderItem({required this.product, required this.quantity});

  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json, List<Product> allProducts) {
    final product = allProducts.firstWhere((p) => p.id == json['productId']);
    return OrderItem(product: product, quantity: json['quantity']);
  }
}

class OrderModel {
  final String id;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime date;
  final OrderStatus status;
  final String city;
  final String address;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.date,
    required this.status,
    required this.city,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((i) => i.toJson()).toList(),
      'totalAmount': totalAmount,
      'date': date.toIso8601String(),
      'status': status.index,
      'city': city,
      'address': address,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json, List<Product> allProducts) {
    return OrderModel(
      id: json['id'],
      items: (json['items'] as List)
          .map((i) => OrderItem.fromJson(i, allProducts))
          .toList(),
      totalAmount: json['totalAmount'],
      date: DateTime.parse(json['date']),
      status: OrderStatus.values[json['status']],
      city: json['city'],
      address: json['address'],
    );
  }
}
