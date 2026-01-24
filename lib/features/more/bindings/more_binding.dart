import 'package:get/get.dart';
import '../logic/more_controller.dart';
import '../../../core/services/storage_service.dart';

/// Binding for More feature
/// Injects MoreController with its dependencies
class MoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MoreController>(
      () => MoreController(storageService: Get.find<StorageService>()),
    );
  }
}
