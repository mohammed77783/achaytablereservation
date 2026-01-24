import 'package:achaytablereservation/core/network/api_client.dart';
import 'package:achaytablereservation/features/reservation/data/datasources/reservation_datasource.dart';
import 'package:achaytablereservation/features/reservation/data/repositories/ReservationRepository.dart';
import 'package:achaytablereservation/features/reservation/logic/controller/booking_controller.dart';
import 'package:achaytablereservation/features/reservation/logic/controller/booking_detail_controller.dart';
import 'package:get/get.dart';

/// Binding for BookingsPage
/// Sets up dependencies for the bookings list feature
class BookingsBinding extends Bindings {
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

    // Register BookingsController
    Get.lazyPut<BookingsController>(
      () => BookingsController(repository: Get.find<ReservationRepository>()),
    );
  }
}

/// Binding for BookingDetailsPage
/// Sets up dependencies for the booking detail feature
class BookingDetailBinding extends Bindings {
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

    // Register BookingDetailController
    Get.lazyPut<BookingDetailController>(
      () => BookingDetailController(
        repository: Get.find<ReservationRepository>(),
      ),
    );
  }
}
