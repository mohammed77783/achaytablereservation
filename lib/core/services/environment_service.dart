import 'package:get/get.dart';

import '../config/app_environment.dart';
import '../config/environment_config.dart';

/// Service for managing environment configuration
/// Provides centralized access to environment-specific settings
/// Must be initialized with an EnvironmentConfig before use
class EnvironmentService extends GetxService {
  late EnvironmentConfig _config;
  bool _isInitialized = false;

  /// Initialize the environment service with a configuration
  /// [config] - The environment configuration to use
  /// Must be called before accessing any configuration values
  void initialize(EnvironmentConfig config) {
    _config = config;
    _isInitialized = true;
  }

  /// Check if the service has been initialized
  bool get isInitialized => _isInitialized;

  /// Get the complete environment configuration
  /// Throws [StateError] if not initialized
  EnvironmentConfig get config {
    _ensureInitialized();
    return _config;
  }

  /// Get the current environment
  /// Throws [StateError] if not initialized
  AppEnvironment get currentEnvironment {
    _ensureInitialized();
    return _config.environment;
  }

  /// Get the API base URL for the current environment
  /// Throws [StateError] if not initialized
  String get apiBaseUrl {
    _ensureInitialized();
    return _config.apiBaseUrl;
  }

  /// Get the application name for the current environment
  /// Throws [StateError] if not initialized
  String get appName {
    _ensureInitialized();
    return _config.appName;
  }

  /// Check if logging is enabled in the current environment
  /// Throws [StateError] if not initialized
  bool get enableLogging {
    _ensureInitialized();
    return _config.enableLogging;
  }

  /// Check if analytics is enabled in the current environment
  /// Throws [StateError] if not initialized
  bool get enableAnalytics {
    _ensureInitialized();
    return _config.enableAnalytics;
  }

  /// Get the Moyasar publishable API key for the current environment
  /// Throws [StateError] if not initialized
  String get publishableKey {
    _ensureInitialized();
    return _config.publishableKey;
  }

  /// Get additional configuration values
  /// Throws [StateError] if not initialized
  Map<String, dynamic> get additionalConfig {
    _ensureInitialized();
    return _config.additionalConfig;
  }

  /// Check if current environment is production
  /// Throws [StateError] if not initialized
  bool get isProduction {
    _ensureInitialized();
    return _config.environment.isProduction;
  }

  /// Check if current environment is development
  /// Throws [StateError] if not initialized
  bool get isDevelopment {
    _ensureInitialized();
    return _config.environment.isDevelopment;
  }

  /// Check if current environment is staging
  /// Throws [StateError] if not initialized
  bool get isStaging {
    _ensureInitialized();
    return _config.environment.isStaging;
  }

  /// Get a specific additional config value by key
  /// Returns null if the key doesn't exist
  /// Throws [StateError] if not initialized
  T? getAdditionalConfig<T>(String key) {
    _ensureInitialized();
    return _config.additionalConfig[key] as T?;
  }

  /// Ensure the service is initialized before accessing configuration
  /// Throws [StateError] if not initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'EnvironmentService not initialized. Call initialize() first.',
      );
    }
  }
}
