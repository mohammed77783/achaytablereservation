import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/storage_constants.dart';
import 'storage_service.dart';
import '../../app/translations/app_translations.dart';

/// Translation service for managing language preferences
/// Handles language switching, persistence, and locale management
/// Integrates with GetX for reactive language updates
class TranslationService extends GetxService {
  // Get StorageService from GetX dependency injection
  late final StorageService _storageService;

  /// Current locale as a reactive variable
  final Rx<Locale> _currentLocale = AppTranslations.fallbackLocale.obs;

  /// Get the current locale
  Locale get currentLocale => _currentLocale.value;

  /// Get the current locale as an observable
  Rx<Locale> get currentLocaleObs => _currentLocale;

  /// Initialize the translation service
  /// Loads saved language preference or uses device locale
  Future<TranslationService> init() async {
    _storageService = Get.find<StorageService>();
    final savedLocale = await loadLanguagePreference();
    if (savedLocale != null) {
      _currentLocale.value = savedLocale;
    } else {
      // Use device locale if supported, otherwise use fallback
      final deviceLocale = Get.deviceLocale;
      if (deviceLocale != null &&
          AppTranslations.isLocaleSupported(deviceLocale)) {
        _currentLocale.value = deviceLocale;
      } else {
        _currentLocale.value = AppTranslations.fallbackLocale;
      }
    }
    return this;
  }
  
  /// Save language preference to storage
  /// [locale] - The locale to save
  /// Stores language code, country code, and RTL flag
  Future<void> saveLanguagePreference(Locale locale) async {
    try {
      await _storageService.write(
        StorageConstants.languageCode,
        locale.languageCode,
      );
      await _storageService.write(
        StorageConstants.countryCode,
        locale.countryCode ?? '',
      );
      await _storageService.write(
        StorageConstants.locale,
        '${locale.languageCode}_${locale.countryCode}',
      );
      await _storageService.write(
        StorageConstants.isRTL,
        AppTranslations.isRTL(locale),
      );
    } catch (e) {
      debugPrint('Failed to save language preference: $e');
      rethrow;
    }
  }

  /// Load language preference from storage
  /// Returns the saved locale or null if not found
  Future<Locale?> loadLanguagePreference() async {
    try {
      final languageCode = await _storageService.read<String>(
        StorageConstants.languageCode,
      );
      final countryCode = await _storageService.read<String>(
        StorageConstants.countryCode,
      );

      if (languageCode != null && countryCode != null) {
        final locale = Locale(languageCode, countryCode);
        if (AppTranslations.isLocaleSupported(locale)) {
          return locale;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Failed to load language preference: $e');
      return null;
    }
  }

  /// Change the application language
  /// [locale] - The new locale to apply
  /// Updates GetX locale and saves preference
  Future<void> changeLanguage(Locale locale) async {
    try {
      if (!AppTranslations.isLocaleSupported(locale)) {
        debugPrint('Locale not supported: $locale');
        return;
      }

      // Update GetX locale
      await Get.updateLocale(locale);

      // Save preference
      await saveLanguagePreference(locale);

      // Update current locale
      _currentLocale.value = locale;

      debugPrint(
        'Language changed to: ${locale.languageCode}_${locale.countryCode}',
      );
    } catch (e) {
      debugPrint('Failed to change language: $e');
      rethrow;
    }
  }

  /// Change language by language code and country code
  /// [languageCode] - The language code (e.g., 'en', 'ar')
  /// [countryCode] - The country code (e.g., 'US', 'SA')
  Future<void> changeLanguageByCode(
    String languageCode,
    String countryCode,
  ) async {
    final locale = Locale(languageCode, countryCode);
    await changeLanguage(locale);
  }

  /// Get the current language name
  /// Returns the localized name of the current language
  String getCurrentLanguageName() {
    return AppTranslations.getLocaleName(_currentLocale.value);
  }

  /// Check if current language is RTL
  /// Returns true if the current language uses RTL text direction
  bool isCurrentLanguageRTL() {
    return AppTranslations.isRTL(_currentLocale.value);
  }

  /// Get list of supported locales
  /// Returns all available locales in the application
  List<Locale> getSupportedLocales() {
    return AppTranslations.supportedLocales;
  }

  /// Get list of supported locale names
  /// Returns localized names for all supported locales
  List<String> getSupportedLocaleNames() {
    return AppTranslations.supportedLocales
        .map((locale) => AppTranslations.getLocaleName(locale))
        .toList();
  }

  /// Switch to next available language
  /// Cycles through supported languages
  Future<void> switchToNextLanguage() async {
    final currentIndex = AppTranslations.supportedLocales.indexWhere(
      (locale) =>
          locale.languageCode == _currentLocale.value.languageCode &&
          locale.countryCode == (_currentLocale.value.countryCode ?? ''),
    );

    final nextIndex =
        (currentIndex + 1) % AppTranslations.supportedLocales.length;
    final nextLocale = AppTranslations.supportedLocales[nextIndex];

    await changeLanguage(nextLocale);
  }
}
