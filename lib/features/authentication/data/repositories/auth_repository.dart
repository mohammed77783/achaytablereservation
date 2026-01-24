/// Authentication repository implementing repository pattern
/// Handles authentication operations, token management, and data persistence
library;

import 'dart:convert';

import 'package:achaytablereservation/core/constants/storage_constants.dart';
import 'package:achaytablereservation/core/errors/exceptions.dart';
import 'package:achaytablereservation/core/errors/error_handler.dart';
import 'package:achaytablereservation/core/services/storage_service.dart';
import 'package:achaytablereservation/core/shared/model/api_response.dart';
import 'package:achaytablereservation/core/shared/model/user_model.dart';
import 'package:achaytablereservation/features/authentication/data/datasources/auth_datasource.dart';
import 'package:achaytablereservation/features/authentication/data/models/auth_request_models.dart';
import 'package:achaytablereservation/features/authentication/data/models/auth_response_models.dart';

/// Repository for authentication operations
/// Implements repository pattern to abstract data access and provide clean interface
/// Handles token management, automatic refresh, and secure data persistence
class AuthRepository {
  final AuthDataSource _dataSource;
  final StorageService _storageService;

  AuthRepository({
    required AuthDataSource dataSource,
    required StorageService storageService,
  }) : _dataSource = dataSource,
       _storageService = storageService;

  // ==================== Authentication Operations ====================

  /// Register a new user account
  ///
  /// Handles user registration and returns OTP response if verification is required
  /// Automatically handles API errors and provides proper exception mapping
  ///
  /// Throws [ValidationException] for invalid input data
  /// Throws [ServerException] for server errors
  /// Throws [NetworkException] for network issues
  Future<ApiResponse<OtpResponse>> register(RegisterRequest request) async {
    try {
      final response = await _dataSource.register(request);
      return response;
    } catch (e) {
      throw _handleRepositoryException(e, 'Registration failed');
    }
  }

  /// Login with phone number and password
  ///
  /// Authenticates user credentials and handles both OTP and direct login flows
  /// Automatically stores tokens and user data on successful authentication
  ///
  /// Returns [OtpResponse] if OTP verification is required
  /// Returns [AuthResponse] if login is successful without OTP
  ///
  /// Throws [AuthenticationException] for invalid credentials
  /// Throws [ValidationException] for invalid input data
  /// Throws [ServerException] for server errors
  /// Throws [NetworkException] for network issues
  Future<ApiResponse<dynamic>> login(LoginRequest request) async {
    try {
      final response = await _dataSource.login(request);

      // If response contains AuthResponse, store the authentication data
      if (response.success && response.data is AuthResponse) {
        final authResponse = response.data as AuthResponse;
        await _storeAuthenticationData(authResponse);
      }

      return response;
    } catch (e) {
      throw _handleRepositoryException(e, 'Login failed');
    }
  }

  /// Verify OTP code for authentication
  ///
  /// Completes authentication process by verifying OTP code
  /// Automatically stores tokens and user data on successful verification
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
      final response = await _dataSource.verifyOtp(request, operation);

      // Store authentication data on successful verification
      if (response.success && response.data != null) {
        await _storeAuthenticationData(response.data!);
      }

      return response;
    } catch (e) {
      throw _handleRepositoryException(e, 'OTP verification failed');
    }
  }

  /// Request password reset via phone number
  ///
  /// Initiates password reset flow by sending OTP to user's phone
  ///
  /// Throws [ValidationException] for invalid phone number
  /// Throws [ServerException] for server errors
  /// Throws [NetworkException] for network issues
  Future<ApiResponse<OtpResponse>> forgotPassword(
    ForgotPasswordRequest request,
  ) async {
    try {
      final response = await _dataSource.forgotPassword(request);
      return response;
    } catch (e) {
      throw _handleRepositoryException(e, 'Password reset request failed');
    }
  }

  /// Reset password with OTP verification
  ///
  /// Completes password reset process with new password and OTP verification
  ///
  /// Throws [ValidationException] for invalid input data or weak password
  /// Throws [AuthenticationException] for invalid or expired OTP
  /// Throws [ServerException] for server errors
  /// Throws [NetworkException] for network issues
  Future<ApiResponse<void>> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _dataSource.resetPassword(request);
      return response;
    } catch (e) {
      throw _handleRepositoryException(e, 'Password reset failed');
    }
  }

  /// Logout current user session
  ///
  /// Invalidates session on server and clears all local authentication data
  /// Always clears local data even if server logout fails
  ///
  /// Throws [ServerException] for server errors (but still clears local data)
  /// Throws [NetworkException] for network issues (but still clears local data)
  Future<ApiResponse<void>> logout() async {
    try {
      // Attempt to logout on server
      final response = await _dataSource.logout();

      // Always clear local data regardless of server response
      await clearAuthenticationData();

      return response;
    } catch (e) {
      // Even if server logout fails, clear local data
      await clearAuthenticationData();
      throw _handleRepositoryException(e, 'Logout failed');
    }
  }

  // ==================== Token Management ====================

  /// Refresh authentication tokens
  ///
  /// Uses refresh token to obtain new access and refresh tokens
  /// Automatically stores new tokens on successful refresh
  /// Implements retry logic for network failures
  ///
  /// Throws [AuthenticationException] for invalid or expired refresh token
  /// Throws [ServerException] for server errors
  /// Throws [NetworkException] for network issues
  Future<ApiResponse<AuthResponse>> refreshToken() async {
    try {
      // Get current tokens from storage
      final currentTokens = await _getCurrentTokens();
      if (currentTokens == null) {
        throw AuthenticationException('No refresh token available');
      }

      final request = RefreshTokenRequest(
        accessToken: currentTokens['accessToken']!,
        refreshToken: currentTokens['refreshToken']!,
      );

      // Attempt token refresh with retry logic
      final response = await _refreshTokenWithRetry(request);

      // Store new authentication data on successful refresh
      if (response.success && response.data != null) {
        await _storeAuthenticationData(response.data!);
      }

      return response;
    } catch (e) {
      throw _handleRepositoryException(e, 'Token refresh failed');
    }
  }

  /// Refresh tokens with retry mechanism
  ///
  /// Implements automatic retry for network failures with exponential backoff
  /// Retries up to 3 times with increasing delays: 2s, 4s, 8s
  /// Logs retry attempts for debugging while maintaining user experience
  Future<ApiResponse<AuthResponse>> _refreshTokenWithRetry(
    RefreshTokenRequest request, {
    int maxRetries = 3,
  }) async {
    int retryCount = 0;
    Exception? lastException;

    while (retryCount < maxRetries) {
      try {
        if (retryCount > 0) {
          ErrorHandler.logError(
            'Retrying token refresh (attempt ${retryCount + 1}/$maxRetries)',
            StackTrace.current,
            context: 'AuthRepository - Token Refresh Retry',
            additionalData: {
              'attempt': retryCount + 1,
              'maxRetries': maxRetries,
              'previousError': lastException?.toString(),
            },
          );
        }

        return await _dataSource.refreshToken(request);
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        retryCount++;

        // If it's an authentication error, don't retry
        if (e is AuthenticationException) {
          ErrorHandler.logError(
            'Token refresh failed with authentication error - not retrying',
            StackTrace.current,
            context: 'AuthRepository - Token Refresh',
            additionalData: {
              'error': e.toString(),
              'code': e.code,
              'attempt': retryCount,
            },
          );
          rethrow;
        }

        // If we've exhausted retries, log final failure and rethrow
        if (retryCount >= maxRetries) {
          ErrorHandler.logError(
            'Token refresh failed after all retry attempts',
            StackTrace.current,
            context: 'AuthRepository - Token Refresh Final Failure',
            additionalData: {
              'totalAttempts': retryCount,
              'maxRetries': maxRetries,
              'finalError': e.toString(),
            },
          );
          rethrow;
        }

        // Calculate exponential backoff delay: 2^retryCount seconds
        final delaySeconds = (2 * retryCount).clamp(2, 16); // Max 16 seconds

        ErrorHandler.logError(
          'Token refresh attempt $retryCount failed, retrying in ${delaySeconds}s',
          StackTrace.current,
          context: 'AuthRepository - Token Refresh Retry',
          additionalData: {
            'attempt': retryCount,
            'delaySeconds': delaySeconds,
            'error': e.toString(),
          },
        );

        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }

    // This should never be reached, but included for completeness
    throw NetworkException(
      'Token refresh failed after $maxRetries attempts. Last error: ${lastException?.toString()}',
    );
  }

  /// Check if access token is expired with enhanced error handling
  ///
  /// Returns true if token is expired or will expire within the next 5 minutes
  /// Returns false if token is valid or if no token exists
  /// Implements graceful handling of corrupted expiration data
  Future<bool> isAccessTokenExpired() async {
    return await _handleStorageOperation(
      () async {
        final expirationString = await _storageService.read<String>(
          StorageConstants.tokenExpiration,
        );

        if (expirationString == null) {
          ErrorHandler.logError(
            'No token expiration found in storage',
            StackTrace.current,
            context: 'AuthRepository - Token Expiration Check',
            additionalData: {'reason': 'missing_expiration'},
          );
          return true;
        }

        try {
          final expiration = DateTime.parse(expirationString);
          final now = DateTime.now();
          final bufferTime = const Duration(minutes: 5);
          final isExpired = expiration.isBefore(now.add(bufferTime));

          // Log token status for debugging
          ErrorHandler.logError(
            'Access token expiration check completed',
            StackTrace.current,
            context: 'AuthRepository - Token Status',
            additionalData: {
              'expiration': expiration.toIso8601String(),
              'currentTime': now.toIso8601String(),
              'bufferMinutes': 5,
              'isExpired': isExpired,
              'timeUntilExpiry': expiration.difference(now).inMinutes,
            },
          );

          return isExpired;
        } catch (e) {
          // If we can't parse the expiration, consider token expired and clean up
          ErrorHandler.logError(
            'Invalid token expiration format detected - treating as expired',
            StackTrace.current,
            context: 'AuthRepository - Token Expiration Parse Error',
            additionalData: {
              'expirationString': expirationString,
              'parseError': e.toString(),
            },
          );

          // Clean up corrupted expiration data
          try {
            await _storageService.remove(StorageConstants.tokenExpiration);
          } catch (cleanupError) {
            ErrorHandler.logError(
              'Failed to clean up corrupted token expiration',
              StackTrace.current,
              context: 'AuthRepository - Cleanup Error',
              additionalData: {'cleanupError': cleanupError.toString()},
            );
          }

          return true;
        }
      },
      'Check access token expiration',
      fallbackValue: true,
    );
  }

  /// Check if refresh token is expired with enhanced error handling
  ///
  /// Returns true if refresh token is expired
  /// Returns false if refresh token is valid or if no token exists
  /// Implements graceful handling of corrupted expiration data
  Future<bool> isRefreshTokenExpired() async {
    return await _handleStorageOperation(
      () async {
        final refreshExpirationString = await _storageService.read<String>(
          StorageConstants.refreshTokenExpiration,
        );

        if (refreshExpirationString == null) {
          ErrorHandler.logError(
            'No refresh token expiration found in storage',
            StackTrace.current,
            context: 'AuthRepository - Refresh Token Expiration Check',
            additionalData: {'reason': 'missing_refresh_expiration'},
          );
          return true;
        }

        try {
          final expiration = DateTime.parse(refreshExpirationString);
          final now = DateTime.now();
          final isExpired = expiration.isBefore(now);

          // Log refresh token status for debugging
          ErrorHandler.logError(
            'Refresh token expiration check completed',
            StackTrace.current,
            context: 'AuthRepository - Refresh Token Status',
            additionalData: {
              'expiration': expiration.toIso8601String(),
              'currentTime': now.toIso8601String(),
              'isExpired': isExpired,
              'timeUntilExpiry': expiration.difference(now).inHours,
            },
          );

          return isExpired;
        } catch (e) {
          // If we can't parse the expiration, consider token expired and clean up
          ErrorHandler.logError(
            'Invalid refresh token expiration format detected - treating as expired',
            StackTrace.current,
            context: 'AuthRepository - Refresh Token Parse Error',
            additionalData: {
              'refreshExpirationString': refreshExpirationString,
              'parseError': e.toString(),
            },
          );

          // Clean up corrupted refresh expiration data
          try {
            await _storageService.remove(
              StorageConstants.refreshTokenExpiration,
            );
          } catch (cleanupError) {
            ErrorHandler.logError(
              'Failed to clean up corrupted refresh token expiration',
              StackTrace.current,
              context: 'AuthRepository - Refresh Cleanup Error',
              additionalData: {'cleanupError': cleanupError.toString()},
            );
          }

          return true;
        }
      },
      'Check refresh token expiration',
      fallbackValue: true,
    );
  }

  // ==================== User Profile Management ====================

  /// Get current authenticated user profile
  ///
  /// Fetches user profile from server using current access token
  /// Automatically handles token refresh if access token is expired
  ///
  /// Throws [AuthenticationException] for invalid or expired tokens
  /// Throws [ServerException] for server errors
  /// Throws [NetworkException] for network issues
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    try {
      // Check if access token is expired and refresh if needed
      if (await isAccessTokenExpired()) {
        await refreshToken();
      }

      final response = await _dataSource.getCurrentUser();

      // Update stored user data if successful
      if (response.success && response.data != null) {
        await _storeUserData(response.data!);
      }

      return response;
    } catch (e) {
      throw _handleRepositoryException(e, 'Failed to get user profile');
    }
  }

  // ==================== Data Persistence ====================

  /// Store authentication data securely
  ///
  /// Persists access token, refresh token, expiration times, and user data
  /// Uses secure storage for sensitive information
  Future<void> _storeAuthenticationData(AuthResponse authResponse) async {
    await _handleStorageOperation(() async {
      // Store tokens
      await _storageService.write(
        StorageConstants.authToken,
        authResponse.accessToken,
      );
      await _storageService.write(
        StorageConstants.refreshToken,
        authResponse.refreshToken,
      );

      // Store expiration times
      await _storageService.write(
        StorageConstants.tokenExpiration,
        authResponse.accessTokenExpiration.toIso8601String(),
      );
      await _storageService.write(
        StorageConstants.refreshTokenExpiration,
        authResponse.refreshTokenExpiration.toIso8601String(),
      );

      // Store user data
      await _storeUserData(authResponse.user);

      // Mark user as logged in
      await _storageService.write(StorageConstants.isLoggedIn, true);

      // Store last login time
      await _storageService.write(
        StorageConstants.lastLoginTime,
        DateTime.now().toIso8601String(),
      );
    }, 'Store authentication data');
  }

  /// Store user data securely
  ///
  /// Persists user profile information to secure storage
  Future<void> _storeUserData(UserModel user) async {
    await _handleStorageOperation(() async {
      // Store complete user data as JSON
      await _storageService.write(
        StorageConstants.userData,
        jsonEncode(user.toJson()),
      );

      // Store individual user fields for easy access
      await _storageService.write(StorageConstants.userId, user.id);
      await _storageService.write(StorageConstants.userName, user.fullName);
      await _storageService.write(StorageConstants.userEmail, user.email);
      await _storageService.write(StorageConstants.userPhone, user.phoneNumber);
    }, 'Store user data');
  }

  /// Get current tokens from storage
  ///
  /// Returns map with access and refresh tokens or null if not available
  Future<Map<String, String>?> _getCurrentTokens() async {
    return await _handleStorageOperation(() async {
      final accessToken = await _storageService.read<String>(
        StorageConstants.authToken,
      );
      final refreshToken = await _storageService.read<String>(
        StorageConstants.refreshToken,
      );

      if (accessToken == null || refreshToken == null) {
        return null;
      }

      return {'accessToken': accessToken, 'refreshToken': refreshToken};
    }, 'Get current tokens');
  }

  // ==================== Data Retrieval ====================

  /// Get stored access token
  ///
  /// Returns current access token or null if not available
  Future<String?> getAccessToken() async {
    return await _handleStorageOperation(() async {
      return await _storageService.read<String>(StorageConstants.authToken);
    }, 'Get access token');
  }

  /// Get stored refresh token
  ///
  /// Returns current refresh token or null if not available
  Future<String?> getRefreshToken() async {
    return await _handleStorageOperation(() async {
      return await _storageService.read<String>(StorageConstants.refreshToken);
    }, 'Get refresh token');
  }

  /// Get stored user data with enhanced error handling and recovery
  ///
  /// Returns current user model or null if not available
  /// Implements graceful handling of corrupted user data
  Future<UserModel?> getStoredUser() async {
    return await _handleStorageOperation(
      () async {
        final userDataString = await _storageService.read<String>(
          StorageConstants.userData,
        );

        if (userDataString == null) {
          ErrorHandler.logError(
            'No user data found in storage',
            StackTrace.current,
            context: 'AuthRepository - Get Stored User',
            additionalData: {'reason': 'missing_user_data'},
          );
          return null;
        }

        try {
          final userJson = jsonDecode(userDataString) as Map<String, dynamic>;
          final user = UserModel.fromJson(userJson);

          // Log successful user data retrieval
          ErrorHandler.logError(
            'User data retrieved successfully from storage',
            StackTrace.current,
            context: 'AuthRepository - User Data Success',
            additionalData: {
              'userId': user.id,
              'userEmail': user.email,
              'dataSize': userDataString.length,
            },
          );

          return user;
        } catch (e) {
          // If user data is corrupted, clean it up and return null
          ErrorHandler.logError(
            'Corrupted user data detected in storage - cleaning up',
            StackTrace.current,
            context: 'AuthRepository - User Data Corruption',
            additionalData: {
              'userDataString': userDataString.length > 500
                  ? '${userDataString.substring(0, 500)}...[truncated]'
                  : userDataString,
              'parseError': e.toString(),
            },
          );

          // Clean up corrupted user data
          try {
            await _storageService.remove(StorageConstants.userData);
            await _storageService.remove(StorageConstants.userId);
            await _storageService.remove(StorageConstants.userName);
            await _storageService.remove(StorageConstants.userEmail);
            await _storageService.remove(StorageConstants.userPhone);

            ErrorHandler.logError(
              'Corrupted user data cleaned up successfully',
              StackTrace.current,
              context: 'AuthRepository - User Data Cleanup Success',
            );
          } catch (cleanupError) {
            ErrorHandler.logError(
              'Failed to clean up corrupted user data',
              StackTrace.current,
              context: 'AuthRepository - User Data Cleanup Error',
              additionalData: {'cleanupError': cleanupError.toString()},
            );
          }

          return null;
        }
      },
      'Get stored user',
      fallbackValue: null,
    );
  }

  /// Check if user is currently logged in with comprehensive validation
  ///
  /// Returns true if user has valid authentication data
  /// Checks for both tokens and login status with enhanced error handling
  Future<bool> isLoggedIn() async {
    return await _handleStorageOperation(
      () async {
        final isLoggedIn = await _storageService.read<bool>(
          StorageConstants.isLoggedIn,
        );
        final accessToken = await getAccessToken();
        final refreshToken = await getRefreshToken();

        final hasValidTokens = accessToken != null && refreshToken != null;
        final isMarkedLoggedIn = isLoggedIn == true;
        final finalResult = isMarkedLoggedIn && hasValidTokens;

        // Log login status check for debugging
        ErrorHandler.logError(
          'Login status check completed',
          StackTrace.current,
          context: 'AuthRepository - Login Status Check',
          additionalData: {
            'isMarkedLoggedIn': isMarkedLoggedIn,
            'hasAccessToken': accessToken != null,
            'hasRefreshToken': refreshToken != null,
            'finalResult': finalResult,
          },
        );

        // If tokens are missing but user is marked as logged in, clean up inconsistent state
        if (isMarkedLoggedIn && !hasValidTokens) {
          ErrorHandler.logError(
            'Inconsistent authentication state detected - user marked as logged in but tokens missing',
            StackTrace.current,
            context: 'AuthRepository - State Inconsistency',
            additionalData: {
              'isLoggedIn': isMarkedLoggedIn,
              'hasAccessToken': accessToken != null,
              'hasRefreshToken': refreshToken != null,
            },
          );

          // Clean up inconsistent state in background
          _cleanupInconsistentStateInBackground();
        }

        return finalResult;
      },
      'Check login status',
      fallbackValue: false,
    );
  }

  /// Clean up inconsistent authentication state in background
  /// This runs asynchronously to avoid blocking the main login check
  void _cleanupInconsistentStateInBackground() {
    Future.microtask(() async {
      try {
        await clearAuthenticationData();
        ErrorHandler.logError(
          'Inconsistent authentication state cleaned up successfully',
          StackTrace.current,
          context: 'AuthRepository - Background Cleanup Success',
        );
      } catch (e) {
        ErrorHandler.logError(
          'Failed to clean up inconsistent authentication state',
          StackTrace.current,
          context: 'AuthRepository - Background Cleanup Error',
          additionalData: {'error': e.toString()},
        );
      }
    });
  }

  // ==================== Data Cleanup ====================

  /// Clear all authentication data with comprehensive error handling
  ///
  /// Removes all stored tokens, user data, and authentication status
  /// Used during logout and when tokens are invalid
  /// Implements graceful cleanup that continues even if individual operations fail
  Future<void> clearAuthenticationData() async {
    final List<String> failedOperations = [];

    // Define all cleanup operations
    final cleanupOperations = [
      () async {
        await _storageService.remove(StorageConstants.authToken);
        return 'authToken';
      },
      () async {
        await _storageService.remove(StorageConstants.refreshToken);
        return 'refreshToken';
      },
      () async {
        await _storageService.remove(StorageConstants.tokenExpiration);
        return 'tokenExpiration';
      },
      () async {
        await _storageService.remove(StorageConstants.refreshTokenExpiration);
        return 'refreshTokenExpiration';
      },
      () async {
        await _storageService.remove(StorageConstants.userData);
        return 'userData';
      },
      () async {
        await _storageService.remove(StorageConstants.userId);
        return 'userId';
      },
      () async {
        await _storageService.remove(StorageConstants.userName);
        return 'userName';
      },
      () async {
        await _storageService.remove(StorageConstants.userEmail);
        return 'userEmail';
      },
      () async {
        await _storageService.remove(StorageConstants.userPhone);
        return 'userPhone';
      },
      () async {
        await _storageService.remove(StorageConstants.isLoggedIn);
        return 'isLoggedIn';
      },
      () async {
        await _storageService.remove(StorageConstants.lastLoginTime);
        return 'lastLoginTime';
      },
    ];

    // Execute each cleanup operation independently
    for (final operation in cleanupOperations) {
      try {
        final operationName = await operation();
        // Log successful cleanup for debugging
        ErrorHandler.logError(
          'Successfully cleared $operationName',
          StackTrace.current,
          context: 'AuthRepository - Cleanup Success',
          additionalData: {'operation': operationName},
        );
      } catch (e) {
        final operationName = 'unknown_operation';
        failedOperations.add(operationName);

        // Log individual failure but continue with other operations
        ErrorHandler.logError(
          'Failed to clear $operationName during authentication cleanup',
          StackTrace.current,
          context: 'AuthRepository - Cleanup Failure',
          additionalData: {
            'operation': operationName,
            'error': e.toString(),
            'errorType': e.runtimeType.toString(),
          },
        );
      }
    }

    // Log overall cleanup status
    if (failedOperations.isEmpty) {
      ErrorHandler.logError(
        'Authentication data cleanup completed successfully',
        StackTrace.current,
        context: 'AuthRepository - Cleanup Complete',
        additionalData: {'totalOperations': cleanupOperations.length},
      );
    } else {
      ErrorHandler.logError(
        'Authentication data cleanup completed with some failures',
        StackTrace.current,
        context: 'AuthRepository - Cleanup Partial',
        additionalData: {
          'totalOperations': cleanupOperations.length,
          'failedOperations': failedOperations,
          'successfulOperations':
              cleanupOperations.length - failedOperations.length,
        },
      );
    }
  }

  /// Handle 401 error with automatic token refresh and retry
  ///
  /// Attempts to refresh the token and retry the original operation
  /// Returns the result of the retry if successful, throws exception if failed
  Future<T> handleUnauthorizedError<T>(
    Future<T> Function() originalOperation,
    String operationName,
  ) async {
    try {
      // Check if refresh token is available and not expired
      final isRefreshTokenExpired = await this.isRefreshTokenExpired();

      if (isRefreshTokenExpired) {
        // Refresh token is expired, cannot recover
        await clearAuthenticationData();
        throw AuthenticationException(
          'Session expired. Please login again.',
          401,
        );
      }

      // Attempt token refresh
      final refreshResponse = await refreshToken();

      if (refreshResponse.success && refreshResponse.data != null) {
        // Token refresh successful, retry original operation
        ErrorHandler.logError(
          'Token refreshed successfully, retrying $operationName',
          StackTrace.current,
          context: 'AuthRepository - handleUnauthorizedError',
          additionalData: {'operation': operationName},
        );

        return await originalOperation();
      } else {
        // Token refresh failed
        await clearAuthenticationData();
        throw AuthenticationException(
          'Failed to refresh authentication token',
          401,
        );
      }
    } catch (e) {
      // If refresh fails, clear authentication data and rethrow
      if (e is! AuthenticationException) {
        await clearAuthenticationData();
        throw AuthenticationException(
          'Authentication failed: ${e.toString()}',
          401,
        );
      }
      rethrow;
    }
  }

  /// Handle missing tokens gracefully
  ///
  /// Wraps an operation to automatically handle 401 errors with token refresh
  /// Retries the operation once after successful token refresh
  Future<T> executeWithAuth<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    try {
      return await operation();
    } on AuthenticationException catch (e) {
      if (e.code == 401) {
        // Handle 401 error with token refresh and retry
        return await handleUnauthorizedError(operation, operationName);
      }
      rethrow;
    }
  }

  ///
  /// Clears any partial authentication data and ensures clean state
  /// Used when tokens are missing or corrupted
  Future<void> handleMissingTokens() async {
    try {
      await clearAuthenticationData();
    } catch (e) {
      // Graceful handling - don't throw exceptions for cleanup operations
      ErrorHandler.logError(
        'Error handling missing tokens',
        StackTrace.current,
        context: 'AuthRepository - handleMissingTokens',
        additionalData: {'error': e.toString()},
      );
    }
  }

  // ==================== Error Handling ====================

  /// Handle repository-level exceptions
  ///
  /// Wraps data source exceptions with additional context
  /// Provides consistent error handling across repository methods
  Exception _handleRepositoryException(dynamic error, String operation) {
    // Log the error for debugging
    ErrorHandler.logError(
      error,
      StackTrace.current,
      context: 'AuthRepository - $operation',
      additionalData: {'operation': operation},
    );

    if (error is AppException) {
      return error;
    }

    if (error is FormatException) {
      return ParsingException(
        '$operation: Invalid data format - ${error.message}',
      );
    }

    if (error is TypeError) {
      return ParsingException(
        '$operation: Type error in data parsing - $error',
      );
    }

    // Handle storage-specific errors
    if (error.toString().toLowerCase().contains('storage') ||
        error.toString().toLowerCase().contains('cache')) {
      return CacheException('$operation: Storage error - $error');
    }

    // Handle network-specific errors
    if (error.toString().toLowerCase().contains('network') ||
        error.toString().toLowerCase().contains('connection') ||
        error.toString().toLowerCase().contains('timeout')) {
      return NetworkException('$operation: Network error - $error');
    }

    // For any other unexpected errors
    return ServerException('$operation: Unexpected error occurred - $error');
  }

  /// Handle storage operations with proper error handling and recovery
  ///
  /// Wraps storage operations to provide consistent error handling and recovery
  /// Implements graceful degradation for storage failures
  /// Logs errors for debugging while maintaining user experience
  Future<T> _handleStorageOperation<T>(
    Future<T> Function() operation,
    String operationName, {
    T? fallbackValue,
    bool allowRetry = true,
  }) async {
    int retryCount = 0;
    const maxRetries = 2;
    Exception? lastException;

    while (retryCount <= maxRetries) {
      try {
        if (retryCount > 0) {
          ErrorHandler.logError(
            'Retrying storage operation: $operationName (attempt ${retryCount + 1}/${maxRetries + 1})',
            StackTrace.current,
            context: 'AuthRepository - Storage Operation Retry',
            additionalData: {
              'operation': operationName,
              'attempt': retryCount + 1,
              'previousError': lastException?.toString(),
            },
          );
        }

        return await operation();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());

        // Log the storage error with context
        ErrorHandler.logError(
          'Storage operation failed: $operationName',
          StackTrace.current,
          context: 'AuthRepository - Storage Operation',
          additionalData: {
            'operation': operationName,
            'attempt': retryCount + 1,
            'error': e.toString(),
            'errorType': e.runtimeType.toString(),
          },
        );

        // Check if this is a critical storage error that shouldn't be retried
        final errorString = e.toString().toLowerCase();
        final isCriticalError =
            errorString.contains('permission denied') ||
            errorString.contains('access denied') ||
            errorString.contains('read-only') ||
            errorString.contains('corrupted');

        if (isCriticalError || !allowRetry || retryCount >= maxRetries) {
          // For critical errors or after max retries, handle gracefully
          if (fallbackValue != null) {
            ErrorHandler.logError(
              'Using fallback value for failed storage operation: $operationName',
              StackTrace.current,
              context: 'AuthRepository - Storage Fallback',
              additionalData: {
                'operation': operationName,
                'fallbackValue': fallbackValue.toString(),
                'finalError': e.toString(),
              },
            );
            return fallbackValue;
          }

          // If no fallback available, throw a cache exception with enhanced context
          final enhancedMessage = _enhanceStorageErrorMessage(e, operationName);
          throw CacheException(enhancedMessage);
        }

        retryCount++;

        // Brief delay before retry (100ms, 200ms)
        await Future.delayed(Duration(milliseconds: 100 * retryCount));
      }
    }

    // This should never be reached, but included for completeness
    throw CacheException(
      'Storage operation "$operationName" failed after all retries. Last error: ${lastException?.toString()}',
    );
  }

  /// Enhance storage error messages with user-friendly context
  String _enhanceStorageErrorMessage(dynamic error, String operation) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('permission') || errorString.contains('access')) {
      return 'Storage access denied for $operation. Please check app permissions.';
    } else if (errorString.contains('space') || errorString.contains('full')) {
      return 'Insufficient storage space for $operation. Please free up device storage.';
    } else if (errorString.contains('corruption') ||
        errorString.contains('corrupted')) {
      return 'Storage corruption detected during $operation. Data will be reset for security.';
    } else if (errorString.contains('timeout')) {
      return 'Storage operation timed out for $operation. Please try again.';
    } else if (errorString.contains('locked') || errorString.contains('busy')) {
      return 'Storage is temporarily unavailable for $operation. Please try again.';
    }

    return 'Storage error during $operation: ${error.toString()}';
  }
}
