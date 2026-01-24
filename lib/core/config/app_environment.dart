/// Enum representing different application environments
/// Used to distinguish between development, staging, and production builds
enum AppEnvironment {
  /// Development environment for local testing
  dev,

  /// Staging environment for pre-production testing
  staging,

  /// Production environment for live application
  production;

  /// Check if current environment is development
  bool get isDevelopment => this == AppEnvironment.dev;

  /// Check if current environment is staging
  bool get isStaging => this == AppEnvironment.staging;

  /// Check if current environment is production
  bool get isProduction => this == AppEnvironment.production;
}
