import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/features/profile/logic/controller/update_profile_controller.dart';
import 'package:achaytablereservation/features/profile/ui/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Update Profile Screen
/// Allows user to update their profile information
class UpdateProfileScreen extends GetView<UpdateProfileController> {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تعديل الملف الشخصي')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(LightTheme.spacingMedium),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username field
                CustomTextField(
                  controller: controller.usernameController,
                  label: 'اسم المستخدم',
                  hint: 'أدخل اسم المستخدم',
                  prefixIcon: Icons.person_outline,
                  validator: controller.validateUsername,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: LightTheme.spacingMedium),

                // Email field
                CustomTextField(
                  controller: controller.emailController,
                  label: 'البريد الإلكتروني',
                  hint: 'أدخل البريد الإلكتروني',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: controller.validateEmail,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: LightTheme.spacingMedium),

                // First Name field
                CustomTextField(
                  controller: controller.firstNameController,
                  label: 'الاسم الأول',
                  hint: 'أدخل الاسم الأول',
                  prefixIcon: Icons.badge_outlined,
                  validator: controller.validateFirstName,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: LightTheme.spacingMedium),

                // Last Name field
                CustomTextField(
                  controller: controller.lastNameController,
                  label: 'الاسم الأخير',
                  hint: 'أدخل الاسم الأخير',
                  prefixIcon: Icons.badge_outlined,
                  validator: controller.validateLastName,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => controller.updateProfile(),
                ),

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

                // Save Button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.updateProfile,
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text('حفظ التغييرات'),
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
}
