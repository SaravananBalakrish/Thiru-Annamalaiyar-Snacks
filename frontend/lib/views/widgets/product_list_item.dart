import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product.dart';

class ProductListItem extends StatelessWidget {
  final Product product;
  final bool showBadge;

  const ProductListItem({
    super.key,
    required this.product,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: kPaddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(colorScheme),
          const SizedBox(width: kPaddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductTitle(theme, colorScheme),
                Text(
                  "$kCurrency${product.price}",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: kPaddingS),
                Selector<CartController, int>(
                  selector: (_, cart) => cart.items[product.id] ?? 0,
                  builder: (context, qty, _) =>
                      _buildAddButton(context, product, qty, colorScheme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(ColorScheme colorScheme) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(kRadiusM),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusM),
        child: product.image != null && product.image!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: product.image!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildProductTitle(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            product.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showBadge)
          const Icon(
            Icons.check_box_outline_blank,
            color: kVegColor,
            size: kIconSmall,
          ),
      ],
    );
  }

  Widget _buildPlaceholder() => Center(
        child: Text(
          product.emoji,
          style: const TextStyle(fontSize: 32),
        ),
      );

  Widget _buildAddButton(
    BuildContext context,
    Product product,
    int qty,
    ColorScheme colorScheme,
  ) {
    final cart = context.read<CartController>();
    if (qty > 0) {
      return Container(
        width: 100,
        height: 32,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(kRadiusS),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _qtyAction(
              Icons.remove,
              () => cart.removeItem(product.id),
              colorScheme.primary,
            ),
            Text(
              "$qty",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            _qtyAction(
              Icons.add,
              () => cart.addItem(product.id),
              colorScheme.primary,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: 80,
      height: 32,
      child: OutlinedButton(
        onPressed: () => cart.addItem(product.id),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusS),
          ),
        ),
        child: Text(
          kAdd,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }

  Widget _qtyAction(IconData icon, VoidCallback onTap, Color color) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(icon, size: 16, color: color),
        ),
      );
}
