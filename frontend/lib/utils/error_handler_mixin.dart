import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'exceptions.dart';
import 'result.dart';

mixin ErrorHandlerMixin on ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Executes an async [call], handling loading state and mapping errors automatically.
  Future<Result<T>> runSafeResult<T>(Future<T> Function() call) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await call();
      return Result.success(result);
    } catch (e) {
      final appEx = _mapToAppException(e);
      _error = appEx.message;
      return Result.failure(appEx);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  AppException _mapToAppException(Object e) {
    if (e is DioException && e.error is AppException) {
      return e.error as AppException;
    } else if (e is AppException) {
      return e;
    } else {
      return AppException(e.toString());
    }
  }

  /// Original runSafe for backward compatibility or when Result is not needed.
  Future<T?> runSafe<T>(Future<T> Function() call) async {
    final result = await runSafeResult(call);
    return result.valueOrNull;
  }
}
