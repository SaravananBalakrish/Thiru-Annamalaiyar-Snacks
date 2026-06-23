class AppException implements Exception {
  final String message;
  final String? prefix;
  final int? statusCode;

  AppException(this.message, [this.prefix, this.statusCode]);

  @override
  String toString() => "${prefix ?? ""}$message";
}

class FetchDataException extends AppException {
  FetchDataException(String message) : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException(String message, [int? statusCode]) : super(message, "Invalid Request: ", statusCode);
}

class UnauthorisedException extends AppException {
  UnauthorisedException(String message) : super(message, "Unauthorised: ");
}

class NotFoundException extends AppException {
  NotFoundException(String message) : super(message, "Not Found: ");
}

class InternalServerErrorException extends AppException {
  InternalServerErrorException(String message) : super(message, "Server Error: ");
}

class NoInternetException extends AppException {
  NoInternetException() : super("No Internet Connection. Please check your network.");
}
