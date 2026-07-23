import 'package:dio/dio.dart';
import 'package:e_shop_api/e_shop_api.dart' as api;
import 'package:flutter/material.dart';
import '../models/product.dart' as model;
import '../models/address.dart';
import '../constants.dart';
import '../utils/exceptions.dart';
import 'storage_service.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: kBaseUrl,
    connectTimeout: kNetworkTimeout,
    receiveTimeout: kNetworkTimeout,
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
          if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            if (e.response?.statusCode == 401) {
              final data = e.response?.data;
              final code = (data is Map) ? data['code'] as String? : null;

              // TOKEN_EXPIRED — try a silent refresh before giving up
              if (code == 'TOKEN_EXPIRED') {
                final refreshed = await ApiService.tryRefreshToken();
                if (refreshed) {
                  // Retry the original request with the new access token
                  final newToken = await StorageService.getToken();
                  e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                  try {
                    return handler.resolve(await _dio.fetch(e.requestOptions));
                  } catch (retryError) {
                    return handler.reject(retryError is DioException ? retryError : e);
                  }
                }
              }
            }

            // Any 403 or other 401 (revoked, invalid, no refresh token) — force re-login
            await StorageService.clearAllTokens();
            final message = e.response?.statusCode == 403
                ? "User not found"
                : "Session expired. Please login again.";
            _showErrorSnackBar(message);
            navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
            return handler.reject(e);
          }

          int retryCount = e.requestOptions.extra['retryCount'] ?? 0;
          if (_shouldRetry(e) && retryCount < kMaxRetries) {
            retryCount++;
            e.requestOptions.extra['retryCount'] = retryCount;
            await Future.delayed(Duration(seconds: retryCount));
            try {
              return handler.resolve(await _dio.fetch(e.requestOptions));
            } catch (retryError) {
              if (retryError is DioException && retryCount >= kMaxRetries) {
                return _handleFinalError(retryError, handler);
              }
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
    debugPrint("Error: ${appEx.message}");
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
    
    if (e.type == DioExceptionType.connectionError) return NoInternetException();

    if (e.response != null) {
      final data = e.response?.data;
      final message = (data is Map && data.containsKey('message'))
          ? data['message']
          : (data is String && data.isNotEmpty ? data : 'Something went wrong');

      return switch (e.response?.statusCode) {
        400 => BadRequestException(message, 400),
        401 => UnauthorisedException(message),
        404 => NotFoundException(message),
        500 => InternalServerErrorException(message),
        final code => AppException(message, 'Error ($code): ', code),
      };
    }
    return AppException('An unexpected error occurred');
  }

  static void _showErrorSnackBar(String message) {
    final context = navigatorKey.currentContext;
    final colorScheme = context != null ? Theme.of(context).colorScheme : null;
    
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme?.error ?? kRed,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: colorScheme?.onError ?? kWhite,
          onPressed: () => scaffoldMessengerKey.currentState?.hideCurrentSnackBar(),
        ),
      ),
    );
  }

  static final api.EShopApi _api = api.EShopApi(dio: _dio);

  /// Exposes the configured [Dio] instance so specialist services (e.g.
  /// [SellerApiService]) can reuse auth interceptors without duplication.
  static Dio get sharedDio => _dio;

  static Future<bool> requestOtp(String phone) async {
    final response = await _api.getAuthApi().v1AuthRequestOtpPost(
          v1AuthRequestOtpPostRequest: api.V1AuthRequestOtpPostRequest((b) => b..phone = phone),
        );
    return response.statusCode == 200;
  }

  static Future<String?> verifyOtp(String phone, String code, {String? role}) async {
    try {
      final response = await _dio.post(
        '/v1/auth/verify-otp',
        data: {
          'phone': phone,
          'code': code,
          if (role != null) 'role': role,
        },
      );
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        if (data is Map) {
          final accessToken = data['accessToken'] as String?;
          final refreshToken = data['refreshToken'] as String?;
          if (accessToken != null && refreshToken != null) {
            await StorageService.saveRefreshToken(refreshToken);
            return accessToken;
          }
          return data['token'] as String?;
        } else if (data is String) {
          return data;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Silently refresh the access token using the stored refresh token.
  /// Returns true on success (new tokens saved), false if refresh failed.
  static Future<bool> tryRefreshToken() async {
    final refreshToken = await StorageService.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post(
        '/v1/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(extra: {'skipAuthRefresh': true}), // prevent retry loop
      );
      final data = response.data;
      if (data is Map) {
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;
        if (newAccessToken != null && newRefreshToken != null) {
          await StorageService.saveToken(newAccessToken);
          await StorageService.saveRefreshToken(newRefreshToken);
          return true;
        }
      }
    } catch (_) {
      // Refresh failed (expired, revoked) — caller will force re-login
    }
    return false;
  }

  /// Logout: revoke both tokens server-side, then clear local storage.
  static Future<void> logout() async {
    final refreshToken = await StorageService.getRefreshToken();
    try {
      await _dio.post(
        '/v1/auth/logout',
        data: refreshToken != null ? {'refreshToken': refreshToken} : {},
      );
    } catch (_) {
      // Best-effort — always clear local tokens regardless
    }
    await StorageService.clearAllTokens();
  }

  static Future<bool> validateToken() async {
    final response = await _api.getAuthApi().v1AuthValidatePost();
    return response.statusCode == 200 && (response.data?.success ?? false);
  }

  /// Fetches the authenticated user's profile (id, phone, role).
  /// Returns null on any failure — the caller decides what to do next.
  static Future<Map<String, dynamic>?> fetchCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/auth/me');
      return response.data?['data'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
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

  // --- Address API ---
  static Future<List<Address>> fetchAddresses() async {
    try {
      final response = await _api.getAddressesApi().v1AddressesGet();
      if (response.statusCode == 200 && response.data?.data != null) {
        return response.data!.data!
            .map((a) => _mapApiAddressToModel(a))
            .whereType<Address>()
            .toList();
      }
      return [];
    } catch (e, stacktrace) {
      debugPrint('Error fetching addresses: $e');
      debugPrint('Stacktrace: $stacktrace');
      rethrow;
    }
  }

  static Future<Address?> saveAddress(Address address) async {
    final input = _convertToAddressInput(address);
    final response = await _api.getAddressesApi().v1AddressesPost(addressInput: input);
    return _mapApiAddressToModel(response.data?.data);
  }

  static Future<Address?> updateAddress(Address address) async {
    final intId = int.tryParse(address.id);
    if (intId == null) return null;

    final update = _convertToAddressUpdate(address);
    final response = await _api.getAddressesApi().v1AddressesIdPut(
      id: intId,
      addressUpdate: update,
    );
    return _mapApiAddressToModel(response.data?.data);
  }

  static api.AddressInput _convertToAddressInput(Address address) {
    return api.AddressInput((b) => b
      ..fullName = address.fullName
      ..phoneNumber = address.phoneNumber
      ..street = address.street
      ..landmark = address.landmark
      ..city = address.city
      ..state = address.state
      ..zipCode = address.zipCode
      ..country = 'India'
      ..addressType = _mapLabelToInputType(address.label)
      ..isDefault = address.isDefault
      ..latitude = address.latitude
      ..longitude = address.longitude
    );
  }

  static api.AddressUpdate _convertToAddressUpdate(Address address) {
    return api.AddressUpdate((b) => b
      ..fullName = address.fullName
      ..phoneNumber = address.phoneNumber
      ..street = address.street
      ..landmark = address.landmark
      ..city = address.city
      ..state = address.state
      ..zipCode = address.zipCode
      ..country = 'India'
      ..addressType = _mapLabelToUpdateType(address.label)
      ..isDefault = address.isDefault
      ..latitude = address.latitude
      ..longitude = address.longitude
    );
  }

  static api.AddressInputAddressTypeEnum _mapLabelToInputType(String label) {
    final l = label.toLowerCase();
    if (l == 'home') return api.AddressInputAddressTypeEnum.home;
    if (l == 'work' || l == 'office') return api.AddressInputAddressTypeEnum.work;
    if (l == 'billing') return api.AddressInputAddressTypeEnum.billing;
    if (l == 'shipping') return api.AddressInputAddressTypeEnum.shipping;
    return api.AddressInputAddressTypeEnum.other;
  }

  static api.AddressUpdateAddressTypeEnum _mapLabelToUpdateType(String label) {
    final l = label.toLowerCase();
    if (l == 'home') return api.AddressUpdateAddressTypeEnum.home;
    if (l == 'work' || l == 'office') return api.AddressUpdateAddressTypeEnum.work;
    if (l == 'billing') return api.AddressUpdateAddressTypeEnum.billing;
    if (l == 'shipping') return api.AddressUpdateAddressTypeEnum.shipping;
    return api.AddressUpdateAddressTypeEnum.other;
  }

  static Address? _mapApiAddressToModel(api.Address? a) {
    if (a == null) return null;
    return Address(
      id: a.id.toString(),
      label: a.addressType?.name ?? 'Other',
      fullName: a.fullName ?? '',
      phoneNumber: a.phoneNumber ?? '',
      street: a.street ?? '',
      landmark: a.landmark,
      city: a.city ?? '',
      state: a.state ?? '',
      zipCode: a.zipCode ?? '',
      isDefault: a.isDefault ?? false,
      latitude: a.latitude != null ? (a.latitude is String ? double.tryParse(a.latitude as String) : (a.latitude as num).toDouble()) : null,
      longitude: a.longitude != null ? (a.longitude is String ? double.tryParse(a.longitude as String) : (a.longitude as num).toDouble()) : null,
    );
  }

  static Future<void> deleteAddress(String id) async {
    final intId = int.tryParse(id);
    if (intId != null) {
      await _api.getAddressesApi().v1AddressesIdDelete(id: intId);
    }
  }

  static Future<void> setDefaultAddress(String id) async {
    final intId = int.tryParse(id);
    if (intId != null) {
      await _api.getAddressesApi().v1AddressesIdSetDefaultPost(id: intId);
    }
  }

  static Future<api.Order?> placeOrder(String address, String city, String paymentMethod) async {
    final response = await _api.getOrdersApi().v1OrdersPost(
          orderInput: api.OrderInput((b) => b
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
