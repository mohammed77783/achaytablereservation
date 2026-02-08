import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/features/profile/logic/controller/change_phone_controller.dart';
import 'package:achaytablereservation/features/profile/ui/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Change Phone Number Screen
/// Allows user to change their phone number with OTP verification
class ChangePhoneScreen extends GetView<ChangePhoneController> {
  const ChangePhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تغيير رقم الجوال'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (controller.otpSent.value) {
                controller.goBackToPhoneInput();
              } else {
                Get.back();
              }
            },
          ),
        ),
        body: Obx(() {
          if (controller.otpSent.value) {
            return _buildOtpVerification(context);
          }
          return _buildPhoneInput(context);
        }),
      ),
    );
  }

  Widget _buildPhoneInput(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LightTheme.spacingMedium),
      child: Form(
        key: controller.phoneFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(LightTheme.spacingMedium),
              decoration: BoxDecoration(
                color: LightTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(LightTheme.borderRadius),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: LightTheme.infoColor),
                  const SizedBox(width: LightTheme.spacingSmall),
                  Expanded(
                    child: Text(
                      'سيتم إرسال رمز تحقق إلى رقم الجوال الجديد',
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

            // Phone field
            CustomTextField(
              controller: controller.phoneController,
              label: 'رقم الجوال الجديد',
              hint: '05xxxxxxxx',
              prefixIcon: Icons.phone_android,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              validator: controller.validatePhone,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => controller.requestPhoneChange(),
            ),

            const SizedBox(height: LightTheme.spacingSmall),

            // Phone format hint
            Text(
              'الصيغة المدعومة: 05xxxxxxxx أو 5xxxxxxxx',
              style: TextStyle(fontSize: 12, color: LightTheme.textHint),
            ),

            const SizedBox(height: LightTheme.spacingMedium),

            // Error message
            _buildErrorMessage(),

            // Success message
            _buildSuccessMessage(),

            const SizedBox(height: LightTheme.spacingLarge),

            // Send OTP Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.requestPhoneChange,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text('إرسال رمز التحقق'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpVerification(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LightTheme.spacingMedium),
      child: Form(
        key: controller.otpFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // OTP Sent Info
            Container(
              padding: const EdgeInsets.all(LightTheme.spacingMedium),
              decoration: BoxDecoration(
                color: LightTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(LightTheme.borderRadius),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: LightTheme.successColor,
                  ),
                  const SizedBox(width: LightTheme.spacingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تم إرسال رمز التحقق',
                          style: TextStyle(
                            color: LightTheme.successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'إلى الرقم: ${controller.phoneController.text}',
                          style: TextStyle(
                            color: LightTheme.successColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: LightTheme.spacingLarge),

            // OTP field
            CustomTextField(
              controller: controller.otpController,
              label: 'رمز التحقق',
              hint: 'أدخل الرمز المكون من 6 أرقام',
              prefixIcon: Icons.pin,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: controller.validateOtp,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => controller.verifyPhoneChange(),
            ),

            const SizedBox(height: LightTheme.spacingMedium),

            // Resend OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'لم يصلك الرمز؟',
                  style: TextStyle(color: LightTheme.textSecondary),
                ),
                Obx(() {
                  if (controller.resendCountdown.value > 0) {
                    return Text(
                      ' إعادة الإرسال بعد ${controller.resendCountdown.value} ثانية',
                      style: TextStyle(color: LightTheme.textHint),
                    );
                  }
                  return TextButton(
                    onPressed: controller.resendOtp,
                    child: const Text('إعادة الإرسال'),
                  );
                }),
              ],
            ),

            const SizedBox(height: LightTheme.spacingMedium),

            // Error message
            _buildErrorMessage(),

            // Success message
            _buildSuccessMessage(),

            const SizedBox(height: LightTheme.spacingLarge),

            // Verify Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.verifyPhoneChange,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text('تأكيد'),
                ),
              ),
            ),

            const SizedBox(height: LightTheme.spacingMedium),

            // Change Number Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: controller.goBackToPhoneInput,
                child: const Text('تغيير الرقم'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Obx(() {
      if (controller.errorMessage.isEmpty) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: LightTheme.spacingMedium),
        child: Container(
          padding: const EdgeInsets.all(LightTheme.spacingMedium),
          decoration: BoxDecoration(
            color: LightTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(LightTheme.borderRadius),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: LightTheme.errorColor),
              const SizedBox(width: LightTheme.spacingSmall),
              Expanded(
                child: Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: LightTheme.errorColor),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSuccessMessage() {
    return Obx(() {
      if (controller.successMessage.isEmpty) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: LightTheme.spacingMedium),
        child: Container(
          padding: const EdgeInsets.all(LightTheme.spacingMedium),
          decoration: BoxDecoration(
            color: LightTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(LightTheme.borderRadius),
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
                  style: const TextStyle(color: LightTheme.successColor),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
