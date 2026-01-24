/// General application constants
/// Includes app name, version, and configuration settings
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ==================== Application Info ====================

  /// Application name
  static const String appName = 'AjaIHR Application';

  /// Application version
  static const String appVersion = '1.0.0';

  /// Application build number
  static const String buildNumber = '1';

  /// Application package name
  static const String packageName = 'com.example.achaytablereservation';

  /// Application description
  static const String appDescription =
      'A Flutter application with clean architecture';

  static const String termsUrlEn =
      'https://mohammed77783.github.io/achaytermandcondition/';
  static const String termsUrlAr =
      'https://mohammed77783.github.io/achaytermandcondition/index-ar';

  // ==================== Default Settings ====================

  /// Default language code
  static const String defaultLanguage = 'en';

  /// Default country code
  static const String defaultCountryCode = 'US';

  /// Default locale
  static const String defaultLocale = 'en_US';

  /// Supported languages
  static const List<String> supportedLanguages = ['en', 'ar'];

  /// Supported locales
  static const List<String> supportedLocales = ['en_US', 'ar_SA'];

  /// Default theme mode (light, dark, system)
  static const String defaultThemeMode = 'system';

  /// Enable biometric authentication by default
  static const bool defaultBiometricEnabled = false;

  /// Enable notifications by default
  static const bool defaultNotificationsEnabled = true;

  // ==================== UI Configuration ====================

  /// Default animation duration in milliseconds
  static const int defaultAnimationDuration = 300;

  /// Default page transition duration in milliseconds
  static const int defaultPageTransitionDuration = 250;

  /// Default debounce duration in milliseconds
  static const int defaultDebounceDuration = 500;

  /// Default pagination page size
  static const int defaultPageSize = 20;

  /// Maximum file upload size in bytes (10 MB)
  static const int maxFileUploadSize = 10 * 1024 * 1024;

  /// Allowed image file extensions
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
  ];

  /// Allowed document file extensions
  static const List<String> allowedDocumentExtensions = [
    'pdf',
    'doc',
    'docx',
    'txt',
  ];

  // ==================== Cache Configuration ====================
  /// Cache expiration time in hours
  static const int cacheExpirationHours = 24;

  /// Maximum cache size in MB
  static const int maxCacheSizeMB = 100;

  /// Enable cache
  static const bool enableCache = true;

  // ==================== Session Configuration ====================
  /// Session timeout in minutes
  static const int sessionTimeoutMinutes = 60;

  /// Auto logout on session timeout
  static const bool autoLogoutOnTimeout = true;

  /// Remember me duration in days
  static const int rememberMeDays = 30;

  // ==================== Validation Rules ====================

  // /// Minimum password length
  // static const int minPasswordLength = 8;
  // /// Maximum password length
  // static const int maxPasswordLength = 32;
  // /// Minimum username length
  // static const int minUsernameLength = 3;
  // /// Maximum username length
  // static const int maxUsernameLength = 20;
  // /// Password requires uppercase
  // static const bool passwordRequiresUppercase = true;
  // /// Password requires lowercase
  // static const bool passwordRequiresLowercase = true;
  // /// Password requires digit
  // static const bool passwordRequiresDigit = true;
  // /// Password requires special character
  // static const bool passwordRequiresSpecialChar = true;

  // ==================== Date & Time Formats ====================

  /// Default date format
  static const String defaultDateFormat = 'yyyy-MM-dd';

  /// Default time format
  static const String defaultTimeFormat = 'HH:mm:ss';

  /// Default datetime format
  static const String defaultDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  /// Display date format
  static const String displayDateFormat = 'MMM dd, yyyy';

  /// Display time format
  static const String displayTimeFormat = 'hh:mm a';

  // ==================== Error Messages ====================

  /// Generic error message
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';

  /// Network error message
  static const String networkErrorMessage =
      'No internet connection. Please check your network.';

  /// Timeout error message
  static const String timeoutErrorMessage =
      'Request timeout. Please try again.';

  /// Server error message
  static const String serverErrorMessage =
      'Server error. Please try again later.';

  // ==================== Feature Flags ====================

  /// Enable dark mode feature
  static const bool enableDarkMode = true;

  /// Enable multi-language feature
  static const bool enableMultiLanguage = true;

  /// Enable offline mode
  static const bool enableOfflineMode = false;

  /// Enable analytics
  static const bool enableAnalytics = false;

  /// Enable crash reporting
  static const bool enableCrashReporting = false;
}
