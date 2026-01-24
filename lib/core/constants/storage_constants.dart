/// Storage key constants for local data persistence
/// Includes keys for theme, language, user data, and other preferences
class StorageConstants {
  // Private constructor to prevent instantiation
  StorageConstants._();

  // ==================== Storage Container ====================

  /// Main storage container name
  static const String storageContainer = 'app_storage';
  // ==================== Theme Preferences ====================

  /// Key for storing theme mode preference (light, dark, system)
  static const String themeMode = 'theme_mode';

  /// Key for storing custom theme color
  static const String themeColor = 'theme_color';

  /// Key for storing theme brightness
  static const String themeBrightness = 'theme_brightness';

  // ==================== Language Preferences ====================

  /// Key for storing selected language code (en, ar, etc.)
  static const String languageCode = 'language_code';

  /// Key for storing selected country code (US, SA, etc.)
  static const String countryCode = 'country_code';

  /// Key for storing full locale (en_US, ar_SA, etc.)
  static const String locale = 'locale';

  /// Key for storing RTL (right-to-left) preference
  static const String isRTL = 'is_rtl';

  // ==================== User Data ====================

  /// Key for storing user ID
  static const String userId = 'user_id';

  /// Key for storing user email
  static const String userEmail = 'user_email';

  /// Key for storing user name
  static const String userName = 'user_name';

  /// Key for storing user phone number
  static const String userPhone = 'user_phone';

  /// Key for storing user profile picture URL
  static const String userProfilePicture = 'user_profile_picture';

  /// Key for storing user role
  static const String userRole = 'user_role';

  /// Key for storing complete user data as JSON
  static const String userData = 'user_data';

  // ==================== Authentication ====================

  /// Key for storing authentication token
  static const String authToken = 'auth_token';

  /// Key for storing authenticated user data as JSON
  static const String authUser = 'auth_user';

  /// Key for storing refresh token
  static const String refreshToken = 'refresh_token';

  /// Key for storing token expiration time
  static const String tokenExpiration = 'token_expiration';

  /// Key for storing refresh token expiration time
  static const String refreshTokenExpiration = 'refresh_token_expiration';

  /// Key for storing login status
  static const String isLoggedIn = 'is_logged_in';

  /// Key for storing remember me preference
  static const String rememberMe = 'remember_me';

  /// Key for storing last login timestamp
  static const String lastLoginTime = 'last_login_time';

  /// Key for storing current authentication flow state
  static const String authFlow = 'auth_flow';

  /// Key for storing phone number during authentication flows
  static const String authPhoneNumber = 'auth_phone_number';

  // ==================== App Settings ====================

  /// Key for storing notification enabled status
  static const String notificationsEnabled = 'notifications_enabled';

  /// Key for storing biometric authentication enabled status
  static const String biometricEnabled = 'biometric_enabled';

  /// Key for storing auto-lock enabled status
  static const String autoLockEnabled = 'auto_lock_enabled';

  /// Key for storing auto-lock timeout duration
  static const String autoLockTimeout = 'auto_lock_timeout';

  /// Key for storing sound enabled status
  static const String soundEnabled = 'sound_enabled';

  /// Key for storing vibration enabled status
  static const String vibrationEnabled = 'vibration_enabled';

  // ==================== Onboarding & First Launch ====================

  /// Key for storing first launch status
  static const String isFirstLaunch = 'is_first_launch';

  /// Key for storing onboarding completed status
  static const String onboardingCompleted = 'onboarding_completed';

  /// Key for storing app version for migration tracking
  static const String appVersion = 'app_version';

  /// Key for storing last app update check time
  static const String lastUpdateCheck = 'last_update_check';

  // ==================== Cache & Data ====================

  /// Key for storing cached data timestamp
  static const String cacheTimestamp = 'cache_timestamp';

  /// Key for storing last sync time
  static const String lastSyncTime = 'last_sync_time';

  /// Key for storing offline mode status
  static const String offlineMode = 'offline_mode';

  /// Key for storing cached user preferences
  static const String cachedPreferences = 'cached_preferences';

  // ==================== Search & History ====================

  /// Key for storing search history
  static const String searchHistory = 'search_history';

  /// Key for storing recent items
  static const String recentItems = 'recent_items';

  /// Key for storing favorites list
  static const String favorites = 'favorites';

  /// Key for storing bookmarks
  static const String bookmarks = 'bookmarks';

  // ==================== Analytics & Tracking ====================

  /// Key for storing analytics enabled status
  static const String analyticsEnabled = 'analytics_enabled';

  /// Key for storing crash reporting enabled status
  static const String crashReportingEnabled = 'crash_reporting_enabled';

  /// Key for storing user consent for data collection
  static const String dataCollectionConsent = 'data_collection_consent';

  // ==================== Feature-Specific Keys ====================

  /// Prefix for feature-specific storage keys
  static const String featurePrefix = 'feature_';

  /// Key for storing example feature data
  static const String exampleFeatureData = 'feature_example_data';

  /// Key for storing example feature settings
  static const String exampleFeatureSettings = 'feature_example_settings';

  // ==================== Helper Methods ====================

  /// Generate a feature-specific key
  static String featureKey(String featureName, String key) {
    return '${featurePrefix}${featureName}_$key';
  }

  /// Generate a user-specific key
  static String userKey(String userId, String key) {
    return 'user_${userId}_$key';
  }

  /// Generate a cache key with timestamp
  static String cacheKey(String key) {
    return 'cache_$key';
  }
}
