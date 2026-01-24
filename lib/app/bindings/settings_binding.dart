import 'package:get/get.dart';

/// Binding for Settings page dependencies
/// This binding is responsible for injecting dependencies
/// required by the Settings page when the route is accessed.
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // Dependencies for settings page will be injected here
    // Example: Get.lazyPut(() => SettingsController());

    // ThemeService and TranslationService are already available globally
    // Additional dependencies can be added as needed

    
  }
}
