import 'package:achaytablereservation/features/profile/data/repositories/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:achaytablereservation/core/base/base_controller.dart';

/// Controller for Update Password screen
class UpdatePasswordController extends BaseController {
  final ProfileRepository _profileRepository;

  UpdatePasswordController({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository;

  // Text Controllers
  late TextEditingController oldPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;
  // Form key
  final formKey = GlobalKey<FormState>();
  // Observable states
  final RxString successMessage = ''.obs;
  // Password visibility
  final RxBool obscureOldPassword = true.obs;
  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  @override
  void onInit() {
    super.onInit();
    oldPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  /// Toggle old password visibility
  void toggleOldPasswordVisibility() {
    obscureOldPassword.value = !obscureOldPassword.value;
  }

  /// Toggle new password visibility
  void toggleNewPasswordVisibility() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  /// Validate old password
  String? validateOldPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور الحالية مطلوبة';
    }
    return null;
  }

  /// Validate new password
  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور الجديدة مطلوبة';
    }
    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    if (value.length > 100) {
      return 'كلمة المرور يجب أن تكون أقل من 100 حرف';
    }
    if (value == oldPasswordController.text) {
      return 'كلمة المرور الجديدة يجب أن تختلف عن الحالية';
    }
    return null;
  }

  /// Validate confirm password
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    if (value != newPasswordController.text) {
      return 'كلمة المرور غير متطابقة';
    }
    return null;
  }

  /// Clear success message
  void clearSuccessMessage() {
    successMessage.value = '';
  }

  /// Update password
  Future<void> updatePassword() async {
    if (!formKey.currentState!.validate()) return;

    showLoading();
    successMessage.value = '';

    final result = await _profileRepository.updatePassword(
      oldPassword: oldPasswordController.text,
      newPassword: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
    );

    result.fold(
      (failure) {
        showErrorFromFailure(failure);
      },
      (response) {
        hideLoading();
        if (response.passwordUpdated) {
          successMessage.value =
              'تم تحديث كلمة المرور بنجاح. يرجى تسجيل الدخول مرة أخرى';

          // Navigate to login after success
          Future.delayed(const Duration(seconds: 2), () {
            Get.offAllNamed('/login');
          });
        }
      },
    );
  }
}
