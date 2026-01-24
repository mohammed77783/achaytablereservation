import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'en_US.dart';
import 'ar_SA.dart';

/// AppTranslations class for managing multi-language support
/// Implements GetX Translations to provide localized strings
/// Supports English (en_US) and Arabic (ar_SA) with English as fallback
class AppTranslations extends Translations {
  /// Returns a map of language codes to translation maps
  /// Each language code maps to a complete set of translation keys
  @override
  Map<String, Map<String, String>> get keys => {'en_US': enUS, 'ar_SA': arSA};

  /// Fallback locale when requested locale is not available
  /// Defaults to English (United States)
  static const fallbackLocale = Locale('ar', 'SA');

  /// List of supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English (United States)
    Locale('ar', 'SA'), // Arabic (Saudi Arabia)
  ];

  /// Get locale from language code
  /// [languageCode] - The language code (e.g., 'en', 'ar')
  /// [countryCode] - The country code (e.g., 'US', 'SA')
  /// Returns the corresponding Locale object
  static Locale getLocale(String languageCode, String countryCode) {
    return Locale(languageCode, countryCode);
  }

  /// Check if a locale is supported
  /// [locale] - The locale to check
  /// Returns true if the locale is supported, false otherwise
  static bool isLocaleSupported(Locale locale) {
    return supportedLocales.any(
      (supportedLocale) =>
          supportedLocale.languageCode == locale.languageCode &&
          supportedLocale.countryCode == (locale.countryCode ?? ''),
    );
  }

  /// Get locale name in the locale's language
  /// [locale] - The locale to get the name for
  /// Returns the localized name of the locale
  static String getLocaleName(Locale locale) {
    final localeKey = '${locale.languageCode}_${locale.countryCode}';
    switch (localeKey) {
      case 'en_US':
        return 'English';
      case 'ar_SA':
        return 'العربية';
      default:
        return 'Unknown';
    }
  }

  /// Check if locale is RTL (Right-to-Left)
  /// [locale] - The locale to check
  /// Returns true if the locale uses RTL text direction
  static bool isRTL(Locale locale) {
    return locale.languageCode == 'ar';
  }
}
