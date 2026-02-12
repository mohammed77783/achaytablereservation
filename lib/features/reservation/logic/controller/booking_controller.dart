import 'package:achaytablereservation/app/routes/app_routes.dart';
import 'package:achaytablereservation/core/base/base_controller.dart';
import 'package:achaytablereservation/features/authentication/logic/authstate_Controller.dart';
import 'package:achaytablereservation/features/reservation/data/models/my_reservation_item.dart';
import 'package:achaytablereservation/features/reservation/data/repositories/ReservationRepository.dart';
import 'package:get/get.dart';

/// Controller for managing user's bookings/reservations list
class BookingsController extends BaseController {
  final ReservationRepository _repository;

  BookingsController({required ReservationRepository repository})
    : _repository = repository;

  /// List of user's reservations
  final reservations = <MyReservationItem>[].obs;

  /// Loading state for initial load
  final isInitialLoading = true.obs;

  /// Loading state for refresh
  final isRefreshing = false.obs;

  /// Check if Arabic locale
  bool get isArabic => Get.locale?.languageCode == 'ar';

  @override
  void onInit() {
    super.onInit();
    // Skip fetching reservations if user is a guest (controller inits via IndexedStack)
    final authController = Get.find<AuthStateController>();
    if (!authController.isGuest) {
      fetchReservations();
    }
  }

  /// Fetch user's reservations from API
  Future<void> fetchReservations() async {
    if (!isInitialLoading.value) {
      isRefreshing.value = true;
    }
    clearError();

    final result = await _repository.getMyReservations();

    result.fold(
      (failure) {
        showErrorFromFailure(failure);
        isInitialLoading.value = false;
        isRefreshing.value = false;
      },
      (data) {
        reservations.value = data;
        isInitialLoading.value = false;
        isRefreshing.value = false;
      },
    );
  }

  /// Refresh reservations list
  Future<void> refreshReservations() async {
    await fetchReservations();
  }

  /// Get status color based on reservation status
  String getStatusKey(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'confirmed';
      case 'pending':
        return 'pending';
      case 'cancelled':
        return 'cancelled';
      case 'completed':
        return 'completed';
      default:
        return status;
    }
  }

  /// Navigate to booking details
  void navigateToDetails(int bookingId) {
    Get.toNamed(AppRoutes.bookingDetails, arguments: {'bookingId': bookingId});
  }
}
