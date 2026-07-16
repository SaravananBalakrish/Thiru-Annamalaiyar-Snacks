import 'package:flutter/material.dart';
import '../../../constants.dart';

class OrderSummaryCard extends StatelessWidget {
  final double itemTotal;
  final double deliveryFee;

  const OrderSummaryCard({
    super.key,
    required this.itemTotal,
    this.deliveryFee = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grandTotal = itemTotal + deliveryFee;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kPaddingM),
        child: Column(
          children: [
            _buildBillRow(theme, "Item Total", "$kCurrency${itemTotal.toStringAsFixed(2)}"),
            _buildBillRow(theme, "Delivery Fee", "$kCurrency${deliveryFee.toStringAsFixed(2)}"),
            const Divider(height: kPaddingL),
            _buildBillRow(theme, "Total Amount", "$kCurrency${grandTotal.toStringAsFixed(2)}", isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildBillRow(ThemeData theme, String label, String value, {bool isTotal = false}) {
    final colorScheme = theme.colorScheme;
    final style = isTotal ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold) : theme.textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kPaddingXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style?.copyWith(color: isTotal ? colorScheme.primary : null)),
        ],
      ),
    );
  }
}
