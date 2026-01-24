import 'app_environment.dart';
import 'environment_config.dart';

/// Production environment configuration
/// Used for live application in production
class ProdConfig implements EnvironmentConfig {
  @override
  AppEnvironment get environment => AppEnvironment.production;

  @override
  String get apiBaseUrl => 'https://api.example.com';

  @override
  String get appName => 'Achay';

  @override
  bool get enableLogging => false;

  @override
  bool get enableAnalytics => true;

  @override
  Map<String, dynamic> get additionalConfig => {
    'timeout': 15000,
    'enableDebugMode': false,
    'enableMockData': false,
    'showPerformanceOverlay': false,
  };
}
