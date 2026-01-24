import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/light_theme.dart';
import '../themes/dark_theme.dart';
import 'settings_controller.dart';

/// Settings page
/// Displays theme, language, and notification settings
class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? DarkTheme.backgroundColor
          : LightTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'settings'.tr,
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            _buildSectionTitle(context, 'theme'.tr, isDark),
            const SizedBox(height: 12),
            _buildAppearanceCard(context, isDark),

            const SizedBox(height: 24),

            // Language Section
            _buildSectionTitle(context, 'language'.tr, isDark),
            const SizedBox(height: 12),
            _buildLanguageCard(context, isDark),

            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionTitle(context, 'notification_settings'.tr, isDark),
            const SizedBox(height: 12),
            _buildNotificationsCard(context, isDark),
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

  Widget _buildAppearanceCard(BuildContext context, bool isDark) {
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
      child: Obx(
        () => Column(
          children: [
            _buildThemeOption(
              context: context,
              icon: Icons.light_mode_outlined,
              title: 'light_theme'.tr,
              value: 'light',
              isDark: isDark,
            ),
            _buildDivider(isDark),
            _buildThemeOption(
              context: context,
              icon: Icons.dark_mode_outlined,
              title: 'dark_theme'.tr,
              value: 'dark',
              isDark: isDark,
            ),
            _buildDivider(isDark),
            _buildThemeOption(
              context: context,
              icon: Icons.settings_suggest_outlined,
              title: 'system_theme'.tr,
              value: 'system',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    final isSelected = controller.currentTheme.value == value;
    final accentColor = isDark
        ? DarkTheme.secondaryColor
        : LightTheme.primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.changeTheme(value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? accentColor
                    : (isDark
                          ? DarkTheme.textSecondary
                          : LightTheme.textSecondary),
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? accentColor
                        : (isDark
                              ? DarkTheme.textPrimary
                              : LightTheme.textPrimary),
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: accentColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, bool isDark) {
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
      child: Obx(
        () => Column(
          children: [
            _buildLanguageOption(
              context: context,
              flag: '🇸🇦',
              title: 'arabic'.tr,
              value: 'ar',
              isDark: isDark,
            ),
            _buildDivider(isDark),
            _buildLanguageOption(
              context: context,
              flag: '🇺🇸',
              title: 'english'.tr,
              value: 'en',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String flag,
    required String title,
    required String value,
    required bool isDark,
  }) {
    final isSelected = controller.currentLanguage.value == value;
    final accentColor = isDark
        ? DarkTheme.secondaryColor
        : LightTheme.primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.changeLanguage(value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? accentColor
                        : (isDark
                              ? DarkTheme.textPrimary
                              : LightTheme.textPrimary),
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: accentColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsCard(BuildContext context, bool isDark) {
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
      child: Obx(
        () => Column(
          children: [
            _buildNotificationToggle(
              context: context,
              icon: Icons.notifications_outlined,
              title: 'push_notifications'.tr,
              value: controller.notificationsEnabled.value,
              isDark: isDark,
              onChanged: (value) => controller.toggleNotifications(value),
            ),
            _buildDivider(isDark),
            _buildNotificationToggle(
              context: context,
              icon: Icons.calendar_today_outlined,
              title: 'booking_reminders'.tr,
              value: controller.notificationsEnabled.value,
              isDark: isDark,
              onChanged: (value) => controller.toggleNotifications(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? DarkTheme.textSecondary : LightTheme.textSecondary,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: isDark
                ? DarkTheme.secondaryColor
                : LightTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 54,
      color: isDark ? DarkTheme.dividerColor : LightTheme.dividerColor,
    );
  }
}
