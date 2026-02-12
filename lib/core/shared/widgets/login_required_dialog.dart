import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/themes/light_theme.dart';
import '../../../app/themes/dark_theme.dart';

class LoginRequiredDialog {
  LoginRequiredDialog._();

  /// Show login required dialog.
  /// [returnRoute] and [returnArguments] are passed to the login page
  /// so the user can be redirected back after authentication.
  static void show({String? returnRoute, dynamic returnArguments}) {
    final isDark = Get.isDarkMode;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor:
            isDark ? DarkTheme.surfaceColor : LightTheme.surfaceColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDark
                          ? DarkTheme.primaryColor
                          : LightTheme.primaryColor)
                      .withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 32,
                  color: isDark
                      ? DarkTheme.primaryColor
                      : LightTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'login_required'.tr,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color:
                      isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Message
              Text(
                'login_required_message'.tr,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: isDark
                      ? DarkTheme.textSecondary
                      : LightTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Sign In button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // close dialog
                    Get.toNamed(
                      AppRoutes.LOGIN,
                      arguments: {
                        'returnRoute': returnRoute,
                        'returnArguments': returnArguments,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? DarkTheme.primaryColor
                        : LightTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'login'.tr,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Sign Up button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Get.back(); // close dialog
                    Get.toNamed(
                      AppRoutes.REGISTER,
                      arguments: {
                        'returnRoute': returnRoute,
                        'returnArguments': returnArguments,
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark
                          ? DarkTheme.primaryColor
                          : LightTheme.primaryColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'sign_up'.tr,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? DarkTheme.primaryColor
                          : LightTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Cancel button
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'cancel'.tr,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: isDark
                        ? DarkTheme.textSecondary
                        : LightTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
