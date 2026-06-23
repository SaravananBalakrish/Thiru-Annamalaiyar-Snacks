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
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;
  }

  IconData _getIconForCategory(String name) {
    if (name.toLowerCase() == 'sweets') return Icons.cake_outlined;
    if (name.toLowerCase() == 'savoury') return Icons.set_meal_outlined;
    if (name.toLowerCase() == 'bakery') return Icons.bakery_dining_outlined;
    if (name.toLowerCase() == 'all') return Icons.menu_book_outlined;
    return Icons.cookie_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final productController = context.watch<ProductController>();
    final categories = productController.getCategories();

    // If the initial category is not in the list, fallback to the first available category
    if (categories.isNotEmpty && !categories.contains(selectedCategory)) {
      selectedCategory = categories.first;
    }

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
          selectedCategory,
          style: const TextStyle(color: kText, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: kGold),
            onPressed: () {},
          ),
        ],
      ),
      body: Row(
        children: [
          _buildSidebar(categories),
          Expanded(child: _buildProductList(cart, productController)),
        ],
      ),
      bottomNavigationBar: cart.totalCount > 0 ? _buildCartStrip(cart, productController.products) : null,
    );
  }

  Widget _buildSidebar(List<String> categories) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: kCream.withValues(alpha: 0.5),
        border: Border(right: BorderSide(color: kGold.withValues(alpha: 0.1))),
      ),
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedCategory == cat;
          return InkWell(
            onTap: () => setState(() => selectedCategory = cat),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                  color: isSelected ? Colors.white : Colors.transparent,
                  child: Column(
                    children: [
                      Icon(_getIconForCategory(cat), color: isSelected ? kGold : kTextMuted, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        cat,
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
    final products = productController.getProductsByCategory(selectedCategory);

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
                        product.name,
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
