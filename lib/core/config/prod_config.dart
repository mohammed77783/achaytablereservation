import 'app_environment.dart';
import 'environment_config.dart';

/// Production environment configuration
/// Used for live application in production
class ProdConfig implements EnvironmentConfig {
  
  @override
  AppEnvironment get environment => AppEnvironment.dev;
  @override
  String get apiBaseUrl => 'https://shamoustable-api-hwfghabqdxbpbqe6.canadacentral-01.azurewebsites.net/api/reservationMobileApi';
  @override
  String get appName => 'Achay (Pro)';
  @override
  bool get enableLogging => true;
  @override
  bool get enableAnalytics => false;
  @override
  String get publishableKey => 'pk_live_MUqXgycb1VpYZyMaDVQ1NCkuPFmwrqtx7d6n2dYC';
  @override
  Map<String, dynamic> get additionalConfig => {
    'timeout': 30000,
    'enableDebugMode': true,
    'enableMockData': true,
    'showPerformanceOverlay': false,
  };

//pk_live_7nfDAK84rNJtAxuFwXqhyTkxZYpf7Ls4MK88FXhj
}



