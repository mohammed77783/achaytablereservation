import 'package:achaytablereservation/features/authentication/logic/Reset_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:achaytablereservation/core/utils/responsive_utils.dart';

/// Password reset screen using StatelessWidget
/// OTP is already verified locally before reaching this screen
/// Only requires new password and confirmation
class ResetPasswordPage extends StatelessWidget {
  ResetPasswordPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<ResetPasswordController>();

  // Form controllers (NO OTP field - already verified)
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // UI state
  final _obscureNewPassword = true.obs;
  final _obscureConfirmPassword = true.obs;
  final _passwordText = ''.obs; // For real-time strength feedback

  @override
  Widget build(BuildContext context) {
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
                _buildPasswordResetForm(context),
                SizedBox(height: context.spacing(24)),
                _buildResetPasswordButton(context),
                SizedBox(height: context.spacing(24)),
                // _buildBackToLoginLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePasswordReset() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _controller.resetPassword(
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success indicator that OTP was verified
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing(12),
            vertical: context.spacing(8),
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: context.fontSize(16),
              ),
              SizedBox(width: context.spacing(8)),
              Text(
                'Identity Verified',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: context.fontSize(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.spacing(16)),
        Text(
          'create_new_password'.tr,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: context.fontSize(28),
          ),
        ),
        SizedBox(height: context.spacing(8)),
        Text(
          "identity_verified_message".tr,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: context.fontSize(16),
          ),
        ),
        if (_controller.phoneNumber.isNotEmpty) ...[
          SizedBox(height: context.spacing(4)),
          Text(
            'Account: ${_controller.phoneNumber}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: context.fontSize(14),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordResetForm(BuildContext context) {
    return Column(
      children: [
        // New Password field
        Obx(
          () => TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword.value,
            textInputAction: TextInputAction.next,
            onChanged: (value) => _passwordText.value = value,
            style: TextStyle(fontSize: context.fontSize(16)),
            decoration: _inputDecoration(
              context,
              labelText: 'new_password'.tr,
              hintText: 'Enter your new password',
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Theme.of(
                    context,
                  ).iconTheme.color?.withValues(alpha: 0.6),
                ),
                onPressed: () => _obscureNewPassword.toggle(),
              ),
            ),
          ),
        ),

        // Real-time password strength feedback
        Obx(() => _buildPasswordStrengthFeedback(context)),

        SizedBox(height: context.spacing(16)),

        // Confirm Password field
        Obx(
          () => TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword.value,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handlePasswordReset(),
            style: TextStyle(fontSize: context.fontSize(16)),
            decoration: _inputDecoration(
              context,
              labelText: 'confirm_password'.tr,
              hintText: 'Re-enter your new password',
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Theme.of(
                    context,
                  ).iconTheme.color?.withValues(alpha: 0.6),
                ),
                onPressed: () => _obscureConfirmPassword.toggle(),
              ),
            ),
          ),
        ),

        Obx(() => _buildFormErrors(context)),
        Obx(() => _buildGeneralError(context)),
      ],
    );
  }

  Widget _buildPasswordStrengthFeedback(BuildContext context) {
    final password = _passwordText.value;
    if (password.isEmpty) return const SizedBox.shrink();

    final feedback = _controller.getPasswordStrengthFeedback(password);
    final isStrong = feedback.isEmpty;

    return Container(
      margin: EdgeInsets.only(top: context.spacing(12)),
      padding: EdgeInsets.all(context.spacing(12)),
      decoration: BoxDecoration(
        color: isStrong
            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isStrong
              ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isStrong ? Icons.check_circle : Icons.info_outline,
                size: context.fontSize(16),
                color: isStrong
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.error,
              ),
              SizedBox(width: context.spacing(8)),
              Text(
                isStrong ? 'Strong password!' : 'Password must contain:',
                style: TextStyle(
                  color: isStrong
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.error,
                  fontSize: context.fontSize(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (!isStrong) ...[
            SizedBox(height: context.spacing(8)),
            ...feedback.map(
              (requirement) => Padding(
                padding: EdgeInsets.only(bottom: context.spacing(4)),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: context.fontSize(6),
                      color: Theme.of(context).colorScheme.error,
                    ),
                    SizedBox(width: context.spacing(8)),
                    Text(
                      requirement,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: context.fontSize(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(
        prefixIcon,
        color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
      ),
      suffixIcon: suffixIcon,
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
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
      ),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.spacing(16),
        vertical: context.spacing(16),
      ),
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
    return Padding(
      padding: EdgeInsets.only(bottom: context.spacing(4)),
      child: Row(
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
      ),
    );
  }

  Widget _buildResetPasswordButton(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: context.spacing(56),
        child: ElevatedButton(
          onPressed: _controller.isLoading.value ? null : _handlePasswordReset,
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
                  "reset_password".tr,
                  style: TextStyle(
                    fontSize: context.fontSize(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
