import 'package:test/test.dart';
import 'package:e_shop_api/e_shop_api.dart';

// tests for Order
void main() {
  final instance = OrderBuilder();
  // TODO add properties to the builder and call build()

  group(Order, () {
    // int id
    test('to test the property `id`', () async {
      // TODO
    });

    // int userId
    test('to test the property `userId`', () async {
      // TODO
    });

    // Decimal total price (e.g. \"49.95\")
    // String totalPrice
    test('to test the property `totalPrice`', () async {
      // TODO
    });

    // DateTime createdAt
    test('to test the property `createdAt`', () async {
      // TODO
    });

    // e.g. \"gpay\", \"phonepe\", \"upi\"
    // String paymentMethod
    test('to test the property `paymentMethod`', () async {
      // TODO
    });

    // e.g. \"pending\", \"paid\"
    // String paymentStatus
    test('to test the property `paymentStatus`', () async {
      // TODO
    });

    // UPI transaction reference / UTR number
    // String transactionRef
    test('to test the property `transactionRef`', () async {
      // TODO
    });

    // UPI deep link for GPay/PhonePe
    // String upiUri
    test('to test the property `upiUri`', () async {
      // TODO
    });

    // URL to the scan-and-pay QR code
    // String qrCodeUrl
    test('to test the property `qrCodeUrl`', () async {
      // TODO
    });

    // BuiltList<OrderItem> items
    test('to test the property `items`', () async {
      // TODO
    });

  });
}
