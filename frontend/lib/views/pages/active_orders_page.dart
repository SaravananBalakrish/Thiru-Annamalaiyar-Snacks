import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants.dart';
import '../../controllers/order_controller.dart';
import '../../models/order.dart';
import 'order_details_page.dart';

class ActiveOrdersPage extends StatelessWidget {
  const ActiveOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(kActiveOrders),
      ),
      body: Consumer<OrderController>(
        builder: (context, controller, child) {
          final activeOrders = controller.orders
              .where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled)
              .toList();

          if (activeOrders.isEmpty) {
            return _buildEmptyState(theme, colorScheme);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(kPaddingM),
            itemCount: activeOrders.length,
            itemBuilder: (context, index) {
              return _ActiveOrderCard(order: activeOrders[index], theme: theme, colorScheme: colorScheme);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
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
              child: Icon(Icons.timer_outlined, size: 80, color: colorScheme.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: kPaddingL),
            Text(
              "No active orders",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: kPaddingS),
            Text(
              "You don't have any orders in progress right now.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  final OrderModel order;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _ActiveOrderCard({required this.order, required this.theme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: kPaddingM),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderDetailsPage(order: order)),
          );
        },
        borderRadius: BorderRadius.circular(kRadiusM),
        child: Padding(
          padding: const EdgeInsets.all(kPaddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8).toUpperCase()}',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('MMM dd, hh:mm a').format(order.date),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  _StatusChip(status: order.status, colorScheme: colorScheme),
                ],
              ),
              const Divider(height: kPaddingL),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${order.items.length} ${order.items.length == 1 ? 'Item' : 'Items'}',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '$kCurrency${order.totalAmount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                ],
              ),
              const SizedBox(height: kPaddingM),
              LinearProgressIndicator(
                value: _getStatusProgress(order.status),
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                borderRadius: BorderRadius.circular(kRadiusS),
                minHeight: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getStatusProgress(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 0.2;
      case OrderStatus.processing: return 0.5;
      case OrderStatus.shipped: return 0.8;
      case OrderStatus.delivered: return 1.0;
      default: return 0.0;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  final ColorScheme colorScheme;
  const _StatusChip({required this.status, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case OrderStatus.shipped: color = colorScheme.primary; break;
      case OrderStatus.processing: color = colorScheme.secondary; break;
      default: color = colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(kRadiusXL),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
