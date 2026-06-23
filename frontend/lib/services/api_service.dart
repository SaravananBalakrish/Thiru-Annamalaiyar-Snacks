import 'package:dio/dio.dart';
import 'package:e_shop_api/e_shop_api.dart' as api;
import 'package:flutter/material.dart';
import '../models/product.dart' as model;
import '../constants.dart';
import '../utils/exceptions.dart';
import 'storage_service.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.167:3000';
  static const int maxRetries = 3;

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
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
          // 1. Handle Unauthorised globally
          if (e.response?.statusCode == 401) {
            await StorageService.deleteToken();
            navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
            return handler.reject(e);
          }

          // 2. Centralized Retry Logic
          int retryCount = e.requestOptions.extra['retryCount'] ?? 0;
          if (_shouldRetry(e) && retryCount < maxRetries) {
            retryCount++;
            e.requestOptions.extra['retryCount'] = retryCount;
            await Future.delayed(Duration(seconds: retryCount));
            try {
              final response = await _dio.fetch(e.requestOptions);
              return handler.resolve(response);
            } catch (retryError) {
              if (retryError is DioException && retryCount >= maxRetries) {
                return _handleFinalError(retryError, handler);
              }
              // If it's not the last retry, we might want to continue retrying
              // but Dio Interceptors are a bit tricky with nested retries here.
              // For simplicity, we just reject if the immediate retry fails.
              return handler.reject(retryError is DioException ? retryError : e);
            }
          }

          return _handleFinalError(e, handler);
        },
      ),
    ]);

  static Future<void> _handleFinalError(DioException e, ErrorInterceptorHandler handler) async {
    final appEx = _mapException(e);
    _showErrorSnackBar(appEx.message);
    
    // Reject with the original exception but with our mapped AppException as the error
    return handler.reject(DioException(
      requestOptions: e.requestOptions,
      error: appEx,
      type: e.type,
      response: e.response,
    ));
  }

  static bool _shouldRetry(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        (e.response != null && e.response!.statusCode! >= 500);
  }

  static AppException _mapException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout) {
      return FetchDataException('Connection timed out. Please check your internet.');
    }
    
    if (e.type == DioExceptionType.connectionError) {
      return NoInternetException();
    }

    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      String message = 'Something went wrong';
      
      if (data is Map && data.containsKey('message')) {
        message = data['message'];
      } else if (data is String && data.isNotEmpty) {
        message = data;
      }

      switch (statusCode) {
        case 400: return BadRequestException(message, statusCode);
        case 401: return UnauthorisedException(message);
        case 404: return NotFoundException(message);
        case 500: return InternalServerErrorException(message);
        default: return AppException(message, 'Error ($statusCode): ', statusCode);
      }
    }
    return AppException('An unexpected error occurred');
  }

  static void _showErrorSnackBar(String message) {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: kRed,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () => scaffoldMessengerKey.currentState?.hideCurrentSnackBar(),
        ),
      ),
    );
  }

  static final api.EShopApi _api = api.EShopApi(dio: _dio);

  static Future<bool> requestOtp(String phone) async {
    final response = await _api.getAuthApi().v1AuthRequestOtpPost(
          v1AuthRequestOtpPostRequest: api.V1AuthRequestOtpPostRequest((b) => b..phone = phone),
        );
    return response.statusCode == 200;
  }

  static Future<String?> verifyOtp(String phone, String code) async {
    final response = await _api.getAuthApi().v1AuthVerifyOtpPost(
          v1AuthVerifyOtpPostRequest: api.V1AuthVerifyOtpPostRequest((b) => b
            ..phone = phone
            ..code = code),
        );
    if (response.statusCode == 200) {
      final dynamic data = (response as Response).data;
      if (data is Map) {
        return data['token'] as String?;
      } else if (data is String) {
        return data;
      }
    }
    return null;
  }

  static Future<List<model.Product>> fetchProducts() async {
    final productsResponse = await _api.getProductsApi().v1ProductsGet();
    final categoriesResponse = await _api.getCategoriesApi().v1CategoriesGet();

    final Map<int, String> categoriesMap = {};
    if (categoriesResponse.data != null) {
      for (var c in categoriesResponse.data!) {
        if (c.id != null && c.name != null) categoriesMap[c.id!] = c.name!;
      }
    }

    if (productsResponse.statusCode == 200 && productsResponse.data != null) {
      return productsResponse.data!.map((p) {
        final catName = p.categoryId != null ? categoriesMap[p.categoryId] : null;
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
  }

  static Future<List<String>> fetchCategoryNames() async {
    final response = await _api.getCategoriesApi().v1CategoriesGet();
    if (response.statusCode == 200 && response.data != null) {
      return response.data!.map((c) => c.name ?? '').where((n) => n.isNotEmpty).toList();
    }
    return [];
  }

  static Future<Map<int, int>> fetchCart() async {
    final response = await _api.getCartApi().v1CartGet();
    if (response.statusCode == 200 && response.data != null) {
      return {
        for (var item in response.data!)
          if (item.product?.id != null && item.quantity != null) item.product!.id!: item.quantity!
      };
    }
    return {};
  }

  static Future<void> addToCart(int productId, int quantity) async {
    await _api.getCartApi().v1CartPost(
          cartAdd: api.CartAdd((b) => b
            ..productId = productId
            ..quantity = quantity),
        );
  }

  static Future<void> updateCartItem(int productId, int quantity) async {
    final response = await _api.getCartApi().v1CartGet();
    final items = response.data;
    if (items == null) throw NotFoundException('Cart is empty');

    final item = items.firstWhere(
      (i) => i.product?.id == productId,
      orElse: () => throw NotFoundException('Item not in cart'),
    );

    if (item.id != null) {
      await _api.getCartApi().v1CartIdPatch(
        id: item.id!,
        cartPatch: api.CartPatch((b) => b..quantity = quantity),
      );
    }
  }

  static Future<void> removeFromCart(int productId) async {
    final response = await _api.getCartApi().v1CartGet();
    final items = response.data;
    if (items == null) throw NotFoundException('Cart is empty');

    final item = items.firstWhere(
      (i) => i.product?.id == productId,
      orElse: () => throw NotFoundException('Item not in cart'),
    );

    if (item.id != null) {
      await _api.getCartApi().v1CartIdDelete(id: item.id!);
    }
  }

  static Future<List<api.Order>> fetchOrders() async {
    final response = await _api.getOrdersApi().v1OrdersGet();
    if (response.statusCode == 200 && response.data != null) {
      return response.data!.toList();
    }
    return [];
  }

  static Future<api.Order?> placeOrder(String address, String city, String paymentMethod) async {
    final response = await _api.getOrdersApi().v1OrdersPost(
          orderInput: api.OrderInput((b) => b
            ..userId = 1 
            ..paymentMethod = paymentMethod),
        );
    return response.data;
  }

  static String _getEmojiForCategory(String? categoryName) {
    switch (categoryName?.toLowerCase()) {
      case 'savoury': return '🌀';
      case 'sweets': return '🥮';
      case 'bakery': return '🍪';
      default: return '🥨';
    }
  }
}
