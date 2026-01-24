import 'package:get/get.dart';
import 'settings_controller.dart';
import '../../core/services/storage_service.dart';

/// Binding for Settings feature
/// Injects SettingsController with its dependencies
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(
      () => SettingsController(storageService: Get.find<StorageService>()),
    );
  }
}
