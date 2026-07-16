import 'package:flutter_test/flutter_test.dart';
import 'package:thiru_annamalaiyar_snacks/controllers/cart_controller.dart';
import 'package:thiru_annamalaiyar_snacks/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thiru_annamalaiyar_snacks/services/storage_service.dart';

import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return null;
    });
  });

  group('CartController Tests', () {
    late CartController cartController;
    late List<Product> mockProducts;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await StorageService.init();
      mockProducts = [
        Product(id: 1, name: 'Murukku', emoji: '🌀', price: 100, unit: 'pk', category: 'Savoury', desc: '', tags: []),
        Product(id: 2, name: 'Ladoo', emoji: '🥮', price: 50, unit: 'pc', category: 'Sweets', desc: '', tags: []),
      ];
      cartController = CartController();
      // Ensure initial data loading is complete or just start fresh since we mocked storage
      await Future.delayed(Duration.zero);
    });

    test('Initial cart should be empty', () {
      expect(cartController.items.isEmpty, true);
      expect(cartController.totalCount, 0);
    });

    test('Adding item should increase count and total price', () async {
      await cartController.addItem(1);
      expect(cartController.items[1], 1);
      expect(cartController.totalCount, 1);
      expect(cartController.getTotalPrice(mockProducts), 100.0);

      await cartController.addItem(1);
      expect(cartController.items[1], 2);
      expect(cartController.totalCount, 2);
      expect(cartController.getTotalPrice(mockProducts), 200.0);
    });

    test('Removing item should decrease count and total price', () async {
      await cartController.addItem(1);
      await cartController.addItem(1);
      await cartController.removeItem(1);
      
      expect(cartController.items[1], 1);
      expect(cartController.totalCount, 1);
      expect(cartController.getTotalPrice(mockProducts), 100.0);

      await cartController.removeItem(1);
      expect(cartController.items.containsKey(1), false);
      expect(cartController.totalCount, 0);
      expect(cartController.getTotalPrice(mockProducts), 0.0);
    });

    test('Total price should handle multiple products', () async {
      await cartController.addItem(1);
      await cartController.addItem(2);
      
      expect(cartController.totalCount, 2);
      expect(cartController.getTotalPrice(mockProducts), 150.0);
    });

    test('Clear cart should reset everything', () async {
      await cartController.addItem(1);
      await cartController.addItem(2);
      await cartController.clearCart();
      
      expect(cartController.items.isEmpty, true);
      expect(cartController.totalCount, 0);
      expect(cartController.getTotalPrice(mockProducts), 0.0);
    });
  });
}
