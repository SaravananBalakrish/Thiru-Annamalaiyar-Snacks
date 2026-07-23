/// Rich order model used by the seller dashboard.
/// Decoupled from the customer-facing [OrderModel] so each can evolve independently.
library;

// ---------------------------------------------------------------------------
// Status enum
// ---------------------------------------------------------------------------

/// The complete lifecycle of an order, driven by the seller.
enum SellerOrderStatus {
  pending,
  confirmed,
  packed,
  outForDelivery,
  delivered,
  rejected;

  /// Deserialises the snake_case string returned by the backend.
  static SellerOrderStatus fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'confirmed' => SellerOrderStatus.confirmed,
      'packed' => SellerOrderStatus.packed,
      'out_for_delivery' => SellerOrderStatus.outForDelivery,
      'delivered' => SellerOrderStatus.delivered,
      'rejected' => SellerOrderStatus.rejected,
      _ => SellerOrderStatus.pending,
    };
  }

  /// The snake_case string expected by the backend PUT endpoint.
  String get apiValue => switch (this) {
        SellerOrderStatus.pending => 'pending',
        SellerOrderStatus.confirmed => 'confirmed',
        SellerOrderStatus.packed => 'packed',
        SellerOrderStatus.outForDelivery => 'out_for_delivery',
        SellerOrderStatus.delivered => 'delivered',
        SellerOrderStatus.rejected => 'rejected',
      };

  /// Human-readable label shown in the UI.
  String get label => switch (this) {
        SellerOrderStatus.pending => 'Pending',
        SellerOrderStatus.confirmed => 'Confirmed',
        SellerOrderStatus.packed => 'Packed',
        SellerOrderStatus.outForDelivery => 'Out for Delivery',
        SellerOrderStatus.delivered => 'Delivered',
        SellerOrderStatus.rejected => 'Rejected',
      };

  /// The next status the seller can move this order to.
  /// Returns null when no further transition is possible.
  SellerOrderStatus? get nextStatus => switch (this) {
        SellerOrderStatus.pending => SellerOrderStatus.confirmed,
        SellerOrderStatus.confirmed => SellerOrderStatus.packed,
        SellerOrderStatus.packed => SellerOrderStatus.outForDelivery,
        SellerOrderStatus.outForDelivery => SellerOrderStatus.delivered,
        SellerOrderStatus.delivered => null,
        SellerOrderStatus.rejected => null,
      };

  /// Label text for the primary action button.
  String? get actionLabel => switch (this) {
        SellerOrderStatus.pending => 'Confirm Order',
        SellerOrderStatus.confirmed => 'Mark as Packed',
        SellerOrderStatus.packed => 'Out for Delivery',
        SellerOrderStatus.outForDelivery => 'Mark Delivered',
        _ => null,
      };

  /// Whether an order in this status can still be rejected.
  bool get canReject =>
      this == SellerOrderStatus.pending || this == SellerOrderStatus.confirmed;

  /// Whether this is a terminal state (no further seller action needed).
  bool get isTerminal =>
      this == SellerOrderStatus.delivered || this == SellerOrderStatus.rejected;
}

// ---------------------------------------------------------------------------
// Payment status enum
// ---------------------------------------------------------------------------

enum SellerPaymentStatus {
  pending,
  paid;

  static SellerPaymentStatus fromString(String? value) =>
      value?.toLowerCase() == 'paid'
          ? SellerPaymentStatus.paid
          : SellerPaymentStatus.pending;

  String get label => switch (this) {
        SellerPaymentStatus.pending => 'Unpaid',
        SellerPaymentStatus.paid => 'Paid',
      };
}

// ---------------------------------------------------------------------------
// Line item inside an order
// ---------------------------------------------------------------------------

class SellerOrderItem {
  final int id;
  final int productId;
  final String productName;
  final String? productImageUrl;
  final int quantity;
  final double price;

  const SellerOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.quantity,
    required this.price,
  });

  double get lineTotal => price * quantity;

  factory SellerOrderItem.fromJson(Map<String, dynamic> json) {
    return SellerOrderItem(
      id: json['id'] as int,
      productId: json['productId'] as int,
      productName: (json['productName'] as String?) ?? 'Unknown Product',
      productImageUrl: json['productImageUrl'] as String?,
      quantity: json['quantity'] as int,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
    );
  }
}

// ---------------------------------------------------------------------------
// Customer snapshot embedded in the order
// ---------------------------------------------------------------------------

class SellerOrderCustomer {
  final int id;
  final String phoneNumber;

  const SellerOrderCustomer({required this.id, required this.phoneNumber});

  /// Returns a masked phone number: e.g. "+91 98765 ****"
  String get maskedPhone {
    if (phoneNumber.length < 5) return phoneNumber;
    return '${phoneNumber.substring(0, phoneNumber.length - 4)}****';
  }

  factory SellerOrderCustomer.fromJson(Map<String, dynamic> json) {
    return SellerOrderCustomer(
      id: json['id'] as int,
      phoneNumber: (json['phoneNumber'] as String?) ?? '',
    );
  }
}

// ---------------------------------------------------------------------------
// The order itself (list view — no items)
// ---------------------------------------------------------------------------

class SellerOrderSummary {
  final int id;
  final SellerOrderStatus status;
  final SellerPaymentStatus paymentStatus;
  final double totalPrice;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final SellerOrderCustomer? customer;

  const SellerOrderSummary({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.totalPrice,
    required this.paymentMethod,
    required this.createdAt,
    this.updatedAt,
    this.customer,
  });

  factory SellerOrderSummary.fromJson(Map<String, dynamic> json) {
    // The list endpoint returns { order: {...}, customer: {...} }
    final orderMap = (json['order'] as Map<String, dynamic>?) ?? json;
    final customerMap = json['customer'] as Map<String, dynamic>?;

    return SellerOrderSummary(
      id: orderMap['id'] as int,
      status: SellerOrderStatus.fromString(orderMap['status'] as String?),
      paymentStatus:
          SellerPaymentStatus.fromString(orderMap['paymentStatus'] as String?),
      totalPrice:
          double.tryParse(orderMap['totalPrice']?.toString() ?? '0') ?? 0,
      paymentMethod:
          (orderMap['paymentMethod'] as String?) ?? 'upi',
      createdAt: DateTime.tryParse(orderMap['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(orderMap['updatedAt']?.toString() ?? ''),
      customer:
          customerMap != null ? SellerOrderCustomer.fromJson(customerMap) : null,
    );
  }
}

// ---------------------------------------------------------------------------
// The order with full item details (detail view)
// ---------------------------------------------------------------------------

class SellerOrderDetail extends SellerOrderSummary {
  final List<SellerOrderItem> items;
  final String? transactionRef;
  final String? rejectionReason;

  const SellerOrderDetail({
    required super.id,
    required super.status,
    required super.paymentStatus,
    required super.totalPrice,
    required super.paymentMethod,
    required super.createdAt,
    super.updatedAt,
    super.customer,
    required this.items,
    this.transactionRef,
    this.rejectionReason,
  });

  factory SellerOrderDetail.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];

    return SellerOrderDetail(
      id: json['id'] as int,
      status: SellerOrderStatus.fromString(json['status'] as String?),
      paymentStatus:
          SellerPaymentStatus.fromString(json['paymentStatus'] as String?),
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0,
      paymentMethod: (json['paymentMethod'] as String?) ?? 'upi',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
      customer: json['customer'] != null
          ? SellerOrderCustomer.fromJson(
              json['customer'] as Map<String, dynamic>)
          : null,
      items: rawItems
          .map((e) => SellerOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      transactionRef: json['transactionRef'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }
}

// ---------------------------------------------------------------------------
// Dashboard stats snapshot
// ---------------------------------------------------------------------------

class SellerDashboardStats {
  final int totalOrders;
  final int pendingOrders;
  final int confirmedOrders;
  final double todayRevenue;

  const SellerDashboardStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.confirmedOrders,
    required this.todayRevenue,
  });

  factory SellerDashboardStats.fromJson(Map<String, dynamic> json) {
    return SellerDashboardStats(
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      pendingOrders: (json['pendingOrders'] as num?)?.toInt() ?? 0,
      confirmedOrders: (json['confirmedOrders'] as num?)?.toInt() ?? 0,
      todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ?? 0,
    );
  }

  static SellerDashboardStats get empty => const SellerDashboardStats(
        totalOrders: 0,
        pendingOrders: 0,
        confirmedOrders: 0,
        todayRevenue: 0,
      );
}
