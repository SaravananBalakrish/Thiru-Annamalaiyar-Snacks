import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import '../../constants.dart';
import '../pages/main_screen.dart';

class CompactCartStrip extends StatelessWidget {
  const CompactCartStrip({super.key});

  @override
  Widget build(BuildContext context) {
    // Optimization: Use Selector to only rebuild when relevant cart data changes
    return Selector2<CartController, ProductController, _CartStripData>(
      selector: (_, cart, pc) => _CartStripData(
        count: cart.totalCount,
        totalPrice: cart.getTotalPrice(pc.products),
      ),
      builder: (context, data, child) {
        if (data.count == 0) return const SizedBox.shrink();

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return InkWell(
          onTap: () {
            final mainScreen = MainScreen.of(context);
            if (mainScreen != null) {
              mainScreen.setIndex(2); // Index 2 is CartPage
            } else {
              Navigator.pushNamed(context, '/cart');
            }
          },
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(
              horizontal: kPaddingM,
              vertical: kPaddingS + 2,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(kRadiusL),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriceInfo(context, data, colorScheme),
                _buildViewCartButton(colorScheme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceInfo(
    BuildContext context,
    _CartStripData data,
    ColorScheme colorScheme,
  ) {
    final itemText = data.count > 1 ? kItems : kItem;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${data.count} $itemText | $kCurrency ${data.totalPrice.toStringAsFixed(0)}",
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          kExtraChargesNote,
          style: TextStyle(
            color: colorScheme.onPrimary.withValues(alpha: 0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildViewCartButton(ColorScheme colorScheme) {
    return Row(
      children: [
        Text(
          kViewCart,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: kPaddingS),
        Icon(
          Icons.shopping_bag_outlined,
          color: colorScheme.onPrimary,
          size: 20,
        ),
      ],
    );
  }
}

/// Helper class to bundle selector data and prevent unnecessary rebuilds
class _CartStripData {
  final int count;
  final double totalPrice;

  _CartStripData({required this.count, required this.totalPrice});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CartStripData &&
          runtimeType == other.runtimeType &&
          count == other.count &&
          totalPrice == other.totalPrice;

  @override
  int get hashCode => count.hashCode ^ totalPrice.hashCode;
}
