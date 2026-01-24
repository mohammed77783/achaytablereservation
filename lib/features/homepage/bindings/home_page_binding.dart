import 'package:achaytablereservation/features/homepage/logic/branch_info_controller.dart';
import 'package:get/get.dart';
import 'package:achaytablereservation/core/network/api_client.dart';
import 'package:achaytablereservation/core/services/storage_service.dart';
import 'package:achaytablereservation/features/homepage/data/datasources/homepage_data_sources.dart';
import 'package:achaytablereservation/features/homepage/data/repositories/homepage_repository.dart';
import 'package:achaytablereservation/features/homepage/logic/homepage_controller.dart';

class HomePageBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure core dependencies are available
    // These should already be registered in InitialBinding, but we verify they exist
    if (!Get.isRegistered<StorageService>()) {
      Get.lazyPut<StorageService>(() => StorageService());
    }

    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient());
    }

    // Register HomepageDataSources with explicit dependency injection
    // HomepageDataSources depends on ApiClient (constructor) and StorageService (Get.find)
    Get.lazyPut<HomepageDataSources>(
      () => HomepageDataSources(apiClient: Get.find<ApiClient>()),
      fenix: true, // Allow recreation if needed
    );

    // Register HomepageRepository with explicit dependency injection
    // HomepageRepository depends on HomepageDataSources
    Get.lazyPut<HomepageRepository>(
      () => HomepageRepository(homepageData: Get.find<HomepageDataSources>()),
      fenix: true, // Allow recreation if needed
    );

    // Register HomeController with explicit dependency injection
    // HomeController depends on HomepageRepository
    Get.lazyPut<HomeController>(
      () => HomeController(repository: Get.find<HomepageRepository>()),
      fenix: true, // Allow recreation if needed
    );

    Get.lazyPut<BranchInfoController>(
      fenix: true,
      () => BranchInfoController(repository: Get.find<HomepageRepository>()),
    );
  }
}
