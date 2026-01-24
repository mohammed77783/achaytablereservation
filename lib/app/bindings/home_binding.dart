import 'package:get/get.dart';

/// Binding for Home page dependencies
///
/// This binding is responsible for injecting dependencies
/// required by the Home page when the route is accessed.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Dependencies for home page will be injected here
    // Example: Get.lazyPut(() => HomeController());

    // Currently no specific controller for home page
    // as it's using inline implementation in main.dart
  }
}
