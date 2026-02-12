import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:achaytablereservation/core/utils/responsive_utils.dart';
import 'package:achaytablereservation/features/authentication/logic/otp_controller.dart';
import 'package:achaytablereservation/app/routes/app_routes.dart';

/// OTP verification screen using StatelessWidget
/// For password reset: verifies OTP locally then navigates to reset password
/// For login/registration: verifies via API
class OtpPage extends StatelessWidget {
  OtpPage({super.key});

  final _controller = Get.find<OtpController>();

  // OTP input controllers
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  // Focus nodes for automatic focus management
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

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
        actions: [
          IconButton(
            icon: Icon(
              Icons.clear_all,
              color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
            ),
            onPressed: _clearOtpFields,
            tooltip: 'Clear code',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing(24),
            vertical: context.spacing(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              SizedBox(height: context.spacing(40)),
              _buildOtpInputFields(context),
              SizedBox(height: context.spacing(24)),
              Obx(() => _buildErrorDisplay(context)),
              SizedBox(height: context.spacing(32)),
              _buildVerifyButton(context),
              SizedBox(height: context.spacing(24)),
              _buildResendSection(context),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNavigation(OtpNavigationEvent? event) {
    if (event == null) return;
    _controller.resetNavigationEvent();

    // Check for returnRoute passed through login flow
    final args = Get.arguments;
    final returnRoute = args is Map ? args['returnRoute'] as String? : null;
    final returnArguments = args is Map ? args['returnArguments'] : null;

    switch (event) {
      case OtpNavigationEvent.navigateToHome:
        Get.offAllNamed(AppRoutes.MAIN_NAVIGATION);
        if (returnRoute != null) {
          Get.toNamed(returnRoute, arguments: returnArguments);
        }
        break;
      case OtpNavigationEvent.navigateToResetPassword:
        // Navigate to reset password after local OTP verification
        Get.toNamed(
          AppRoutes.RESET_PASSWORD,
          arguments: {
            'phoneNumber': _controller.phoneNumber,
            'flow': 'password_reset',
          },
        );
        break;
      case OtpNavigationEvent.navigateToLogin:
        Get.offAllNamed(AppRoutes.LOGIN);
        break;
    }
  }

  Future<void> _handleOtpVerification() async {
    final otpCode = _otpControllers.map((c) => c.text).join();

    if (otpCode.length != 6) {
      _controller.errorMessage.value = 'Please enter all 6 digits';
      return;
    }

    await _controller.verifyOtp(otpCode);
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
        _handleOtpVerification();
      }
    }
  }

  void _onOtpKeyPressed(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_otpControllers[index].text.isEmpty && index > 0) {
        _otpFocusNodes[index - 1].requestFocus();
      }
    }
  }

  void _clearOtpFields() {
    for (final controller in _otpControllers) {
      controller.clear();
    }
    _otpFocusNodes[0].requestFocus();
    _controller.clearError();
  }

  String _getTitle() {
    switch (_controller.flowType) {
      case 'password_reset':
        return 'verify_identity'.tr;
      case 'login':
        return 'login_verification'.tr;
      case 'registration':
        return 'verify_phone_number'.tr;
      default:
        return 'otp_verification'.tr;
    }
  }

  String _getSubtitle() {
    switch (_controller.flowType) {
      case 'password_reset':
        return 'password_reset_subtitle'.tr;
      case 'login':
        return 'login_verification_subtitle'.tr;
      case 'registration':
        return 'registration_verification_subtitle'.tr;
      default:
        return 'enter_otp_code'.tr;
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: context.spacing(80),
          height: context.spacing(80),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _controller.flowType == 'password_reset'
                ? Icons.lock_reset_outlined
                : Icons.sms_outlined,
            size: context.spacing(40),
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: context.spacing(24)),
        Text(
          _getTitle(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: context.fontSize(28),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.spacing(12)),
        Text(
          _getSubtitle(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: context.fontSize(16),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.spacing(8)),
        Text(
          _controller.phoneNumber.isNotEmpty
              ? _controller.phoneNumber
              : 'your phone number',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
            fontSize: context.fontSize(16),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOtpInputFields(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (index) {
          return SizedBox(
            width: context.spacing(48),
            height: context.spacing(56),
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) => _onOtpKeyPressed(event, index),
              child: TextFormField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: TextStyle(
                  fontSize: context.fontSize(24),
                  fontWeight: FontWeight.bold,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => _onOtpChanged(value, index),
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1.5,
                    ),
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
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: context.spacing(16),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorDisplay(BuildContext context) {
    if (_controller.errorMessage.value.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(context.spacing(12)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
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
              _controller.errorMessage.value,
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

  Widget _buildVerifyButton(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: context.spacing(56),
        child: ElevatedButton(
          onPressed: _controller.isLoading.value
              ? null
              : _handleOtpVerification,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.black,
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
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : Text(
                  _controller.flowType == 'password_reset'
                      ? 'verify_otp'.tr
                      : 'verify_otp'.tr,
                  style: TextStyle(
                    fontSize: context.fontSize(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildResendSection(BuildContext context) {
    return Column(
      children: [
        Text(
          'didnt_receive_code'.tr,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: context.fontSize(14),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.spacing(8)),
        Obx(
          () => _controller.canResend.value
              ? GestureDetector(
                  onTap: _controller.resendOtp,
                  child: Text(
                    'resend_otp'.tr,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: context.fontSize(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : Text(
                  '${'resend_otp_in'.tr} ${_controller.resendCountdown.value}s',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: context.fontSize(14),
                  ),
                ),
        ),
      ],
    );
  }
}
