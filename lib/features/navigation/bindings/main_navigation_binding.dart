import 'package:achaytablereservation/features/homepage/bindings/home_page_binding.dart';
import 'package:achaytablereservation/features/reservation/bindging/bookings_binding.dart';
import 'package:achaytablereservation/features/more/bindings/more_binding.dart';
import 'package:get/get.dart';
import 'package:achaytablereservation/core/services/storage_service.dart';
import 'package:achaytablereservation/features/navigation/logic/main_navigation_controller.dart';

/// Binding for Main Navigation dependencies
///
/// This binding is responsible for injecting dependencies
/// required by the MainNavigationScaffold when the route is accessed.
/// Registers the MainNavigationController with its required StorageService dependency.
class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure StorageService is available
    // This should already be registered in InitialBinding, but we verify it exists
    if (!Get.isRegistered<StorageService>()) {
      Get.lazyPut<StorageService>(() => StorageService());
    }

    // Register MainNavigationController with explicit dependency injection
    // MainNavigationController depends on StorageService
    Get.lazyPut<MainNavigationController>(
      () =>
          MainNavigationController(storageService: Get.find<StorageService>()),
      fenix: true, // Allow recreation if needed
    );

    // Register HomePage dependencies
    HomePageBinding().dependencies();

    // Register BookingsController for the bookings tab
    BookingsBinding().dependencies();

    // Register MoreController for the more tab
    MoreBinding().dependencies();
  }
}
