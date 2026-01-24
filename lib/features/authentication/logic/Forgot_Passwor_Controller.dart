/// ForgotPassword controller for password reset initiation
/// Handles phone number validation and OTP request
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

/// ForgotPassword screen controller
/// Manages password reset request and OTP sending
class ForgotPasswordController extends GetxController {
  final AuthRepository _authRepository;
  final AuthStateController _authStateController;

  ForgotPasswordController({
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
  final Rx<ForgotPasswordNavigationEvent?> navigationEvent =
      Rx<ForgotPasswordNavigationEvent?>(null);

  // ==================== Public Methods ====================

  /// Request password reset OTP
  Future<void> requestPasswordReset(String phoneNumber) async {
    // Clear previous state
    _clearErrors();

    // Validate phone number
    final phoneError = AuthValidators.validatePasswordResetPhoneNumber(
      phoneNumber,
    );
    if (phoneError != null) {
      errorMessage.value = phoneError;
      return;
    }

    try {
      isLoading.value = true;

      final request = ForgotPasswordRequest(phoneNumber: phoneNumber.trim());

      final response = await _authRepository.forgotPassword(request);

      if (response.success && response.data != null) {
        final trimmedPhone = phoneNumber.trim();
        _authStateController.setPhoneNumber(trimmedPhone);
        _authStateController.setFlowType('password_reset');

        if (response.data!.requiresOtp) {
          // Store OTP for local verification
          if (response.data!.otp != null && response.data!.otp!.isNotEmpty) {
            _authStateController.setReceivedOtpCode(response.data!.otp!);
          }
          // Navigate to OTP screen first (NOT reset password screen)
          navigationEvent.value = ForgotPasswordNavigationEvent.navigateToOtp;
        } else {
          errorMessage.value = 'Password reset not available';
        }
      } else {
        _handleApiError(response);
      }
    } catch (e) {
      _handleException(e, 'Password reset request failed');
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
        'password_reset_request',
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
      context: 'ForgotPasswordController',
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

/// Navigation events for forgot password screen
enum ForgotPasswordNavigationEvent {
  /// Navigate to OTP verification screen (for local OTP verification)
  navigateToOtp,
}
