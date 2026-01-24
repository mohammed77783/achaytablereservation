/// ResetPassword controller for new password entry
/// Handles password reset with pre-verified OTP
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
import 'package:achaytablereservation/app/routes/app_routes.dart';
// import 'package:achaytablereservation/features/authentication/logic/base_auth_controller.dart';

/// ResetPassword screen controller
/// Manages new password entry after OTP verification
class ResetPasswordController extends GetxController {
  final AuthRepository _authRepository;
  final AuthStateController _authStateController;

  ResetPasswordController({
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

  // ==================== Getters ====================

  /// Get phone number from shared state
  String get phoneNumber => _authStateController.phoneNumber;

  /// Get verified OTP code from shared state
  String get verifiedOtpCode => _authStateController.receivedOtpCode.value;

  // ==================== Public Methods ====================

  /// Reset password with new password
  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Clear previous state
    _clearErrors();

    // Validate that we have required data
    if (phoneNumber.isEmpty) {
      errorMessage.value =
          'Phone number not found. Please restart password reset.';
      return;
    }

    if (verifiedOtpCode.isEmpty) {
      errorMessage.value =
          'Verification code not found. Please restart password reset.';
      return;
    }

    // Validate password form (without phone and OTP since they're pre-verified)
    final passwordError = AuthValidators.validatePasswordResetNewPassword(
      newPassword,
    );
    if (passwordError != null) {
      formErrors['newPassword'] = passwordError;
    }

    final confirmError = AuthValidators.validatePasswordConfirmation(
      newPassword,
      confirmPassword,
    );
    if (confirmError != null) {
      formErrors['confirmPassword'] = confirmError;
    }

    if (formErrors.isNotEmpty) {
      return;
    }

    try {
      isLoading.value = true;

      final request = ResetPasswordRequest(
        phoneNumber: phoneNumber,
        otpCode: verifiedOtpCode,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final response = await _authRepository.resetPassword(request);

      if (response.success) {
        // Clear flow data
        _authStateController.clearFlowData();
        // Handle success navigation directly
        _handleSuccessNavigation();
      } else {
        _handleApiError(response);
      }
    } catch (e) {
      _handleException(e, 'Password reset failed');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get password strength feedback for real-time UI updates
  List<String> getPasswordStrengthFeedback(String password) {
    final feedback = <String>[];

    if (password.length < 8) {
      feedback.add('At least 8 characters');
    }
    if (!password.contains(RegExp(r'[A-Za-z]'))) {
      feedback.add('One letter is required');
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      feedback.add('One number');
    }

    return feedback;
  }

  /// Check if password is strong
  bool isPasswordStrong(String password) {
    return getPasswordStrengthFeedback(password).isEmpty;
  }

  /// Clear all errors
  void clearErrors() {
    _clearErrors();
  }

  // ==================== Private Methods ====================

  void _handleSuccessNavigation() {
    // Show success message
    Get.snackbar(
      'success'.tr,
      "password_reset_success_message".tr,
      backgroundColor: Get.theme.primaryColor.withValues(alpha: 0.1),
      colorText: Get.theme.primaryColor,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );

    // Navigate to login
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  void _clearErrors() {
    errorMessage.value = '';
    formErrors.clear();
  }

  void _handleApiError(ApiResponse response) {
    if (response.errors != null && response.errors!.isNotEmpty) {
      final fieldErrors = ErrorHandler.mapValidationErrors(
        response.errors!,
        'password_reset',
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
      context: 'ResetPasswordController',
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
