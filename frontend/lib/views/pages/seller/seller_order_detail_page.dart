import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../controllers/seller_order_controller.dart';
import '../../../models/seller_order.dart';

/// Full order detail view for the seller.
///
/// Fetches order data on first build and shows action buttons based on the
/// current fulfillment status. Status transitions are one-directional; the
/// seller can also reject pending/confirmed orders.
class SellerOrderDetailPage extends StatefulWidget {
  final int orderId;

  const SellerOrderDetailPage({super.key, required this.orderId});

  @override
  State<SellerOrderDetailPage> createState() => _SellerOrderDetailPageState();
}

class _SellerOrderDetailPageState extends State<SellerOrderDetailPage> {
  SellerOrderDetail? _order;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await context
        .read<SellerOrderController>()
        .loadOrderDetail(widget.orderId);

    if (!mounted) return;

    result.fold(
      (detail) => setState(() {
        _order = detail;
        _loading = false;
      }),
      (ex) => setState(() {
        _error = ex.message;
        _loading = false;
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // Status update helpers
  // ---------------------------------------------------------------------------

  Future<void> _advanceStatus(SellerOrderStatus next) async {
    final result = await context
        .read<SellerOrderController>()
        .updateStatus(widget.orderId, next);

    if (!mounted) return;

    if (result.isSuccess) {
      _showSnack('Order updated to "${next.label}"', isError: false);
      // Reload detail to reflect the new status
      _loadDetail();
    }
  }

  Future<void> _rejectOrder() async {
    final reason = await _showRejectionDialog();
    if (reason == null || !mounted) return;

    final result = await context
        .read<SellerOrderController>()
        .updateStatus(
          widget.orderId,
          SellerOrderStatus.rejected,
          rejectionReason: reason,
        );

    if (!mounted) return;
    if (result.isSuccess) {
      _showSnack('Order rejected', isError: false);
      _loadDetail();
    }
  }

  Future<void> _verifyPayment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify Payment?'),
        content: const Text(
            'Mark this order\'s payment as received? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result =
        await context.read<SellerOrderController>().verifyPayment(widget.orderId);

    if (!mounted) return;
    if (result.isSuccess) {
      _showSnack('Payment verified ✓', isError: false);
      _loadDetail();
    }
  }

  Future<String?> _showRejectionDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for the customer:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Out of stock, unable to deliver today...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final reason = controller.text.trim();
              if (reason.isEmpty) return;
              Navigator.pop(ctx, reason);
            },
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message, {required bool isError}) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? cs.error : const Color(0xFF2E7D32),
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order #${widget.orderId}',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDetail,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Builder(builder: (_) {
        if (_loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(kPaddingXL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 56,
                      color: colorScheme.error.withValues(alpha: 0.7)),
                  const SizedBox(height: 16),
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                      onPressed: _loadDetail, child: const Text(kRetry)),
                ],
              ),
            ),
          );
        }

        final order = _order!;
        return _DetailBody(
          order: order,
          onAdvance: order.status.nextStatus != null
              ? () => _advanceStatus(order.status.nextStatus!)
              : null,
          onReject: order.status.canReject ? _rejectOrder : null,
          onVerifyPayment:
              order.paymentStatus == SellerPaymentStatus.pending
                  ? _verifyPayment
                  : null,
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail body — scrollable content + sticky action bar
// ---------------------------------------------------------------------------

class _DetailBody extends StatelessWidget {
  final SellerOrderDetail order;
  final VoidCallback? onAdvance;
  final VoidCallback? onReject;
  final VoidCallback? onVerifyPayment;

  const _DetailBody({
    required this.order,
    this.onAdvance,
    this.onReject,
    this.onVerifyPayment,
  });

  @override
  Widget build(BuildContext context) {
    final hasActions =
        onAdvance != null || onReject != null || onVerifyPayment != null;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: kPaddingM,
              right: kPaddingM,
              top: kPaddingM,
              bottom: hasActions ? 0 : kPaddingM,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusRow(order: order),
                const SizedBox(height: kPaddingM),
                _CustomerCard(order: order),
                const SizedBox(height: kPaddingM),
                _ItemsCard(order: order),
                const SizedBox(height: kPaddingM),
                _PaymentCard(order: order),
                if (order.rejectionReason != null) ...[
                  const SizedBox(height: kPaddingM),
                  _RejectionCard(reason: order.rejectionReason!),
                ],
                const SizedBox(height: kPaddingM),
              ],
            ),
          ),
        ),
        if (hasActions) _ActionBar(
          order: order,
          onAdvance: onAdvance,
          onReject: onReject,
          onVerifyPayment: onVerifyPayment,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Status row at the top
// ---------------------------------------------------------------------------

class _StatusRow extends StatelessWidget {
  final SellerOrderDetail order;
  const _StatusRow({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Text('Status:', style: theme.textTheme.bodyMedium),
        const SizedBox(width: 8),
        _statusBadge(context, order.status, colorScheme),
        const Spacer(),
        Text(
          _formatDateTime(order.createdAt),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _statusBadge(
      BuildContext context, SellerOrderStatus s, ColorScheme cs) {
    final (bg, text) = switch (s) {
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(kRadiusXL),
      ),
      child: Text(s.label,
          style: TextStyle(
              color: text,
              fontWeight: FontWeight.bold,
              fontSize: 12)),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------
// Customer info card
// ---------------------------------------------------------------------------

class _CustomerCard extends StatelessWidget {
  final SellerOrderDetail order;
  const _CustomerCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _SectionCard(
      title: 'Customer',
      icon: Icons.person_outline,
      child: Row(
        children: [
          Icon(Icons.phone_outlined,
              size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            order.customer?.phoneNumber ?? 'N/A',
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Items card
// ---------------------------------------------------------------------------

class _ItemsCard extends StatelessWidget {
  final SellerOrderDetail order;
  const _ItemsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _SectionCard(
      title: 'Items (${order.items.length})',
      icon: Icons.shopping_bag_outlined,
      child: Column(
        children: [
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(item.productName,
                          style: theme.textTheme.bodyMedium),
                    ),
                    Text(
                      '× ${item.quantity}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '$kCurrency${item.lineTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )),
          const Divider(height: 24),
          Row(
            children: [
              const Spacer(),
              Text('Total', style: theme.textTheme.titleSmall),
              const SizedBox(width: 24),
              Text(
                '$kCurrency${order.totalPrice.toStringAsFixed(2)}',
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Payment card
// ---------------------------------------------------------------------------

class _PaymentCard extends StatelessWidget {
  final SellerOrderDetail order;
  const _PaymentCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPaid = order.paymentStatus == SellerPaymentStatus.paid;

    return _SectionCard(
      title: 'Payment',
      icon: Icons.payments_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'Method', value: order.paymentMethod.toUpperCase()),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Status',
            value: order.paymentStatus.label,
            valueColor: isPaid
                ? const Color(0xFF2E7D32)
                : colorScheme.error,
          ),
          if (order.transactionRef != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Txn Ref',
              value: order.transactionRef!,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rejection reason card
// ---------------------------------------------------------------------------

class _RejectionCard extends StatelessWidget {
  final String reason;
  const _RejectionCard({required this.reason});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(kPaddingM),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(kRadiusM),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cancel_outlined,
              color: colorScheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rejection Reason',
                    style: TextStyle(
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                const SizedBox(height: 4),
                Text(reason),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sticky action bar at the bottom
// ---------------------------------------------------------------------------

class _ActionBar extends StatelessWidget {
  final SellerOrderDetail order;
  final VoidCallback? onAdvance;
  final VoidCallback? onReject;
  final VoidCallback? onVerifyPayment;

  const _ActionBar({
    required this.order,
    this.onAdvance,
    this.onReject,
    this.onVerifyPayment,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: kPaddingM,
        right: kPaddingM,
        bottom: MediaQuery.of(context).padding.bottom + kPaddingM,
        top: kPaddingM,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary action (advance status)
          if (onAdvance != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAdvance,
                icon: const Icon(Icons.arrow_forward),
                label: Text(order.status.actionLabel ?? 'Update'),
              ),
            ),

          if (onVerifyPayment != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onVerifyPayment,
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Verify Payment'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                  side: const BorderSide(color: Color(0xFF2E7D32)),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          ],

          // Reject (secondary destructive)
          if (onReject != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onReject,
                icon: Icon(Icons.cancel_outlined, color: colorScheme.error),
                label: Text('Reject Order',
                    style: TextStyle(color: colorScheme.error)),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable section card
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
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
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: colorScheme.onSurfaceVariant,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: theme.textTheme.bodySmall),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
