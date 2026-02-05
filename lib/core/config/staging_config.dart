import 'app_environment.dart';
import 'environment_config.dart';

/// Staging environment configuration
/// Used for pre-production testing and QA
class StagingConfig implements EnvironmentConfig {
  @override
  AppEnvironment get environment => AppEnvironment.staging;

  @override
  String get apiBaseUrl => 'https://staging-api.example.com';

  @override
  String get appName => 'AjaIHR (Staging)';

  @override
  bool get enableLogging => true;

  @override
  bool get enableAnalytics => true;

  @override
  String get publishableKey => 'pk_test_SiJyYMve66Myma5vCZfhKrbWhp3ikYd25viRcRGt';

  @override
  Map<String, dynamic> get additionalConfig => {
    'timeout': 30000,
    'enableDebugMode': false,
    'enableMockData': false,
    'showPerformanceOverlay': false,
  };
}
