import 'package:achaytablereservation/core/network/api_client.dart';
import 'package:achaytablereservation/features/reservation/data/datasources/reservation_datasource.dart';
import 'package:achaytablereservation/features/reservation/data/repositories/ReservationRepository.dart';
import 'package:achaytablereservation/features/reservation/logic/controller/reservation_confirmation_controller.dart';
import 'package:achaytablereservation/features/payment/logic/payment_controller.dart';
import 'package:get/get.dart';

/// Binding for ReservationConfirmationPage
/// Sets up the confirmation controller dependency
class ReservationConfirmationBinding extends Bindings {
  @override
  void dependencies() {
    // Get ApiClient (should already be registered globally)
    final apiClient = Get.find<ApiClient>();

    // Register ReservationDataSource if not already registered
    if (!Get.isRegistered<ReservationDataSource>()) {
      Get.lazyPut<ReservationDataSource>(
        () => ReservationDataSource(apiClient: apiClient),
      );
    }

    // Register ReservationRepository if not already registered
    if (!Get.isRegistered<ReservationRepository>()) {
      Get.lazyPut<ReservationRepository>(
        () => ReservationRepository(
          reservationDataSource: Get.find<ReservationDataSource>(),
        ),
      );
    }

    // Register ReservationConfirmationController
    Get.lazyPut<ReservationConfirmationController>(
      () => ReservationConfirmationController(
        repository: Get.find<ReservationRepository>(),
      ),
    );

    // Register PaymentController
    // Get.lazyPut<PaymentController>(
    //   () => PaymentController(
    //     reservationRepository: Get.find<ReservationRepository>(),
    //   ),
    // );
  }
}
