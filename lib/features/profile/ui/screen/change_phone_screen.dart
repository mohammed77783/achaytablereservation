import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/features/profile/logic/controller/update_password_controller.dart';
import 'package:achaytablereservation/features/profile/ui/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Update Password Screen
/// Allows user to change their password
class UpdatePasswordScreen extends GetView<UpdatePasswordController> {
  const UpdatePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تغيير كلمة المرور')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(LightTheme.spacingMedium),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card
                Container(
                  padding: const EdgeInsets.all(LightTheme.spacingMedium),
                  decoration: BoxDecoration(
                    color: LightTheme.infoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      LightTheme.borderRadius,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: LightTheme.infoColor,
                      ),
                      const SizedBox(width: LightTheme.spacingSmall),
                      Expanded(
                        child: Text(
                          'بعد تغيير كلمة المرور، سيتم تسجيل خروجك تلقائياً',
                          style: TextStyle(
                            color: LightTheme.infoColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: LightTheme.spacingLarge),

                // Old Password field
                Obx(
                  () => CustomTextField(
                    controller: controller.oldPasswordController,
                    label: 'كلمة المرور الحالية',
                    hint: 'أدخل كلمة المرور الحالية',
                    prefixIcon: Icons.lock_outline,
                    obscureText: controller.obscureOldPassword.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureOldPassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: controller.toggleOldPasswordVisibility,
                    ),
                    validator: controller.validateOldPassword,
                    textInputAction: TextInputAction.next,
                  ),
                ),

                const SizedBox(height: LightTheme.spacingMedium),

                // New Password field
                Obx(
                  () => CustomTextField(
                    controller: controller.newPasswordController,
                    label: 'كلمة المرور الجديدة',
                    hint: 'أدخل كلمة المرور الجديدة',
                    prefixIcon: Icons.lock_outline,
                    obscureText: controller.obscureNewPassword.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureNewPassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: controller.toggleNewPasswordVisibility,
                    ),
                    validator: controller.validateNewPassword,
                    textInputAction: TextInputAction.next,
                  ),
                ),

                const SizedBox(height: LightTheme.spacingMedium),

                // Confirm Password field
                Obx(
                  () => CustomTextField(
                    controller: controller.confirmPasswordController,
                    label: 'تأكيد كلمة المرور',
                    hint: 'أعد إدخال كلمة المرور الجديدة',
                    prefixIcon: Icons.lock_outline,
                    obscureText: controller.obscureConfirmPassword.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureConfirmPassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                    validator: controller.validateConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => controller.updatePassword(),
                  ),
                ),

                const SizedBox(height: LightTheme.spacingMedium),

                // Password requirements
                _buildPasswordRequirements(),

                const SizedBox(height: LightTheme.spacingMedium),

                // Error message
                Obx(() {
                  if (controller.errorMessage.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    padding: const EdgeInsets.all(LightTheme.spacingMedium),
                    decoration: BoxDecoration(
                      color: LightTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        LightTheme.borderRadius,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: LightTheme.errorColor,
                        ),
                        const SizedBox(width: LightTheme.spacingSmall),
                        Expanded(
                          child: Text(
                            controller.errorMessage.value,
                            style: const TextStyle(
                              color: LightTheme.errorColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Success message
                Obx(() {
                  if (controller.successMessage.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    padding: const EdgeInsets.all(LightTheme.spacingMedium),
                    decoration: BoxDecoration(
                      color: LightTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        LightTheme.borderRadius,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: LightTheme.successColor,
                        ),
                        const SizedBox(width: LightTheme.spacingSmall),
                        Expanded(
                          child: Text(
                            controller.successMessage.value,
                            style: const TextStyle(
                              color: LightTheme.successColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: LightTheme.spacingLarge),

                // Update Button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.updatePassword,
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('تغيير كلمة المرور'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(LightTheme.spacingMedium),
      decoration: BoxDecoration(
        color: LightTheme.surfaceGray,
        borderRadius: BorderRadius.circular(LightTheme.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'متطلبات كلمة المرور:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: LightTheme.textPrimary,
            ),
          ),
          const SizedBox(height: LightTheme.spacingSmall),
          _buildRequirementItem('8 أحرف على الأقل'),
          _buildRequirementItem('أقل من 100 حرف'),
          _buildRequirementItem('مختلفة عن كلمة المرور الحالية'),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: LightTheme.textSecondary,
          ),
          const SizedBox(width: LightTheme.spacingSmall),
          Text(
            text,
            style: TextStyle(fontSize: 13, color: LightTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
