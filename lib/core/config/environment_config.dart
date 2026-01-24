import 'app_environment.dart';

/// Abstract base class for environment-specific configurations
/// Each environment (dev, staging, production) must implement this interface
/// to provide environment-specific values for API endpoints, feature flags, etc.
abstract class EnvironmentConfig {
  /// The environment this configuration represents
  AppEnvironment get environment;

  /// Base URL for API endpoints
  String get apiBaseUrl;

  /// Application name (may include environment suffix)
  String get appName;

  /// Whether to enable detailed logging
  bool get enableLogging;

  /// Whether to enable analytics tracking
  bool get enableAnalytics;

  /// Additional environment-specific configuration values
  /// Can be used for feature flags, timeouts, or other custom settings
  Map<String, dynamic> get additionalConfig;


}
