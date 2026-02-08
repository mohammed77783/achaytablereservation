import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:achaytablereservation/core/utils/responsive_utils.dart';
import 'package:achaytablereservation/core/utils/validators.dart';
import 'package:achaytablereservation/features/authentication/logic/login_controller.dart';
import 'package:achaytablereservation/app/routes/app_routes.dart';

import 'package:achaytablereservation/app/themes/light_theme.dart';

/// Login screen for user authentication
/// Uses StatefulWidget with GetX controller for state management
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _obscurePassword = true.obs;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    // Set up navigation listener
    ever(
      controller.navigationEvent,
      (event) => _handleNavigation(event, controller),
    );

    return Scaffold(
      backgroundColor: LightTheme.backgroundColor,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.spacing(24.0)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.spacing(40)),
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: context.spacing(80),
                  width: context.spacing(80),
                ),
                SizedBox(height: context.spacing(24)),
                Text(
                  'welcome_back'.tr,
                  style: TextStyle(
                    fontSize: context.fontSize(28),
                    fontWeight: FontWeight.bold,
                    color: LightTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.spacing(8)),
                Text(
                  'login_to_account'.tr,
                  style: TextStyle(
                    fontSize: context.fontSize(14),
                    color: LightTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.spacing(40)),

                // Phone number field
                Obx(
                  () => TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      fontSize: context.fontSize(14),
                      color: LightTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'phone_number'.tr,
                      hintText: '05xxxxxxxx',
                      labelStyle: TextStyle(
                        fontSize: context.fontSize(14),
                        color: LightTheme.textSecondary,
                      ),
                      hintStyle: TextStyle(
                        fontSize: context.fontSize(14),
                        color: LightTheme.textHint,
                      ),
                      prefixIcon: Icon(
                        Icons.phone,
                        color: LightTheme.accentColor,
                        size: context.spacing(20),
                      ),
                      filled: true,
                      fillColor: LightTheme.surfaceColor,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: context.spacing(16),
                        vertical: context.spacing(16),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.spacing(12),
                        ),
                        borderSide: BorderSide(color: LightTheme.inputBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.spacing(12),
                        ),
                        borderSide: BorderSide(color: LightTheme.inputBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.spacing(12),
                        ),
                        borderSide: const BorderSide(
                          color: LightTheme.inputFocusBorder,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.spacing(12),
                        ),
                        borderSide: const BorderSide(
                          color: LightTheme.errorColor,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.spacing(12),
                        ),
                        borderSide: const BorderSide(
                          color: LightTheme.errorColor,
                          width: 2,
                        ),
                      ),
                      errorText: controller.formErrors['phoneNumber'],
                      errorStyle: TextStyle(fontSize: context.fontSize(12)),
                    ),
                    validator: (value) =>
                        Validators.validateSaudiPhoneNumber(value),
                    onChanged: (_) => controller.clearErrors(),
                  ),
                ),
                SizedBox(height: context.spacing(16)),

                // Password field
                Obx(
                  () => TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword.value,
                    style: TextStyle(
                      fontSize: context.fontSize(14),
                      color: LightTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'password'.tr,
                      hintText: 'enter_password'.tr,
                      labelStyle: TextStyle(
                        fontSize: context.fontSize(14),
                        color: LightTheme.textSecondary,
                      ),
                      hintStyle: TextStyle(
                        fontSize: context.fontSize(14),
                        color: LightTheme.textHint,
                      ),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: LightTheme.accentColor,
                        size: context.spacing(20),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: LightTheme.textSecondary,
                          size: context.spacing(20),
                        ),
                        onPressed: () {
                          _obscurePassword.value = !_obscurePassword.value;
                        },
                      ),
                      filled: true,
                      fillColor: LightTheme.surfaceColor,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: context.spacing(16),
                        vertical: context.spacing(16),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.spacing(12),
                        ),
                        borderSide: BorderSide(color: LightTheme.inputBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.spacing(12),
                        ),
                        borderSide: BorderSide(color: LightTheme.inputBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.spacing(12),
                        ),
                        borderSide: const BorderSide(
                          color: LightTheme.inputFocusBorder,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.spacing(12),
                        ),
                        borderSide: const BorderSide(
                          color: LightTheme.errorColor,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.spacing(12),
                        ),
                        borderSide: const BorderSide(
                          color: LightTheme.errorColor,
                          width: 2,
                        ),
                      ),
                      errorText: controller.formErrors['password'],
                      errorStyle: TextStyle(fontSize: context.fontSize(12)),
                    ),
                    validator: (value) => Validators.validateRequired(
                      value,
                      fieldName: 'password'.tr,
                    ),
                    onChanged: (_) => controller.clearErrors(),
                  ),
                ),
                SizedBox(height: context.spacing(24)),

                // Error message
                Obx(() {
                  if (controller.errorMessage.value.isNotEmpty) {
                    return Container(
                      padding: EdgeInsets.all(context.spacing(12)),
                      margin: EdgeInsets.only(bottom: context.spacing(16)),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(
                          context.spacing(12),
                        ),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade700,
                            size: context.spacing(20),
                          ),
                          SizedBox(width: context.spacing(12)),
                          Expanded(
                            child: Text(
                              controller.errorMessage.value,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: context.fontSize(14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Login button
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => _handleLogin(controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LightTheme.primaryColor,
                      foregroundColor: LightTheme.textOnPrimary,
                      disabledBackgroundColor: LightTheme.primaryColor
                          .withValues(alpha: 0.6),
                      padding: EdgeInsets.symmetric(
                        vertical: context.spacing(16),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          context.spacing(12),
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            height: context.spacing(20),
                            width: context.spacing(20),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                LightTheme.textOnPrimary,
                              ),
                            ),
                          )
                        : Text(
                            'sign_in'.tr,
                            style: TextStyle(
                              fontSize: context.fontSize(16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: context.spacing(16)),

                // Forgot password link
                Center(
                  child: GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.FORGOT_PASSWORD),
                    child: Text(
                      'forgot_password'.tr,
                      style: TextStyle(
                        color: LightTheme.accentColor,
                        fontSize: context.fontSize(14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.spacing(24)),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'dont_have_account'.tr,
                      style: TextStyle(
                        color: LightTheme.textSecondary,
                        fontSize: context.fontSize(14),
                      ),
                    ),
                    SizedBox(width: context.spacing(4)),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.REGISTER),
                      child: Text(
                        'sign_up'.tr,
                        style: TextStyle(
                          color: LightTheme.accentColor,
                          fontSize: context.fontSize(14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(
    LoginNavigationEvent? event,
    LoginController controller,
  ) {
    if (event == null) return;
    controller.resetNavigationEvent();

    switch (event) {
      case LoginNavigationEvent.navigateToOtp:
        Get.toNamed(
          AppRoutes.OTP,
          arguments: {
            'phoneNumber': _phoneController.text.trim(),
            'flow': 'login',
          },
        );
        break;
      case LoginNavigationEvent.navigateToHome:
        Get.offAllNamed(AppRoutes.MAIN_NAVIGATION);
        break;
    }
  }

  Future<void> _handleLogin(LoginController controller) async {
    if (_formKey.currentState?.validate() ?? false) {
      await controller.login(
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
      );
    }
  }
}
