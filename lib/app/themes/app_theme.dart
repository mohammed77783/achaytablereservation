import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

/// Central theme configuration for the application
/// Provides access to light and dark themes
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();
  /// Get light theme configuration
  static ThemeData get lightTheme => LightTheme.theme;
  /// Get dark theme configuration
  static ThemeData get darkTheme => DarkTheme.theme;
  /// Get theme based on brightness
  static ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.light ? lightTheme : darkTheme;
  }
  /// Get theme based on theme mode and system brightness
  static ThemeData getThemeForMode(
    ThemeMode mode,
    Brightness systemBrightness,
  ) {
    switch (mode) {
      case ThemeMode.light:
        return lightTheme;
      case ThemeMode.dark:
        return darkTheme;
      case ThemeMode.system:
        return systemBrightness == Brightness.light ? lightTheme : darkTheme;
    }
  }
}
