/// Base authentication controller for shared state management
/// Contains shared authentication state and utilities used across auth screens
library;

import 'package:achaytablereservation/core/shared/model/user_model.dart';
import 'package:get/get.dart';
import 'package:achaytablereservation/core/errors/exceptions.dart';
import 'package:achaytablereservation/core/errors/error_handler.dart';
import 'package:achaytablereservation/features/authentication/data/repositories/auth_repository.dart';
import 'package:achaytablereservation/features/authentication/data/models/auth_response_models.dart';

/// Shared authentication state controller
/// Manages global auth state accessible across all auth-related screens
class AuthStateController extends GetxController {
  final AuthRepository authRepository;

  AuthStateController({required this.authRepository});

  // ==================== Global Observable State ====================

  /// Current authenticated user
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  /// Authentication status
  final RxBool isAuthenticated = false.obs;

  /// Initialization status - tracks if authentication state is being determined
  final RxBool isInitializing = false.obs;

  /// Phone number for current authentication flow (shared across screens)
  final RxString currentPhoneNumber = ''.obs;

  /// OTP code received from API (for local verification)
  final RxString receivedOtpCode = ''.obs;

  /// Current flow type
  final RxString currentFlowType = ''.obs;

  /// Last authentication check timestamp
  final Rx<DateTime?> lastAuthCheck = Rx<DateTime?>(null);

  /// Authentication error state
  final RxString authError = ''.obs;

  /// User profile completeness status
  final RxBool isProfileComplete = false.obs;

  /// List of dependent controllers that need to be notified of state changes
  final List<Function()> _stateChangeListeners = [];

  // ==================== Lifecycle ====================

  @override
  void onClose() {
    // Clear all state change listeners when controller is disposed
    _stateChangeListeners.clear();
    super.onClose();
  }

  // ==================== State Change Notification System ====================

  /// Register a listener to be notified when authentication state changes
  /// This allows dependent components to react to authentication state changes
  void addStateChangeListener(Function() listener) {
    if (!_stateChangeListeners.contains(listener)) {
      _stateChangeListeners.add(listener);

      ErrorHandler.logError(
        'State change listener registered',
        StackTrace.current,
        context: 'AuthStateController - Listener Registration',
        additionalData: {'totalListeners': _stateChangeListeners.length},
      );
    }
  }

  /// Remove a state change listener
  void removeStateChangeListener(Function() listener) {
    _stateChangeListeners.remove(listener);
    ErrorHandler.logError(
      'State change listener removed',
      StackTrace.current,
      context: 'AuthStateController - Listener Removal',
      additionalData: {'totalListeners': _stateChangeListeners.length},
    );
  }

  /// Notify all registered listeners of authentication state changes
  /// This ensures all dependent components are synchronized with the current state
  void _notifyStateChangeListeners() {
    ErrorHandler.logError(
      'Notifying state change listeners',
      StackTrace.current,
      context: 'AuthStateController - State Change Notification',
      additionalData: {
        'listenersCount': _stateChangeListeners.length,
        'currentState': isAuthenticated.value
            ? 'authenticated'
            : 'unauthenticated',
        'hasUser': currentUser.value != null,
      },
    );

    for (final listener in _stateChangeListeners) {
      try {
        listener();
      } catch (e) {
        ErrorHandler.logError(
          'Error notifying state change listener',
          StackTrace.current,
          context: 'AuthStateController - Listener Notification Error',
          additionalData: {'error': e.toString()},
        );
      }
    }

    // Also trigger GetX update for any GetBuilder widgets
    update();
  }

  /// Public method to initialize authentication state with comprehensive error handling
  /// Called by SplashScreenController during app startup
  /// Implements graceful error handling and recovery mechanisms
  /// Ensures all reactive state variables are properly updated (Requirement 5.1)
  Future<void> initializeAuthenticationState() async {
    try {
      isInitializing.value = true;
      _clearAuthError(); // Clear any previous errors
      lastAuthCheck.value = DateTime.now(); // Track when check occurred

      ErrorHandler.logError(
        'Starting authentication state initialization',
        StackTrace.current,
        context: 'AuthStateController - Initialization Start',
      );

      await _checkAuthenticationStatus();

      ErrorHandler.logError(
        'Authentication state initialization completed successfully',
        StackTrace.current,
        context: 'AuthStateController - Initialization Success',
        additionalData: {
          'isAuthenticated': isAuthenticated.value,
          'hasUser': currentUser.value != null,
          'isProfileComplete': isProfileComplete.value,
          'lastAuthCheck': lastAuthCheck.value?.toIso8601String(),
        },
      );

      // Notify all dependent components of the final state
      _notifyStateChangeListeners();
    } catch (e) {
      // Handle initialization errors gracefully
      ErrorHandler.logError(
        'Authentication initialization failed - implementing recovery',
        StackTrace.current,
        context: 'AuthStateController - Initialization Error',
        additionalData: {
          'error': e.toString(),
          'errorType': e.runtimeType.toString(),
        },
      );

      await _handleInitializationError(e);
    } finally {
      isInitializing.value = false;

      ErrorHandler.logError(
        'Authentication initialization process completed',
        StackTrace.current,
        context: 'AuthStateController - Initialization Complete',
        additionalData: {
          'finalState': isAuthenticated.value
              ? 'authenticated'
              : 'unauthenticated',
        },
      );
    }
  }

  /// Handle initialization errors with comprehensive recovery
  Future<void> _handleInitializationError(dynamic error) async {
    try {
      // Set error state for UI feedback
      _setAuthError('Initialization failed: ${error.toString()}');

      // Attempt to clean up potentially corrupted data
      await authRepository.handleMissingTokens();

      ErrorHandler.logError(
        'Authentication data cleanup completed during error recovery',
        StackTrace.current,
        context: 'AuthStateController - Error Recovery',
      );
    } catch (cleanupError) {
      ErrorHandler.logError(
        'Failed to clean up authentication data during error recovery',
        StackTrace.current,
        context: 'AuthStateController - Cleanup Error',
        additionalData: {
          'originalError': error.toString(),
          'cleanupError': cleanupError.toString(),
        },
      );
    } finally {
      // Always ensure we end up in a clean unauthenticated state
      _setUnauthenticatedState();
      // Notify listeners of the error state
      _notifyStateChangeListeners();
    }
  }

  /// Check authentication status on app startup with enhanced error handling
  Future<void> _checkAuthenticationStatus() async {
    try {
      ErrorHandler.logError(
        'Checking authentication status from storage',
        StackTrace.current,
        context: 'AuthStateController - Status Check Start',
      );

      final isLoggedIn = await authRepository.isLoggedIn();

      ErrorHandler.logError(
        'Authentication status retrieved from storage',
        StackTrace.current,
        context: 'AuthStateController - Status Retrieved',
        additionalData: {'isLoggedIn': isLoggedIn},
      );

      if (isLoggedIn) {
        await _validateAndRefreshTokens();
      } else {
        ErrorHandler.logError(
          'User not logged in - setting unauthenticated state',
          StackTrace.current,
          context: 'AuthStateController - Not Logged In',
        );
        _setUnauthenticatedState();
      }
    } catch (e) {
      ErrorHandler.logError(
        'Error checking authentication status - handling gracefully',
        StackTrace.current,
        context: 'AuthStateController - Status Check Error',
        additionalData: {
          'error': e.toString(),
          'errorType': e.runtimeType.toString(),
        },
      );

      // Handle storage errors gracefully - default to unauthenticated state
      await _handleStorageError(e);
      rethrow;
    }
  }

  /// Handle storage errors during authentication checks
  Future<void> _handleStorageError(dynamic error) async {
    try {
      ErrorHandler.logError(
        'Handling storage error during authentication check',
        StackTrace.current,
        context: 'AuthStateController - Storage Error Handler',
        additionalData: {'error': error.toString()},
      );

      await authRepository.handleMissingTokens();

      ErrorHandler.logError(
        'Storage error handled successfully',
        StackTrace.current,
        context: 'AuthStateController - Storage Error Resolved',
      );
    } catch (handlingError) {
      ErrorHandler.logError(
        'Failed to handle storage error',
        StackTrace.current,
        context: 'AuthStateController - Storage Error Handling Failed',
        additionalData: {
          'originalError': error.toString(),
          'handlingError': handlingError.toString(),
        },
      );
    } finally {
      _setUnauthenticatedState();
    }
  }

  /// Validate tokens and refresh if needed with comprehensive error handling
  Future<void> _validateAndRefreshTokens() async {
    try {
      ErrorHandler.logError(
        'Starting token validation process',
        StackTrace.current,
        context: 'AuthStateController - Token Validation Start',
      );

      final isAccessTokenExpired = await authRepository.isAccessTokenExpired();

      ErrorHandler.logError(
        'Access token expiration status checked',
        StackTrace.current,
        context: 'AuthStateController - Access Token Check',
        additionalData: {'isExpired': isAccessTokenExpired},
      );

      if (isAccessTokenExpired) {
        final isRefreshTokenExpired = await authRepository
            .isRefreshTokenExpired();

        ErrorHandler.logError(
          'Refresh token expiration status checked',
          StackTrace.current,
          context: 'AuthStateController - Refresh Token Check',
          additionalData: {'isExpired': isRefreshTokenExpired},
        );

        if (!isRefreshTokenExpired) {
          ErrorHandler.logError(
            'Attempting silent token refresh',
            StackTrace.current,
            context: 'AuthStateController - Token Refresh Attempt',
          );
          await _refreshTokenSilently();
        } else {
          ErrorHandler.logError(
            'Both tokens expired - handling token expiration',
            StackTrace.current,
            context: 'AuthStateController - Tokens Expired',
          );
          await _handleTokenExpiration();
        }
      } else {
        ErrorHandler.logError(
          'Access token valid - loading user data',
          StackTrace.current,
          context: 'AuthStateController - Token Valid',
        );
        await _loadUserData();
      }
    } catch (e) {
      ErrorHandler.logError(
        'Token validation failed - handling as token expiration',
        StackTrace.current,
        context: 'AuthStateController - Token Validation Error',
        additionalData: {
          'error': e.toString(),
          'errorType': e.runtimeType.toString(),
        },
      );

      // Handle token validation errors
      await _handleTokenExpiration();
      rethrow;
    }
  }

  /// Load user data from storage or server with enhanced error handling
  /// Ensures all user-related state is properly populated (Requirement 5.2)
  Future<void> _loadUserData() async {
    try {
      ErrorHandler.logError(
        'Loading user data from storage',
        StackTrace.current,
        context: 'AuthStateController - Load User Data Start',
      );

      final storedUser = await authRepository.getStoredUser();

      if (storedUser != null) {
        ErrorHandler.logError(
          'User data loaded from storage successfully',
          StackTrace.current,
          context: 'AuthStateController - Storage User Data Success',
          additionalData: {
            'userId': storedUser.id,
            'userEmail': storedUser.email,
          },
        );

        // Set authenticated state and populate all user-related reactive variables
        setAuthenticatedState(storedUser);

        // Refresh user data in background without blocking initialization
        ErrorHandler.logError(
          'Starting background user data refresh',
          StackTrace.current,
          context: 'AuthStateController - Background Refresh Start',
        );
        _refreshUserDataInBackground();
      } else {
        ErrorHandler.logError(
          'No stored user data found - fetching from server',
          StackTrace.current,
          context: 'AuthStateController - No Stored User',
        );
        await _fetchCurrentUser();
      }
    } catch (e) {
      ErrorHandler.logError(
        'User data loading failed - handling as token expiration',
        StackTrace.current,
        context: 'AuthStateController - User Data Load Error',
        additionalData: {
          'error': e.toString(),
          'errorType': e.runtimeType.toString(),
        },
      );

      // If user data loading fails, handle as token expiration
      await _handleTokenExpiration();
      rethrow;
    }
  }

  /// Refresh user data in background with error handling
  /// Updates user state without blocking main authentication flow
  Future<void> _refreshUserDataInBackground() async {
    try {
      ErrorHandler.logError(
        'Background user data refresh started',
        StackTrace.current,
        context: 'AuthStateController - Background Refresh',
      );

      final response = await authRepository.getCurrentUser();
      if (response.success && response.data != null) {
        // Update user data and related state
        currentUser.value = response.data;
        _updateUserRelatedState(response.data!);

        ErrorHandler.logError(
          'Background user data refresh completed successfully',
          StackTrace.current,
          context: 'AuthStateController - Background Refresh Success',
          additionalData: {
            'userId': response.data!.id,
            'userEmail': response.data!.email,
          },
        );

        // Notify listeners of the updated user data
        _notifyStateChangeListeners();
      } else {
        ErrorHandler.logError(
          'Background user data refresh failed - response unsuccessful',
          StackTrace.current,
          context: 'AuthStateController - Background Refresh Failed',
          additionalData: {
            'success': response.success,
            'message': response.message,
          },
        );
      }
    } catch (e) {
      // Silently fail background refresh - don't affect main flow
      ErrorHandler.logError(
        'Background user data refresh failed with exception',
        StackTrace.current,
        context: 'AuthStateController - Background Refresh Exception',
        additionalData: {
          'error': e.toString(),
          'errorType': e.runtimeType.toString(),
        },
      );
    }
  }

  /// Fetch current user from server with enhanced error handling
  Future<void> _fetchCurrentUser() async {
    try {
      ErrorHandler.logError(
        'Fetching current user from server',
        StackTrace.current,
        context: 'AuthStateController - Fetch User Start',
      );

      final response = await authRepository.getCurrentUser();

      if (response.success && response.data != null) {
        ErrorHandler.logError(
          'User data fetched from server successfully',
          StackTrace.current,
          context: 'AuthStateController - Fetch User Success',
          additionalData: {
            'userId': response.data!.id,
            'userEmail': response.data!.email,
          },
        );

        setAuthenticatedState(response.data!);
      } else {
        ErrorHandler.logError(
          'Failed to fetch user data from server - response unsuccessful',
          StackTrace.current,
          context: 'AuthStateController - Fetch User Failed',
          additionalData: {
            'success': response.success,
            'message': response.message,
          },
        );

        throw AuthenticationException(
          'Failed to fetch user data: ${response.message}',
        );
      }
    } catch (e) {
      ErrorHandler.logError(
        'Failed to fetch user from server - handling as token expiration',
        StackTrace.current,
        context: 'AuthStateController - Fetch User Error',
        additionalData: {
          'error': e.toString(),
          'errorType': e.runtimeType.toString(),
        },
      );

      // Failed to fetch user - handle as token expiration
      await _handleTokenExpiration();
      rethrow;
    }
  }

  /// Refresh token silently with comprehensive error handling
  Future<void> _refreshTokenSilently() async {
    try {
      ErrorHandler.logError(
        'Starting silent token refresh',
        StackTrace.current,
        context: 'AuthStateController - Silent Refresh Start',
      );

      final response = await authRepository.refreshToken();

      if (response.success && response.data != null) {
        ErrorHandler.logError(
          'Silent token refresh completed successfully',
          StackTrace.current,
          context: 'AuthStateController - Silent Refresh Success',
          additionalData: {
            'userId': response.data!.user.id,
            'userEmail': response.data!.user.email,
          },
        );

        setAuthenticatedState(response.data!.user);
      } else {
        ErrorHandler.logError(
          'Silent token refresh failed - response unsuccessful',
          StackTrace.current,
          context: 'AuthStateController - Silent Refresh Failed',
          additionalData: {
            'success': response.success,
            'message': response.message,
          },
        );

        await _handleTokenExpiration();
      }
    } catch (e) {
      ErrorHandler.logError(
        'Silent token refresh failed with exception - handling as expiration',
        StackTrace.current,
        context: 'AuthStateController - Silent Refresh Exception',
        additionalData: {
          'error': e.toString(),
          'errorType': e.runtimeType.toString(),
        },
      );

      // Token refresh failed - handle as expiration
      await _handleTokenExpiration();
      rethrow;
    }
  }

  /// Handle token expiration with comprehensive cleanup and logging
  Future<void> _handleTokenExpiration() async {
    ErrorHandler.logError(
      'Handling token expiration - starting cleanup',
      StackTrace.current,
      context: 'AuthStateController - Token Expiration Start',
    );

    try {
      await authRepository.clearAuthenticationData();

      ErrorHandler.logError(
        'Authentication data cleared successfully during token expiration',
        StackTrace.current,
        context: 'AuthStateController - Token Expiration Cleanup Success',
      );
    } catch (e) {
      // Log error but continue with state cleanup
      ErrorHandler.logError(
        'Error clearing authentication data during token expiration',
        StackTrace.current,
        context: 'AuthStateController - Token Expiration Cleanup Error',
        additionalData: {
          'error': e.toString(),
          'errorType': e.runtimeType.toString(),
        },
      );
    } finally {
      _setUnauthenticatedState();

      ErrorHandler.logError(
        'Token expiration handling completed - user set to unauthenticated',
        StackTrace.current,
        context: 'AuthStateController - Token Expiration Complete',
      );
    }
  }

  // ==================== Public State Methods ====================

  /// Set authenticated state with enhanced logging and comprehensive state updates
  /// Ensures all reactive state variables are properly synchronized (Requirement 5.3)
  void setAuthenticatedState(UserModel user) {
    ErrorHandler.logError(
      'Setting authenticated state',
      StackTrace.current,
      context: 'AuthStateController - Set Authenticated',
      additionalData: {
        'userId': user.id,
        'userEmail': user.email,
        'previousState': isAuthenticated.value
            ? 'authenticated'
            : 'unauthenticated',
      },
    );

    // Update all authentication-related state variables
    currentUser.value = user;
    isAuthenticated.value = true;
    _clearAuthError(); // Clear any previous errors
    lastAuthCheck.value = DateTime.now();

    // Update user-related state
    _updateUserRelatedState(user);

    // Clear flow-specific data since authentication is complete
    clearFlowData();

    // Notify all dependent components of state change (Requirement 5.3)
    _notifyStateChangeListeners();

    ErrorHandler.logError(
      'Authenticated state set successfully',
      StackTrace.current,
      context: 'AuthStateController - Authenticated State Complete',
    );
  }

  /// Update user-related reactive state variables
  /// Ensures comprehensive state synchronization when user data changes
  void _updateUserRelatedState(UserModel user) {
    // Update profile completeness based on user data
    isProfileComplete.value = _checkProfileCompleteness(user);

    ErrorHandler.logError(
      'User-related state updated',
      StackTrace.current,
      context: 'AuthStateController - User State Update',
      additionalData: {
        'isProfileComplete': isProfileComplete.value,
        'userId': user.id,
      },
    );
  }

  /// Check if user profile is complete
  /// This can be extended based on business requirements
  bool _checkProfileCompleteness(UserModel user) {
    // Basic completeness check - can be enhanced based on requirements
    return (user.email?.isNotEmpty ?? false) && user.fullName.isNotEmpty;
  }

  /// Set unauthenticated state with enhanced logging and immediate cleanup
  /// Implements immediate state cleanup as required (Requirement 5.4)
  void _setUnauthenticatedState() {
    ErrorHandler.logError(
      'Setting unauthenticated state',
      StackTrace.current,
      context: 'AuthStateController - Set Unauthenticated',
      additionalData: {
        'previousState': isAuthenticated.value
            ? 'authenticated'
            : 'unauthenticated',
        'hadUser': currentUser.value != null,
      },
    );

    // Immediately clear all user-related state (Requirement 5.4)
    currentUser.value = null;
    isAuthenticated.value = false;
    isProfileComplete.value = false;
    lastAuthCheck.value = DateTime.now();

    // Clear flow-specific data
    clearFlowData();

    // Notify all dependent components of state change (Requirement 5.3)
    _notifyStateChangeListeners();

    ErrorHandler.logError(
      'Unauthenticated state set successfully',
      StackTrace.current,
      context: 'AuthStateController - Unauthenticated State Complete',
    );
  }

  /// Clear flow-specific data
  void clearFlowData() {
    currentPhoneNumber.value = '';
    receivedOtpCode.value = '';
    currentFlowType.value = '';
  }

  /// Set authentication error state
  void _setAuthError(String error) {
    authError.value = error;
    ErrorHandler.logError(
      'Authentication error set',
      StackTrace.current,
      context: 'AuthStateController - Error State',
      additionalData: {'error': error},
    );
  }

  /// Clear authentication error state
  void _clearAuthError() {
    authError.value = '';
  }

  /// Set phone number for current flow
  void setPhoneNumber(String phoneNumber) {
    currentPhoneNumber.value = phoneNumber;
  }

  /// Set received OTP code for local verification
  void setReceivedOtpCode(String otp) {
    receivedOtpCode.value = otp;
  }

  /// Set current flow type
  void setFlowType(String flowType) {
    currentFlowType.value = flowType;
  }

  /// Verify OTP locally
  bool verifyOtpLocally(String enteredOtp) {
    return receivedOtpCode.value.isNotEmpty &&
        receivedOtpCode.value == enteredOtp.trim();
  }

  /// Logout with comprehensive error handling and immediate state cleanup
  /// Implements immediate state cleanup as required (Requirement 5.4)
  Future<void> logout() async {
    ErrorHandler.logError(
      'Starting logout process',
      StackTrace.current,
      context: 'AuthStateController - Logout Start',
      additionalData: {
        'currentState': isAuthenticated.value
            ? 'authenticated'
            : 'unauthenticated',
        'hasUser': currentUser.value != null,
      },
    );

    try {
      await authRepository.logout();

      ErrorHandler.logError(
        'Server logout completed successfully',
        StackTrace.current,
        context: 'AuthStateController - Server Logout Success',
      );
    } catch (e) {
      // Continue with local cleanup even if server logout fails
      ErrorHandler.logError(
        'Server logout failed - continuing with local cleanup',
        StackTrace.current,
        context: 'AuthStateController - Server Logout Error',
        additionalData: {
          'error': e.toString(),
          'errorType': e.runtimeType.toString(),
        },
      );
    } finally {
      // Immediately clear all user-related state (Requirement 5.4)
      _setUnauthenticatedState();

      ErrorHandler.logError(
        'Logout process completed',
        StackTrace.current,
        context: 'AuthStateController - Logout Complete',
      );
    }
  }

  // ==================== Getters ====================
  bool get isUserAuthenticated => isAuthenticated.value;
  UserModel? get user => currentUser.value;
  String get phoneNumber => currentPhoneNumber.value;
  String get flowType => currentFlowType.value;
  bool get isInitializingAuth => isInitializing.value;
  DateTime? get lastAuthenticationCheck => lastAuthCheck.value;
  String get authenticationError => authError.value;
  bool get hasAuthError => authError.value.isNotEmpty;
  bool get isUserProfileComplete => isProfileComplete.value;
  // ==================== Public Utility Methods ====================

  /// Force refresh of authentication state
  /// Useful for manual state synchronization when needed
  Future<void> refreshAuthenticationState() async {
    if (!isInitializing.value) {
      await initializeAuthenticationState();
    }
  }

  /// Get comprehensive authentication status for debugging
  Map<String, dynamic> getAuthenticationStatus() {
    return {
      'isAuthenticated': isAuthenticated.value,
      'isInitializing': isInitializing.value,
      'hasUser': currentUser.value != null,
      'userId': currentUser.value?.id,
      'userEmail': currentUser.value?.email,
      'isProfileComplete': isProfileComplete.value,
      'lastAuthCheck': lastAuthCheck.value?.toIso8601String(),
      'hasError': hasAuthError,
      'error': authError.value,
      'currentFlow': currentFlowType.value,
      'phoneNumber': currentPhoneNumber.value,
      'listenersCount': _stateChangeListeners.length,
    };
  }
}
