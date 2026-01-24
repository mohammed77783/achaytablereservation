/// OTP controller for OTP verification screen
/// Handles OTP input, local verification, and API verification
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

/// OTP screen controller
/// Manages OTP verification for different flows (login, registration, password reset)
class OtpController extends GetxController {
  final AuthRepository _authRepository;
  final AuthStateController _authStateController;

  OtpController({
    required AuthRepository authRepository,
    required AuthStateController authStateController,
  }) : _authRepository = authRepository,
       _authStateController = authStateController;

  // ==================== Observable State ====================

  /// Loading state
  final RxBool isLoading = false.obs;

  /// Error message
  final RxString errorMessage = ''.obs;

  /// Navigation event
  final Rx<OtpNavigationEvent?> navigationEvent = Rx<OtpNavigationEvent?>(null);

  /// Resend countdown
  final RxInt resendCountdown = 0.obs;

  /// Can resend OTP
  final RxBool canResend = true.obs;

  // ==================== Getters ====================

  /// Get phone number from shared state
  String get phoneNumber => _authStateController.phoneNumber;

  /// Get flow type from shared state
  String get flowType => _authStateController.flowType;

  // ==================== Lifecycle ====================

  @override
  void onInit() {
    super.onInit();
    startResendCountdown();
  }

  // ==================== Public Methods ====================

  /// Verify OTP code
  /// For password reset: verifies locally then navigates to reset password screen
  /// For login/registration: calls API for verification
  Future<void> verifyOtp(String otpCode) async {
    // Clear previous error
    errorMessage.value = '';

    // Validate OTP format
    final otpError = AuthValidators.validateOtpCode(otpCode);
    if (otpError != null) {
      errorMessage.value = otpError;
      return;
    }

    if (phoneNumber.isEmpty) {
      errorMessage.value =
          'Phone number not found. Please restart the process.';
      return;
    }

    // For password reset flow: verify OTP locally first
    if (flowType == 'password_reset') {
      await _verifyOtpLocally(otpCode);
      return;
    }

    // For login/registration: verify via API
    await _verifyOtpViaApi(otpCode);
  }

  /// Start resend countdown
  void startResendCountdown() {
    resendCountdown.value = 60;
    canResend.value = false;

    _runCountdown();
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    if (!canResend.value || phoneNumber.isEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Call appropriate resend API based on flow
      switch (flowType) {
        case 'password_reset':
          final request = ForgotPasswordRequest(phoneNumber: phoneNumber);
          final response = await _authRepository.forgotPassword(request);

          if (response.success && response.data != null) {
            if (response.data!.otp != null && response.data!.otp!.isNotEmpty) {
              _authStateController.setReceivedOtpCode(response.data!.otp!);
            }
          }
          break;

        case 'login':
        case 'registration':
          // For login/registration, we typically can't resend without re-initiating
          // the flow, so we'll show a message
          errorMessage.value =
              'Please restart the ${flowType == "login" ? "login" : "registration"} process to get a new code.';
          return;
      }

      // Restart countdown
      startResendCountdown();
    } catch (e) {
      _handleException(e, 'Failed to resend OTP');
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear error
  void clearError() {
    errorMessage.value = '';
  }

  /// Reset navigation event
  void resetNavigationEvent() {
    navigationEvent.value = null;
  }

  // ==================== Private Methods ====================

  /// Verify OTP locally (for password reset flow)
  Future<void> _verifyOtpLocally(String otpCode) async {
    isLoading.value = true;

    try {
      // Simulate slight delay for better UX
      await Future.delayed(const Duration(milliseconds: 300));

      // Verify locally using stored OTP
      final isValid = _authStateController.verifyOtpLocally(otpCode);

      if (isValid) {
        // Store verified OTP for reset password screen
        _authStateController.setReceivedOtpCode(otpCode);
        // Navigate to reset password screen
        navigationEvent.value = OtpNavigationEvent.navigateToResetPassword;
      } else {
        errorMessage.value = 'Invalid verification code. Please try again.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify OTP via API (for login/registration)
  Future<void> _verifyOtpViaApi(String otpCode) async {
    try {
      isLoading.value = true;

      final request = VerifyOtpRequest(
        phoneNumber: phoneNumber,
        otpCode: otpCode.trim(),
      );

      final response = await _authRepository.verifyOtp(
        request,
        flowType == "login" ? "login" : "register",
      );

      if (response.success && response.data != null) {
        _authStateController.setAuthenticatedState(response.data!.user);

        navigationEvent.value = OtpNavigationEvent.navigateToHome;
        // switch (flowType) {
        //   case 'login':
        //     navigationEvent.value = OtpNavigationEvent.navigateToHome;
        //     break;
        //   case 'registration':
        //     navigationEvent.value = OtpNavigationEvent.navigateToHome;
        //     break;
        // }
      } else {
        _handleApiError(response);
      }
    } catch (e) {
      _handleException(e, 'OTP verification failed');
    } finally {
      isLoading.value = false;
    }
  }

  /// Run countdown timer
  Future<void> _runCountdown() async {
    while (resendCountdown.value > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      }
    }
    canResend.value = true;
  }

  void _handleApiError(ApiResponse response) {
    if (response.errors != null && response.errors!.isNotEmpty) {
      errorMessage.value = response.errors!.first;
    } else {
      errorMessage.value = response.message.isNotEmpty
          ? response.message
          : 'Verification failed';
    }
  }

  void _handleException(dynamic exception, String defaultMessage) {
    ErrorHandler.logException(
      exception is Exception ? exception : Exception(exception.toString()),
      context: 'OtpController',
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
    errorMessage.value = '';
    super.onClose();
  }
}

/// Navigation events for OTP screen
enum OtpNavigationEvent {
  /// Navigate to home screen (after successful login/registration)
  navigateToHome,

  /// Navigate to reset password screen (after local OTP verification)
  navigateToResetPassword,

  /// Navigate to login screen
  navigateToLogin,
}
