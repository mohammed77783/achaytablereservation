import 'app_environment.dart';
import 'environment_config.dart';

/// Development environment configuration
/// Used for local development and testing
class DevConfig implements EnvironmentConfig {
  
  @override
  AppEnvironment get environment => AppEnvironment.dev;
  @override
  String get apiBaseUrl => 'http://192.168.185.247:5265/api';
  @override
  String get appName => 'Achay (Dev)';
  @override
  bool get enableLogging => true;
  @override
  bool get enableAnalytics => false;
  @override
  String get publishableKey => 'pk_test_SiJyYMve66Myma5vCZfhKrbWhp3ikYd25viRcRGt';
  @override
  Map<String, dynamic> get additionalConfig => {
    'timeout': 30000,
    'enableDebugMode': true,
    'enableMockData': true,
    'showPerformanceOverlay': false,
  };
}
