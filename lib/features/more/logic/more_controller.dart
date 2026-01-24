import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/services/storage_service.dart';

/// Controller for More page
/// Handles support center actions, navigation, and logout functionality
class MoreController extends BaseController {
  final StorageService _storageService;

  MoreController({required StorageService storageService})
    : _storageService = storageService;

  // Observable states
  final RxBool isLoggingOut = false.obs;

  // Support contact details - can be moved to config
  static const String supportPhone = '+966500000000';
  static const String supportWhatsApp = '+966500000000';
  static const String supportEmail = 'support@aja.com';

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

  /// Navigate to Terms and Conditions page
  void goToTermsAndConditions() {
    Get.toNamed(AppRoutes.TERMS_CONDITIONS);
  }

  /// Navigate to Settings page
  void goToSettings() {
    Get.toNamed(AppRoutes.SETTINGS);
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
      // Clear stored tokens and user data
      await _storageService.remove('access_token');
      await _storageService.remove('refresh_token');
      await _storageService.remove('user_data');

      // Show success message
      Get.snackbar(
        'success'.tr,
        'logout_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );

      // Navigate to login screen
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      showError('error'.tr);
    } finally {
      isLoggingOut.value = false;
    }
  }
}
