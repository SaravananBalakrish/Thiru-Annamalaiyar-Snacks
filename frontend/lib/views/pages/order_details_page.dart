import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thiru_annamalaiyar_snacks/models/order.dart';
import 'package:thiru_annamalaiyar_snacks/constants.dart';

class OrderDetailsPage extends StatelessWidget {
  final OrderModel order;
  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kPaddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(theme),
            const SizedBox(height: kPaddingL),
            Text('ORDER ITEMS', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant, letterSpacing: 1.2)),
            const SizedBox(height: kPaddingM),
            _buildItemsList(theme),
            const Divider(height: kPaddingXL),
            _buildSummary(theme),
            const SizedBox(height: kPaddingL),
            Text('DELIVERY ADDRESS', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant, letterSpacing: 1.2)),
            const SizedBox(height: kPaddingM),
            _buildAddress(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(kPaddingM),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(kRadiusM),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.receipt_long, color: colorScheme.primary, size: kIconLarge),
          const SizedBox(width: kPaddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #${order.id.toUpperCase()}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(DateFormat('MMM dd, yyyy • hh:mm a').format(order.date), style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: kPaddingS, vertical: kPaddingXS),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(kRadiusXL),
            ),
            child: Text(
              order.status.name.toUpperCase(),
              style: TextStyle(color: colorScheme.onPrimary, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItemsList(ThemeData theme) {
    return Column(
      children: order.items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: kPaddingM),
        child: Row(
          children: [
            Text(item.product.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: kPaddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Text('${item.quantity} x ${item.product.unit}', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Text('$kCurrency${(item.product.price * item.quantity).toStringAsFixed(2)}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildSummary(ThemeData theme) {
    return Column(
      children: [
        _summaryRow(theme, 'Subtotal', '$kCurrency${order.totalAmount.toStringAsFixed(2)}'),
        const SizedBox(height: kPaddingS),
        _summaryRow(theme, 'Delivery Fee', 'FREE', isGreen: true),
        const Divider(height: kPaddingXL),
        _summaryRow(theme, 'Total', '$kCurrency${order.totalAmount.toStringAsFixed(2)}', isBold: true),
      ],
    );
  }

  Widget _summaryRow(ThemeData theme, String label, String value, {bool isBold = false, bool isGreen = false}) {
    final colorScheme = theme.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: isGreen ? kVegColor : (isBold ? colorScheme.primary : colorScheme.onSurface),
        )),
      ],
    );
  }

  Widget _buildAddress(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kPaddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.city, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: kPaddingXS),
            Text(order.address, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
