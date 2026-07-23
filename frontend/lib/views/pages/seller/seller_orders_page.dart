import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../controllers/seller_order_controller.dart';
import '../../../models/seller_order.dart';
import 'seller_order_detail_page.dart';

/// The main orders list screen for the seller.
///
/// A top [TabBar] lets the seller quickly filter by status.
/// Tapping a row opens [SellerOrderDetailPage].
class SellerOrdersPage extends StatefulWidget {
  const SellerOrdersPage({super.key});

  @override
  State<SellerOrdersPage> createState() => _SellerOrdersPageState();
}

class _SellerOrdersPageState extends State<SellerOrdersPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    (label: 'All', status: null),
    (label: 'Pending', status: SellerOrderStatus.pending),
    (label: 'Confirmed', status: SellerOrderStatus.confirmed),
    (label: 'Delivered', status: SellerOrderStatus.delivered),
    (label: 'Rejected', status: SellerOrderStatus.rejected),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Orders',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: colorScheme.primary,
          unselectedLabelColor:
              colorScheme.onSurface.withValues(alpha: 0.5),
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          tabs: _tabs
              .map((t) => Tab(text: t.label))
              .toList(),
        ),
      ),
      body: Consumer<SellerOrderController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null && controller.orders.isEmpty) {
            return _ErrorView(
              message: controller.error!,
              onRetry: () => controller.loadAll(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: _tabs.map((t) {
              final filtered = controller.byStatus(t.status);
              return _OrderList(
                orders: filtered,
                onRefresh: () => controller.loadAll(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scrollable order list with pull-to-refresh
// ---------------------------------------------------------------------------

class _OrderList extends StatelessWidget {
  final List<SellerOrderSummary> orders;
  final Future<void> Function() onRefresh;

  const _OrderList({required this.orders, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 400,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No orders here yet',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(kPaddingM),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: kPaddingS),
        itemBuilder: (ctx, i) => _OrderCard(order: orders[i]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual order card
// ---------------------------------------------------------------------------

class _OrderCard extends StatelessWidget {
  final SellerOrderSummary order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SellerOrderDetailPage(orderId: order.id),
          ),
        ),
        borderRadius: BorderRadius.circular(kRadiusM),
        child: Padding(
          padding: const EdgeInsets.all(kPaddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header row ---
              Row(
                children: [
                  Text(
                    '#${order.id}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  _StatusChip(status: order.status),
                ],
              ),
              const SizedBox(height: 8),

              // --- Customer & time ---
              Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Text(
                    order.customer?.maskedPhone ?? 'Unknown',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Icon(Icons.access_time,
                      size: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(order.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // --- Amount & payment status ---
              Row(
                children: [
                  Text(
                    '$kCurrency${order.totalPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall,
                  ),
                  const Spacer(),
                  _PaymentChip(status: order.paymentStatus),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return 'Today $h:$m';
    }
    return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------
// Status chip
// ---------------------------------------------------------------------------

class _StatusChip extends StatelessWidget {
  final SellerOrderStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = _colors(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(kRadiusXL),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  (Color bg, Color text) _colors(BuildContext context, SellerOrderStatus s) {
    final cs = Theme.of(context).colorScheme;
    return switch (s) {
      SellerOrderStatus.pending => (
          const Color(0xFFFFF3E0),
          const Color(0xFFE65100)
        ),
      SellerOrderStatus.confirmed => (
          const Color(0xFFE3F2FD),
          const Color(0xFF1565C0)
        ),
      SellerOrderStatus.packed => (
          const Color(0xFFF3E5F5),
          const Color(0xFF6A1B9A)
        ),
      SellerOrderStatus.outForDelivery => (
          cs.primary.withValues(alpha: 0.12),
          cs.primary
        ),
      SellerOrderStatus.delivered => (
          const Color(0xFFE8F5E9),
          const Color(0xFF2E7D32)
        ),
      SellerOrderStatus.rejected => (
          cs.error.withValues(alpha: 0.12),
          cs.error
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Payment chip
// ---------------------------------------------------------------------------

class _PaymentChip extends StatelessWidget {
  final SellerPaymentStatus status;
  const _PaymentChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isPaid = status == SellerPaymentStatus.paid;
    final bg = isPaid
        ? const Color(0xFFE8F5E9)
        : cs.error.withValues(alpha: 0.1);
    final textColor =
        isPaid ? const Color(0xFF2E7D32) : cs.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(kRadiusXL),
        border: Border.all(
          color: textColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaid ? Icons.check_circle_outline : Icons.pending_outlined,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kPaddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: 64, color: colorScheme.error.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text(kRetry),
            ),
          ],
        ),
      ),
    );
  }
}
