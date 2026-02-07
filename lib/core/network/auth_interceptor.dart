import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../constants/storage_constants.dart';
import '../services/storage_service.dart';
import '../services/environment_service.dart';
import '../errors/error_handler.dart';
import '../../app/routes/app_routes.dart';

/// Request interceptor that automatically injects authentication token
/// into API requests that require authentication and handles 401 errors
/// with automatic token refresh and retry
class AuthInterceptor {
  final StorageService _storageService;
  final http.Client _httpClient;

  /// List of endpoints that should not have token injection
  /// (e.g., login, register endpoints)
  final List<String> _excludedEndpoints = [
    ApiConstants.login,
    ApiConstants.register,
    ApiConstants.forgotPassword,
    ApiConstants.resetPassword,
    ApiConstants.verifyOtp,
  ];

  /// List of endpoints that should not trigger token refresh on 401
  /// (e.g., refresh token endpoint itself)
  final List<String> _noRefreshEndpoints = [
    ApiConstants.refreshToken,
    ApiConstants.logout,
  ];

  /// Flag to prevent multiple simultaneous refresh attempts
  bool _isRefreshing = false;

  /// Completer for pending requests during token refresh
  Completer<String?>? _refreshCompleter;

  AuthInterceptor(this._storageService, this._httpClient);

  /// Intercept request and add Authorization header if token exists
  /// and endpoint is not in excluded list
  Future<void> onRequest(
    String method,
    String url,
    Map<String, String> headers,
  ) async {
    // Check if this endpoint should be excluded from token injection
    if (_shouldExcludeEndpoint(url)) {
      return;
    }

    // Retrieve token from storage
    final token = await _storageService.read<String>(
      StorageConstants.authToken,
    );

    // Add Authorization header if token exists
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Intercept response and handle authentication errors
  /// Attempts token refresh on 401 responses before clearing credentials
  Future<void> onResponse(http.Response response) async {
    // Handle 401 Unauthorized responses
    if (response.statusCode == 401) {
      final url = response.request?.url.toString() ?? '';
      // Check if this endpoint should not trigger token refresh
      if (_shouldSkipRefresh(url)) {
        await _handleAuthenticationFailure(response);
        return;
      }
      // Attempt token refresh and retry
      final newToken = await _attemptTokenRefresh();
      if (newToken != null) {
        // Token refresh successful, retry the original request
        await _retryOriginalRequest(response, newToken);
      } else {
        // Token refresh failed, handle as authentication failure
        await _handleAuthenticationFailure(response);
      }
    }
  }

  /// Attempt to refresh the authentication token
  /// Returns new access token if successful, null if failed
  Future<String?> _attemptTokenRefresh() async {
    // Prevent multiple simultaneous refresh attempts
    if (_isRefreshing) {
      // Wait for ongoing refresh to complete
      return await _refreshCompleter?.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();

    try {
      // Get current tokens from storage
      final accessToken = await _storageService.read<String>(
        StorageConstants.authToken,
      );
      final refreshToken = await _storageService.read<String>(
        StorageConstants.refreshToken,
      );

      if (accessToken == null || refreshToken == null) {
        _refreshCompleter!.complete(null);
        return null;
      }

      // Prepare refresh request
      final refreshRequest = {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };

      // Get base URL from environment service
      final environmentService = Get.find<EnvironmentService>();
      final baseUrl = environmentService.apiBaseUrl;
      final refreshUrl = '$baseUrl${ApiConstants.refreshToken}';

      // Make refresh token request
      final response = await _httpClient
          .post(
            Uri.parse(refreshUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(refreshRequest),
          )
          .timeout(Duration(milliseconds: ApiConstants.connectionTimeout));

      if (response.statusCode == 200) { 
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final authData = responseData['data'];
          final newAccessToken = authData['accessToken'] as String?;
          final newRefreshToken = authData['refreshToken'] as String?;

          if (newAccessToken != null && newRefreshToken != null) {
            // Store new tokens
            await _storageService.write(
              StorageConstants.authToken,
              newAccessToken,
            );
            await _storageService.write(
              StorageConstants.refreshToken,
              newRefreshToken,
            );

            // Store expiration times if available
            if (authData['accessTokenExpiration'] != null) {
              await _storageService.write(
                StorageConstants.tokenExpiration,
                authData['accessTokenExpiration'],
              );
            }
            if (authData['refreshTokenExpiration'] != null) {
              await _storageService.write(
                StorageConstants.refreshTokenExpiration,
                authData['refreshTokenExpiration'],
              );
            }

            ErrorHandler.logError(
              'Token refresh successful',
              StackTrace.current,
              context: 'AuthInterceptor',
            );

            _refreshCompleter!.complete(newAccessToken);
            return newAccessToken;
          }
        }
      }

      // Refresh failed
      ErrorHandler.logError(
        'Token refresh failed: ${response.statusCode}',
        StackTrace.current,
        context: 'AuthInterceptor',
        additionalData: {
          'status_code': response.statusCode,
          'response_body': response.body,
        },
      );

      _refreshCompleter!.complete(null);
      return null;
    } catch (e) {
      ErrorHandler.logError(
        'Token refresh error: $e',
        StackTrace.current,
        context: 'AuthInterceptor',
        additionalData: {'error': e.toString()},
      );

      _refreshCompleter!.complete(null);
      return null;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  /// Retry the original request with the new token
  Future<void> _retryOriginalRequest(
    http.Response originalResponse,
    String newToken,
  ) async {
    try {
      final originalRequest = originalResponse.request;
      if (originalRequest == null) return;

      // Create new request with updated token
      final newHeaders = Map<String, String>.from(originalRequest.headers);
      newHeaders['Authorization'] = 'Bearer $newToken';

      http.Response? retryResponse;

      // Retry based on original request method
      switch (originalRequest.method.toUpperCase()) {
        case 'GET':
          retryResponse = await _httpClient.get(
            originalRequest.url,
            headers: newHeaders,
          );
          break;
        case 'POST':
          final body = originalRequest is http.Request
              ? originalRequest.body
              : null;
          retryResponse = await _httpClient.post(
            originalRequest.url,
            headers: newHeaders,
            body: body,
          );
          break;
        case 'PUT':
          final body = originalRequest is http.Request
              ? originalRequest.body
              : null;
          retryResponse = await _httpClient.put(
            originalRequest.url,
            headers: newHeaders,
            body: body,
          );
          break;
        case 'DELETE':
          retryResponse = await _httpClient.delete(
            originalRequest.url,
            headers: newHeaders,
          );
          break;
        case 'PATCH':
          final body = originalRequest is http.Request
              ? originalRequest.body
              : null;
          retryResponse = await _httpClient.patch(
            originalRequest.url,
            headers: newHeaders,
            body: body,
          );
          break;
      }

      if (retryResponse != null && retryResponse.statusCode < 400) {
        ErrorHandler.logError(
          'Request retry successful after token refresh',
          StackTrace.current,
          context: 'AuthInterceptor',
          additionalData: {
            'original_url': originalRequest.url.toString(),
            'retry_status': retryResponse.statusCode,
          },
        );
      }
    } catch (e) {
      ErrorHandler.logError(
        'Failed to retry request after token refresh: $e',
        StackTrace.current,
        context: 'AuthInterceptor',
        additionalData: {
          'error': e.toString(),
          'original_url': originalResponse.request?.url.toString(),
        },
      );
    }
  }

  /// Handle authentication failure by clearing credentials and redirecting
  Future<void> _handleAuthenticationFailure(http.Response response) async {
    // Log the authentication failure
    ErrorHandler.logError(
      'Authentication failed: 401 Unauthorized',
      StackTrace.current,
      context: 'AuthInterceptor',
      additionalData: {
        'url': response.request?.url.toString(),
        'method': response.request?.method,
        'status_code': response.statusCode,
      },
    );

    // Clear stored authentication credentials
    await _clearAuthCredentials();

    // Navigate to login page if not already there
    if (Get.currentRoute != AppRoutes.LOGIN) {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  /// Clear stored authentication credentials
  Future<void> _clearAuthCredentials() async {
    try {
      await _storageService.remove(StorageConstants.authToken);
      await _storageService.remove(StorageConstants.refreshToken);
      await _storageService.remove(StorageConstants.tokenExpiration);
      await _storageService.remove(StorageConstants.refreshTokenExpiration);
      await _storageService.remove(StorageConstants.userData);
      await _storageService.remove(StorageConstants.userId);
      await _storageService.remove(StorageConstants.userName);
      await _storageService.remove(StorageConstants.userEmail);
      await _storageService.remove(StorageConstants.userPhone);
      await _storageService.remove(StorageConstants.isLoggedIn);
      await _storageService.remove(StorageConstants.lastLoginTime);

      ErrorHandler.logError(
        'Authentication credentials cleared due to 401 response',
        StackTrace.current,
        context: 'AuthInterceptor',
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError(
        'Failed to clear authentication credentials',
        stackTrace,
        context: 'AuthInterceptor',
        additionalData: {'error': e.toString()},
      );
    }
  }

  /// Check if the endpoint should be excluded from token injection
  bool _shouldExcludeEndpoint(String url) {
    return _excludedEndpoints.any((endpoint) => url.contains(endpoint));
  }

  /// Check if the endpoint should skip token refresh on 401
  bool _shouldSkipRefresh(String url) {
    return _noRefreshEndpoints.any((endpoint) => url.contains(endpoint));
  }
}
