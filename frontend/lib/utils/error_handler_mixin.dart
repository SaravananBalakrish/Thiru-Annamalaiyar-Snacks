import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'exceptions.dart';

mixin ErrorHandlerMixin on ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Executes an async [call], handling loading state and mapping errors automatically.
  Future<T?> runSafe<T>(Future<T> Function() call) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await call();
      return result;
    } catch (e) {
      if (e is DioException && e.error is AppException) {
        _error = (e.error as AppException).message;
      } else if (e is AppException) {
        _error = e.message;
      } else {
        _error = e.toString();
      }
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
