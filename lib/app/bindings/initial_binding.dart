import 'package:achaytablereservation/core/network/api_client.dart';
import 'package:achaytablereservation/core/network/auth_interceptor.dart';
import 'package:achaytablereservation/features/setupfeature/logic/splash_screen_controller.dart';
import 'package:achaytablereservation/features/authentication/data/datasources/auth_datasource.dart';
import 'package:achaytablereservation/features/authentication/data/repositories/auth_repository.dart';
import 'package:achaytablereservation/features/authentication/logic/authstate_Controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/services/storage_service.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/translation_service.dart';

/// Initial binding for dependency injection
/// Injects core services that are needed throughout the application lifecycle
/// Enhanced for authentication persistence with proper dependency order
/// Uses lazy loading to instantiate services only when they are first accessed
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ==================== Core Services ====================
    // Core services that should be available throughout the app
    // Note: EnvironmentService is initialized in main_common.dart before this binding
    Get.lazyPut<StorageService>(() => StorageService());
    Get.lazyPut<ThemeService>(() => ThemeService());
    Get.lazyPut<TranslationService>(() => TranslationService());

    // ==================== Network Layer ====================
    // API client with authentication interceptor
    Get.lazyPut<ApiClient>(() {
      final apiClient = ApiClient();
      final storageService = Get.find<StorageService>();
      final httpClient = http.Client();
      final authInterceptor = AuthInterceptor(storageService, httpClient);
      // Register auth interceptor for automatic token injection and 401 handling
      apiClient.addRequestInterceptor(authInterceptor.onRequest);
      apiClient.addResponseInterceptor(authInterceptor.onResponse);
      return apiClient;
    }, fenix: true);

    // ==================== Authentication Layer ====================
    // Authentication dependencies needed for splash screen and app initialization
    // Order is important: DataSource -> Repository -> StateController -> SplashController

    Get.lazyPut<AuthDataSource>(
      () => AuthDataSource(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<AuthRepository>(
      () => AuthRepository(
        dataSource: Get.find<AuthDataSource>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    // AuthStateController as permanent since it's needed throughout the app lifecycle
    // This controller manages global authentication state and is used by splash screen
    Get.put<AuthStateController>(
      AuthStateController(authRepository: Get.find<AuthRepository>()),
      permanent: true,
    );

    // ==================== App Initialization ====================
    // Splash screen controller - handles app startup and authentication flow
    // Uses AuthStateController for authentication state management
    Get.lazyPut<SplashScreenController>(
      () => SplashScreenController(),
      fenix: true,
    );
  }
}
