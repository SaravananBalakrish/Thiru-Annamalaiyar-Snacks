import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../models/product.dart';
import '../../controllers/cart_controller.dart';
import 'product_detail_sheet.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  void _showProductDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final qty = cart.items[product.id] ?? 0;

    return GestureDetector(
      onTap: () => _showProductDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kGold.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kGoldPale,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [kGoldPale, Color(0xFFFFF0D8)],
                      ),
                    ),
                    child: Center(
                      child: Hero(
                        tag: 'product-${product.id}',
                        child: Text(product.emoji, style: const TextStyle(fontSize: 60)),
                      ),
                    ),
                  ),
                  if (product.badge != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kRed,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          product.badge!,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: kTextMuted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: product.tags
                        .map((t) => Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: kGoldPale,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: kGold.withValues(alpha: 0.2)),
                              ),
                              child: Text(t, style: const TextStyle(color: kGold, fontSize: 9, fontWeight: FontWeight.bold)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(text: "₹${product.price.toStringAsFixed(0)}"),
                            TextSpan(
                              text: " / ${product.unit}",
                              style: const TextStyle(fontSize: 11, color: kTextMuted, fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      if (qty == 0)
                        IconButton.filled(
                          onPressed: () => context.read<CartController>().addItem(product.id),
                          icon: const Icon(Icons.add, size: 20),
                          style: IconButton.styleFrom(backgroundColor: kDark, foregroundColor: kGoldLight),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: kDark,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => context.read<CartController>().removeItem(product.id),
                                icon: const Icon(Icons.remove, size: 16, color: kGoldLight),
                                visualDensity: VisualDensity.compact,
                              ),
                              Text(qty.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              IconButton(
                                onPressed: () => context.read<CartController>().addItem(product.id),
                                icon: const Icon(Icons.add, size: 16, color: kGoldLight),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
