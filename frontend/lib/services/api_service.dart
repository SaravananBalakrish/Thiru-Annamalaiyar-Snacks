import 'package:dio/dio.dart';
import 'package:e_shop_api/e_shop_api.dart' as api;
import 'package:flutter/material.dart';
import '../models/product.dart' as model;
import '../constants.dart';
import 'storage_service.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';
  static const int maxRetries = 3;

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ))..interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await StorageService.deleteToken();
            navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
            return handler.reject(e);
          }

          // Centralized Retry Logic
          int retryCount = e.requestOptions.extra['retryCount'] ?? 0;
          if (_shouldRetry(e) && retryCount < maxRetries) {
            retryCount++;
            e.requestOptions.extra['retryCount'] = retryCount;
            
            // Add a slight delay before retrying
            await Future.delayed(Duration(seconds: retryCount));

            try {
              final response = await _dio.fetch(e.requestOptions);
              return handler.resolve(response);
            } catch (retryError) {
              if (retryError is DioException) {
                // If the last retry also fails, handle the error
                if (retryCount >= maxRetries) {
                  _handleError(retryError);
                }
                return handler.reject(retryError);
              }
            }
          }

          _handleError(e);
          return handler.next(e);
        },
      ),
    ]);

  static bool _shouldRetry(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        (e.response != null && e.response!.statusCode! >= 500);
  }

  static void _handleError(DioException e) {
    String message = 'An unexpected error occurred';
    
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timed out. Please check your internet.';
    } else if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        message = data['message'];
      } else {
        message = 'Server Error: ${e.response?.statusCode}';
      }
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'Cannot connect to server. Is the backend running?';
    }

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static final api.EShopApi _api = api.EShopApi(dio: _dio);

  static Future<bool> requestOtp(String phone) async {
    try {
      final response = await _api.getAuthApi().v1AuthRequestOtpPost(
            v1AuthRequestOtpPostRequest: api.V1AuthRequestOtpPostRequest((b) => b..phone = phone),
          );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> verifyOtp(String phone, String code) async {
    try {
      final response = await _api.getAuthApi().v1AuthVerifyOtpPost(
            v1AuthVerifyOtpPostRequest: api.V1AuthVerifyOtpPostRequest((b) => b
              ..phone = phone
              ..code = code),
          );
      if (response.statusCode == 200) {
        // Since the generated code says Response<void>, we cast to dynamic to access data.
        final dynamic data = (response as Response).data;
        if (data is Map) {
          final token = data['token'];
          if (token is String) return token;
        } else if (data is String) {
          return data;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<model.Product>> fetchProducts() async {
    try {
      final productsResponse = await _api.getProductsApi().v1ProductsGet();
      final categoriesResponse = await _api.getCategoriesApi().v1CategoriesGet();

      final Map<int, String> categoriesMap = {};
      if (categoriesResponse.data != null) {
        for (var c in categoriesResponse.data!) {
          final id = c.id;
          final name = c.name;
          if (id != null && name != null) {
            categoriesMap[id] = name;
          }
        }
      }

      if (productsResponse.statusCode == 200 && productsResponse.data != null) {
        return productsResponse.data!.map((p) {
          final catId = p.categoryId;
          final catName = catId != null ? categoriesMap[catId] : null;
          return model.Product(
            id: p.id ?? 0,
            name: p.name ?? '',
            emoji: _getEmojiForCategory(catName),
            price: double.tryParse(p.price ?? '0') ?? 0.0,
            unit: 'pcs',
            category: catName ?? 'General',
            desc: p.description ?? '',
            tags: [],
            image: p.imageUrl,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<int, int>> fetchCart() async {
    try {
      final response = await _api.getCartApi().v1CartGet();
      if (response.statusCode == 200 && response.data != null) {
        return {
          for (var item in response.data!)
            if (item.product?.id != null && item.quantity != null) item.product!.id!: item.quantity!
        };
      }
    } catch (e) {
      // Ignore if not logged in
    }
    return {};
  }

  static Future<void> addToCart(int productId, int quantity) async {
    try {
      await _api.getCartApi().v1CartPost(
            cartAdd: api.CartAdd((b) => b
              ..productId = productId
              ..quantity = quantity),
          );
    } catch (e) {
      // Log or handle error
    }
  }

  static Future<void> updateCartItem(int productId, int quantity) async {
    try {
      final cart = await _api.getCartApi().v1CartGet();
      final item = cart.data?.firstWhere((i) => i.product?.id == productId);
      if (item != null && item.id != null) {
        await _api.getCartApi().v1CartIdPatch(
              id: item.id!,
              cartPatch: api.CartPatch((b) => b..quantity = quantity),
            );
      }
    } catch (e) {
      // Handle error
    }
  }

  static Future<void> removeFromCart(int productId) async {
    try {
      final cart = await _api.getCartApi().v1CartGet();
      final item = cart.data?.firstWhere((i) => i.product?.id == productId);
      if (item != null && item.id != null) {
        await _api.getCartApi().v1CartIdDelete(id: item.id!);
      }
    } catch (e) {
      // Handle error
    }
  }

  static Future<List<api.Order>> fetchOrders() async {
    try {
      final response = await _api.getOrdersApi().v1OrdersGet();
      if (response.statusCode == 200 && response.data != null) {
        return response.data!.toList();
      }
    } catch (e) {
      // Handle error
    }
    return [];
  }

  static Future<api.Order?> placeOrder(String address, String city, String paymentMethod) async {
    try {
      final response = await _api.getOrdersApi().v1OrdersPost(
            orderInput: api.OrderInput((b) => b
              ..userId = 1 // Default or fetch from profile
              ..paymentMethod = paymentMethod),
          );
      return response.data;
    } catch (e) {
      return null;
    }
  }

  static String _getEmojiForCategory(String? categoryName) {
    switch (categoryName?.toLowerCase()) {
      case 'savoury':
        return '🌀';
      case 'sweets':
        return '🥮';
      case 'bakery':
        return '🍪';
      default:
        return '🥨';
    }
  }
}
