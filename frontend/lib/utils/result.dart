import 'exceptions.dart';

sealed class Result<T> {
  const Result();

  factory Result.success(T value) = Success<T>;
  factory Result.failure(AppException exception) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
    Success(value: var v) => v,
    Failure() => null,
  };

  AppException? get exceptionOrNull => switch (this) {
    Success() => null,
    Failure(exception: var e) => e,
  };

  R fold<R>(R Function(T value) onSuccess, R Function(AppException exception) onFailure) {
    return switch (this) {
      Success(value: var v) => onSuccess(v),
      Failure(exception: var e) => onFailure(e),
    };
  }
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class Failure<T> extends Result<T> {
  final AppException exception;
  const Failure(this.exception);
}
