import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/themes/dark_theme.dart';
import '../../../app/themes/light_theme.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/services/storage_service.dart';
import '../../../features/authentication/logic/authstate_Controller.dart';

/// Controller for More page
/// Handles support center actions, navigation, and logout functionality
class MoreController extends BaseController {
  final StorageService _storageService;

  MoreController({required StorageService storageService})
    : _storageService = storageService;

  // Observable states
  final RxBool isLoggingOut = false.obs;

  // Support contact details - can be moved to config
  static const String supportPhone = '+966562760098';
  static const String supportWhatsApp = '+966562760098';
  static const String supportEmail = 'achaytea1@gmail..com';

  // Terms & Conditions URLs
  static const String termsUrlEn ='https://achay.com.sa/term&condition';
  static const String termsUrlAr =
      'https://achay.com.sa/term&condition-ar';

  // Privacy Policy URLs
  static const String privacyUrlEn = 'https://achay.com.sa/privacy';
  static const String privacyUrlAr = 'https://achay.com.sa/privacy-ar';

  /// Make a phone call to support
  Future<void> callSupport() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: supportPhone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        showError('could_not_launch_phone'.tr);
      }
    } catch (e) {
      showError('error'.tr);
    }
  }

  /// Open WhatsApp to contact support
  Future<void> openWhatsApp() async {
    // WhatsApp URL format: https://wa.me/phonenumber
    final String whatsappNumber = supportWhatsApp.replaceAll('+', '');
    final Uri whatsappUri = Uri.parse('https://wa.me/$whatsappNumber');
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        showError('could_not_launch_whatsapp'.tr);
      }
    } catch (e) {
      showError('error'.tr);
    }
  }

  /// Open email client to contact support
  Future<void> emailSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {'subject': 'Support Request - Aja Reservation App'},
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        showError('could_not_launch_email'.tr);
      }
    } catch (e) {
      showError('error'.tr);
    }
  }

  bool get isArabic => Get.locale?.languageCode == 'ar';

  /// Show Terms and Conditions in a WebView dialog
  void goToTermsAndConditions() {
    final String url = isArabic ? termsUrlAr : termsUrlEn;
    _showWebViewDialog(
      url: url,
      title: isArabic ? 'الشروط والأحكام' : 'Terms & Conditions',
      icon: Iconsax.document_text,
    );
  }

  /// Show Privacy Policy in a WebView dialog
  void goToPrivacyPolicy() {
    final String url = isArabic ? privacyUrlAr : privacyUrlEn;
    _showWebViewDialog(
      url: url,
      title: isArabic ? 'سياسة الخصوصية' : 'Privacy Policy',
      icon: Iconsax.shield_tick,
    );
  }

  /// Navigate to Settings page
  void goToSettings() {
    Get.toNamed(AppRoutes.SETTINGS);
  }

  /// Show a WebView dialog with the given URL and title
  void _showWebViewDialog({
    required String url,
    required String title,
    required IconData icon,
  }) {
    final webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(
        Get.isDarkMode ? DarkTheme.backgroundColor : LightTheme.backgroundColor,
      )
      ..loadRequest(Uri.parse(url));

    Get.dialog(
      Dialog(
        backgroundColor: Get.isDarkMode
            ? DarkTheme.cardBackground
            : LightTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SizedBox(
          width: double.maxFinite,
          height: Get.height * 0.75,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Get.isDarkMode
                          ? DarkTheme.borderColor
                          : LightTheme.borderColor,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: Get.isDarkMode
                          ? DarkTheme.secondaryColor
                          : LightTheme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Get.isDarkMode
                              ? DarkTheme.textPrimary
                              : LightTheme.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: Get.isDarkMode
                            ? DarkTheme.textSecondary
                            : LightTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: WebViewWidget(controller: webViewController),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// Show logout confirmation dialog
  void showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Text('logout'.tr),
        content: Text('logout_confirmation'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              logout();
            },
            child: Text('logout'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Logout user
  Future<void> logout() async {
    isLoggingOut.value = true;

    try {
      // Use AuthStateController to properly clear all auth state
      final authController = Get.find<AuthStateController>();
      await authController.logout();

      // Show success message
      Get.snackbar(
        'success'.tr,
        'logout_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );

      // Navigate to home screen (as guest)
      Get.offAllNamed(AppRoutes.MAIN_NAVIGATION);
    } catch (e) {
      showError('error'.tr);
    } finally {
      isLoggingOut.value = false;
    }
  }
}
