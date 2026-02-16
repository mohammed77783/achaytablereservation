import 'package:achaytablereservation/features/reservation/data/repositories/ReservationRepository.dart';
import 'package:achaytablereservation/features/reservation/logic/controller/reservation_controller.dart';
import 'package:get/get.dart';
import 'package:achaytablereservation/core/network/api_client.dart';
import 'package:achaytablereservation/features/reservation/data/datasources/reservation_datasource.dart';

/// Binding for ReservationPage
/// Sets up all required dependencies for the reservation feature
class ReservationBinding extends Bindings {
  @override
  void dependencies() {
    // Get ApiClient (should already be registered globally)
    final apiClient = Get.find<ApiClient>();

    // Register ReservationDataSource if not already registered
    if (!Get.isRegistered<ReservationDataSource>()) {
      Get.lazyPut<ReservationDataSource>(
        () => ReservationDataSource(apiClient: apiClient),
        fenix: true,
      );
    }

    // Register ReservationRepository if not already registered
    if (!Get.isRegistered<ReservationRepository>()) {
      Get.lazyPut<ReservationRepository>(
        () => ReservationRepository(
          reservationDataSource: Get.find<ReservationDataSource>(),
        ),
        fenix: true,
      );
    }

    // Register ReservationController
    Get.lazyPut<ReservationController>(
      () =>
          ReservationController(repository: Get.find<ReservationRepository>()),
      fenix: true,
    );
  }
}
