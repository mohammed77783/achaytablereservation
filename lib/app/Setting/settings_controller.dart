import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/light_theme.dart';
import '../themes/dark_theme.dart';
import '../../core/services/storage_service.dart';

/// Controller for Settings page
/// Handles theme and language preferences
class SettingsController extends GetxController {
  final StorageService _storageService;

  SettingsController({required StorageService storageService})
    : _storageService = storageService;

  // Observable states
  final RxString currentTheme = 'system'.obs;
  final RxString currentLanguage = 'ar'.obs;
  final RxBool notificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  /// Load saved settings
  Future<void> _loadSettings() async {
    // Load theme preference
    final savedTheme = await _storageService.read<String>('theme');
    if (savedTheme != null) {
      currentTheme.value = savedTheme;
    }

    // Load language preference
    final savedLanguage = await _storageService.read<String>('language');
    if (savedLanguage != null) {
      currentLanguage.value = savedLanguage;
    }

    // Load notification preference
    final savedNotifications = await _storageService.read<bool>(
      'notifications',
    );
    if (savedNotifications != null) {
      notificationsEnabled.value = savedNotifications;
    }
  }

  /// Change app theme
  Future<void> changeTheme(String theme) async {
    currentTheme.value = theme;
    await _storageService.write('theme', theme);

    switch (theme) {
      case 'light':
        Get.changeTheme(LightTheme.theme);
        Get.changeThemeMode(ThemeMode.light);
        break;
      case 'dark':
        Get.changeTheme(DarkTheme.theme);
        Get.changeThemeMode(ThemeMode.dark);
        break;
      case 'system':
      default:
        Get.changeThemeMode(ThemeMode.system);
        break;
    }

    Get.snackbar(
      'success'.tr,
      'theme_changed'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Change app language
  Future<void> changeLanguage(String languageCode) async {
    currentLanguage.value = languageCode;
    await _storageService.write('language', languageCode);

    final locale = languageCode == 'ar'
        ? const Locale('ar', 'SA')
        : const Locale('en', 'US');
    Get.updateLocale(locale);

    Get.snackbar(
      'success'.tr,
      'language_changed'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    notificationsEnabled.value = enabled;
    await _storageService.write('notifications', enabled);
  }

  /// Show theme selection dialog
  void showThemeDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('change_theme'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('light', 'light_theme'.tr, Icons.light_mode),
            _buildThemeOption('dark', 'dark_theme'.tr, Icons.dark_mode),
            _buildThemeOption(
              'system',
              'system_theme'.tr,
              Icons.settings_suggest,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String value, String title, IconData icon) {
    return Obx(
      () => ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: currentTheme.value == value
            ? const Icon(Icons.check, color: Colors.green)
            : null,
        onTap: () {
          changeTheme(value);
          Get.back();
        },
      ),
    );
  }

  /// Show language selection dialog
  void showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('change_language'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('ar', 'arabic'.tr, '🇸🇦'),
            _buildLanguageOption('en', 'english'.tr, '🇺🇸'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String title, String flag) {
    return Obx(
      () => ListTile(
        leading: Text(flag, style: const TextStyle(fontSize: 24)),
        title: Text(title),
        trailing: currentLanguage.value == code
            ? const Icon(Icons.check, color: Colors.green)
            : null,
        onTap: () {
          changeLanguage(code);
          Get.back();
        },
      ),
    );
  }
}
