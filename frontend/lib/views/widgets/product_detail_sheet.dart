import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../models/product.dart';
import '../../controllers/cart_controller.dart';

class ProductDetailSheet extends StatelessWidget {
  final Product product;
  const ProductDetailSheet({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final qty = cart.items[product.id] ?? 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: ListView(
          controller: controller,
          padding: EdgeInsets.zero,
          children: [
            Stack(
              children: [
                Container(
                  height: 350,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: kGoldPale,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [kGoldPale, Colors.white],
                    ),
                  ),
                  child: Center(
                    child: Hero(
                      tag: 'product-${product.id}',
                      child: Text(product.emoji, style: const TextStyle(fontSize: 120)),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton.filled(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.8),
                      foregroundColor: kDark,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kRed,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        product.badge!,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "₹${product.price.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kRed),
                      ),
                    ],
                  ),
                  Text(
                    "per ${product.unit}",
                    style: const TextStyle(color: kTextMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.desc,
                    style: const TextStyle(color: kTextMuted, fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Highlights",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildHighlight(Icons.verified_outlined, "Authentic"),
                      _buildHighlight(Icons.home_outlined, "Homemade"),
                      _buildHighlight(Icons.timer_outlined, "Freshly Made"),
                      _buildHighlight(Icons.eco_outlined, "No Preservatives"),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      if (qty > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: kGold.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => cart.removeItem(product.id),
                                icon: const Icon(Icons.remove),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  qty.toString(),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                onPressed: () => cart.addItem(product.id),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (qty == 0) cart.addItem(product.id);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kDark,
                            foregroundColor: kGoldLight,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            qty > 0 ? "Check Cart" : "Add to Cart • ₹${product.price.toStringAsFixed(0)}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlight(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kGold.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: kGold),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
