import 'package:flutter/material.dart';

class CategoryMeta {
  final String name;
  final String imageUrl;
  final IconData icon;

  const CategoryMeta({
    required this.name,
    required this.imageUrl,
    required this.icon,
  });

  static const List<CategoryMeta> all = [
    CategoryMeta(
      name: 'Savoury',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/3014/3014534.png',
      icon: Icons.set_meal_outlined,
    ),
    CategoryMeta(
      name: 'Sweets',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/2513/2513831.png',
      icon: Icons.cake_outlined,
    ),
    CategoryMeta(
      name: 'Bakery',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/3014/3014498.png',
      icon: Icons.bakery_dining_outlined,
    ),
    CategoryMeta(
      name: 'All',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/3014/3014511.png',
      icon: Icons.menu_book_outlined,
    ),
  ];

  static CategoryMeta getByName(String name) {
    return all.firstWhere(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
      orElse: () => CategoryMeta(
        name: name,
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/3014/3014511.png',
        icon: Icons.cookie_outlined,
      ),
    );
  }
}

class Product {
  final int id;
  final String name;
  final String emoji;
  final double price;
  final String unit;
  final String category;
  final String desc;
  final List<String> tags;
  final String? badge;
  final String? image;

  Product({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    required this.unit,
    required this.category,
    required this.desc,
    required this.tags,
    this.badge,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'] ?? '🥨',
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] ?? 'pcs',
      category: json['category'] ?? 'General',
      desc: json['description'] ?? json['desc'] ?? '',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      badge: json['badge'],
      image: json['image'],
    );
  }

  factory Product.empty(int id) {
    return Product(
      id: id,
      name: 'Unknown',
      emoji: '❓',
      price: 0.0,
      unit: '',
      category: 'General',
      desc: '',
      tags: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'price': price,
      'unit': unit,
      'category': category,
      'description': desc,
      'tags': tags,
      'badge': badge,
      'image': image,
    };
  }
}
