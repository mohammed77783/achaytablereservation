import 'package:achaytablereservation/app/routes/app_pages.dart';
import 'package:achaytablereservation/app/routes/app_routes.dart';
import 'package:achaytablereservation/app/themes/dark_theme.dart';
import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/app/translations/app_translations.dart';
import 'package:achaytablereservation/core/config/dev_config.dart';
import 'package:achaytablereservation/core/config/prod_config.dart';
import 'package:achaytablereservation/core/services/theme_service.dart';
import 'package:achaytablereservation/core/services/translation_service.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/bindings/initial_binding.dart';

import 'core/config/environment_config.dart';
import 'core/services/environment_service.dart';
import 'core/services/storage_service.dart';

/// Shared initialization logic for all flavors
/// Initializes services and dependencies before app startup
/// Enhanced for authentication persistence with proper initialization order
///
/// [config] - The environment configuration to use for this flavor
Future<void> initializeApp(EnvironmentConfig config) async {
  // ==================== Locale Data Initialization ====================
  // Initialize date formatting for Arabic and English locales
  await initializeDateFormatting('ar', null);
  await initializeDateFormatting('en', null);

  // ==================== Environment Service Pre-Initialization ====================
  // Initialize EnvironmentService FIRST before any other dependencies
  // This is critical because ApiClient (created in InitialBinding) depends on it
  
  Get.put<EnvironmentService>(EnvironmentService(), permanent: true);

  final environmentService = Get.find<EnvironmentService>();
  environmentService.initialize(config);

  // ==================== Core Services Initialization ====================
  // Now initialize other services - EnvironmentService is ready for ApiClient
  InitialBinding().dependencies();

  // Initialize StorageService - critical for authentication persistence
  final storageService = Get.find<StorageService>();
  await storageService.init();

  // ==================== Authentication System Preparation ====================
  // Ensure AuthStateController is available for splash screen
  // This is already registered in InitialBinding as permanent
  // The splash screen will handle the actual authentication initialization

  // ==================== Security Configuration ====================
  // Initialize SecurityService with freeRASP configuration
  // (Currently commented out - uncomment when security is needed)
  // final securityService = Get.put(SecurityService());
  // await securityService.init(
  //   config: TalsecConfig(
  //     // Android configuration
  //     androidConfig: AndroidConfig(
  //       packageName: 'com.example.tempstractureforachayreservation',
  //       signingCertHashes: [
  //         // Add your signing certificate hashes here
  //         // For development, you can leave this empty or use debug keystore hash
  //       ],
  //       supportedStores: ['com.android.vending'], // Google Play Store
  //     ),
  //     // iOS configuration
  //     iosConfig: IOSConfig(
  //       bundleIds: ['com.example.tempstractureforachayreservation'],
  //       teamId: 'YOUR_TEAM_ID', // Replace with your Apple Team ID
  //     ),
  //     // Watch configuration (optional)
  //     watcherMail: 'security@example.com',
  //   ),
  // );

  // // Perform security check during initialization
  // final securityCheckResult = securityService.performSecurityCheck();

  // // Handle insecure device detection in production builds
  // if (config.environment == AppEnvironment.production &&
  //     !securityCheckResult.isSecure) {
  //   // In production, we want to be strict about security
  //   if (kDebugMode) {
  //     // In debug mode, just log the warning
  //     debugPrint(
  //       'WARNING: Security threats detected in production build: ${securityCheckResult.threats}',
  //     );
  //   }
  //    else
  //     {
  // In release mode, show error and prevent app from running
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Security Warning',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'This app cannot run on this device due to security concerns.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  //     return; // Prevent further initialization
  //   }
  // }

  // Log security check results in non-production environments
  // if (config.environment != AppEnvironment.production) {
  //   debugPrint('Security check completed: ${securityCheckResult.toString()}');
  // }
}

/// Root application widget
/// Shared across all flavors
/// Enhanced for authentication persistence with proper route configuration
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    final translationService = Get.find<TranslationService>();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // ==================== Theme Configuration ====================
      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: themeService.themeMode,

      // ==================== Localization Configuration ====================
      translations: AppTranslations(),
      // Use Arabic as default locale for this app
      // locale: const Locale('ar', 'SA'),
      // locale: translationService.currentLocale, // Uncomment to use dynamic locale
      fallbackLocale: AppTranslations.fallbackLocale,

      // ==================== Navigation Configuration ====================
      // Start with splash screen which will handle authentication flow
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.routes,

      // ==================== App Configuration ====================
      locale: translationService.currentLocale,
 
      // Enable smart management for better performance
      smartManagement: SmartManagement.full,

      // Configure default transitions
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),

      // Handle unknown routes gracefully
      unknownRoute: GetPage(
        name: '/unknown',
        page: () => const Scaffold(body: Center(child: Text('Page not found'))),
      ),
    );
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp(ProdConfig());
  runApp(MyApp());
}
