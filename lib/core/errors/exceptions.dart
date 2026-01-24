/// Custom exception classes for error handling throughout the application.
/// These exceptions are thrown at the data layer and converted to failures at the repository layer.
library;

/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final int? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

/// Exception thrown when a server error occurs
class ServerException extends AppException {
  ServerException(super.message, [super.code]);
}

/// Exception thrown when a network connectivity error occurs
class NetworkException extends AppException {
  NetworkException(super.message, [super.code]);
}

/// Exception thrown when a local storage/cache error occurs
class CacheException extends AppException {
  CacheException(super.message, [super.code]);
}

/// Exception thrown when input validation fails
class ValidationException extends AppException {
  ValidationException(super.message, [super.code]);
}

/// Exception thrown when authentication fails
class AuthenticationException extends AppException {
  AuthenticationException(super.message, [super.code]);
}

/// Exception thrown when authorization fails
class AuthorizationException extends AppException {
  AuthorizationException(super.message, [super.code]);
}

/// Exception thrown when a timeout occurs
class TimeoutException extends AppException {
  TimeoutException(super.message, [super.code]);
}

/// Exception thrown when data parsing fails
class ParsingException extends AppException {
  ParsingException(super.message, [super.code]);
}

/// Exception thrown when navigation fails
class NavigationException extends AppException {
  NavigationException(super.message, [super.code]);
}

/// Exception thrown when storage operations fail
class StorageException extends AppException {
  StorageException(super.message, [super.code]);
}
