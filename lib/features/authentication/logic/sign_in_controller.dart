/// SignUp controller for registration screen state management
/// Handles registration form validation and API calls
library;

import 'package:achaytablereservation/core/shared/model/api_response.dart';
import 'package:achaytablereservation/features/authentication/logic/authstate_Controller.dart';
import 'package:get/get.dart';
import 'package:achaytablereservation/core/errors/exceptions.dart';
import 'package:achaytablereservation/core/errors/error_handler.dart';
import 'package:achaytablereservation/features/authentication/data/repositories/auth_repository.dart';
import 'package:achaytablereservation/features/authentication/data/models/auth_request_models.dart';
import 'package:achaytablereservation/features/authentication/logic/auth_validators.dart';

/// SignUp screen controller
/// Manages registration form state, validation, and API calls
class SignUpController extends GetxController {
  final AuthRepository _authRepository;
  final AuthStateController _authStateController;

  SignUpController({
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
  final Rx<SignUpNavigationEvent?> navigationEvent = Rx<SignUpNavigationEvent?>(
    null,
  );

  // ==================== Public Methods ====================

  /// Register new user
  Future<void> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? email,
    required String password,
    required String confirmPassword,
  }) async {
    // Clear previous state
    _clearErrors();

    // Validate form
    final validationErrors = AuthValidators.validateRegistrationForm(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (validationErrors.isNotEmpty) {
      formErrors.addAll(validationErrors);
      // Trigger form validation to show errors
      update();
      return;
    }

    try {
      isLoading.value = true;

      final request = RegisterRequest(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        phoneNumber: phoneNumber.trim(),
        email: email?.trim(),
        password: password,
        confirmPassword: confirmPassword,
      );

      final response = await _authRepository.register(request);

      if (response.success && response.data != null) {
        final trimmedPhone = phoneNumber.trim();
        _authStateController.setPhoneNumber(trimmedPhone);
        _authStateController.setFlowType('registration');

        if (response.data!.requiresOtp) {
          // Store OTP for local verification if provided
          if (response.data!.otp != null && response.data!.otp!.isNotEmpty) {
            _authStateController.setReceivedOtpCode(response.data!.otp!);
          }
          navigationEvent.value = SignUpNavigationEvent.navigateToOtp;
        } else {
          // Registration complete without OTP
          navigationEvent.value = SignUpNavigationEvent.navigateToHome;
        }
      } else {
        _handleApiError(response);
      }
    } catch (e) {
      _handleException(e, 'Registration failed');
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear field-specific error when user starts typing
  void clearFieldError(String fieldKey) {
    if (formErrors.containsKey(fieldKey)) {
      formErrors.remove(fieldKey);
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
        'registration',
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
      context: 'SignUpController',
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

/// Navigation events for signup screen
enum SignUpNavigationEvent { navigateToOtp, navigateToHome }
