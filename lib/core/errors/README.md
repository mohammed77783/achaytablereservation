# Error Handling System

This directory contains the error handling system for the application, following clean architecture principles.

## Components

### 1. Exceptions (`exceptions.dart`)

Custom exception classes thrown at the data layer:

- `ServerException` - API/server errors
- `NetworkException` - Network connectivity errors
- `CacheException` - Local storage errors
- `ValidationException` - Input validation errors
- `AuthenticationException` - Authentication failures
- `AuthorizationException` - Authorization failures
- `TimeoutException` - Request timeout errors
- `ParsingException` - Data parsing errors

### 2. Failures (`failures.dart`)

Failure classes used at the domain and presentation layers:

- `ServerFailure` - Converted from ServerException
- `NetworkFailure` - Converted from NetworkException
- `CacheFailure` - Converted from CacheException
- `ValidationFailure` - Converted from ValidationException
- `AuthenticationFailure` - Converted from AuthenticationException
- `AuthorizationFailure` - Converted from AuthorizationException
- `TimeoutFailure` - Converted from TimeoutException
- `ParsingFailure` - Converted from ParsingException
- `UnknownFailure` - For unexpected errors

### 3. Error Handler (`error_handler.dart`)

Utility class for error handling:

- `getErrorMessage(Failure)` - Converts failures to localized user messages
- `logError()` - Logs errors for debugging
- `logFailure()` - Logs failures with context
- `logException()` - Logs exceptions with context
- `exceptionToFailure()` - Converts exceptions to failures

## Usage

### In Data Layer (Repositories)

```dart
class ExampleRepositoryImpl extends BaseRepository {
  Future<Either<Failure, Data>> getData() async {
    return handleApiCall(() async {
      // API call that might throw exceptions
      final response = await apiClient.get('/data');
      if (response.statusCode != 200) {
        throw ServerException('Failed to fetch data', response.statusCode);
      }
      return Data.fromJson(response.data);
    });
  }
}
```

### In Presentation Layer (Controllers)

```dart
class ExampleController extends BaseController {
  Future<void> loadData() async {
    showLoading();

    final result = await useCase.call();

    result.fold(
      (failure) => showErrorFromFailure(failure),
      (data) {
        hideLoading();
        // Handle success
      },
    );
  }
}
```

### Manual Error Handling

```dart
try {
  // Some operation
} catch (e, stackTrace) {
  ErrorHandler.logError(e, stackTrace, context: 'Operation Name');
}
```

## Error Flow

```
Data Source → Exception → Repository → Failure → Controller → User Message
```

1. **Data Source**: Throws specific exceptions (e.g., `ServerException`)
2. **Repository**: Catches exceptions and converts to failures using `BaseRepository.handleApiCall()`
3. **Controller**: Receives failures and converts to user messages using `ErrorHandler.getErrorMessage()`
4. **UI**: Displays localized error messages to the user

## Localization

All error messages support localization through GetX translations. Error keys are defined in:

- `lib/app/translations/en_US.dart`
- `lib/app/translations/ar_SA.dart`

Common error message keys:

- `network_error` - Network connectivity issues
- `server_error` - Server-side errors
- `timeout_error` - Request timeouts
- `validation_error` - Input validation failures
- `authorization_error` - Permission denied
- `cache_error` - Local storage errors
- `parsing_error` - Data parsing failures

## Best Practices

1. **Always use specific exceptions** in the data layer
2. **Never expose exceptions** to the presentation layer
3. **Always convert exceptions to failures** in repositories
4. **Use ErrorHandler.getErrorMessage()** for user-facing messages
5. **Log errors** with context for debugging
6. **Provide localized messages** for all error types
