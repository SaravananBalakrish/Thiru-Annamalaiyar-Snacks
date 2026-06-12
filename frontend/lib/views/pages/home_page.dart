import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../models/product.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import 'category_menu_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final productController = context.watch<ProductController>();
    
    if (productController.isLoading) {
      return const Center(child: CircularProgressIndicator(color: kGold));
    }

    if (productController.error != null) {
      return Center(child: Text(productController.error!));
    }

    final products = productController.products;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBanner(),
          _buildMindSection(),
          _buildRecommendedSection(cart, products),
          const Footer(),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 180,
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1505253149613-112d21d9f6a9?q=80&w=1000&auto=format&fit=crop'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "TRIPLE BERRY SUNDAE",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Text(
              "THIS SUNDAE IS UN-BERRY-LIEVABLY\nDELICIOUS!",
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("SHOP NOW", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMindSection() {
    final categories = [
      {'name': 'Sweets', 'img': 'https://cdn-icons-png.flaticon.com/512/2513/2513831.png'},
      {'name': 'Savoury', 'img': 'https://cdn-icons-png.flaticon.com/512/3014/3014534.png'},
      {'name': 'Bakery', 'img': 'https://cdn-icons-png.flaticon.com/512/3014/3014498.png'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "WHAT'S ON YOUR MIND ?",
            style: GoogleFonts.lato(
              color: kGold,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryMenuPage(initialCategory: cat['name']!),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.network(cat['img']!),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: kText),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSection(CartController cart, List<Product> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            "RECOMMENDED ITEMS",
            style: TextStyle(color: kGold, fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: kCream,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(child: Text(product.emoji, style: const TextStyle(fontSize: 40))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Icon(Icons.check_box_outline_blank, color: Colors.green, size: 16),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("₹ ${product.price}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildAddButton(cart, product),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddButton(CartController cart, Product product) {
    final qty = cart.items[product.id] ?? 0;
    
    if (qty > 0) {
      return Container(
        decoration: BoxDecoration(
          color: kGold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kGold.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 16, color: kGold),
              onPressed: () => cart.removeItem(product.id),
            ),
            Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold, color: kGold)),
            IconButton(
              icon: const Icon(Icons.add, size: 16, color: kGold),
              onPressed: () => cart.addItem(product.id),
            ),
          ],
        ),
      );
    }

    return OutlinedButton(
      onPressed: () => cart.addItem(product.id),
      style: OutlinedButton.styleFrom(
        foregroundColor: kGold,
        side: const BorderSide(color: kGold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text("Add +", style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDark,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ANNAMALAIYAR",
                        style: GoogleFonts.playfairDisplay(color: kGoldLight, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    const Text(
                      "Preserving the rich culinary heritage of Chettinad through authentic flavours and traditional recipes.",
                      style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              const Expanded(
                child: FooterCol(
                  title: "CONTACT",
                  items: ["+91 98765 43210", "WhatsApp Us", "Email Us"],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),
          const Text("© 2025 Annamalaiyar Chettinadu Snacks. Karaikudi",
              style: TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }
}

class FooterCol extends StatelessWidget {
  final String title;
  final List<String> items;
  const FooterCol({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
        const SizedBox(height: 12),
        ...items.map((i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(i, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            )),
      ],
    );
  }
}
