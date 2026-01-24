import 'package:achaytablereservation/features/profile/data/repositories/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:achaytablereservation/core/base/base_controller.dart';

/// Controller for Change Phone Number screen
class ChangePhoneController extends BaseController {
  final ProfileRepository _profileRepository;

  ChangePhoneController({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository;

  // Text Controllers
  late TextEditingController phoneController;
  late TextEditingController otpController;

  // Form keys
  final phoneFormKey = GlobalKey<FormState>();
  final otpFormKey = GlobalKey<FormState>();

  // Observable states
  final RxString successMessage = ''.obs;

  // OTP state
  final RxBool otpSent = false.obs;
  final RxInt resendCountdown = 0.obs;

  // Phone number for verification
  String _pendingPhoneNumber = '';

  @override
  void onInit() {
    super.onInit();
    phoneController = TextEditingController();
    otpController = TextEditingController();
  }

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  /// Validate phone number (Saudi format)
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الجوال مطلوب';
    }

    // Remove spaces and dashes
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-]'), '');

    // Saudi phone regex: 05xxxxxxxx, 5xxxxxxxx, 9665xxxxxxxx, 966xxxxxxxxx
    final saudiPhoneRegex = RegExp(r'^(05|5|9665|966)[0-9]{8}$');

    if (!saudiPhoneRegex.hasMatch(cleanPhone)) {
      return 'رقم الجوال غير صحيح';
    }

    return null;
  }

  /// Validate OTP code
  String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'رمز التحقق مطلوب';
    }
    if (value.length != 6) {
      return 'رمز التحقق يجب أن يكون 6 أرقام';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'رمز التحقق يجب أن يحتوي على أرقام فقط';
    }
    return null;
  }

  /// Clear success message
  void clearSuccessMessage() {
    successMessage.value = '';
  }

  /// Request phone change (send OTP)
  Future<void> requestPhoneChange() async {
    if (!phoneFormKey.currentState!.validate()) return;

    showLoading();
    successMessage.value = '';

    // Clean and format phone number
    _pendingPhoneNumber = _formatPhoneNumber(phoneController.text);

    final result = await _profileRepository.changePhoneNumber(
      newPhoneNumber: _pendingPhoneNumber,
    );

    result.fold(
      (failure) {
        showErrorFromFailure(failure);
      },
      (response) {
        hideLoading();
        if (response.requiresOtp) {
          otpSent.value = true;
          successMessage.value = 'تم إرسال رمز التحقق إلى رقم الجوال الجديد';
          _startResendCountdown();
        }
      },
    );
  }

  /// Verify phone change with OTP
  Future<void> verifyPhoneChange() async {
    if (!otpFormKey.currentState!.validate()) return;

    showLoading();
    successMessage.value = '';

    final result = await _profileRepository.verifyPhoneChange(
      newPhoneNumber: _pendingPhoneNumber,
      otpCode: otpController.text,
    );

    result.fold(
      (failure) {
        showErrorFromFailure(failure);
      },
      (updatedProfile) {
        hideLoading();
        successMessage.value = 'تم تحديث رقم الجوال بنجاح';

        // Go back and refresh profile
        Future.delayed(const Duration(seconds: 1), () {
          Get.back(result: true);
        });
      },
    );
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    if (resendCountdown.value > 0) return;

    await requestPhoneChange();
  }

  /// Start resend countdown
  void _startResendCountdown() {
    resendCountdown.value = 60;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
        return true;
      }
      return false;
    });
  }

  /// Go back to phone input
  void goBackToPhoneInput() {
    otpSent.value = false;
    otpController.clear();
    clearError();
    successMessage.value = '';
  }

  /// Format phone number to standard format
  String _formatPhoneNumber(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');

    // If starts with 05, convert to 9665
    if (cleanPhone.startsWith('05')) {
      cleanPhone = '966${cleanPhone.substring(1)}';
    }
    // If starts with 5, convert to 9665
    else if (cleanPhone.startsWith('5') && cleanPhone.length == 9) {
      cleanPhone = '966$cleanPhone';
    }
    return cleanPhone;
  }
}
