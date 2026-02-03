import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:achaytablereservation/core/utils/responsive_utils.dart';
import 'package:achaytablereservation/features/authentication/logic/sign_in_controller.dart';
import 'package:achaytablereservation/features/authentication/logic/auth_validators.dart';
import 'package:achaytablereservation/app/routes/app_routes.dart';

/// Color constants for modern design
class AppColors {
  static const primaryNavy = Color(0xFF1A2332);
  static const mintAccent = Color(0xFF7DD3C0);
  static const backgroundLight = Color(0xFFF8F9FA);
  static const textPrimary = Color(0xFF202124);
  static const textSecondary = Color(0xFF5F6368);
}

/// Registration screen using StatefulWidget with GetX controller
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _obscurePassword = true.obs;
  final _obscureConfirmPassword = true.obs;

  @override
  void initState() {
    super.initState();
    _setupTextControllerListeners();
  }

  void _setupTextControllerListeners() {
    _firstNameController.addListener(() {
      Get.find<SignUpController>().clearFieldError('firstName');
    });

    _lastNameController.addListener(() {
      Get.find<SignUpController>().clearFieldError('lastName');
    });

    _phoneController.addListener(() {
      Get.find<SignUpController>().clearFieldError('phoneNumber');
    });

    _emailController.addListener(() {
      Get.find<SignUpController>().clearFieldError('email');
    });

    _passwordController.addListener(() {
      Get.find<SignUpController>().clearFieldError('password');
    });

    _confirmPasswordController.addListener(() {
      Get.find<SignUpController>().clearFieldError('confirmPassword');
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignUpController>();

    ever(
      controller.navigationEvent,
      (event) => _handleNavigation(event, controller),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () {
            controller.clearErrors();
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.spacing(24.0)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.spacing(20)),
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: context.spacing(80),
                  width: context.spacing(80),
                ),
                SizedBox(height: context.spacing(24)),
                Text(
                  'create_account'.tr,
                  style: TextStyle(
                    fontSize: context.fontSize(28),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.spacing(8)),
                Text(
                  'sign_up_subtitle'.tr,
                  style: TextStyle(
                    fontSize: context.fontSize(14),
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.spacing(32)),

                // First name field
                _buildTextField(
                  context,
                  controller: _firstNameController,
                  labelText: 'first_name'.tr,
                  hintText: 'enter_first_name'.tr,
                  prefixIcon: Icons.person,
                  validator: (v) => AuthValidators.validateFirstName(v),
                  fieldKey: 'firstName',
                ),
                SizedBox(height: context.spacing(16)),

                // Last name field
                _buildTextField(
                  context,
                  controller: _lastNameController,
                  labelText: 'last_name'.tr,
                  hintText: 'enter_last_name'.tr,
                  prefixIcon: Icons.person,
                  validator: (v) => AuthValidators.validateLastName(v),
                  fieldKey: 'lastName',
                ),
                SizedBox(height: context.spacing(16)),

                // Phone number field
                _buildTextField(
                  context,
                  controller: _phoneController,
                  labelText: 'phone_number'.tr,
                  hintText: '05xxxxxxxx',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      AuthValidators.validateRegistrationPhoneNumber(v),
                  fieldKey: 'phoneNumber',
                ),
                SizedBox(height: context.spacing(16)),

                // Email field (optional)
                _buildTextField(
                  context,
                  controller: _emailController,
                  labelText: 'email_optional'.tr,
                  hintText: 'enter_email'.tr,
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => AuthValidators.validateRegistrationEmail(v),
                  fieldKey: 'email',
                ),
                SizedBox(height: context.spacing(16)),

                // Password field
                _buildPasswordField(
                  context,
                  controller: _passwordController,
                  labelText: 'password'.tr,
                  hintText: 'enter_password'.tr,
                  obscureValue: _obscurePassword,
                  validator: (v) =>
                      AuthValidators.validateRegistrationPassword(v),
                  fieldKey: 'password',
                ),
                SizedBox(height: context.spacing(16)),

                // Confirm password field
                _buildPasswordField(
                  context,
                  controller: _confirmPasswordController,
                  labelText: 'confirm_password'.tr,
                  hintText: 'confirm_password_hint'.tr,
                  obscureValue: _obscureConfirmPassword,
                  validator: (v) => AuthValidators.validatePasswordConfirmation(
                    _passwordController.text,
                    v,
                  ),
                  fieldKey: 'confirmPassword',
                  onFieldSubmitted: (_) => _handleRegistration(controller),
                ),
                SizedBox(height: context.spacing(24)),

                // Error message
                Obx(() {
                  final formController = Get.find<SignUpController>();
                  if (formController.errorMessage.value.isNotEmpty) {
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
                              formController.errorMessage.value,
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

                // Register button
                Obx(() {
                  final btnController = Get.find<SignUpController>();
                  return ElevatedButton(
                    onPressed: btnController.isLoading.value
                        ? null
                        : () => _handleRegistration(btnController),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primaryNavy
                          .withOpacity(0.6),
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
                    child: btnController.isLoading.value
                        ? SizedBox(
                            height: context.spacing(20),
                            width: context.spacing(20),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'sign_up'.tr,
                            style: TextStyle(
                              fontSize: context.fontSize(16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                }),
                SizedBox(height: context.spacing(24)),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'already_have_account'.tr,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: context.fontSize(14),
                      ),
                    ),
                    SizedBox(width: context.spacing(4)),
                    GestureDetector(
                      onTap: () => Get.offNamed(AppRoutes.LOGIN),
                      child: Text(
                        'sign_in'.tr,
                        style: TextStyle(
                          color: AppColors.mintAccent,
                          fontSize: context.fontSize(14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.spacing(24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? fieldKey,
  }) {
    return Obx(() {
      final formController = Get.find<SignUpController>();
      final fieldError = fieldKey != null
          ? formController.formErrors[fieldKey]
          : null;

      return TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        validator: (value) {
          // First check field-specific error from controller
          if (fieldError != null) {
            return fieldError;
          }
          // Then run the validator function
          return validator?.call(value);
        },
        style: TextStyle(
          fontSize: context.fontSize(14),
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          labelStyle: TextStyle(
            fontSize: context.fontSize(14),
            color: AppColors.textSecondary,
          ),
          hintStyle: TextStyle(
            fontSize: context.fontSize(14),
            color: AppColors.textSecondary.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: AppColors.mintAccent,
            size: context.spacing(20),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.spacing(16),
            vertical: context.spacing(16),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.spacing(12)),
            borderSide: BorderSide(
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.spacing(12)),
            borderSide: BorderSide(
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.spacing(12)),
            borderSide: const BorderSide(color: AppColors.mintAccent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.spacing(12)),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.spacing(12)),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          errorStyle: TextStyle(fontSize: context.fontSize(12)),
        ),
      );
    });
  }

  Widget _buildPasswordField(
    BuildContext context, {
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required RxBool obscureValue,
    String? Function(String?)? validator,
    String? fieldKey,
    void Function(String)? onFieldSubmitted,
  }) {
    return Obx(() {
      final formController = Get.find<SignUpController>();
      final fieldError = fieldKey != null
          ? formController.formErrors[fieldKey]
          : null;

      return TextFormField(
        controller: controller,
        obscureText: obscureValue.value,
        textInputAction: onFieldSubmitted != null
            ? TextInputAction.done
            : TextInputAction.next,
        validator: (value) {
          // First check field-specific error from controller
          if (fieldError != null) {
            return fieldError;
          }
          // Then run the validator function
          return validator?.call(value);
        },
        onFieldSubmitted: onFieldSubmitted,
        style: TextStyle(
          fontSize: context.fontSize(14),
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          labelStyle: TextStyle(
            fontSize: context.fontSize(14),
            color: AppColors.textSecondary,
          ),
          hintStyle: TextStyle(
            fontSize: context.fontSize(14),
            color: AppColors.textSecondary.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            Icons.lock,
            color: AppColors.mintAccent,
            size: context.spacing(20),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureValue.value ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textSecondary,
              size: context.spacing(20),
            ),
            onPressed: () => obscureValue.value = !obscureValue.value,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.spacing(16),
            vertical: context.spacing(16),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.spacing(12)),
            borderSide: BorderSide(
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.spacing(12)),
            borderSide: BorderSide(
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.spacing(12)),
            borderSide: const BorderSide(color: AppColors.mintAccent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.spacing(12)),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.spacing(12)),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          errorStyle: TextStyle(fontSize: context.fontSize(12)),
        ),
      );
    });
  }

  void _handleNavigation(
    SignUpNavigationEvent? event,
    SignUpController controller,
  ) {
    if (event == null) return;
    controller.resetNavigationEvent();

    switch (event) {
      case SignUpNavigationEvent.navigateToOtp:
        Get.toNamed(
          AppRoutes.OTP,
          arguments: {
            'phoneNumber': _phoneController.text.trim(),
            'flow': 'registration',
          },
        );
        break;
      case SignUpNavigationEvent.navigateToHome:
        Get.offAllNamed(AppRoutes.MAIN_NAVIGATION);
        break;
    }
  }

  Future<void> _handleRegistration(SignUpController controller) async {
    // Always attempt registration - validation will be handled by the controller
    await controller.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    // If there are form errors, trigger form validation to show them
    if (controller.formErrors.isNotEmpty) {
      _formKey.currentState?.validate();
    }
  }
}
