import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thiru_annamalaiyar_snacks/models/order.dart';
import 'package:thiru_annamalaiyar_snacks/constants.dart';

class OrderDetailsPage extends StatelessWidget {
  final OrderModel order;
  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.white,
        foregroundColor: kDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 24),
            const Text('ORDER ITEMS', style: TextStyle(fontWeight: FontWeight.bold, color: kTextMuted, fontSize: 12, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            _buildItemsList(),
            const Divider(height: 32),
            _buildSummary(),
            const SizedBox(height: 24),
            const Text('DELIVERY ADDRESS', style: TextStyle(fontWeight: FontWeight.bold, color: kTextMuted, fontSize: 12, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            _buildAddress(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kGoldPale,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, color: kGold, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #${order.id.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(DateFormat('MMM dd, yyyy • hh:mm a').format(order.date), style: TextStyle(color: kTextMuted, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kGold,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              order.status.name.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Column(
      children: order.items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Text(item.product.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('${item.quantity} x ${item.product.unit}', style: TextStyle(color: kTextMuted, fontSize: 12)),
                ],
              ),
            ),
            Text('₹${(item.product.price * item.quantity).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildSummary() {
    return Column(
      children: [
        _summaryRow('Subtotal', '₹${order.totalAmount.toStringAsFixed(2)}'),
        const SizedBox(height: 8),
        _summaryRow('Delivery Fee', 'FREE', isGreen: true),
        const Divider(height: 24),
        _summaryRow('Total', '₹${order.totalAmount.toStringAsFixed(2)}', isBold: true),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false, bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 16 : 14)),
        Text(value, style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: isBold ? 16 : 14,
          color: isGreen ? Colors.green : (isBold ? kRed : kText),
        )),
      ],
    );
  }

  Widget _buildAddress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(order.city, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(order.address, style: TextStyle(color: kTextMuted)),
        ],
      ),
    );
  }
}
