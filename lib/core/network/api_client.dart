import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:achaytablereservation/core/services/environment_service.dart';
import 'package:achaytablereservation/core/errors/error_handler.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

/// HTTP API client wrapper that provides common HTTP methods with
/// timeout configuration, retry logic, and request/response interceptors
class ApiClient {
  final http.Client _client;
  final String baseUrl;
  final Map<String, String> _defaultHeaders;

  /// Request interceptors - called before each request
  final List<RequestInterceptor> _requestInterceptors = [];

  /// Response interceptors - called after each response
  final List<ResponseInterceptor> _responseInterceptors = [];

  ApiClient({
    http.Client? client,
    String? baseUrl,
    Map<String, String>? defaultHeaders,
  }) : _client = client ?? http.Client(),
       baseUrl = baseUrl ?? Get.find<EnvironmentService>().apiBaseUrl,
       _defaultHeaders =
           defaultHeaders ??
           {
             ApiConstants.headerContentType: ApiConstants.contentTypeJson,
             ApiConstants.headerAccept: ApiConstants.contentTypeJson,
           };

  /// Add a request interceptor
  void addRequestInterceptor(RequestInterceptor interceptor) {
    _requestInterceptors.add(interceptor);
  }

  /// Add a response interceptor
  void addResponseInterceptor(ResponseInterceptor interceptor) {
    _responseInterceptors.add(interceptor);
  }

  /// Remove a request interceptor
  void removeRequestInterceptor(RequestInterceptor interceptor) {
    _requestInterceptors.remove(interceptor);
  }

  /// Remove a response interceptor
  void removeResponseInterceptor(ResponseInterceptor interceptor) {
    _responseInterceptors.remove(interceptor);
  }

  /// Perform GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    final mergedHeaders = _mergeHeaders(headers);

    return _executeWithRetry(
      () => _performRequest(
        () => _client.get(uri, headers: mergedHeaders),
        'GET',
        uri.toString(),
        mergedHeaders,
      ),
    );
  }

  /// Perform POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    final mergedHeaders = _mergeHeaders(headers);
    final encodedBody = _encodeBody(body);

    return _executeWithRetry(
      () => _performRequest(
        () => _client.post(uri, headers: mergedHeaders, body: encodedBody),
        'POST',
        uri.toString(),
        mergedHeaders,
      ),
    );
  }

  /// Perform PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    final mergedHeaders = _mergeHeaders(headers);
    final encodedBody = _encodeBody(body);

    return _executeWithRetry(
      () => _performRequest(
        () => _client.put(uri, headers: mergedHeaders, body: encodedBody),
        'PUT',
        uri.toString(),
        mergedHeaders,
      ),
    );
  }

  /// Perform DELETE request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    final mergedHeaders = _mergeHeaders(headers);
    final encodedBody = body != null ? _encodeBody(body) : null;

    return _executeWithRetry(
      () => _performRequest(
        () => _client.delete(uri, headers: mergedHeaders, body: encodedBody),
        'DELETE',
        uri.toString(),
        mergedHeaders,
      ),
    );
  }

  /// Perform PATCH request
  Future<dynamic> patch(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    final mergedHeaders = _mergeHeaders(headers);
    final encodedBody = _encodeBody(body);

    return _executeWithRetry(
      () => _performRequest(
        () => _client.patch(uri, headers: mergedHeaders, body: encodedBody),
        'PATCH',
        uri.toString(),
        mergedHeaders,
      ),
    );
  }

  /// Build URI with base URL, endpoint, and query parameters
  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final p2 = baseUrl;
    final fullUrl = '$p2$path';

    if (queryParameters != null && queryParameters.isNotEmpty) {
      return Uri.parse(fullUrl).replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }

    return Uri.parse(fullUrl);
  }

  /// Merge default headers with custom headers
  Map<String, String> _mergeHeaders(Map<String, String>? customHeaders) {
    return {..._defaultHeaders, if (customHeaders != null) ...customHeaders};
  }

  /// Encode request body to JSON string
  String _encodeBody(dynamic body) {
    if (body == null) return '';
    if (body is String) return body;
    return jsonEncode(body);
  }

  /// Perform HTTP request with timeout, interceptors, and enhanced error handling
  Future<dynamic> _performRequest(
    Future<http.Response> Function() request,
    String method,
    String url,
    Map<String, String> headers,
  ) async {
    try {
      // Log request start for debugging
      ErrorHandler.logError(
        'Starting HTTP request',
        StackTrace.current,
        context: 'ApiClient - Request Start',
        additionalData: {
          'method': method,
          'url': url,
          'hasHeaders': headers.isNotEmpty,
        },
      );

      // Apply request interceptors
      for (final interceptor in _requestInterceptors) {
        await interceptor(method, url, headers);
      }

      // Execute request with timeout
      final response = await request().timeout(
        Duration(milliseconds: ApiConstants.connectionTimeout),
        onTimeout: () {
          ErrorHandler.logError(
            'Request timeout occurred',
            StackTrace.current,
            context: 'ApiClient - Request Timeout',
            additionalData: {
              'method': method,
              'url': url,
              'timeoutMs': ApiConstants.connectionTimeout,
            },
          );

          throw TimeoutException(
            'Request timeout after ${ApiConstants.connectionTimeout}ms for $method $url',
          );
        },
      );

      // Log successful response
      ErrorHandler.logError(
        'HTTP request completed successfully',
        StackTrace.current,
        context: 'ApiClient - Request Success',
        additionalData: {
          'method': method,
          'url': url,
          'statusCode': response.statusCode,
          'responseSize': response.body.length,
        },
      );

      // Apply response interceptors
      for (final interceptor in _responseInterceptors) {
        await interceptor(response);
      }

      // Handle response
      return _handleResponse(response);
    } on SocketException catch (e) {
      ErrorHandler.logError(
        'Socket exception occurred during HTTP request',
        StackTrace.current,
        context: 'ApiClient - Socket Exception',
        additionalData: {
          'method': method,
          'url': url,
          'error': e.toString(),
          'osError': e.osError?.toString(),
        },
      );

      if (e.message.contains('Connection refused')) {
        throw NetworkException(
          'Server connection refused for $method $url. Is the server running? ${e.message}',
        );
      } else if (e.message.contains('Failed host lookup')) {
        throw NetworkException('DNS resolution failed for $url: ${e.message}');
      } else if (e.message.contains('Network is unreachable')) {
        throw NetworkException('Network is unreachable for $url: ${e.message}');
      } else {
        throw NetworkException('Network error for $method $url: ${e.message}');
      }
    } on TimeoutException catch (e) {
      ErrorHandler.logError(
        'Timeout exception during HTTP request',
        StackTrace.current,
        context: 'ApiClient - Timeout Exception',
        additionalData: {'method': method, 'url': url, 'error': e.toString()},
      );
      rethrow;
    } on http.ClientException catch (e) {
      ErrorHandler.logError(
        'HTTP client exception occurred',
        StackTrace.current,
        context: 'ApiClient - Client Exception',
        additionalData: {'method': method, 'url': url, 'error': e.toString()},
      );

      throw NetworkException(
        'HTTP client error for $method $url: ${e.message}',
      );
    } catch (e) {
      ErrorHandler.logError(
        'Unexpected error during HTTP request',
        StackTrace.current,
        context: 'ApiClient - Unexpected Error',
        additionalData: {
          'method': method,
          'url': url,
          'error': e.toString(),
          'errorType': e.runtimeType.toString(),
        },
      );
      rethrow;
    }
  }

  /// Handle HTTP response and throw appropriate exceptions
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    // Success responses (200-299)
    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }

      try {
        return jsonDecode(response.body);
      } catch 
      (e)
       {
        throw ParsingException('Failed to parse response: $e');
      }
    }

    // Error responses
    String errorMessage = 'Request failed with status: $statusCode';
    try {
      final errorBody = jsonDecode(response.body);
      errorMessage = errorBody['message'] ?? errorMessage;
    } catch (_) {
      // If parsing fails, use default error message
    }

    // Handle specific status codes
    switch (statusCode) {
      case 400:
        throw ValidationException(errorMessage, statusCode);
      case 401:
        throw AuthenticationException(errorMessage, statusCode);
      case 403:
        throw AuthorizationException(errorMessage, statusCode);
      case 404:
        throw ServerException('Resource not found', statusCode);
      case 500:
      case 502:
      case 503:
        throw ServerException(errorMessage, statusCode);
      default:
        throw ServerException(errorMessage, statusCode);
    }
  }

  /// Execute request with enhanced retry logic and exponential backoff
  Future<dynamic> _executeWithRetry(
    Future<dynamic> Function() request, {
    int retryCount = 0,
  }) async {
    try {
      return await request();
    } 
    on NetworkException catch  (e) {
      // Retry on network errors with exponential backoff
      if (retryCount < ApiConstants.maxRetries) {
        final delayMs =
            ApiConstants.retryDelay *
            (1 << retryCount); // Exponential: 1000, 2000, 4000ms

        ErrorHandler.logError(
          'Network error occurred - retrying in ${delayMs}ms',
          StackTrace.current,
          context: 'ApiClient - Network Retry',
          additionalData: {
            'attempt': retryCount + 1,
            'maxRetries': ApiConstants.maxRetries,
            'delayMs': delayMs,
            'error': e.toString(),
          },
        );

        await Future.delayed(Duration(milliseconds: delayMs));
        return _executeWithRetry(request, retryCount: retryCount + 1);
      }

      ErrorHandler.logError(
        'Network error - max retries exceeded',
        StackTrace.current,
        context: 'ApiClient - Network Retry Failed',
        additionalData: {
          'totalAttempts': retryCount + 1,
          'maxRetries': ApiConstants.maxRetries,
          'finalError': e.toString(),
        },
      );
      rethrow;
    } on TimeoutException catch (e) {
      // Retry on timeout errors with exponential backoff
      if (retryCount < ApiConstants.maxRetries) {
        final delayMs =
            ApiConstants.retryDelay * (1 << retryCount); // Exponential backoff

        ErrorHandler.logError(
          'Timeout error occurred - retrying in ${delayMs}ms',
          StackTrace.current,
          context: 'ApiClient - Timeout Retry',
          additionalData: {
            'attempt': retryCount + 1,
            'maxRetries': ApiConstants.maxRetries,
            'delayMs': delayMs,
            'error': e.toString(),
          },
        );

        await Future.delayed(Duration(milliseconds: delayMs));
        return _executeWithRetry(request, retryCount: retryCount + 1);
      }

      ErrorHandler.logError(
        'Timeout error - max retries exceeded',
        StackTrace.current,
        context: 'ApiClient - Timeout Retry Failed',
        additionalData: {
          'totalAttempts': retryCount + 1,
          'maxRetries': ApiConstants.maxRetries,
          'finalError': e.toString(),
        },
      );
      rethrow;
    } on ServerException catch (e) {
      // Retry on 5xx server errors with exponential backoff
      if (e.code != null &&
          e.code! >= 500 &&
          retryCount < ApiConstants.maxRetries) {
        final delayMs =
            ApiConstants.retryDelay * (1 << retryCount); // Exponential backoff

        ErrorHandler.logError(
          'Server error ${e.code} occurred - retrying in ${delayMs}ms',
          StackTrace.current,
          context: 'ApiClient - Server Error Retry',
          additionalData: {
            'attempt': retryCount + 1,
            'maxRetries': ApiConstants.maxRetries,
            'delayMs': delayMs,
            'statusCode': e.code,
            'error': e.toString(),
          },
        );

        await Future.delayed(Duration(milliseconds: delayMs));
        return _executeWithRetry(request, retryCount: retryCount + 1);
      }

      if (e.code != null && e.code! >= 500) {
        ErrorHandler.logError(
          'Server error ${e.code} - max retries exceeded',
          StackTrace.current,
          context: 'ApiClient - Server Error Retry Failed',
          additionalData: {
            'totalAttempts': retryCount + 1,
            'maxRetries': ApiConstants.maxRetries,
            'statusCode': e.code,
            'finalError': e.toString(),
          },
        );
      }
      rethrow;
    }
     catch (e) {
      // For non-retryable errors, log and rethrow immediately
      ErrorHandler.logError(
        'Non-retryable error occurred',
        StackTrace.current,
        context: 'ApiClient - Non-Retryable Error',
        additionalData: {
          'error': e.toString(),
          'errorType': e.runtimeType.toString(),
          'attempt': retryCount + 1,
        },
      );
      rethrow;
    }
  }

  /// Close the HTTP client
  void dispose() {
    _client.close();
  }
}

/// Type definition for request interceptor
/// Allows modification of headers before request is sent
typedef RequestInterceptor =
    Future<void> Function(
      String method,
      String url,
      Map<String, String> headers,
    );

/// Type definition for response interceptor
typedef ResponseInterceptor = Future<void> Function(http.Response response);
