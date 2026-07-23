import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../controllers/seller_order_controller.dart';
import '../../../models/seller_order.dart';

/// Stats overview tab for the seller dashboard.
///
/// Shows summary KPI cards at the top and a visual breakdown of order statuses.
class SellerStatsPage extends StatefulWidget {
  const SellerStatsPage({super.key});

  @override
  State<SellerStatsPage> createState() => _SellerStatsPageState();
}

class _SellerStatsPageState extends State<SellerStatsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stats',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<SellerOrderController>().loadAll(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<SellerOrderController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = controller.stats;
          final orders = controller.orders;

          return RefreshIndicator(
            onRefresh: () => controller.loadAll(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(kPaddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Today label ---
                  Text(
                    'TODAY',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: kPaddingS),

                  // --- KPI cards row ---
                  _RevenueCard(revenue: stats.todayRevenue),
                  const SizedBox(height: kPaddingM),

                  Text(
                    'OVERVIEW',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: kPaddingS),

                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Total Orders',
                          value: '${stats.totalOrders}',
                          icon: Icons.receipt_long,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: kPaddingS),
                      Expanded(
                        child: _StatCard(
                          label: 'Pending',
                          value: '${stats.pendingOrders}',
                          icon: Icons.hourglass_top_outlined,
                          color: const Color(0xFFE65100),
                        ),
                      ),
                      const SizedBox(width: kPaddingS),
                      Expanded(
                        child: _StatCard(
                          label: 'Confirmed',
                          value: '${stats.confirmedOrders}',
                          icon: Icons.check_circle_outline,
                          color: const Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: kPaddingL),

                  // --- Status breakdown ---
                  if (orders.isNotEmpty) ...[
                    Text(
                      'STATUS BREAKDOWN',
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: kPaddingS),
                    _StatusBreakdownCard(orders: orders),
                    const SizedBox(height: kPaddingM),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Revenue highlight card
// ---------------------------------------------------------------------------

class _RevenueCard extends StatelessWidget {
  final double revenue;
  const _RevenueCard({required this.revenue});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(kPaddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(kRadiusL),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.currency_rupee,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                "Today's Revenue",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$kCurrency${revenue.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small KPI tile
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(kPaddingM),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(kRadiusM),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(kRadiusS),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status breakdown card with progress bars
// ---------------------------------------------------------------------------

class _StatusBreakdownCard extends StatelessWidget {
  final List<SellerOrderSummary> orders;
  const _StatusBreakdownCard({required this.orders});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final statusRows = [
      (SellerOrderStatus.pending, const Color(0xFFE65100)),
      (SellerOrderStatus.confirmed, const Color(0xFF1565C0)),
      (SellerOrderStatus.packed, const Color(0xFF6A1B9A)),
      (SellerOrderStatus.outForDelivery, colorScheme.primary),
      (SellerOrderStatus.delivered, const Color(0xFF2E7D32)),
      (SellerOrderStatus.rejected, colorScheme.error),
    ];

    final total = orders.isEmpty ? 1 : orders.length;

    return Container(
      padding: const EdgeInsets.all(kPaddingM),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(kRadiusM),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: statusRows.map((row) {
          final (status, color) = row;
          final count = orders.where((o) => o.status == status).length;
          if (count == 0) return const SizedBox.shrink();
          final fraction = count / total;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(status.label,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    Text('$count',
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(kRadiusXL),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 8,
                    backgroundColor: color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
