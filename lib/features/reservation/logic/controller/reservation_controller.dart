import 'package:achaytablereservation/app/routes/app_routes.dart';
import 'package:achaytablereservation/app/themes/dark_theme.dart';
import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/features/reservation/data/models/available_table.dart';
import 'package:achaytablereservation/features/reservation/data/repositories/ReservationRepository.dart';
import 'package:achaytablereservation/features/reservation/logic/class/SelectedTimeSlot.dart';
import 'package:achaytablereservation/features/reservation/ui/widget/buildInfoRow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:achaytablereservation/core/errors/failures.dart';
import 'package:achaytablereservation/features/reservation/data/models/reservation_models.dart';
import 'package:achaytablereservation/features/reservation/data/models/reservation_arguments.dart';
import 'package:iconsax/iconsax.dart';

/// Controller for ReservationPage
/// Handles calendar selection, time slot fetching, and price calculation
class ReservationController extends GetxController {
  final ReservationRepository _repository;

  ReservationController({required ReservationRepository repository})
    : _repository = repository;

  // ══════════════════════════════════════════════════════════════════════════
  // OBSERVABLE STATE
  // ══════════════════════════════════════════════════════════════════════════

  /// Restaurant information from API
  final Rx<RestaurantInfo?> restaurantInfo = Rx<RestaurantInfo?>(null);

  /// Current availability response
  final Rx<RestaurantAvailabilityResponse?> currentResponse =
      Rx<RestaurantAvailabilityResponse?>(null);

  /// Calendar state
  final Rx<DateTime> focusedDate = Rx<DateTime>(DateTime.now());
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  /// Selected Hijri date string (from API response format: "1447-07-16")
  final Rx<String?> selectedHijriDate = Rx<String?>(null);

  /// Availability data cache - maps Hijri date string to availability response
  final RxMap<String, RestaurantAvailabilityResponse> _availabilityCache =
      <String, RestaurantAvailabilityResponse>{}.obs;

  /// Loading states
  final RxBool isLoadingSlots = false.obs;
  final RxBool isInitialLoading = true.obs;
  final RxBool isCheckingAvailability = false.obs;

  /// Error state
  final Rx<String?> errorMessage = Rx<String?>(null);

  /// Time slots for selected date (grouped by hall name)
  final RxMap<String, List<TimeSlot>> groupedTimeSlots =
      <String, List<TimeSlot>>{}.obs;

  /// All halls from current response
  final RxList<Hall> currentHalls = <Hall>[].obs;

  /// Selected time slot
  final Rx<SelectedTimeSlot?> selectedTimeSlot = Rx<SelectedTimeSlot?>(null);

  /// Guest count
  final RxInt guestCount = 1.obs;

  /// Restaurant ID (should be passed via arguments)
  late final int restaurantId;

  /// Restaurant display name
  String get displayName =>
      restaurantInfo.value?.fullName ??
      restaurantInfo.value?.branchName ??
      (isArabic ? 'المطعم' : 'Restaurant');

  /// Selected date display from API (e.g., "الاثنين، 16 رجب 1447")
  String get selectedDateDisplay =>
      currentResponse.value?.selectedDateDisplay ?? '';

  /// Month name from API
  String get monthName => currentResponse.value?.monthName ?? '';

  /// Year from API
  int get year => currentResponse.value?.year ?? DateTime.now().year;

  // ══════════════════════════════════════════════════════════════════════════
  // CONSTANTS - Table Capacity Tiers
  // ══════════════════════════════════════════════════════════════════════════

  /// Table capacity tiers:
  /// 1-4 guests → 4 person table (minimum)
  /// 5-8 guests → 8 person table
  /// 9-12 guests → 12 person table
  /// 13+ guests → calculated based on guest count (rounded up to nearest 4)
  static const List<int> _tableCapacityTiers = [4, 8, 12];

  /// Minimum guests
  int get minGuests => 1;

  /// Maximum guests (set to a reasonable limit, can be increased if needed)
  int get maxGuests => 250;

  // ══════════════════════════════════════════════════════════════════════════
  // COMPUTED PROPERTIES
  // ══════════════════════════════════════════════════════════════════════════

  /// Check if current locale is Arabic
  bool get isArabic => Get.locale?.languageCode == 'ar';

  /// Get price per person from selected time slot
  double get pricePerPerson => selectedTimeSlot.value?.timeSlot.price ?? 0.0;

  /// Calculate table capacity based on guest count
  /// Uses tier system: 1-4 → 4, 5-8 → 8, 9-12 → 12
  /// For 13+ guests, calculates capacity by rounding up to nearest 4
  int get tableCapacity {
    // Use predefined tiers for smaller groups
    for (final tier in _tableCapacityTiers) {
      if (guestCount.value <= tier) {
        return tier;
      }
    }

    // For larger groups (13+), calculate capacity by rounding up to nearest 4
    // This ensures we always have enough seats
    final extraGuests = guestCount.value - _tableCapacityTiers.last;
    final extraTables = (extraGuests / 4).ceil();
    return _tableCapacityTiers.last + (extraTables * 4);
  }

  /// Calculate total price based on table capacity (not guest count)
  /// Price = pricePerPerson × tableCapacity
  double get totalPrice => pricePerPerson * tableCapacity;

  /// Check if user can proceed to confirmation
  bool get canProceed =>
      selectedDate.value != null &&
      selectedTimeSlot.value != null &&
      guestCount.value >= minGuests &&
      guestCount.value <= maxGuests;

  /// Get calendar days from current response
  List<CalendarDay> get calendarDays => currentResponse.value?.calendar ?? [];

  // ══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ══════════════════════════════════════════════════════════════════════════

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  /// Initialize controller with restaurant ID from arguments
  Future<void> _initializeController() async {
    try {
      // Get restaurant ID from route arguments
      final args = Get.arguments;
      if (args != null && args is Map<String, dynamic>) {
        restaurantId = args['restaurantId'] as int? ?? 4;
      } else if (args is int) {
        restaurantId = args;
      } else {
        restaurantId = 4; // Default fallback (from sample response)
      }

      // Fetch initial data (without date to get default/today)
      await _fetchAvailability();
    } catch (e) {
      errorMessage.value = 'failed_to_load_data'.tr;
    } finally {
      isInitialLoading.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DATE SELECTION & AVAILABILITY
  // ══════════════════════════════════════════════════════════════════════════

  /// Select a date and fetch availability
  /// [date] is the Gregorian DateTime from calendar widget
  Future<void> selectDate(DateTime date) async {
    // Don't reselect the same date
    if (selectedDate.value != null && _isSameDay(selectedDate.value!, date)) {
      return;
    }

    selectedDate.value = date;
    focusedDate.value = date;

    // Clear previous selection
    selectedTimeSlot.value = null;
    groupedTimeSlots.clear();

    // Fetch availability for selected date
    await _fetchAvailabilityForDate(date);
  }

  /// Fetch availability data without specific date (initial load)
  Future<void> _fetchAvailability() async {
    isLoadingSlots.value = true;
    errorMessage.value = null;

    try {
      final result = await _repository.getRestaurantAvailability(
        restaurantId: restaurantId,
      );

      result.fold(
        (failure) => _handleFailure(failure),
        (response) => _handleSuccessResponse(response),
      );
    } catch (e) {
      errorMessage.value = 'error_fetching_data'.tr;
    } finally {
      isLoadingSlots.value = false;
    }
  }

  /// Fetch availability data for a specific date
  Future<void> _fetchAvailabilityForDate(DateTime date) async {
    final dateString = _formatDateForApi(date);

    // Check cache first
    if (_availabilityCache.containsKey(dateString)) {
      _handleSuccessResponse(_availabilityCache[dateString]!);
      return;
    }

    isLoadingSlots.value = true;
    errorMessage.value = null;

    try {
      final result = await _repository.getRestaurantAvailability(
        restaurantId: restaurantId,
        date: dateString,
      );

      result.fold((failure) => _handleFailure(failure), (response) {
        // Cache the response
        _availabilityCache[dateString] = response;
        _handleSuccessResponse(response);
      });
    } catch (e) {
      errorMessage.value = 'error_fetching_data'.tr;
    } finally {
      isLoadingSlots.value = false;
    }
  }

  /// Handle successful API response
  void _handleSuccessResponse(RestaurantAvailabilityResponse response) {
    currentResponse.value = response;
    restaurantInfo.value = response.restaurant;
    selectedHijriDate.value = response.selectedDate;
    // Update halls
    currentHalls.value = response.halls;
    // Group time slots by hall
    _updateGroupedTimeSlots(response.halls);
  }

  /// Update grouped time slots from halls
  void _updateGroupedTimeSlots(List<Hall> halls) {
    groupedTimeSlots.clear();

    for (final hall in halls) {
      // Include all slots, UI will show availability status
      if (hall.timeSlots.isNotEmpty) {
        groupedTimeSlots[hall.hallName] = hall.timeSlots;
      }
    }
  }

  /// Get availability status for a date (for calendar display)
  /// Uses calendar data from API response
  AvailabilityStatus getDateStatus(DateTime date) {
    // Past dates are unavailable
    if (_isBeforeToday(date)) {
      return AvailabilityStatus.unavailable;
    }

    // Check calendar data from current response
    final calendar = currentResponse.value?.calendar;
    if (calendar != null && calendar.isNotEmpty) {
      // Find matching calendar day by date string or day number
      final dateString = _formatDateForApi(date);
      CalendarDay? calendarDay;

      for (final day in calendar) {
        if (day.date == dateString || day.day == date.day) {
          calendarDay = day;
          break;
        }
      }

      // If date is not in calendar list, it's unavailable
      if (calendarDay == null) {
        return AvailabilityStatus.unavailable;
      }

      // Return status based on availability
      return calendarDay.hasAvailability
          ? AvailabilityStatus.available
          : AvailabilityStatus.unavailable;
    }

    // Default to available for future dates when no calendar data
    return AvailabilityStatus.available;
  }

  /// Check if a date is selectable
  bool isDateSelectable(DateTime date) {
    // Can't select past dates
    if (_isBeforeToday(date)) {
      return false;
    }

    // Can't select dates more than 90 days in future
    final maxDate = DateTime.now().add(const Duration(days: 90));
    if (date.isAfter(maxDate)) {
      return false;
    }

    // Check if date exists in calendar list from API
    final calendar = currentResponse.value?.calendar;
    if (calendar != null && calendar.isNotEmpty) {
      // Find matching calendar day by date string or day number
      final dateString = _formatDateForApi(date);
      CalendarDay? calendarDay;

      for (final day in calendar) {
        if (day.date == dateString || day.day == date.day) {
          calendarDay = day;
          break;
        }
      }

      // If date is not in calendar list, it's not selectable
      if (calendarDay == null) {
        return false;
      }

      // Date must have availability to be selectable
      return calendarDay.hasAvailability;
    }

    // If no calendar data available, allow selection (fallback)
    return true;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TIME SLOT SELECTION
  // ══════════════════════════════════════════════════════════════════════════

  /// Select a time slot
  void selectTimeSlot(TimeSlot slot, String hallName) {
    // Only allow selecting available slots
    if (!slot.isAvailable) return;

    // Find the hall
    Hall? hall;
    for (final h in currentHalls) {
      if (h.hallName == hallName) {
        hall = h;
        break;
      }
    }

    if (hall != null) {
      selectedTimeSlot.value = SelectedTimeSlot(timeSlot: slot, hall: hall);
    }
  }

  /// Check if a time slot is selected
  bool isTimeSlotSelected(TimeSlot slot, String hallName) {
    final selected = selectedTimeSlot.value;
    if (selected == null) return false;

    return selected.timeSlot.time == slot.time &&
        selected.hall.hallName == hallName;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GUEST COUNT & PRICING
  // ══════════════════════════════════════════════════════════════════════════

  /// Increase guest count
  void increaseGuests() {
    if (guestCount.value < maxGuests) {
      guestCount.value++;
    }
  }

  /// Decrease guest count
  void decreaseGuests() {
    if (guestCount.value > minGuests) {
      guestCount.value--;
    }
  }

  /// Set guest count directly
  void setGuestCount(int count) {
    if (count >= minGuests && count <= maxGuests) {
      guestCount.value = count;
    }
  }

  /// Get pricing breakdown for display
  Map<String, dynamic> getPricingBreakdown() {
    return {
      'pricePerPerson': pricePerPerson,
      'guestCount': guestCount.value,
      'tableCapacity': tableCapacity,
      'totalPrice': totalPrice,
      'capacityTier': _getCapacityTierDescription(),
    };
  }

  /// Get capacity tier description for UI
  String _getCapacityTierDescription() {
    final capacity = tableCapacity;
    final guests = guestCount.value;

    if (guests <= 12) {
      return 'table_capacity_small'.trParams({'capacity': '$capacity'});
    } else {
      // For larger groups, show both guest count and table capacity
      return 'table_capacity_large'.trParams({
        'guests': '$guests',
        'capacity': '$capacity',
      });
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NAVIGATION
  // ══════════════════════════════════════════════════════════════════════════

  /// Navigate back
  void goBack() {
    Get.back;
  }

  /// Navigate to confirmation page
  // void navigateToConfirmation() {
  //   if (!canProceed) return;

  //   final reservationData = {
  //     'restaurantId': restaurantId,
  //     'restaurantInfo': restaurantInfo.value,
  //     'selectedDate': selectedDate.value,
  //     'selectedHijriDate': selectedHijriDate.value,
  //     'selectedDateDisplay': selectedDateDisplay,
  //     'selectedTimeSlot': selectedTimeSlot.value,
  //     'hallId': selectedTimeSlot.value?.hall.hallId,
  //     'hallName': selectedTimeSlot.value?.hall.hallName,
  //     'guestCount': guestCount.value,
  //     'tableCapacity': tableCapacity,
  //     'pricePerPerson': pricePerPerson,
  //     'totalPrice': totalPrice,
  //   };

  //   Get.toNamed('/reservation/confirmation', arguments: reservationData);
  // }
  /// Navigate to confirmation page after checking table availability
  Future<void> navigateToConfirmation() async {
    if (!canProceed) return;
    // Show loading indicator
    isCheckingAvailability.value = true;
    try {
      // Check table availability first
      final result = await _repository.checkTableAvailability(
        hallId: selectedTimeSlot.value!.hall.hallId,
        date: _formatDateForApi(selectedDate.value!),
        time: selectedTimeSlot.value!.timeSlot.time,
      );
      result.fold(
        (failure) {
          // Handle failure
          isCheckingAvailability.value = false;
          _showAvailabilityErrorDialog(failure);
        },
        (response) {
          isCheckingAvailability.value = false;
          if (response.availableTablesCount > 0) {
            // Calculate required number of tables based on guest count
            final requiredTables = _calculateRequiredTables(guestCount.value);
            // Check if we have enough available tables
            if (response.availableTablesCount >= requiredTables) {
              // Sufficient tables available, proceed to confirmation
              // Sufficient tables available, proceed to confirmation
              final args = ReservationConfirmationArguments(
                restaurantId: restaurantId,
                restaurantInfo: restaurantInfo.value,
                selectedDate: selectedDate.value,
                selectedHijriDate: selectedHijriDate.value,
                selectedDateDisplay: selectedDateDisplay,
                selectedTimeSlot: selectedTimeSlot.value,
                hallId: selectedTimeSlot.value?.hall.hallId,
                hallName: selectedTimeSlot.value?.hall.hallName,
                guestCount: guestCount.value,
                tableCapacity: tableCapacity,
                pricePerPerson: pricePerPerson,
                totalPrice: totalPrice,
                availableTablesCount: response.availableTablesCount,
                availableTables: response.availableTables,
                requiredTables: requiredTables,
                totalCapacity: response.totalCapacity,
              );

              Get.toNamed(
                AppRoutes.reservationpageconfirmation,
                arguments: args,
              );
            } else {
              // Not enough tables available, show insufficient tables dialog
              _showInsufficientTablesDialog(response, requiredTables);
            }
          } else {
            // No tables available, show dialog with details
            _showNoTablesAvailableDialog(response);
          }
        },
      );
    } catch (e) {
      isCheckingAvailability.value = false;
      _showGeneralErrorDialog();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ERROR HANDLING
  // ══════════════════════════════════════════════════════════════════════════

  /// Handle failure and set appropriate error message
  void _handleFailure(Failure failure) {
    if (failure is NetworkFailure) {
      errorMessage.value = 'network_error'.tr;
    } else if (failure is ServerFailure) {
      errorMessage.value = 'server_error'.tr;
    } else if (failure is TimeoutFailure) {
      errorMessage.value = 'timeout_error'.tr;
    } else {
      errorMessage.value = 'unexpected_error'.tr;
    }
  }

  /// Clear error message
  void clearError() {
    errorMessage.value = null;
  }

  /// Retry fetching data
  Future<void> retry() async {
    clearError();
    if (selectedDate.value != null) {
      await _fetchAvailabilityForDate(selectedDate.value!);
    } else {
      await _fetchAvailability();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// Format date for API (yyyy-MM-dd)
  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check if date is before today
  bool _isBeforeToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isBefore(today);
  }

  /// Calculate the number of tables required based on guest count
  /// Uses the same logic as tableCapacity but returns number of tables needed
  int _calculateRequiredTables(int guests) {
    // Each table seats 4 people
    // Round up to get the number of tables needed
    return (guests / 4).ceil();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // check availability
  // ══════════════════════════════════════════════════════════════════════════

  // check avalbility
  void _showAvailabilityErrorDialog(Failure failure) {
    String message;

    if (failure is NetworkFailure) {
      message = failure.message;
    } else if (failure is TimeoutFailure) {
      message = failure.message;
    } else {
      message = failure.message;
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: Get.isDarkMode
            ? DarkTheme.cardBackground
            : LightTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
        ),
        title: Row(
          children: [
            Icon(
              Iconsax.warning_2,
              color: Get.isDarkMode
                  ? DarkTheme.errorColor
                  : LightTheme.errorColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'error'.tr,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Get.isDarkMode
                      ? DarkTheme.textPrimary
                      : LightTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: Get.isDarkMode
                ? DarkTheme.textSecondary
                : LightTheme.textSecondary,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.isDarkMode
                  ? DarkTheme.secondaryColor
                  : LightTheme.primaryColor,
              foregroundColor: Get.isDarkMode
                  ? DarkTheme.textOnSecondary
                  : LightTheme.textOnPrimary,
            ),
            child: Text(
              isArabic ? 'حسناً' : 'OK',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }

  void _showNoTablesAvailableDialog(CheckTableAvailabilityResponse response) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.isDarkMode
            ? DarkTheme.cardBackground
            : LightTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
        ),
        title: Row(
          children: [
            Icon(
              Iconsax.info_circle,
              color: Get.isDarkMode
                  ? DarkTheme.warningColor
                  : LightTheme.warningColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'no_tables_available_title'.tr,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Get.isDarkMode
                      ? DarkTheme.textPrimary
                      : LightTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'no_tables_available_message'.tr,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Get.isDarkMode
                    ? DarkTheme.textSecondary
                    : LightTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // Show details
            buildInfoRow(
              icon: Iconsax.building_4,
              label: 'hall'.tr + ':',
              value: response.hallName,
            ),
            const SizedBox(height: 8),
            buildInfoRow(
              icon: Iconsax.calendar,
              label: 'date'.tr + ':',
              value: selectedDateDisplay,
            ),
            const SizedBox(height: 8),
            buildInfoRow(
              icon: Iconsax.clock,
              label: 'time'.tr + ':',
              value: selectedTimeSlot.value?.timeSlot.time ?? '',
            ),
            const SizedBox(height: 16),
            Text(
              'select_different_time'.tr,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Get.isDarkMode
                    ? DarkTheme.primaryLight
                    : LightTheme.primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              // Refresh availability for current date
              if (selectedDate.value != null) {
                await _fetchAvailabilityForDate(selectedDate.value!);
              }
            },
            child: Text(
              isArabic ? 'تحديث الأوقات' : 'Refresh Times',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Get.isDarkMode
                    ? DarkTheme.primaryLight
                    : LightTheme.primaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.isDarkMode
                  ? DarkTheme.secondaryColor
                  : LightTheme.primaryColor,
              foregroundColor: Get.isDarkMode
                  ? DarkTheme.textOnSecondary
                  : LightTheme.textOnPrimary,
            ),
            child: Text(
              isArabic ? 'حسناً' : 'OK',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showInsufficientTablesDialog(
    CheckTableAvailabilityResponse response,
    int requiredTables,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.isDarkMode
            ? DarkTheme.cardBackground
            : LightTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
        ),
        title: Row(
          children: [
            Icon(
              Iconsax.warning_2,
              color: Get.isDarkMode
                  ? DarkTheme.warningColor
                  : LightTheme.warningColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'insufficient_tables_title'.tr,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Get.isDarkMode
                      ? DarkTheme.textPrimary
                      : LightTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'insufficient_tables_message'.trParams({'guests': '$guestCount'}),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Get.isDarkMode
                    ? DarkTheme.textSecondary
                    : LightTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Show details
            buildInfoRow(
              icon: Iconsax.people,
              label: isArabic ? 'عدد الضيوف:' : 'Guest Count:',
              value: '${guestCount.value}',
            ),
            const SizedBox(height: 8),
            buildInfoRow(
              icon: Iconsax.category,
              label: isArabic ? 'الطاولات المطلوبة:' : 'Tables Required:',
              value: '$requiredTables',
            ),
            const SizedBox(height: 8),
            buildInfoRow(
              icon: Iconsax.category,
              label: isArabic ? 'الطاولات المتاحة:' : 'Available Tables:',
              value: '${response.availableTablesCount}',
            ),
            const SizedBox(height: 8),
            buildInfoRow(
              icon: Iconsax.building_4,
              label: isArabic ? 'القاعة:' : 'Hall:',
              value: response.hallName,
            ),
            const SizedBox(height: 8),
            buildInfoRow(
              icon: Iconsax.calendar,
              label: isArabic ? 'التاريخ:' : 'Date:',
              value: selectedDateDisplay,
            ),
            const SizedBox(height: 8),
            buildInfoRow(
              icon: Iconsax.clock,
              label: isArabic ? 'الوقت:' : 'Time:',
              value: selectedTimeSlot.value?.timeSlot.time ?? '',
            ),
            const SizedBox(height: 16),

            Text(
              'adjust_guests_suggestion'.tr,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Get.isDarkMode
                    ? DarkTheme.primaryLight
                    : LightTheme.primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              // Refresh availability for current date
              if (selectedDate.value != null) {
                await _fetchAvailabilityForDate(selectedDate.value!);
              }
            },
            child: Text(
              'refresh_times'.tr,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Get.isDarkMode
                    ? DarkTheme.primaryLight
                    : LightTheme.primaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.isDarkMode
                  ? DarkTheme.secondaryColor
                  : LightTheme.primaryColor,
              foregroundColor: Get.isDarkMode
                  ? DarkTheme.textOnSecondary
                  : LightTheme.textOnPrimary,
            ),
            child: Text('ok'.tr, style: const TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showGeneralErrorDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.isDarkMode
            ? DarkTheme.cardBackground
            : LightTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
        ),
        title: Row(
          children: [
            Icon(
              Iconsax.warning_2,
              color: Get.isDarkMode
                  ? DarkTheme.errorColor
                  : LightTheme.errorColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'general_error_title'.tr,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Get.isDarkMode
                      ? DarkTheme.textPrimary
                      : LightTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'general_error_message'.tr,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: Get.isDarkMode
                ? DarkTheme.textSecondary
                : LightTheme.textSecondary,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.isDarkMode
                  ? DarkTheme.secondaryColor
                  : LightTheme.primaryColor,
              foregroundColor: Get.isDarkMode
                  ? DarkTheme.textOnSecondary
                  : LightTheme.textOnPrimary,
            ),
            child: Text('ok'.tr, style: const TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}
