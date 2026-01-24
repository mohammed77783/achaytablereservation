/// Authentication data source for API communication
/// Handles all authentication-related API calls and response parsing
library;

import 'package:achaytablereservation/core/constants/api_constants.dart';
import 'package:achaytablereservation/core/errors/exceptions.dart';
import 'package:achaytablereservation/core/errors/error_handler.dart';
import 'package:achaytablereservation/core/network/api_client.dart';
import 'package:achaytablereservation/core/shared/model/api_response.dart';
import 'package:achaytablereservation/core/shared/model/user_model.dart';
import 'package:achaytablereservation/features/authentication/data/models/auth_request_models.dart';
import 'package:achaytablereservation/features/authentication/data/models/auth_response_models.dart';

/// Remote data source for authentication operations
/// Handles API communication for all authentication endpoints
class AuthDataSource {
  final ApiClient _apiClient;

  AuthDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Register a new user account
  ///
  /// Sends registration data to the API and returns the response
  /// May return OtpResponse if OTP verification is required
  ///
  /// Throws [ValidationException] for invalid input data
  /// Throws [ServerException] for server errors
  /// Throws [NetworkException] for network issues
  Future<ApiResponse<OtpResponse>> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        body: request.toJson(),
      );

      return _parseApiResponse<OtpResponse>(
        response,
        (data) => OtpResponse.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Login with phone number and password
  ///
  /// Authenticates user credentials and returns authentication response
  /// May return OtpResponse if OTP verification is required
  ///
  /// Throws [AuthenticationException] for invalid credentials
  /// Throws [ValidationException] for invalid input data
  /// Throws [ServerException] for server errors
  /// Throws [NetworkException] for network issues
  Future<ApiResponse<dynamic>> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        body: request.toJson(),
      );

      return _parseApiResponse<dynamic>(response, (data) {
        // Check if response contains requiresOtp flag
        if (data is Map<String, dynamic> && data.containsKey('requiresOtp')) {
          return OtpResponse.fromJson(data);
        }
        // Otherwise, it's a full authentication response
        return AuthResponse.fromJson(data as Map<String, dynamic>);
      });
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Verify OTP code for authentication
  ///
  /// Verifies the OTP code and completes authentication
  /// Returns full authentication response with tokens and user data
  ///
  /// Throws [ValidationException] for invalid OTP code
  /// Throws [AuthenticationException] for expired or incorrect OTP
  /// Throws [ServerException] for server errors
  /// Throws [NetworkException] for network issues
  Future<ApiResponse<AuthResponse>> verifyOtp(
    VerifyOtpRequest request,
    String operation,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyOtp.replaceAll("{operation}", operation),
        body: request.toJson(),
      );

      return _parseApiResponse<AuthResponse>(
        response,
        (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Request password reset via phone number
  ///
  /// Sends password reset request and triggers OTP sending
  /// Returns success response if request is processed
  ///
  /// Throws [ValidationException] for invalid phone number
  /// Throws [ServerException] for server errors
  /// Throws [NetworkException] for network issues
  Future<ApiResponse<OtpResponse>> forgotPassword(
    ForgotPasswordRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.forgotPassword,
        body: request.toJson(),
      );

      return _parseApiResponse<OtpResponse>(
        response,
        (data) => OtpResponse.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Reset password with OTP verification
  ///
  /// Submits new password with OTP code for verification
  /// Returns success response if password is reset successfully
  ///
  /// Throws [ValidationException] for invalid input data or weak password
  /// Throws [AuthenticationException] for invalid or expired OTP
  /// Throws [ServerException] for server errors
  /// Throws [NetworkException] for network issues
  Future<ApiResponse<void>> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.resetPassword,
        body: request.toJson(),
      );

      return _parseApiResponse<void>(
        response,
        (data) {}, // No data expected for password reset success
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Refresh authentication tokens
  ///
  /// Uses refresh token to obtain new access and refresh tokens
  /// Returns new authentication response with updated tokens
  ///
  /// Throws [AuthenticationException] for invalid or expired refresh token
  /// Throws [ServerException] for server errors
  /// Throws [NetworkException] for network issues
  Future<ApiResponse<AuthResponse>> refreshToken(
    RefreshTokenRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.refreshToken,
        body: request.toJson(),
      );

      return _parseApiResponse<AuthResponse>(
        response,
        (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Logout current user session
  ///
  /// Invalidates current session and tokens on the server
  /// Returns success response if logout is completed
  ///
  /// Throws [AuthenticationException] for invalid session
  /// Throws [ServerException] for server errors
  /// Throws [NetworkException] for network issues
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _apiClient.post(ApiConstants.logout);

      return _parseApiResponse<void>(
        response,
        (data) {}, // No data expected for logout success
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Get current authenticated user profile
  ///
  /// Fetches current user profile data from the server
  /// Returns user model with current profile information
  ///
  /// Throws [AuthenticationException] for invalid or expired token
  /// Throws [ServerException] for server errors
  /// Throws [NetworkException] for network issues
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiConstants.getCurrentUser);

      return _parseApiResponse<UserModel>(
        response,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Parse API response into typed ApiResponse object
  ///
  /// Handles the standard API response format and converts data
  /// using the provided fromJson function
  ApiResponse<T> _parseApiResponse<T>(
    dynamic response,
    T Function(dynamic) fromJsonT,
  ) {
    try {
      if (response == null) {
        ErrorHandler.logError(
          'Null response received from API',
          StackTrace.current,
          context: 'AuthDataSource - _parseApiResponse',
        );
        throw ParsingException('Response is null');
      }

      if (response is! Map<String, dynamic>) {
        ErrorHandler.logError(
          'Invalid response format received from API',
          StackTrace.current,
          context: 'AuthDataSource - _parseApiResponse',
          additionalData: {'response_type': response.runtimeType.toString()},
        );
        throw ParsingException('Response is not a valid JSON object');
      }

      // Validate required fields in API response
      if (!response.containsKey('success')) {
        ErrorHandler.logError(
          'API response missing required success field',
          StackTrace.current,
          context: 'AuthDataSource - _parseApiResponse',
          additionalData: {'response': response},
        );
        throw ParsingException('Response missing required success field');
      }

      return ApiResponse<T>.fromJson(response, fromJsonT);
    } catch (e) {
      if (e is ParsingException) rethrow;

      ErrorHandler.logError(
        'Failed to parse API response',
        StackTrace.current,
        context: 'AuthDataSource - _parseApiResponse',
        additionalData: {
          'error': e.toString(),
          'response': response?.toString(),
        },
      );

      throw ParsingException('Failed to parse API response: $e');
    }
  }

  /// Handle and convert exceptions to appropriate types
  ///
  /// Maps generic exceptions to specific authentication exceptions
  /// Preserves original exception types when appropriate
  Exception _handleException(dynamic error) {
    // Log the exception for debugging
    ErrorHandler.logException(
      error is Exception ? error : Exception(error.toString()),
      context: 'AuthDataSource',
    );

    if (error is AppException) {
      return error;
    }

    if (error is FormatException) {
      return ParsingException('Invalid response format: ${error.message}');
    }

    if (error is TypeError) {
      return ParsingException('Type error in response parsing: $error');
    }

    // Handle network-related errors
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return TimeoutException('Request timeout: $error');
    }

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return NetworkException('Network error: $error');
    }

    if (errorString.contains('host lookup') || errorString.contains('dns')) {
      return NetworkException('DNS resolution failed: $error');
    }

    // For any other unexpected errors
    return ServerException('Unexpected error occurred: $error');
  }
}
