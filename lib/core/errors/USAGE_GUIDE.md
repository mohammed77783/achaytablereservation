# Error Handling Usage Guide

This guide explains how to use the comprehensive error handling system in your Flutter app.

## Architecture Overview

The error handling system follows a clean architecture pattern:

1. **Data Layer**: Throws specific `Exception` types
2. **Repository Layer**: Catches exceptions and converts them to `Failure` types using `Either<Failure, T>`
3. **Presentation Layer**: Handles `Failure` types and shows user-friendly messages

## Key Components

### 1. Exceptions (`lib/core/errors/exceptions.dart`)

- `StorageException`: For local storage errors
- `ParsingException`: For JSON/data parsing errors
- `NetworkException`: For network connectivity issues
- `ServerException`: For API server errors
- `AuthenticationException`: For auth-related errors

### 2. Failures (`lib/core/errors/failures.dart`)

- `StorageFailure`: Converted from `StorageException`
- `ParsingFailure`: Converted from `ParsingException`
- `NetworkFailure`: Converted from `NetworkException`
- And more...

### 3. Error Handler (`lib/core/errors/error_handler.dart`)

- `ErrorHandler.exceptionToFailure()`: Converts exceptions to failures
- `ErrorHandler.getErrorMessage()`: Gets localized error messages
- `ErrorHandler.logError()`: Logs errors for debugging

## Usage Examples

### Data Source Layer

```dart
Future<UserModel?> getUserData() async {
  try {
    final userData = await _storageService.read<String>(_userDataKey);
    if (userData != null) {
      final Map<String, dynamic> userJson = jsonDecode(userData);
      return UserModel.fromJson(userJson);
    }
    return null;
  } on FormatException catch (e) {
    throw ParsingException('Failed to parse user data: ${e.message}');
  } on TypeError catch (e) {
    throw ParsingException('Invalid user data format: $e');
  } catch (e) {
    throw StorageException('Failed to retrieve user data: $e');
  }
}
```

### Repository Layer

```dart
Future<Either<Failure, UserModel?>> userdata() async {
  try {
    final userData = await _homepageDatabaseSources.getUserData();
    return Right(userData);
  } catch (e) {
    final failure = ErrorHandler.exceptionToFailure(e as Exception);
    ErrorHandler.logFailure(
      failure,
      context: 'HomepageRepository.userdata',
      additionalData: {
        'operation': 'getUserData',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    return Left(failure);
  }
}
```

### Controller/Presentation Layer

```dart
Future<void> loadUserData() async {
  try {
    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await _repository.userdata();

    result.fold(
      (failure) {
        // Handle failure case
        _errorMessage.value = ErrorHandler.getErrorMessage(failure);
        _user.value = null;

        // Show user-friendly error message
        Get.snackbar(
          'error'.tr,
          _errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      (userData) {
        // Handle success case
        _user.value = userData;
        _errorMessage.value = '';
      },
    );
  } finally {
    _isLoading.value = false;
  }
}
```

## Error Message Localization

All error messages are localized using GetX translations. The system automatically provides appropriate messages based on the failure type:

### Storage-Specific Messages

- `storage_error`: General storage error
- `user_data_error`: Failed to retrieve user data
- `data_format_error`: Invalid data format
- `user_data_not_found`: User data not found
- `storage_permission_denied`: Storage access denied
- `storage_data_corrupted`: Storage data corrupted

### Network Messages

- `network_connection_error`: Connection issues
- `server_error`: Server-side errors
- `timeout_error`: Request timeouts

### Authentication Messages

- `session_expired`: Session expired
- `invalid_credentials`: Invalid login credentials
- `authentication_required`: Login required

## Best Practices

### 1. Always Use Either in Repositories

```dart
// ✅ Good
Future<Either<Failure, UserModel?>> getUserData() async { ... }

// ❌ Bad
Future<UserModel?> getUserData() async { ... }
```

### 2. Log Errors with Context

```dart
ErrorHandler.logFailure(
  failure,
  context: 'ClassName.methodName',
  additionalData: {
    'userId': userId,
    'operation': 'specific_operation',
  },
);
```

### 3. Handle Both Success and Failure Cases

```dart
result.fold(
  (failure) {
    // Always handle failure case
    final message = ErrorHandler.getErrorMessage(failure);
    // Show error to user
  },
  (data) {
    // Handle success case
    // Update UI with data
  },
);
```

### 4. Use Specific Exception Types

```dart
// ✅ Good - Specific exception
throw StorageException('User data not found in local storage');

// ❌ Bad - Generic exception
throw Exception('Error occurred');
```

### 5. Provide User-Friendly Messages

```dart
// The error handler automatically converts technical errors
// to user-friendly localized messages
final userMessage = ErrorHandler.getErrorMessage(failure);
```

## Testing Error Handling

### Unit Tests

```dart
test('should return StorageFailure when storage throws exception', () async {
  // Arrange
  when(mockDataSource.getUserData())
      .thenThrow(StorageException('Storage error'));

  // Act
  final result = await repository.userdata();

  // Assert
  expect(result, isA<Left<StorageFailure, UserModel?>>());
});
```

### Integration Tests

```dart
testWidgets('should show error message when user data fails to load', (tester) async {
  // Arrange
  when(mockRepository.userdata())
      .thenAnswer((_) async => Left(StorageFailure('Storage error')));

  // Act
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('storage_error'.tr), findsOneWidget);
});
```

## Migration Guide

If you have existing code that doesn't use this error handling system:

### 1. Update Data Sources

- Replace generic `Exception` with specific exception types
- Add proper error context in exception messages

### 2. Update Repositories

- Change return types from `Future<T>` to `Future<Either<Failure, T>>`
- Wrap data source calls in try-catch blocks
- Convert exceptions to failures using `ErrorHandler.exceptionToFailure()`

### 3. Update Controllers/UI

- Handle `Either` return types using `.fold()`
- Use `ErrorHandler.getErrorMessage()` for user-friendly messages
- Remove manual error handling code

### 4. Add Missing Translation Keys

- Add any missing error message keys to translation files
- Test error messages in both supported languages

## Debugging

### Enable Detailed Logging

```dart
// In main.dart or app initialization
Get.isLogEnable = true; // Enable GetX logging
```

### View Error Logs

All errors are logged with:

- Timestamp
- Error context
- Stack trace (for errors)
- Additional data
- Error type and message

### Production Error Reporting

The system is ready for integration with crash reporting services:

```dart
// TODO: Uncomment in production
// if (level == LogLevel.error) {
//   FirebaseCrashlytics.instance.recordError(error, stackTrace);
// }
```
