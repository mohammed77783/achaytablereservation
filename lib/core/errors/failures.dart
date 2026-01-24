/// Failure classes for error handling.
/// Failures represent errors that have been handled and converted from exceptions.
library;

/// Base failure class
abstract class Failure {
  final String message;
  final int? code;

  const Failure(this.message, [this.code]);

  @override
  String toString() => message;
}

/// Failure for server-side errors
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

/// Failure for network connectivity errors
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

/// Failure for local storage/cache errors
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}

/// Failure for input validation errors
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.code]);
}

/// Failure for authentication errors
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, [super.code]);
}

/// Failure for authorization errors
class AuthorizationFailure extends Failure {
  const AuthorizationFailure(super.message, [super.code]);
}

/// Failure for timeout errors
class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message, [super.code]);
}

/// Failure for data parsing errors
class ParsingFailure extends Failure {
  const ParsingFailure(super.message, [super.code]);
}

/// Failure for unknown/unexpected errors
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, [super.code]);
}

/// Failure for storage operation errors
class StorageFailure extends Failure {
  const StorageFailure(super.message, [super.code]);
}
