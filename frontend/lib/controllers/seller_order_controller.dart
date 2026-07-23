import 'package:flutter/foundation.dart';
import '../models/seller_order.dart';
import '../services/seller_api_service.dart';
import '../utils/error_handler_mixin.dart';
import '../utils/result.dart';

/// ChangeNotifier that manages seller-side order state.
///
/// Intentionally separated from [OrderController] (customer view) so
/// the two can evolve independently. Only instantiated for admin users.
class SellerOrderController extends ChangeNotifier with ErrorHandlerMixin {
  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  List<SellerOrderSummary> _orders = [];
  SellerDashboardStats _stats = SellerDashboardStats.empty;

  /// Flat list of all orders, newest first.
  List<SellerOrderSummary> get orders => List.unmodifiable(_orders);

  /// Dashboard header stats.
  SellerDashboardStats get stats => _stats;

  /// Filters orders by [status]. If null, returns all orders.
  List<SellerOrderSummary> byStatus(SellerOrderStatus? status) {
    if (status == null) return orders;
    return _orders.where((o) => o.status == status).toList();
  }

  /// Count of pending orders — used for badge display.
  int get pendingCount =>
      _orders.where((o) => o.status == SellerOrderStatus.pending).length;

  // ---------------------------------------------------------------------------
  // Load
  // ---------------------------------------------------------------------------

  /// Loads all orders and refreshes the stats in a single parallel request pair.
  /// Returns a [Result] so the UI can show targeted error messages.
  Future<Result<void>> loadAll() async {
    return runSafeResult(() async {
      final results = await Future.wait([
        SellerApiService.fetchAllOrders(),
        SellerApiService.fetchStats(),
      ]);

      _orders = results[0] as List<SellerOrderSummary>;
      _stats = results[1] as SellerDashboardStats;
    });
  }

  /// Fetches the full detail for a specific order (items, customer, etc).
  /// Does not modify [_orders]; detail is returned directly to the caller.
  Future<Result<SellerOrderDetail>> loadOrderDetail(int orderId) async {
    return runSafeResult(() => SellerApiService.fetchOrderDetail(orderId));
  }

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  /// Advances an order's fulfillment status.
  /// Optimistically updates the local list so the UI refreshes instantly,
  /// then rolls back on failure.
  Future<Result<void>> updateStatus(
    int orderId,
    SellerOrderStatus newStatus, {
    String? rejectionReason,
  }) async {
    // Optimistic update
    final prevOrders = List<SellerOrderSummary>.from(_orders);
    _patchLocalStatus(orderId, newStatus);
    notifyListeners();

    final result = await runSafeResult(
      () => SellerApiService.updateOrderStatus(
        orderId,
        newStatus,
        rejectionReason: rejectionReason,
      ),
    );

    if (result.isFailure) {
      // Rollback on error
      _orders = prevOrders;
      notifyListeners();
    } else {
      // Refresh stats since pending count may have changed
      _refreshStats();
    }

    return result;
  }

  /// Marks an order's payment as verified.
  Future<Result<void>> verifyPayment(int orderId) async {
    return runSafeResult(() async {
      await SellerApiService.verifyPayment(orderId);
      // Reload full list so paymentStatus chip updates
      _orders = await SellerApiService.fetchAllOrders();
    });
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _patchLocalStatus(int orderId, SellerOrderStatus newStatus) {
    _orders = _orders.map((o) {
      if (o.id != orderId) return o;
      // Rebuild the summary with the new status using a copy-like approach
      return SellerOrderSummary(
        id: o.id,
        status: newStatus,
        paymentStatus: o.paymentStatus,
        totalPrice: o.totalPrice,
        paymentMethod: o.paymentMethod,
        createdAt: o.createdAt,
        updatedAt: DateTime.now(),
        customer: o.customer,
      );
    }).toList();
  }

  Future<void> _refreshStats() async {
    try {
      _stats = await SellerApiService.fetchStats();
      notifyListeners();
    } catch (_) {
      // Best-effort; stats will update on next full refresh
    }
  }
}
