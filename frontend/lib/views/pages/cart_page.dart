import '../../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/product.dart';
import '../../models/order.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String selectedCity = "BENGALURU";
  String address = "No 123, 5th Main, 6th Cross, Indiranagar";
  bool _isPlacingOrder = false;
  
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final productController = context.watch<ProductController>();
    final products = productController.products;
    
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Cart",
          style: TextStyle(color: kText, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: cart.items.isEmpty 
        ? _buildEmptyState(context)
        : _buildCartContent(context, cart, products),
      bottomNavigationBar: cart.items.isEmpty ? null : _buildBottomBar(context, cart, products),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: kGold.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            "Your cart is empty",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText),
          ),
          const SizedBox(height: 8),
          Text(
            "Add some delicious snacks to get started!",
            style: TextStyle(color: kTextMuted.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: kGold,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Browse Snacks", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartController cart, List<Product> products) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFulfillmentCard(),
          const SizedBox(height: 16),
          _buildLocationCard(context),
          const SizedBox(height: 16),
          _buildCartItems(cart, products),
          const SizedBox(height: 24),
          _buildYouMayAlsoLike(),
          const SizedBox(height: 24),
          _buildNoteSection(),
          const SizedBox(height: 24),
          _buildBillDetails(cart, products),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFulfillmentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delivery_dining, color: kGold),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Fulfillment Method", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Choose how you get your order", style: TextStyle(fontSize: 12, color: kTextMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildToggleButton(Icons.motorcycle, "Delivery", true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildToggleButton(Icons.store, "Store Pickup", false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(IconData icon, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? kGold : kCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? kGold : kGold.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.white : kGold, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : kGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        onTap: () => _showLocationPicker(context),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: kGold),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Delivery Address", style: TextStyle(fontSize: 12, color: kTextMuted)),
                  Text(selectedCity, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: kTextMuted.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select City", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildCityItem("BENGALURU"),
            _buildCityItem("Mandya"),
            _buildCityItem("Mysore"),
            _buildCityItem("TUMKUR"),
            _buildCityItem("Hosur"),
          ],
        ),
      ),
    );
  }

  Widget _buildCityItem(String name) {
    return ListTile(
      leading: const Icon(Icons.location_city, color: kGold),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        setState(() {
          selectedCity = name;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCartItems(CartController cart, List<Product> products) {
    return Column(
      children: cart.items.entries.map((entry) {
        final product = products.firstWhere((p) => p.id == entry.key);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_box_outline_blank, color: Colors.green, size: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("₹${product.price}", style: const TextStyle(color: kTextMuted)),
                  ],
                ),
              ),
              _buildQuantitySelector(cart, product, entry.value),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuantitySelector(CartController cart, Product product, int quantity) {
    return Container(
      decoration: BoxDecoration(
        color: kGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 16, color: kGold),
            onPressed: () => cart.removeItem(product.id),
          ),
          Text("$quantity", style: const TextStyle(fontWeight: FontWeight.bold, color: kGold)),
          IconButton(
            icon: const Icon(Icons.add, size: 16, color: kGold),
            onPressed: () => cart.addItem(product.id),
          ),
        ],
      ),
    );
  }

  Widget _buildYouMayAlsoLike() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("You may also like!", style: TextStyle(color: kGold, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildSmallProductCard("Kaju Katli", "319.05"),
              _buildSmallProductCard("Motichoor Laddu", "219.05"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallProductCard(String name, String price) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: kCream,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.image_outlined, color: kGold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("₹$price", style: const TextStyle(color: kTextMuted, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.add_circle, color: kGold),
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.edit_note, color: kGold),
          SizedBox(width: 12),
          Text("Add a note for Annamalaiyar", style: TextStyle(fontWeight: FontWeight.w500)),
          Spacer(),
          Icon(Icons.chevron_right, color: kTextMuted),
        ],
      ),
    );
  }

  Widget _buildBillDetails(CartController cart, List<Product> products) {
    final total = cart.getTotalPrice(products);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildBillRow("Item Total", "₹$total"),
          _buildBillRow("Delivery Fee", "₹0.00"),
          const Divider(),
          _buildBillRow("Total Amount", "₹$total", isTotal: true),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? kGold : kText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CartController cart, List<Product> products) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: ElevatedButton(
        onPressed: _isPlacingOrder ? null : () => _handlePlaceOrder(context, cart, products),
        style: ElevatedButton.styleFrom(
          backgroundColor: kGold,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isPlacingOrder
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Place Order",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ],
              ),
      ),
    );
  }

  Future<void> _handlePlaceOrder(BuildContext context, CartController cart, List<Product> products) async {
    final orderController = context.read<OrderController>();
    final total = cart.getTotalPrice(products);
    
    setState(() => _isPlacingOrder = true);

    final apiOrder = await ApiService.placeOrder(address, selectedCity, "whatsapp");

    setState(() => _isPlacingOrder = false);

    if (apiOrder == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to place order. Please try again.")),
      );
      return;
    }

    final orderId = apiOrder.id.toString();
    final List<OrderItem> items = cart.items.entries.map((entry) {
      final product = products.firstWhere((p) => p.id == entry.key);
      return OrderItem(product: product, quantity: entry.value);
    }).toList();

    // Generate WhatsApp message
    String message = "Hello Annamalaiyar Chettinadu Snacks, I'd like to place an order!\n\n";
    message += "Order ID: #$orderId\n";
    message += "City: $selectedCity\n\n";
    message += "Items:\n";
    for (var item in items) {
      message += "- ${item.product.name} x ${item.quantity}: ₹${(item.product.price * item.quantity).toStringAsFixed(2)}\n";
    }
    message += "\nTotal Amount: ₹${total.toStringAsFixed(2)}";

    final whatsappUrl = "whatsapp://send?phone=+918681020301&text=${Uri.encodeComponent(message)}";
    
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Order Placed Successfully!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text("Order ID: #$orderId", style: const TextStyle(color: kTextMuted)),
            const SizedBox(height: 16),
            const Text("Click OK to confirm your order on WhatsApp."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              cart.clearCart();
              await orderController.loadOrders(products);
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(); // pop dialog
              }
              if (context.mounted) {
                Navigator.of(context).pop(); // pop cart page
              }
              if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                await launchUrl(Uri.parse(whatsappUrl));
              }
            },
            child: const Text("OK", style: TextStyle(color: kGold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
