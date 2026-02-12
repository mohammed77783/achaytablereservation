import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/light_theme.dart';
import '../../../../app/themes/dark_theme.dart';
import '../../../../features/authentication/logic/authstate_Controller.dart';
import '../../logic/more_controller.dart';

/// More page with additional features and settings
/// Displays support center options, terms, settings, and logout
///
/// Requirements implemented:
/// - 6.1: Display more page when navigation item selected
/// - Support Center (Call, WhatsApp, Email)
/// - Terms & Conditions navigation
/// - Settings navigation
/// - Logout with confirmation
class MorePage extends GetView<MoreController> {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? DarkTheme.backgroundColor
          : LightTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'more'.tr,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
          ),
        ),
        backgroundColor: isDark
            ? DarkTheme.surfaceColor
            : LightTheme.surfaceColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Support Center Section
            _buildSectionTitle(context, 'support_center'.tr, isDark),
            const SizedBox(height: 12),
            _buildSupportCenterCard(context, isDark),

            const SizedBox(height: 24),

            // General Section
            _buildSectionTitle(context, 'settings'.tr, isDark),
            const SizedBox(height: 12),
            _buildGeneralOptionsCard(context, isDark),

            const SizedBox(height: 24),

            // Login/Logout Section
            _buildAuthButton(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? DarkTheme.textSecondary : LightTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSupportCenterCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkTheme.surfaceColor : LightTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Call Support
          _buildMenuItem(
            context: context,
            icon: Icons.phone_outlined,
            iconColor: Colors.green,
            title: 'call_us'.tr,
            subtitle: MoreController.supportPhone,
            isDark: isDark,
            onTap: () => controller.callSupport(),
          ),
          _buildDivider(isDark),

          // WhatsApp
          _buildMenuItem(
            context: context,
            icon: Icons.chat_outlined,
            iconColor: const Color(0xFF25D366), // WhatsApp green
            title: 'whatsapp'.tr,
            subtitle: MoreController.supportWhatsApp,
            isDark: isDark,
            onTap: () => controller.openWhatsApp(),
          ),
          _buildDivider(isDark),

          // Email
          _buildMenuItem(
            context: context,
            icon: Icons.email_outlined,
            iconColor: Colors.blue,
            title: 'email_us'.tr,
            subtitle: MoreController.supportEmail,
            isDark: isDark,
            onTap: () => controller.emailSupport(),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralOptionsCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkTheme.surfaceColor : LightTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Settings
          _buildMenuItem(
            context: context,
            icon: Icons.settings_outlined,
            iconColor: isDark
                ? DarkTheme.secondaryColor
                : LightTheme.primaryColor,
            title: 'settings'.tr,
            isDark: isDark,
            onTap: () => controller.goToSettings(),
            showArrow: true,
          ),
          _buildDivider(isDark),

          // Terms & Conditions
          _buildMenuItem(
            context: context,
            icon: Icons.description_outlined,
            iconColor: isDark
                ? DarkTheme.secondaryColor
                : LightTheme.primaryColor,
            title: 'terms_and_conditions'.tr,
            isDark: isDark,
            onTap: () => controller.goToTermsAndConditions(),
            showArrow: true,
          ),
          _buildDivider(isDark),

          // Privacy Policy
          _buildMenuItem(
            context: context,
            icon: Icons.privacy_tip_outlined,
            iconColor: isDark
                ? DarkTheme.secondaryColor
                : LightTheme.primaryColor,
            title: 'privacy_policy'.tr,
            isDark: isDark,
            onTap: () => controller.goToPrivacyPolicy(),
            showArrow: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool isDark,
    required VoidCallback onTap,
    bool showArrow = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? DarkTheme.textPrimary
                            : LightTheme.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: isDark
                              ? DarkTheme.textSecondary
                              : LightTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow Icon
              if (showArrow)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDark
                      ? DarkTheme.textSecondary
                      : LightTheme.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 74,
      color: isDark ? DarkTheme.dividerColor : LightTheme.dividerColor,
    );
  }

  Widget _buildAuthButton(BuildContext context, bool isDark) {
    final authController = Get.find<AuthStateController>();

    return Obx(() {
      final isGuest = authController.isGuest;

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? DarkTheme.surfaceColor : LightTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isGuest
                ? () => Get.toNamed(AppRoutes.LOGIN)
                : (controller.isLoggingOut.value
                    ? null
                    : () => controller.showLogoutConfirmation()),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isGuest
                          ? (isDark
                                  ? DarkTheme.primaryColor
                                  : LightTheme.primaryColor)
                              .withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isGuest
                        ? Icon(
                            Icons.login_outlined,
                            color: isDark
                                ? DarkTheme.primaryColor
                                : LightTheme.primaryColor,
                            size: 22,
                          )
                        : controller.isLoggingOut.value
                            ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      Colors.red,
                                    ),
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.logout_outlined,
                                color: Colors.red,
                                size: 22,
                              ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    isGuest ? 'login'.tr : 'logout'.tr,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isGuest
                          ? (isDark
                              ? DarkTheme.primaryColor
                              : LightTheme.primaryColor)
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
