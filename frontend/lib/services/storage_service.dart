import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart' as model;

class StorageService {
  static const _storage = FlutterSecureStorage();
  static late SharedPreferences _prefs;
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _cartKey = 'cart_items';
  static const _addressesKey = 'saved_addresses';
  static const _selectedAddressIdKey = 'selected_address_id';
  static const _roleKey = 'user_role';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Refresh token — stored securely, valid for 30 days
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Clears both tokens — call this on logout or when refresh token is invalid.
  static Future<void> clearAllTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _prefs.remove(_roleKey); // always clear role on session end
  }

  // --- Role ---

  /// Persists the user's role (e.g. 'customer', 'admin') from the /me endpoint.
  static Future<void> saveRole(String role) async {
    await _prefs.setString(_roleKey, role);
  }

  /// Returns the cached role, or null if not yet fetched.
  static String? getRole() => _prefs.getString(_roleKey);

  /// Removes the cached role (called during logout via [clearAllTokens]).
  static Future<void> clearRole() async {
    await _prefs.remove(_roleKey);
  }

  // --- Product Caching ---
  static const String _productsKey = 'cached_products';

  static Future<void> saveProducts(List<model.Product> products) async {
    final String jsonString = jsonEncode(products.map((p) => p.toJson()).toList());
    await _prefs.setString(_productsKey, jsonString);
  }

  static List<model.Product> getProducts() {
    final String? jsonString = _prefs.getString(_productsKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((item) => model.Product.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
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

  // --- Address Storage ---
  static Future<void> saveAddresses(List<String> addresses) async {
    await _storage.write(key: _addressesKey, value: jsonEncode(addresses));
  }

  static Future<List<String>> getAddresses() async {
    final data = await _storage.read(key: _addressesKey);
    if (data == null) return [];
    return List<String>.from(jsonDecode(data));
  }

  // --- Selected Address ---
  static Future<void> saveSelectedAddressId(String id) async {
    await _storage.write(key: _selectedAddressIdKey, value: id);
  }

  static Future<String?> getSelectedAddressId() async {
    return await _storage.read(key: _selectedAddressIdKey);
  }

  static Future<void> clearSelectedAddressId() async {
    await _storage.delete(key: _selectedAddressIdKey);
  }
}
