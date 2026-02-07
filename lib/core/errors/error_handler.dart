import 'package:get/get.dart';
import 'failures.dart';
import 'exceptions.dart';

/// Log levels for different types of messages
enum LogLevel { debug, info, warning, error }

/// Error handler utility for converting failures to user-friendly messages
/// and logging errors for debugging purposes
class ErrorHandler {
  /// Converts a Failure to a localized user-friendly error message
  /// Uses GetX translations to provide messages in the user's selected language
  static String getErrorMessage(Failure failure) {
    if (failure is ServerFailure) {
      return _getServerErrorMessage(failure);
    } else if (failure is NetworkFailure) {
      return _getNetworkErrorMessage(failure);
    } else if (failure is CacheFailure) {
      return _getCacheErrorMessage(failure);
    } else if (failure is StorageFailure) {
      return _getStorageErrorMessage(failure);
    } else if (failure is ValidationFailure) {
      return _getValidationErrorMessage(failure);
    } else if (failure is AuthenticationFailure) {
      return _getAuthenticationErrorMessage(failure);
    } else if (failure is AuthorizationFailure) {
      return _getAuthorizationErrorMessage(failure);
    } else if (failure is TimeoutFailure) {
      return _getTimeoutErrorMessage(failure);
    } else if (failure is ParsingFailure) {
      return _getParsingErrorMessage(failure);
    } else if (failure is UnknownFailure) {
      return _getUnknownErrorMessage(failure);
    }

    // Default fallback message
    return 'error_occurred'.tr;
  }

  /// Gets a specific server error message based on the error code
  static String _getServerErrorMessage(ServerFailure failure) {
    if (failure.code != null) {
      switch (failure.code) {
        case 400:
          return 'validation_error'.tr;
        case 401:
          return 'invalid_credentials'.tr;
        case 403:
          return 'authorization_error'.tr;
        case 404:
          return 'resource_not_found'.tr;
        case 408:
          return 'timeout_error'.tr;
        case 429:
          return 'Too many requests. Please try again later';
        case 500:
        case 502:
        case 503:
          return 'server_error'.tr;
        case 504:
          return 'connection_timeout'.tr;
        default:
          return failure.message.isNotEmpty
              ? failure.message
              : 'server_error'.tr;
      }
    }
    return failure.message.isNotEmpty ? failure.message : 'server_error'.tr;
  }

  /// Gets a network error message with specific handling for different network issues
  static String _getNetworkErrorMessage(NetworkFailure failure) {
    final message = failure.message.toLowerCase();

    if (message.contains('timeout') || message.contains('timed out')) {
      return 'connection_timeout'.tr;
    } else if (message.contains('dns') || message.contains('host lookup')) {
      return 'dns_resolution_error'.tr;
    } else if (message.contains('connection refused') ||
        message.contains('connection failed')) {
      return 'server_unavailable'.tr;
    } else if (message.contains('no internet') ||
        message.contains('network unreachable')) {
      return 'no_internet'.tr;
    }

    return failure.message.isNotEmpty
        ? failure.message
        : 'network_connection_error'.tr;
  }

  /// Gets a cache error message with specific handling for storage issues
  static String _getCacheErrorMessage(CacheFailure failure) {
    final message = failure.message.toLowerCase();

    if (message.contains('storage full') || message.contains('no space')) {
      return 'storage_full_error'.tr;
    } else if (message.contains('permission') ||
        message.contains('access denied')) {
      return 'permission_denied'.tr;
    } else if (message.contains('corruption') ||
        message.contains('corrupted')) {
      return 'data_corruption_error'.tr;
    }

    return failure.message.isNotEmpty ? failure.message : 'cache_error'.tr;
  }

  /// Gets a storage error message with specific handling for local storage issues
  static String _getStorageErrorMessage(StorageFailure failure) {
    final message = failure.message.toLowerCase();

    if (message.contains('user data') || message.contains('profile')) {
      return 'user_data_error'.tr;
    } else if (message.contains('json') || message.contains('parsing')) {
      return 'data_format_error'.tr;
    } else if (message.contains('not found') || message.contains('missing')) {
      return 'user_data_not_found'.tr;
    } else if (message.contains('permission') ||
        message.contains('access denied')) {
      return 'storage_permission_denied'.tr;
    } else if (message.contains('corruption') ||
        message.contains('corrupted')) {
      return 'storage_data_corrupted'.tr;
    }

    return failure.message.isNotEmpty ? failure.message : 'storage_error'.tr;
  }

  /// Gets a validation error message with field-specific handling
  static String _getValidationErrorMessage(ValidationFailure failure) {
    final message = failure.message.toLowerCase();
    if (message.contains('phone')) {
      if (message.contains("already")) {
        return "invalid_phone_alreadesit".tr;
      } else if (message.contains('number or password')) {
      return  "validation_passwords_or_phon_not_match".tr;
      } else {
        return 'invalid_phone_format'.tr;
      }
    } else if (message.contains('password')) {
      if (message.contains('weak') || message.contains('strength')) {
        return 'weak_password'.tr;
      } else if (message.contains('match') || message.contains('confirm')) {
        return 'password_confirmation_mismatch'.tr;
      }
      return 'invalid_password'.tr;
    } else if (message.contains('otp') || message.contains('code')) {
      return 'invalid_otp_format'.tr;
    } else if (message.contains('email')) {
      return 'invalid_email'.tr;
    } else if (message.contains('required')) {
      return 'required_field'.tr;
    }

    return failure.message.isNotEmpty ? failure.message : 'validation_error'.tr;
  }

  /// Gets an authentication error message with specific handling
  static String _getAuthenticationErrorMessage(AuthenticationFailure failure) {
    final message = failure.message.toLowerCase();

    if (message.contains('token') && message.contains('expired')) {
      return 'session_expired'.tr;
    } else if (message.contains('token') && message.contains('invalid')) {
      return 'authentication_required'.tr;
    } else if (message.contains('otp')) {
      if (message.contains('expired')) {
        return 'otp_expired'.tr;
      } else if (message.contains('invalid')) {
        return 'invalid_otp'.tr;
      }
    } else if (message.contains('credentials')) {
      return 'invalid_credentials'.tr;
    }

    return failure.message.isNotEmpty
        ? failure.message
        : 'invalid_credentials'.tr;
  }

  /// Gets an authorization error message
  static String _getAuthorizationErrorMessage(AuthorizationFailure failure) {
    return failure.message.isNotEmpty
        ? failure.message
        : 'authorization_error'.tr;
  }

  /// Gets a timeout error message with specific handling
  static String _getTimeoutErrorMessage(TimeoutFailure failure) {
    final message = failure.message.toLowerCase();

    if (message.contains('connection')) {
      return 'connection_timeout'.tr;
    }

    return failure.message.isNotEmpty ? failure.message : 'timeout_error'.tr;
  }

  /// Gets a parsing error message with specific handling
  static String _getParsingErrorMessage(ParsingFailure failure) {
    final message = failure.message.toLowerCase();

    if (message.contains('malformed') || message.contains('invalid format')) {
      return 'malformed_response'.tr;
    }

    return failure.message.isNotEmpty ? failure.message : 'parsing_error'.tr;
  }

  /// Gets an unknown error message with fallback handling
  static String _getUnknownErrorMessage(UnknownFailure failure) {
    return failure.message.isNotEmpty
        ? failure.message
        : 'something_went_wrong'.tr;
  }

  /// Maps API validation errors to form field errors
  /// Returns a map of field names to error messages
  static Map<String, String> mapValidationErrors(
    List<String> errors,
    String context,
  ) {
    final Map<String, String> fieldErrors = {};

    for (final error in errors) {
      final lowerError = error.toLowerCase();
      // Common field mappings
      if (lowerError.contains('first name') ||
          lowerError.contains('firstname')) {
        fieldErrors['firstName'] = error;
      } else if (lowerError.contains('last name') ||
          lowerError.contains('lastname')) {
        fieldErrors['lastName'] = error;
      } else if (lowerError.contains('phone') ||
          lowerError.contains('mobile')) {
        fieldErrors['phoneNumber'] = error;
      } else if (lowerError.contains('email')) {
        fieldErrors['email'] = error;
      } else if (lowerError.contains('password')) {
        if (lowerError.contains('confirm') || lowerError.contains('match')) {
          fieldErrors['confirmPassword'] = error;
        } else {
          fieldErrors['password'] = error;
        }
      } else if (lowerError.contains('otp') || lowerError.contains('code')) {
        fieldErrors['otpCode'] = error;
      }

      // Context-specific mappings
      switch (context) {
        case 'registration':
          _mapRegistrationSpecificErrors(lowerError, error, fieldErrors);
          break;
        case 'login':
          _mapLoginSpecificErrors(lowerError, error, fieldErrors);
          break;
        case 'password_reset':
          _mapPasswordResetSpecificErrors(lowerError, error, fieldErrors);
          break;
      }
    }
    return fieldErrors;
  }

  /// Maps registration-specific validation errors
  static void _mapRegistrationSpecificErrors(
    String lowerError,
    String error,
    Map<String, String> fieldErrors,
  ) {
    if (lowerError.contains('username') &&
        !fieldErrors.containsKey('phoneNumber')) {
      fieldErrors['phoneNumber'] = error;
    }
  }

  /// Maps login-specific validation errors
  static void _mapLoginSpecificErrors(
    String lowerError,
    String error,
    Map<String, String> fieldErrors,
  ) {
    if (lowerError.contains('username') &&
        !fieldErrors.containsKey('phoneNumber')) {
      fieldErrors['phoneNumber'] = error;
    }
  }

  /// Maps password reset-specific validation errors
  static void _mapPasswordResetSpecificErrors(
    String lowerError,
    String error,
    Map<String, String> fieldErrors,
  ) {
    if (lowerError.contains('new password') &&
        !fieldErrors.containsKey('password')) {
      fieldErrors['newPassword'] = error;
    }
  }

  /// Handles malformed API responses gracefully
  /// Returns a user-friendly error message for parsing failures
  static String handleMalformedResponse(dynamic response, String context) {
    logError(
      'Malformed API response in $context',
      StackTrace.current,
      context: context,
      additionalData: {'response': response?.toString()},
    );

    return 'malformed_response'.tr;
  }

  /// Handles storage operation failures gracefully
  /// Returns appropriate error message based on storage error type
  static String handleStorageError(dynamic error, String operation) {
    final errorMessage = error.toString().toLowerCase();

    if (errorMessage.contains('permission') ||
        errorMessage.contains('access')) {
      return 'permission_denied'.tr;
    } else if (errorMessage.contains('space') ||
        errorMessage.contains('full')) {
      return 'storage_full_error'.tr;
    } else if (errorMessage.contains('corruption')) {
      return 'data_corruption_error'.tr;
    }

    logError(
      'Storage operation failed: $operation',
      StackTrace.current,
      context: operation,
      additionalData: {'error': error.toString()},
    );

    return 'storage_operation_failed'.tr;
  }

  /// Logs an error for debugging purposes with enhanced context
  /// In production, this could be integrated with crash reporting services
  /// like Firebase Crashlytics, Sentry, etc.
  static void logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
    LogLevel level = LogLevel.error,
  }) {
    // Always log to console in debug mode using Get.log
    if (Get.isLogEnable) {
      final buffer = StringBuffer();
      buffer.writeln(
        '═══════════════════════════════════════════════════════════',
      );
      buffer.writeln(
        '${level.name.toUpperCase()} LOG - ${DateTime.now().toIso8601String()}',
      );
      if (context != null) {
        buffer.writeln('Context: $context');
      }
      buffer.writeln('Error: $error');
      if (stackTrace != null && level == LogLevel.error) {
        buffer.writeln('Stack Trace:\n$stackTrace');
      }
      if (additionalData != null && additionalData.isNotEmpty) {
        buffer.writeln('Additional Data:');
        additionalData.forEach((key, value) {
          buffer.writeln('  $key: $value');
        });
      }
      buffer.writeln(
        '═══════════════════════════════════════════════════════════',
      );

      // Use Get.log instead of print to avoid linting issues
      Get.log(buffer.toString());
    }

    // TODO: In production, send to crash reporting service based on level
    // Example:
    // if (level == LogLevel.error) {
    //   FirebaseCrashlytics.instance.recordError(error, stackTrace);
    // } else if (level == LogLevel.warning) {
    //   FirebaseCrashlytics.instance.log('Warning: $error');
    // }
  }

  /// Log info level messages for debugging and monitoring
  static void logInfo(
    String message, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    logError(
      message,
      null,
      context: context,
      additionalData: additionalData,
      level: LogLevel.info,
    );
  }

  /// Log warning level messages for potential issues
  static void logWarning(
    String message, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    logError(
      message,
      StackTrace.current,
      context: context,
      additionalData: additionalData,
      level: LogLevel.warning,
    );
  }

  /// Log debug level messages for detailed debugging
  static void logDebug(
    String message, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    logError(
      message,
      null,
      context: context,
      additionalData: additionalData,
      level: LogLevel.debug,
    );
  }

  /// Logs a Failure with additional context
  static void logFailure(
    Failure failure, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final errorData = {
      'failure_type': failure.runtimeType.toString(),
      'message': failure.message,
      'code': failure.code,
      ...?additionalData,
    };

    logError(
      failure,
      StackTrace.current,
      context: context,
      additionalData: errorData,
    );
  }

  /// Logs an Exception with additional context
  static void logException(
    Exception exception, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final errorData = {
      'exception_type': exception.runtimeType.toString(),
      if (exception is AppException) ...{
        'message': exception.message,
        'code': exception.code,
      },
      ...?additionalData,
    };

    logError(
      exception,
      stackTrace ?? StackTrace.current,
      context: context,
      additionalData: errorData,
    );
  }

  /// Converts an Exception to a Failure
  /// This is typically used in repositories to convert data layer exceptions
  /// to domain layer failures
  static Failure exceptionToFailure(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(exception.message, exception.code);
    } else if (exception is NetworkException) {
      return NetworkFailure(exception.message, exception.code);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message, exception.code);
    } else if (exception is StorageException) {
      return StorageFailure(exception.message, exception.code);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message, exception.code);
    } else if (exception is AuthenticationException) {
      return AuthenticationFailure(exception.message, exception.code);
    } else if (exception is AuthorizationException) {
      return AuthorizationFailure(exception.message, exception.code);
    } else if (exception is TimeoutException) {
      return TimeoutFailure(exception.message, exception.code);
    } else if (exception is ParsingException) {
      return ParsingFailure(exception.message, exception.code);
    }
    // Unknown exception
    return UnknownFailure(exception.toString());
  }
}
