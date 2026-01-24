/// Login controller for login screen state management
/// Handles login form validation and API calls
library;

import 'package:achaytablereservation/core/shared/model/api_response.dart';
import 'package:achaytablereservation/features/authentication/logic/authstate_Controller.dart';
import 'package:get/get.dart';
import 'package:achaytablereservation/core/errors/exceptions.dart';
import 'package:achaytablereservation/core/errors/error_handler.dart';
import 'package:achaytablereservation/features/authentication/data/repositories/auth_repository.dart';
import 'package:achaytablereservation/features/authentication/data/models/auth_request_models.dart';
import 'package:achaytablereservation/features/authentication/data/models/auth_response_models.dart';
import 'package:achaytablereservation/features/authentication/logic/auth_validators.dart';

/// Login screen controller
/// Manages login form state, validation, and authentication
class LoginController extends GetxController {
  final AuthRepository _authRepository;
  final AuthStateController _authStateController;

  LoginController({
    required AuthRepository authRepository,
    required AuthStateController authStateController,
  }) : _authRepository = authRepository,
       _authStateController = authStateController;

  // ==================== Observable State ====================

  /// Loading state
  final RxBool isLoading = false.obs;

  /// Error message
  final RxString errorMessage = ''.obs;

  /// Form validation errors
  final RxMap<String, String> formErrors = <String, String>{}.obs;

  /// Navigation event
  final Rx<LoginNavigationEvent?> navigationEvent = Rx<LoginNavigationEvent?>(
    null,
  );

  // ==================== Public Methods ====================

  /// Login with phone number and password
  Future<void> login({
    required String phoneNumber,
    required String password,
  }) async {
    // Clear previous state
    _clearErrors();

    // Validate form
    final validationErrors = AuthValidators.validateLoginForm(
      phoneNumber: phoneNumber,
      password: password,
    );

    if (validationErrors.isNotEmpty) {
      formErrors.addAll(validationErrors);
      return;
    }

    try {
      isLoading.value = true;

      final request = LoginRequest(
        phoneNumber: phoneNumber.trim(),
        password: password,
      );

      final response = await _authRepository.login(request);

      if (response.success) {
        final trimmedPhone = phoneNumber.trim();
        _authStateController.setPhoneNumber(trimmedPhone);
        _authStateController.setFlowType('login');

        if (response.data is OtpResponse) {
          final otpResponse = response.data as OtpResponse;
          if (otpResponse.requiresOtp) {
            // Store OTP for local verification if provided
            if (otpResponse.otp != null && otpResponse.otp!.isNotEmpty) {
              _authStateController.setReceivedOtpCode(otpResponse.otp!);
            }
            navigationEvent.value = LoginNavigationEvent.navigateToOtp;
          } else {
            errorMessage.value = 'Unexpected response from server';
          }
        } else if (response.data is AuthResponse) {
          final authResponse = response.data as AuthResponse;
          _authStateController.setAuthenticatedState(authResponse.user);
          navigationEvent.value = LoginNavigationEvent.navigateToHome;
        } else {
          errorMessage.value = 'Unexpected response format';
        }
      } else {
        _handleApiError(response);
      }
    } catch (e) {
      _handleException(e, 'Login failed');
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear all errors
  void clearErrors() {
    _clearErrors();
  }

  /// Reset navigation event
  void resetNavigationEvent() {
    navigationEvent.value = null;
  }

  // ==================== Private Methods ====================

  void _clearErrors() {
    errorMessage.value = '';
    formErrors.clear();
  }

  void _handleApiError(ApiResponse response) {
    if (response.errors != null && response.errors!.isNotEmpty) {
      final fieldErrors = ErrorHandler.mapValidationErrors(
        response.errors!,
        'login',
      );
      formErrors.addAll(fieldErrors);

      if (fieldErrors.isEmpty && response.errors!.isNotEmpty) {
        errorMessage.value = response.errors!.first;
      }
    } else {
      errorMessage.value = response.message.isNotEmpty
          ? response.message
          : 'An error occurred';
    }
  }

  void _handleException(dynamic exception, String defaultMessage) {
    ErrorHandler.logException(
      exception is Exception ? exception : Exception(exception.toString()),
      context: 'LoginController',
      additionalData: {'operation': defaultMessage},
    );

    String errorMsg;

    if (exception is AppException) {
      final failure = ErrorHandler.exceptionToFailure(exception);
      errorMsg = ErrorHandler.getErrorMessage(failure);
    } else {
      errorMsg = defaultMessage;
    }

    errorMessage.value = errorMsg;
  }

  @override
  void onClose() {
    _clearErrors();
    super.onClose();
  }
}

/// Navigation events for login screen
enum LoginNavigationEvent { navigateToOtp, navigateToHome }
