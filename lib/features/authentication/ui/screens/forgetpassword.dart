import 'package:achaytablereservation/features/authentication/logic/Forgot_Passwor_Controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:achaytablereservation/core/utils/responsive_utils.dart';
import 'package:achaytablereservation/core/utils/validators.dart';
import 'package:achaytablereservation/app/routes/app_routes.dart';

/// Forgot password screen using StatelessWidget
/// Navigates to OTP screen for verification before reset password
class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<ForgotPasswordController>();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ever(_controller.navigationEvent, (event) => _handleNavigation(event));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing(24),
            vertical: context.spacing(16),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                SizedBox(height: context.spacing(32)),
                _buildPhoneNumberForm(context),
                SizedBox(height: context.spacing(24)),
                _buildSendCodeButton(context),
                SizedBox(height: context.spacing(24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(ForgotPasswordNavigationEvent? event) {
    if (event == null) return;
    _controller.resetNavigationEvent();

    switch (event) {
      case ForgotPasswordNavigationEvent.navigateToOtp:
        // Navigate to OTP screen first for verification
        Get.toNamed(
          AppRoutes.OTP,
          arguments: {
            'phoneNumber': _phoneController.text.trim(),
            'flow': 'password_reset',
          },
        );
        break;
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _controller.requestPasswordReset(_phoneController.text.trim());
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'forgot_password'.tr,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: context.fontSize(28),
          ),
        ),
        SizedBox(height: context.spacing(8)),
        Text(
          "forgetpass_label".tr,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: context.fontSize(16),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberForm(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          validator: (value) => Validators.validateSaudiPhoneNumber(value),
          onFieldSubmitted: (_) => _handleForgotPassword(),
          style: TextStyle(fontSize: context.fontSize(16)),
          decoration: InputDecoration(
            labelText: 'phone_number'.tr,
            hintText: '05xxxxxxxx',
            prefixIcon: Icon(
              Icons.phone_outlined,
              color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.spacing(16),
              vertical: context.spacing(16),
            ),
          ),
        ),
        Obx(() => _buildFormErrors(context)),
        Obx(() => _buildGeneralError(context)),
      ],
    );
  }

  Widget _buildFormErrors(BuildContext context) {
    if (_controller.formErrors.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: context.spacing(16)),
      padding: EdgeInsets.all(context.spacing(12)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: _controller.formErrors.entries
            .map((e) => _buildErrorRow(context, e.value))
            .toList(),
      ),
    );
  }

  Widget _buildGeneralError(BuildContext context) {
    if (_controller.errorMessage.value.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: context.spacing(16)),
      padding: EdgeInsets.all(context.spacing(12)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: _buildErrorRow(context, _controller.errorMessage.value),
    );
  }

  Widget _buildErrorRow(BuildContext context, String message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.error_outline,
          size: context.fontSize(16),
          color: Theme.of(context).colorScheme.error,
        ),
        SizedBox(width: context.spacing(8)),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: context.fontSize(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendCodeButton(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: context.spacing(56),
        child: ElevatedButton(
          onPressed: _controller.isLoading.value ? null : _handleForgotPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _controller.isLoading.value
              ? SizedBox(
                  height: context.spacing(24),
                  width: context.spacing(24),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  "send_verification".tr,
                  style: TextStyle(
                    fontSize: context.fontSize(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBackToLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Remember your password?',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: context.fontSize(14),
          ),
        ),
        SizedBox(width: context.spacing(4)),
        GestureDetector(
          onTap: () => Get.offNamed(AppRoutes.LOGIN),
          child: Text(
            'sign_in'.tr,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: context.fontSize(14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
