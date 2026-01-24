import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/storage_constants.dart';
import 'storage_service.dart';

/// Theme service for managing application theme preferences
/// Handles saving, loading, and switching between light, dark, and system themes
/// Integrates with StorageService for persistent theme preferences
class ThemeService extends GetxService {
  // Get StorageService from GetX dependency injection
  late final StorageService _storageService;

  // Reactive theme mode
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;

  /// Get current theme mode
  ThemeMode get themeMode => _themeMode.value;

  /// Get current theme mode as observable
  Rx<ThemeMode> get themeModeObs => _themeMode;

  /// Check if current theme is dark
  bool get isDarkMode {
    if (_themeMode.value == ThemeMode.system) {
      return Get.isDarkMode;
    }
    return _themeMode.value == ThemeMode.dark;
  }

  /// Check if current theme is light
  bool get isLightMode {
    if (_themeMode.value == ThemeMode.system) {
      return !Get.isDarkMode;
    }
    return _themeMode.value == ThemeMode.light;
  }

  /// Initialize theme service and load saved theme preference
  Future<ThemeService> init() async {
    _storageService = Get.find<StorageService>();
    await loadThemeMode();
    return this;
  }

  /// Save theme mode preference to storage
  /// [mode] - The theme mode to save (light, dark, or system)
  Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      await _storageService.write(StorageConstants.themeMode, mode.toString());
      _themeMode.value = mode;
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
      rethrow;
    }
  }

  /// Load theme mode preference from storage
  /// Returns the saved theme mode or defaults to system theme
  Future<ThemeMode> loadThemeMode() async {
    try {
      final savedTheme = await _storageService.read<String>(
        StorageConstants.themeMode,
      );
      if (savedTheme != null) {
        final mode = _parseThemeMode(savedTheme);
        _themeMode.value = mode;
        return mode;
      }
      // Default to system theme if no preference saved
      _themeMode.value = ThemeMode.system;
      return ThemeMode.system;
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
      _themeMode.value = ThemeMode.system;
      return ThemeMode.system;
    }
  }

  /// Switch to light theme
  Future<void> switchToLight() async {
    await saveThemeMode(ThemeMode.light);
    Get.changeThemeMode(ThemeMode.light);
  }

  /// Switch to dark theme
  Future<void> switchToDark() async {
    await saveThemeMode(ThemeMode.dark);
    Get.changeThemeMode(ThemeMode.dark);
  }

  /// Switch to system theme
  Future<void> switchToSystem() async {
    await saveThemeMode(ThemeMode.system);
    Get.changeThemeMode(ThemeMode.system);
  }

  /// Toggle between light and dark themes
  /// If currently on system theme, switches to light
  /// If on light theme, switches to dark
  /// If on dark theme, switches to light
  Future<void> switchTheme() async {
    switch (_themeMode.value) {
      case ThemeMode.light:
        await switchToDark();
        break;
      case ThemeMode.dark:
        await switchToLight();
        break;
      case ThemeMode.system:
        // If system theme, switch to opposite of current system preference
        if (Get.isDarkMode) {
          await switchToLight();
        } else {
          await switchToDark();
        }
        break;
    }
  }

  /// Change theme mode and apply it
  /// [mode] - The theme mode to change to
  Future<void> changeThemeMode(ThemeMode mode) async {
    await saveThemeMode(mode);
    Get.changeThemeMode(mode);
  }

  /// Parse theme mode string to ThemeMode enum
  ThemeMode _parseThemeMode(String themeModeString) {
    switch (themeModeString) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  /// Get theme mode name as string
  String getThemeModeName() {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  /// Get all available theme modes
  List<ThemeMode> getAvailableThemeModes() {
    return [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
  }
}
