// ============================================================================
// STEP 6: Apple Pay Button Widget
// ============================================================================
// File: lib/features/payment/ui/widget/apple_pay_button_widget.dart
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moyasar/moyasar.dart' as moyasar;
import 'package:achaytablereservation/app/themes/dark_theme.dart';
import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/core/utils/responsive_utils.dart';
import 'package:achaytablereservation/features/payment/logic/payment_controller.dart';

/// Apple Pay Button Widget
///
/// Displays the native Apple Pay button and handles the Apple Pay flow
/// using Moyasar SDK.
///
/// Features:
/// - Native Apple Pay button styling
/// - Automatic availability detection
/// - Error handling for simulator
/// - Integrates with PaymentController for callbacks
class ApplePayButtonWidget extends StatelessWidget {
  final PaymentController controller;
  final VoidCallback? onPressed;

  const ApplePayButtonWidget({
    super.key,
    required this.controller,
    this.onPressed,
  });

  bool get isDark => Get.isDarkMode;
  Color get textSecondary =>
      isDark ? DarkTheme.textSecondary : LightTheme.textSecondary;

  @override
  Widget build(BuildContext context) {
    // Only show on iOS
    if (!Platform.isIOS) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      // Check if Moyasar config is available
      final config = controller.moyasarPaymentConfig;
      if (config == null) {
        return _buildDisabledButton(context);
      }

      // Show loading state while processing
      if (controller.isProcessing.value &&
          controller.selectedPaymentMethod.value == 'apple_pay') {
        return _buildLoadingButton(context);
      }

      // Use Moyasar's Apple Pay widget
      return Column(
        children: [
          // Moyasar Apple Pay Button
          ClipRRect(
            borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
            child: SizedBox(
              width: double.infinity,
              height: context.spacing(56),
              child: moyasar.ApplePay(
                config: config,
                onPaymentResult: _handlePaymentResult,
              ),
            ),
          ),

          SizedBox(height: context.spacing(8)),

          // Helper text
          Text(
            'apple_pay_description'.tr,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: textSecondary,
              fontSize: context.fontSize(11),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    });
  }

  void _handlePaymentResult(moyasar.PaymentResponse result) {
    controller.onApplePayResult(result);
  }

  Widget _buildDisabledButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: context.spacing(56),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
      ),
      child: Center(
        child: Text(
          'apple_pay_unavailable'.tr,
          style: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.grey.shade600,
            fontSize: context.fontSize(14),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: context.spacing(56),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      ),
    );
  }
}

// ============================================================================
// ALTERNATIVE: Custom Apple Pay Button (if not using Moyasar widget)
// ============================================================================

/// Custom Apple Pay Button for manual implementation
/// Use this if you need more control over the Apple Pay flow
class CustomApplePayButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;

  const CustomApplePayButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled && !isLoading ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isEnabled ? Colors.black : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Apple logo
                    Icon(Icons.apple, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    // Pay text
                    Text(
                      'Pay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
