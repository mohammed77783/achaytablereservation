/// Authentication bindings for dependency injection
/// Registers all auth-related controllers and dependencies
library;

import 'package:achaytablereservation/features/authentication/logic/Forgot_Passwor_Controller.dart';
import 'package:achaytablereservation/features/authentication/logic/Reset_password_controller.dart'
    show ResetPasswordController;
import 'package:achaytablereservation/features/authentication/logic/authstate_Controller.dart';
import 'package:achaytablereservation/features/authentication/logic/sign_in_controller.dart';
import 'package:get/get.dart';
import 'package:achaytablereservation/features/authentication/data/datasources/auth_datasource.dart';
import 'package:achaytablereservation/features/authentication/data/repositories/auth_repository.dart';
import 'package:achaytablereservation/features/authentication/logic/login_controller.dart';
import 'package:achaytablereservation/features/authentication/logic/otp_controller.dart';
import 'package:achaytablereservation/core/network/api_client.dart';
import 'package:achaytablereservation/core/services/storage_service.dart';

/// Login page binding
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Register dependencies in correct order

    // 1. Register AuthDataSource first
    Get.lazyPut<AuthDataSource>(
      () => AuthDataSource(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    // 2. Register AuthRepository second
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(
        dataSource: Get.find<AuthDataSource>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    // 3. Register AuthStateController third (as permanent, shared across all auth screens)
    Get.put<AuthStateController>(
      AuthStateController(authRepository: Get.find<AuthRepository>()),
      permanent: true,
    );

    // 4. Register LoginController last
    Get.lazyPut<LoginController>(
      () => LoginController(
        authRepository: Get.find<AuthRepository>(),
        authStateController: Get.find<AuthStateController>(),
      ),
    );
  }
}

/// SignUp page binding
class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure core dependencies are available
    if (!Get.isRegistered<AuthRepository>()) {
      // Register AuthDataSource
      Get.lazyPut<AuthDataSource>(
        () => AuthDataSource(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );

      // Register AuthRepository
      Get.lazyPut<AuthRepository>(
        () => AuthRepository(
          dataSource: Get.find<AuthDataSource>(),
          storageService: Get.find<StorageService>(),
        ),
        fenix: true,
      );
    }

    // Ensure AuthStateController is available
    if (!Get.isRegistered<AuthStateController>()) {
      Get.put<AuthStateController>(
        AuthStateController(authRepository: Get.find<AuthRepository>()),
        permanent: true,
      );
    }

    Get.lazyPut<SignUpController>(
      () => SignUpController(
        authRepository: Get.find<AuthRepository>(),
        authStateController: Get.find<AuthStateController>(),
      ),
    );
  }
}

/// Forgot password page binding
class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure core dependencies are available
    if (!Get.isRegistered<AuthRepository>()) {
      // Register AuthDataSource
      Get.lazyPut<AuthDataSource>(
        () => AuthDataSource(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );

      // Register AuthRepository
      Get.lazyPut<AuthRepository>(
        () => AuthRepository(
          dataSource: Get.find<AuthDataSource>(),
          storageService: Get.find<StorageService>(),
        ),
        fenix: true,
      );
    }

    // Ensure AuthStateController is available
    if (!Get.isRegistered<AuthStateController>()) {
      Get.put<AuthStateController>(
        AuthStateController(authRepository: Get.find<AuthRepository>()),
        permanent: true,
      );
    }

    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(
        authRepository: Get.find<AuthRepository>(),
        authStateController: Get.find<AuthStateController>(),
      ),
    );
  }
}

/// OTP page binding
class OtpBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure core dependencies are available
    if (!Get.isRegistered<AuthRepository>()) {
      // Register AuthDataSource
      Get.lazyPut<AuthDataSource>(
        () => AuthDataSource(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );

      // Register AuthRepository
      Get.lazyPut<AuthRepository>(
        () => AuthRepository(
          dataSource: Get.find<AuthDataSource>(),
          storageService: Get.find<StorageService>(),
        ),
        fenix: true,
      );
    }

    // Ensure AuthStateController is available
    if (!Get.isRegistered<AuthStateController>()) {
      Get.put<AuthStateController>(
        AuthStateController(authRepository: Get.find<AuthRepository>()),
        permanent: true,
      );
    }

    Get.lazyPut<OtpController>(
      () => OtpController(
        authRepository: Get.find<AuthRepository>(),
        authStateController: Get.find<AuthStateController>(),
      ),
    );
  }
}

/// Reset password page binding
class ResetPasswordBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure core dependencies are available
    if (!Get.isRegistered<AuthRepository>()) {
      // Register AuthDataSource
      Get.lazyPut<AuthDataSource>(
        () => AuthDataSource(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );

      // Register AuthRepository
      Get.lazyPut<AuthRepository>(
        () => AuthRepository(
          dataSource: Get.find<AuthDataSource>(),
          storageService: Get.find<StorageService>(),
        ),
        fenix: true,
      );
    }

    // Ensure AuthStateController is available
    if (!Get.isRegistered<AuthStateController>()) {
      Get.put<AuthStateController>(
        AuthStateController(authRepository: Get.find<AuthRepository>()),
        permanent: true,
      );
    }

    Get.lazyPut<ResetPasswordController>(
      () => ResetPasswordController(
        authRepository: Get.find<AuthRepository>(),
        authStateController: Get.find<AuthStateController>(),
      ),
    );
  }
}

/// Combined binding for all auth screens
/// Use this if you want to initialize all controllers at once
class AllAuthBindings extends Bindings {
  @override
  void dependencies() {
    // Core dependencies
    Get.lazyPut<AuthDataSource>(
      () => AuthDataSource(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<AuthRepository>(
      () => AuthRepository(
        dataSource: Get.find<AuthDataSource>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    // Shared state controller
    Get.put<AuthStateController>(
      AuthStateController(authRepository: Get.find<AuthRepository>()),
      permanent: true,
    );

    // Screen-specific controllers
    Get.lazyPut<LoginController>(
      () => LoginController(
        authRepository: Get.find<AuthRepository>(),
        authStateController: Get.find<AuthStateController>(),
      ),
    );

    Get.lazyPut<SignUpController>(
      () => SignUpController(
        authRepository: Get.find<AuthRepository>(),
        authStateController: Get.find<AuthStateController>(),
      ),
    );

    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(
        authRepository: Get.find<AuthRepository>(),
        authStateController: Get.find<AuthStateController>(),
      ),
    );

    Get.lazyPut<OtpController>(
      () => OtpController(
        authRepository: Get.find<AuthRepository>(),
        authStateController: Get.find<AuthStateController>(),
      ),
    );

    Get.lazyPut<ResetPasswordController>(
      () => ResetPasswordController(
        authRepository: Get.find<AuthRepository>(),
        authStateController: Get.find<AuthStateController>(),
      ),
    );
  }
}
