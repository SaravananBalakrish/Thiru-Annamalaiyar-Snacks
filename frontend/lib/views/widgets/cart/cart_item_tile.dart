import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/product.dart';

class CartItemTile extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: kPaddingS),
      child: Padding(
        padding: const EdgeInsets.all(kPaddingS),
        child: Row(
          children: [
            const Icon(Icons.check_box_outlined, color: kVegColor, size: kIconSmall),
            const SizedBox(width: kPaddingS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text("$kCurrency${product.price}", style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            _buildQuantitySelector(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(kRadiusS),
      ),
      child: Row(
        children: [
          _qtyBtn(Icons.remove, onRemove, colorScheme.primary),
          Text("$quantity", style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
          _qtyBtn(Icons.add, onAdd, colorScheme.primary),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, Color color) => IconButton(
    icon: Icon(icon, size: 16, color: color),
    onPressed: onTap,
    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    padding: EdgeInsets.zero,
  );
}
