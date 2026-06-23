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
}
