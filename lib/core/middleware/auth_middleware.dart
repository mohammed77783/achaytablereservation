import 'package:achaytablereservation/app/routes/app_routes.dart';
import 'package:achaytablereservation/features/authentication/logic/authstate_Controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Authmiddeleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Note: redirect method cannot be async in GetX middleware
    // We need to use a different approach for async operations
    return null;
  }

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    try {
      final authController = Get.find<AuthStateController>();

      // Wait for authentication state to be determined if still initializing
      if (authController.isInitializingAuth) {
        await _waitForAuthInitialization(authController);
      }

      return _handleRouteRedirection(route, authController);
    } catch (e) {
      // If there's an error accessing auth controller, handle gracefully
      return _handleMiddlewareError(route, e);
    }
  }

  /// Wait for authentication initialization to complete
  Future<void> _waitForAuthInitialization(
    AuthStateController controller,
  ) async {
    const maxWaitTime = Duration(seconds: 10); // Prevent infinite waiting
    const checkInterval = Duration(milliseconds: 100);
    final startTime = DateTime.now();

    while (controller.isInitializingAuth) {
      // Check if we've exceeded maximum wait time
      if (DateTime.now().difference(startTime) > maxWaitTime) {
        break;
      }

      await Future.delayed(checkInterval);
    }
  }

  /// Handle route redirection based on authentication status
  GetNavConfig? _handleRouteRedirection(
    GetNavConfig route,
    AuthStateController authController,
  ) {
    final currentRoute = route.uri.path;
    final isAuthenticated = authController.isUserAuthenticated;

    // Define protected routes that require authentication
    final protectedRoutes = [
      AppRoutes.MAIN_NAVIGATION,
      AppRoutes.HOME,
      AppRoutes.PROFILE,
      AppRoutes.SETTINGS,
      AppRoutes.Dashbordpage,
      AppRoutes.EDIT_PROFILE,
    ];

    // Define guest-only routes (should redirect to home if authenticated)
    final guestOnlyRoutes = [
      AppRoutes.LOGIN,
      AppRoutes.REGISTER,
      AppRoutes.FORGOT_PASSWORD,
      AppRoutes.RESET_PASSWORD,
    ];

    try {
      // If user is authenticated and trying to access guest-only pages, redirect to main navigation
      if (isAuthenticated && guestOnlyRoutes.contains(currentRoute)) {
        return GetNavConfig.fromRoute(AppRoutes.MAIN_NAVIGATION);
      }

      // If user is not authenticated and trying to access protected pages, redirect to login
      if (!isAuthenticated && protectedRoutes.contains(currentRoute)) {
        return GetNavConfig.fromRoute(AppRoutes.LOGIN);
      }

      // Allow navigation to proceed
      return null;
    } catch (e) {
      // Handle redirection errors gracefully
      return _handleRedirectionError(currentRoute, isAuthenticated, e);
    }
  }

  /// Handle middleware errors gracefully
  GetNavConfig? _handleMiddlewareError(GetNavConfig route, dynamic error) {
    // Log error for debugging (in production, use proper logging)
    print('Auth middleware error: $error');

    // For critical routes, provide safe fallback
    final currentRoute = route.uri.path;

    // If trying to access main navigation or protected routes and there's an error,
    // redirect to login as a safe fallback
    final criticalRoutes = [
      AppRoutes.MAIN_NAVIGATION,
      AppRoutes.HOME,
      AppRoutes.PROFILE,
      AppRoutes.SETTINGS,
      AppRoutes.Dashbordpage,
    ];

    if (criticalRoutes.contains(currentRoute)) {
      return GetNavConfig.fromRoute(AppRoutes.LOGIN);
    }

    // For other routes, allow navigation to proceed
    return null;
  }

  /// Handle redirection errors gracefully
  GetNavConfig? _handleRedirectionError(
    String currentRoute,
    bool isAuthenticated,
    dynamic error,
  ) {
    // Log error for debugging (in production, use proper logging)
    print('Route redirection error: $error');

    // Provide safe fallback based on authentication status
    if (isAuthenticated) {
      // If authenticated but redirection failed, try to go to main navigation
      return currentRoute != AppRoutes.MAIN_NAVIGATION
          ? GetNavConfig.fromRoute(AppRoutes.MAIN_NAVIGATION)
          : null;
    } else {
      // If not authenticated but redirection failed, try to go to login
      return currentRoute != AppRoutes.LOGIN
          ? GetNavConfig.fromRoute(AppRoutes.LOGIN)
          : null;
    }
  }
}
