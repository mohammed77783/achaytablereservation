import 'package:get/get.dart';
import 'package:achaytablereservation/features/authentication/logic/authstate_Controller.dart';
import 'package:achaytablereservation/app/routes/app_routes.dart';
import 'package:achaytablereservation/core/errors/exceptions.dart';

class SplashScreenController extends GetxController {
  // Dependency injection
  late final AuthStateController _authStateController;

  // ==================== Observable States ====================

  /// Indicates if the app is currently initializing
  final RxBool isInitializing = true.obs;

  /// Current initialization status message
  final RxString initializationStatus = 'Welcome to TeaBake'.obs;

  /// Indicates if an error occurred during initialization
  final RxBool hasError = false.obs;

  /// Error message if initialization fails
  final RxString errorMessage = ''.obs;

  // ==================== Lifecycle ====================

  @override
  void onInit() {
    super.onInit();
    _authStateController = Get.find<AuthStateController>();
    _initializeApp();
  }

  // ==================== Public Methods ====================

  /// Initialize the application with authentication checks
  Future<void> _initializeApp() async {
    try {
      isInitializing.value = true;
      hasError.value = false;
      initializationStatus.value = 'Welcome to TeaBake';

      // Wait for authentication state to be determined
      await _initializeAuthenticationState();

      // Navigate based on authentication status (with 5-second splash display)
      await _navigateBasedOnAuthStatus();
    } catch (e) {
      _handleInitializationError(e);
    }
  }

  /// Initialize authentication state through AuthStateController
  Future<void> _initializeAuthenticationState() async {
    try {
      initializationStatus.value = 'Preparing your experience...';

      // Use the new public initialization method
      await _authStateController.initializeAuthenticationState();

      initializationStatus.value = 'Almost ready...';
    } catch (e) {
      initializationStatus.value = 'Loading...';
      rethrow;
    }
  }

  /// Navigate to appropriate screen based on authentication status
  /// Shows splash screen for 5 seconds regardless of login status
  Future<void> _navigateBasedOnAuthStatus() async {
    try {
      initializationStatus.value = 'Loading...';

      // Show splash screen for 5 seconds regardless of authentication status
      await Future.delayed(const Duration(seconds: 5));

      initializationStatus.value = 'Navigating...';

      if (_authStateController.isAuthenticated.value) {
        // User is authenticated, navigate to home
        await _navigateToHome();
      } else {
        // User is not authenticated, navigate to login
        await _navigateToLogin();
      }
    } catch (e) {
      initializationStatus.value = 'Navigation failed';
      await _handleNavigationError(e);
    }
  }

  /// Navigate to home screen with error handling
  Future<void> _navigateToHome() async {
    try {
      initializationStatus.value = 'Loading home screen...';
      Get.offAllNamed(AppRoutes.MAIN_NAVIGATION);
    } catch (e) {
      initializationStatus.value = 'Failed to load home screen';
      throw NavigationException('Failed to navigate to home: ${e.toString()}');
    }
  }

  /// Navigate to login screen with error handling
  Future<void> _navigateToLogin() async {
    try {
      initializationStatus.value = 'Loading login screen...';
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      initializationStatus.value = 'Failed to load login screen';
      throw NavigationException('Failed to navigate to login: ${e.toString()}');
    }
  }

  /// Handle navigation-specific errors
  Future<void> _handleNavigationError(dynamic error) async {
    hasError.value = true;
    errorMessage.value = 'Navigation error: ${error.toString()}';
    initializationStatus.value = 'Navigation failed';

    // Fallback navigation to login after a delay
    await Future.delayed(const Duration(seconds: 1));
    try {
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (fallbackError) {
      // If even fallback navigation fails, log the error
      errorMessage.value =
          'Critical navigation failure: ${fallbackError.toString()}';
    }
  }

  /// Handle initialization errors gracefully
  void _handleInitializationError(dynamic error) {
    hasError.value = true;

    // Provide specific error messages based on error type
    if (error is NavigationException) {
      errorMessage.value = 'Navigation failed: ${error.message}';
      initializationStatus.value = 'Navigation error';
    } else if (error is AuthenticationException) {
      errorMessage.value = 'Authentication failed: ${error.message}';
      initializationStatus.value = 'Authentication error';
    } else {
      errorMessage.value = 'Initialization failed: ${error.toString()}';
      initializationStatus.value = 'Initialization error';
    }

    // Default to login screen on any error after a delay
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        await _navigateToLogin();
      } catch (fallbackError) {
        // If even fallback navigation fails, update error message
        errorMessage.value =
            'Critical error: Unable to navigate to login screen';
      }
    });
  }

  /// Retry initialization (can be called from UI)
  Future<void> retryInitialization() async {
    await _initializeApp();
  }

  // ==================== Getters ====================

  /// Get current initialization progress
  bool get isAppInitializing => isInitializing.value;

  /// Get current status message
  String get currentStatus => initializationStatus.value;

  /// Check if there's an error
  bool get hasInitializationError => hasError.value;

  /// Get error message
  String get currentErrorMessage => errorMessage.value;

  // ==================== Navigation Utilities ====================

  /// Check if navigation is safe to perform
  bool get canNavigate => !isInitializing.value && !hasError.value;

  /// Get the target route based on current authentication status
  String get targetRoute {
    if (_authStateController.isAuthenticated.value) {
      return AppRoutes.MAIN_NAVIGATION;
    } else {
      return AppRoutes.LOGIN;
    }
  }

  /// Force navigation to a specific route (for manual override)
  Future<void> forceNavigateTo(String route) async {
    try {
      initializationStatus.value = 'Navigating to $route...';
      Get.offAllNamed(route);
    } catch (e) {
      await _handleNavigationError(e);
    }
  }
}
