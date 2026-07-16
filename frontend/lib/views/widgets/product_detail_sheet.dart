import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../models/product.dart';
import '../../controllers/cart_controller.dart';

class ProductDetailSheet extends StatelessWidget {
  final Product product;
  const ProductDetailSheet({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(kRadiusXL),
          ),
        ),
        child: ListView(
          controller: controller,
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(kPaddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.badge != null) _buildBadge(colorScheme),
                  const SizedBox(height: kPaddingM),
                  _buildTitleAndPrice(theme, colorScheme),
                  Text(
                    "per ${product.unit}",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: kPaddingL),
                  Text(
                    kDescription,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: kPaddingS),
                  Text(
                    product.desc,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: kPaddingXL),
                  Text(
                    kHighlights,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: kPaddingM),
                  Wrap(
                    spacing: kPaddingS,
                    runSpacing: kPaddingS,
                    children: [
                      _buildHighlight(
                          colorScheme, Icons.verified_outlined, kAuthentic),
                      _buildHighlight(
                          colorScheme, Icons.home_outlined, kHomemade),
                      _buildHighlight(
                          colorScheme, Icons.timer_outlined, kFreshlyMade),
                      _buildHighlight(
                          colorScheme, Icons.eco_outlined, kNoPreservatives),
                    ],
                  ),
                  const SizedBox(height: kPaddingXL),
                  // Consumer to rebuild only action row when cart changes
                  Consumer<CartController>(
                    builder: (context, cart, _) {
                      final qty = cart.items[product.id] ?? 0;
                      return _buildActionRow(
                          cart, qty, context, theme, colorScheme);
                    },
                  ),
                  const SizedBox(height: kPaddingXL),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          height: 350,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(kRadiusXL),
            ),
          ),
          child: Hero(
            tag: 'product-${product.id}',
            child: product.image != null && product.image!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.image!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImagePlaceholder(),
                    errorWidget: (context, url, error) =>
                        _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
        ),
        Positioned(
          top: kPaddingM,
          right: kPaddingM,
          child: IconButton.filled(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
              foregroundColor: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Text(
        product.emoji,
        style: const TextStyle(fontSize: 100),
      ),
    );
  }

  Widget _buildBadge(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: kPaddingM, vertical: kPaddingXS),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(kRadiusXL),
      ),
      child: Text(
        product.badge!,
        style: TextStyle(
          color: colorScheme.onSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTitleAndPrice(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            product.name,
            style: theme.textTheme.displaySmall,
          ),
        ),
        Text(
          "$kCurrency${product.price.toStringAsFixed(0)}",
          style: theme.textTheme.displaySmall
              ?.copyWith(color: colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildActionRow(
    CartController cart,
    int qty,
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        if (qty > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: kPaddingXS),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(kRadiusM),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => cart.removeItem(product.id),
                  icon: Icon(Icons.remove, color: colorScheme.primary),
                ),
                Text(
                  "$qty",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => cart.addItem(product.id),
                  icon: Icon(Icons.add, color: colorScheme.primary),
                ),
              ],
            ),
          ),
        const SizedBox(width: kPaddingM),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (qty == 0) cart.addItem(product.id);
              Navigator.pop(context);
            },
            child: Text(
              qty > 0
                  ? kInCartContinue
                  : "$kAddToCart • $kCurrency${product.price.toStringAsFixed(0)}",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlight(ColorScheme colorScheme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: kPaddingM, vertical: kPaddingS),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(kRadiusM),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: kPaddingS),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
