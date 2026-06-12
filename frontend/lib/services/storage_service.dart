import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _cartKey = 'cart_items';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<void> saveCart(Map<String, int> cart) async {
    await _storage.write(key: _cartKey, value: jsonEncode(cart));
  }

  static Future<Map<String, int>> getCart() async {
    final data = await _storage.read(key: _cartKey);
    if (data == null) return {};
    return Map<String, int>.from(jsonDecode(data));
  }

  static Future<void> saveOrders(String data) async {
    await _storage.write(key: 'order_history', value: data);
  }

  static Future<String?> getOrders() async {
    return await _storage.read(key: 'order_history');
  }
}
