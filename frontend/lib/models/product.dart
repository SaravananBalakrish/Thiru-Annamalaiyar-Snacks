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

// Keeping allProducts for fallback or development, but using ApiService in production.
final List<Product> allProducts = [
  Product(
    id: 1,
    name: 'Butter Murukku',
    emoji: '🌀',
    price: 120,
    unit: '250g',
    category: 'Savoury',
    desc: 'Classic rice flour murukku with rich butter flavour. Crispy and light.',
    tags: ['Bestseller', 'Crispy'],
    badge: 'Hot',
  ),
  Product(
    id: 2,
    name: 'Kara Murukku',
    emoji: '🌶️',
    price: 100,
    unit: '250g',
    category: 'Savoury',
    desc: 'Spicy rice murukku with red chilli and sesame. Perfectly crunchy.',
    tags: ['Spicy'],
  ),
  Product(
    id: 4,
    name: 'Athirasam',
    emoji: '🥮',
    price: 180,
    unit: '500g',
    category: 'Sweets',
    desc: 'Traditional jaggery sweet — soft inside, crispy outside.',
    tags: ['Traditional', 'Sweet'],
    badge: 'Festival Special',
  ),
  Product(
    id: 5,
    name: 'Mysore Pak',
    emoji: '🟡',
    price: 200,
    unit: '500g',
    category: 'Sweets',
    desc: 'Melt-in-mouth Mysore Pak made with pure ghee and besan.',
    tags: ['Ghee', 'Premium'],
    badge: 'Premium',
  ),
  Product(
    id: 7,
    name: 'Vella Seedai',
    emoji: '🟤',
    price: 130,
    unit: '250g',
    category: 'Savoury',
    desc: 'Sweet jaggery seedai – crispy, caramelised and irresistible.',
    tags: ['Sweet', 'Crispy'],
  ),
  Product(
    id: 11,
    name: 'Mixture',
    emoji: '✨',
    price: 90,
    unit: '250g',
    category: 'Savoury',
    desc: 'A classic savoury mix of boondi, peanuts, curry leaves and more.',
    tags: ['Crunchy', 'Spicy'],
  ),
  Product(
    id: 13,
    name: 'Nei Biscuit',
    emoji: '🍪',
    price: 150,
    unit: '250g',
    category: 'Bakery',
    desc: 'Rich ghee biscuits with cardamom — crumbly and fragrant.',
    tags: ['Ghee', 'Aromatic'],
  ),
  Product(
    id: 14,
    name: 'Kaju Katli',
    emoji: '💎',
    price: 319.05,
    unit: '250g',
    category: 'Sweets',
    desc: 'Premium cashew fudge with silver leaf.',
    tags: ['Premium', 'Best'],
  ),
  Product(
    id: 15,
    name: 'Motichoor Laddu',
    emoji: '🟠',
    price: 219.05,
    unit: '500g',
    category: 'Sweets',
    desc: 'Sweet pearls of gram flour cooked in ghee.',
    tags: ['Traditional'],
  ),
];
