import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/product.dart';
import '../../models/order.dart';
import '../../models/address.dart';
import '../../controllers/address_controller.dart';
import 'saved_addresses_page.dart';
import 'main_screen.dart';
import '../widgets/cart/cart_item_tile.dart';
import '../widgets/cart/order_summary_card.dart';
import '../widgets/cart/fulfillment_selector.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String selectedCity = "BENGALURU";
  bool _isPlacingOrder = false;
  bool _isDelivery = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          kMyCart,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Selector<CartController, bool>(
        selector: (_, cart) => cart.items.isEmpty,
        builder: (context, isEmpty, _) {
          if (isEmpty) {
            return _buildEmptyState(context, theme);
          }
          return _buildCartContent(context, theme);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kPaddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(kPaddingL),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: kPaddingL),
            Text(
              kEmptyCartTitle,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: kPaddingS),
            Text(
              kEmptyCartSubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: kPaddingXL),
            ElevatedButton(
              onPressed: () {
                final mainScreen = MainScreen.of(context);
                Navigator.of(context).popUntil((route) => route.isFirst);
                mainScreen?.setIndex(0);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: kPaddingXL, vertical: kPaddingM),
              ),
              child: const Text(kStartShopping),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(kPaddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FulfillmentSelector(
            isDelivery: _isDelivery,
            onChanged: (val) => setState(() => _isDelivery = val),
          ),
          const SizedBox(height: kPaddingM),
          _buildLocationCard(context, theme),
          const SizedBox(height: kPaddingL),
          Text(
            kOrderItems,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: kPaddingS),
          
          // Optimized: Only the list rebuilds when item count changes
          Selector<CartController, List<int>>(
            selector: (_, cart) => cart.items.keys.toList(),
            builder: (context, productIds, _) {
              final productController = context.read<ProductController>();
              final cart = context.read<CartController>();
              
              return Column(
                children: productIds.map((id) {
                  final product = productController.productsMap[id] ?? Product.empty(id);
                  return Selector<CartController, int>(
                    selector: (_, c) => c.items[id] ?? 0,
                    builder: (context, qty, _) {
                      if (qty == 0) return const SizedBox.shrink();
                      return CartItemTile(
                        product: product,
                        quantity: qty,
                        onAdd: () => cart.addItem(id),
                        onRemove: () => cart.removeItem(id),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
          
          const SizedBox(height: kPaddingL),
          _buildYouMayAlsoLike(theme),
          const SizedBox(height: kPaddingL),
          _buildNoteSection(theme),
          const SizedBox(height: kPaddingL),
          
          // Optimized: Only the price summary rebuilds
          Selector2<CartController, ProductController, double>(
            selector: (_, cart, pc) => cart.getTotalPriceWithMap(pc.productsMap),
            builder: (context, totalPrice, _) => OrderSummaryCard(
              itemTotal: totalPrice,
              deliveryFee: 0.0,
            ),
          ),
          
          const SizedBox(height: kPaddingL),
          _buildActionButtons(context, theme),
          const SizedBox(height: kPaddingXL),
        ],
      ),
    );
  }


  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
  ) {
    return Selector2<CartController, ProductController, double>(
      selector: (_, cart, pc) => cart.getTotalPriceWithMap(pc.productsMap),
      builder: (context, total, _) => ElevatedButton(
        onPressed: _isPlacingOrder ? null : () => _handlePlaceOrder(context, theme),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 54),
        ),
        child: _isPlacingOrder
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(kPlaceOrderTitle, style: TextStyle(fontSize: 18)),
                  SizedBox(width: kPaddingS),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
      ),
    );
  }


  Widget _buildLocationCard(BuildContext context, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Consumer<AddressController>(
      builder: (context, addressController, _) {
        final displayAddress = addressController.selectedAddress;

        final addressText = _isDelivery
            ? (displayAddress?.fullAddress ?? "Select delivery address")
            : "$selectedCity Branch";
        final cityText = displayAddress?.city ?? selectedCity;

        return Card(
          child: InkWell(
            onTap: () async {
              if (_isDelivery) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedAddressesPage(),
                  ),
                );
                if (result != null && result is Address) {
                  addressController.setSelectedAddress(result);
                }
              } else {
                _showLocationPicker(context, theme);
              }
            },
            borderRadius: BorderRadius.circular(kRadiusM),
            child: Padding(
              padding: const EdgeInsets.all(kPaddingM),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(kPaddingS),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(kRadiusS),
                    ),
                    child: Icon(
                      _isDelivery ? Icons.location_on : Icons.store,
                      color: colorScheme.primary,
                      size: kIconMedium,
                    ),
                  ),
                  const SizedBox(width: kPaddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isDelivery ? kDeliveryAddress : kPickupFrom,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        Text(
                          _isDelivery
                              ? (displayAddress != null ? "$cityText: $addressText" : addressText)
                              : addressText,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLocationPicker(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(kPaddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isDelivery ? kSelectCity : kSelectBranch,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: kPaddingM),
            ...["BENGALURU", "Mandya", "Mysore", "TUMKUR", "Hosur"]
                .map((city) => _buildCityItem(city, theme)),
            const SizedBox(height: kPaddingM),
          ],
        ),
      ),
    );
  }

  Widget _buildCityItem(String name, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return ListTile(
      leading: Icon(Icons.location_city, color: colorScheme.primary),
      title: Text(name, style: theme.textTheme.bodyLarge),
      trailing: selectedCity == name
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : null,
      onTap: () {
        setState(() => selectedCity = name);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildYouMayAlsoLike(ThemeData theme) {
    final productController = context.read<ProductController>();
    return Selector<CartController, List<int>>(
      selector: (_, cart) => cart.items.keys.toList(),
      builder: (context, productIds, _) {
        final recommendations = productController.getRecommendations(productIds);
        if (recommendations.isEmpty) return const SizedBox.shrink();
        final colorScheme = theme.colorScheme;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kYouMayLike,
              style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: kPaddingS),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: recommendations.length,
                itemBuilder: (context, index) => _buildSmallProductCard(context, recommendations[index], theme),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSmallProductCard(
    BuildContext context,
    Product product,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;
    final cart = context.read<CartController>();
    return Card(
      margin: const EdgeInsets.only(right: kPaddingM, bottom: kPaddingXS),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(kPaddingS),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(kRadiusS),
              child: product.image != null && product.image!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.image!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildPlaceholder(product, theme),
                      errorWidget: (context, url, error) =>
                          _buildPlaceholder(product, theme),
                    )
                  : _buildPlaceholder(product, theme, 70),
            ),
            const SizedBox(width: kPaddingS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "$kCurrency${product.price}",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.add_circle,
                color: colorScheme.primary,
                size: kIconLarge,
              ),
              onPressed: () => cart.addItem(product.id),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Product product, ThemeData theme, [double size = 24]) =>
      Container(
        width: size,
        height: size,
        color: theme.colorScheme.surfaceContainerHighest,
        child: Center(
            child: Text(product.emoji, style: TextStyle(fontSize: size * 0.4))),
      );

  Widget _buildNoteSection(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Card(
      child: ListTile(
        leading: Icon(Icons.edit_note, color: colorScheme.primary),
        title: Text(kAddNote, style: theme.textTheme.bodyMedium),
        trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
        onTap: () {},
      ),
    );
  }

  Future<void> _handlePlaceOrder(
    BuildContext context,
    ThemeData theme,
  ) async {
    final cart = context.read<CartController>();
    final productController = context.read<ProductController>();
    final orderController = context.read<OrderController>();
    final addressController = context.read<AddressController>();
    final total = cart.getTotalPriceWithMap(productController.productsMap);

    Address? finalAddress = addressController.selectedAddress;

    if (_isDelivery && finalAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a delivery address")),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    final String orderAddress = _isDelivery
        ? "${finalAddress!.fullAddress}, ${finalAddress.city}"
        : "STORE PICKUP";
    final String orderCity = _isDelivery ? finalAddress!.city : selectedCity;

    final apiOrderResult = await orderController.placeOrder(
        orderAddress, orderCity, "whatsapp");

    setState(() => _isPlacingOrder = false);

    if (apiOrderResult.isFailure) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiOrderResult.exceptionOrNull.toString())),
      );
      return;
    }

    final apiOrder = apiOrderResult.valueOrNull;
    final orderId = apiOrder?.id?.toString() ?? "PENDING";
    final List<OrderItem> items = cart.items.entries.map((entry) {
      final product = productController.productsMap[entry.key] ?? Product.empty(entry.key);
      return OrderItem(product: product, quantity: entry.value);
    }).toList();

    // Generate WhatsApp message
    String message =
        "Hello Annamalaiyar Chettinadu Snacks, I'd like to place an order!\n\n";
    message += "Order ID: #$orderId\n";
    message += "Method: ${_isDelivery ? kDelivery : kStorePickup}\n";
    message += "City: $orderCity\n";
    if (_isDelivery) {
      message += "Address: $orderAddress\n";
    }
    message += "\nItems:\n";
    for (var item in items) {
      message +=
          "- ${item.product.name} x ${item.quantity}: ₹${(item.product.price * item.quantity).toStringAsFixed(2)}\n";
    }
    message += "\nTotal Amount: ₹${total.toStringAsFixed(2)}";

    final whatsappUrl =
        "whatsapp://send?phone=+918681020301&text=${Uri.encodeComponent(message)}";

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: kVegColor, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(kOrderSuccess,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text("$kOrderIdPrefix$orderId",
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            const Text(kWhatsAppConfirm),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              cart.clearCart();
              await orderController.loadOrders(productController.products);
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(); // pop dialog
              }
              if (context.mounted) {
                final mainScreen = MainScreen.of(context);
                // Return to main screen / home stack
                Navigator.of(context).popUntil((route) => route.isFirst);
                // Switch to home tab
                mainScreen?.setIndex(0);
              }
              if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                await launchUrl(Uri.parse(whatsappUrl));
              }
            },
            child: Text(kOk,
                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
