import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/product.dart';

class CategoryMenuPage extends StatefulWidget {
  final String initialCategory;
  const CategoryMenuPage({super.key, required this.initialCategory});

  @override
  State<CategoryMenuPage> createState() => _CategoryMenuPageState();
}

class _CategoryMenuPageState extends State<CategoryMenuPage> {
  late String selectedTopCategory;
  String selectedSubCategory = "Ghewars"; // Default as per screenshot

  final List<String> topCategories = ["Sweets", "Namkeens", "Snacks", "Bakery & ..."];
  final List<Map<String, dynamic>> subCategories = [
    {"name": "Packed Sweets", "icon": Icons.cake_outlined},
    {"name": "Ghewars", "icon": Icons.bakery_dining_outlined},
    {"name": "Ghee & Khova Sw...", "icon": Icons.cookie_outlined},
    {"name": "Assorted Sweets", "icon": Icons.icecream_outlined},
    {"name": "Special Kaju Sweets", "icon": Icons.set_meal_outlined},
  ];

  @override
  void initState() {
    super.initState();
    selectedTopCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final productController = context.watch<ProductController>();
    final topCategories = productController.getCategories();

    if (productController.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: kGold)));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          selectedTopCategory,
          style: const TextStyle(color: kText, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: kGold),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTopTabs(topCategories),
          Expanded(
            child: Row(
              children: [
                _buildSidebar(),
                Expanded(child: _buildProductList(cart, productController)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: cart.totalCount > 0 ? _buildCartStrip(cart, productController.products) : null,
    );
  }

  Widget _buildTopTabs(List<String> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: categories.map((cat) {
          final isSelected = selectedTopCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => setState(() => selectedTopCategory = cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? kDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? kDark : kGold.withValues(alpha: 0.2)),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : kText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: kCream.withValues(alpha: 0.5),
        border: Border(right: BorderSide(color: kGold.withValues(alpha: 0.1))),
      ),
      child: ListView.builder(
        itemCount: subCategories.length,
        itemBuilder: (context, index) {
          final sub = subCategories[index];
          final isSelected = selectedSubCategory == sub['name'];
          return InkWell(
            onTap: () => setState(() => selectedSubCategory = sub['name']),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                  color: isSelected ? Colors.white : Colors.transparent,
                  child: Column(
                    children: [
                      Icon(sub['icon'], color: isSelected ? kGold : kTextMuted, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        sub['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? kText : kTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Positioned(
                    left: 0,
                    top: 15,
                    bottom: 15,
                    child: Container(
                      width: 4,
                      decoration: const BoxDecoration(
                        color: kGold,
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList(CartController cart, ProductController productController) {
    final products = productController.getProductsByCategory(selectedTopCategory);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductItem(cart, product);
      },
    );
  }

  Widget _buildProductItem(CartController cart, Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: kCream,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(product.emoji, style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Atta ${product.name}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const Icon(Icons.check_box_outline_blank, color: Colors.green, size: 14),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "₹ ${product.price}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildAddButton(cart, product),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(CartController cart, Product product) {
    final qty = cart.items[product.id] ?? 0;

    if (qty > 0) {
      return Container(
        width: 100,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kGold.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 16, color: kGold),
              onPressed: () => cart.removeItem(product.id),
              padding: EdgeInsets.zero,
            ),
            Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold, color: kGold)),
            IconButton(
              icon: const Icon(Icons.add, size: 16, color: kGold),
              onPressed: () => cart.addItem(product.id),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: 100,
      height: 36,
      child: OutlinedButton(
        onPressed: () => cart.addItem(product.id),
        style: OutlinedButton.styleFrom(
          foregroundColor: kGold,
          side: const BorderSide(color: kGold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
        child: const Text("Add +", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _buildCartStrip(CartController cart, List<Product> products) {
    final total = cart.getTotalPrice(products);
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: kGold,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${cart.totalCount} Item${cart.totalCount > 1 ? 's' : ''} | ₹ $total",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Text(
                "Extra charges may apply",
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
          InkWell(
            onTap: () {
              // Navigate to cart
            },
            child: const Row(
              children: [
                Text(
                  "View Cart",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(width: 4),
                Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
