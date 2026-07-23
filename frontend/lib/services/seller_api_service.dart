import 'package:dio/dio.dart';
import '../models/seller_order.dart';
import 'api_service.dart';

/// All HTTP calls that require `role = admin`.
/// Uses the same [Dio] instance from [ApiService] so auth interceptors
/// (token refresh, error snackbars, retry logic) apply automatically.
class SellerApiService {
  // Share the same configured Dio with auth interceptors already attached.
  // ignore: library_private_types_in_public_api
  static Dio get _dio => ApiService.sharedDio;

  // ---------------------------------------------------------------------------
  // Orders
  // ---------------------------------------------------------------------------

  /// Fetches all orders across all customers, ordered newest-first.
  static Future<List<SellerOrderSummary>> fetchAllOrders() async {
    final response = await _dio.get<Map<String, dynamic>>('/v1/admin/orders');
    final data = response.data?['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => SellerOrderSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches the full detail for a single order, including items and customer.
  static Future<SellerOrderDetail> fetchOrderDetail(int orderId) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/v1/admin/orders/$orderId');
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) throw Exception('Unexpected response from server');
    return SellerOrderDetail.fromJson(data);
  }

  /// Updates the fulfillment status of an order.
  /// [rejectionReason] is required when [status] is `rejected`.
  static Future<void> updateOrderStatus(
    int orderId,
    SellerOrderStatus status, {
    String? rejectionReason,
  }) async {
    await _dio.put<void>(
      '/v1/admin/orders/$orderId/status',
      data: {
        'status': status.apiValue,
        if (status == SellerOrderStatus.rejected && rejectionReason != null)
          'rejectionReason': rejectionReason,
      },
    );
  }

  /// Marks an order's payment as verified (pending → paid).
  /// Idempotent — safe to call if already paid.
  static Future<void> verifyPayment(int orderId) async {
    await _dio.put<void>('/v1/admin/orders/$orderId/verify-payment');
  }

  // ---------------------------------------------------------------------------
  // Stats
  // ---------------------------------------------------------------------------

  /// Fetches the dashboard summary (totals, pending count, today's revenue).
  static Future<SellerDashboardStats> fetchStats() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/v1/admin/dashboard/stats');
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) return SellerDashboardStats.empty;
    return SellerDashboardStats.fromJson(data);
  }
}
