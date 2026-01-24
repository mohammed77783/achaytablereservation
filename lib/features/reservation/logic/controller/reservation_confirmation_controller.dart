import 'dart:async';
import 'package:achaytablereservation/app/routes/app_routes.dart';
import 'package:achaytablereservation/app/themes/dark_theme.dart';
import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/core/base/base_controller.dart';
import 'package:achaytablereservation/core/constants/app_constants.dart';
import 'package:achaytablereservation/features/reservation/data/models/available_table.dart';
import 'package:achaytablereservation/features/reservation/data/models/reservation_models.dart';
import 'package:achaytablereservation/features/reservation/data/repositories/ReservationRepository.dart';
import 'package:achaytablereservation/features/reservation/logic/class/SelectedTimeSlot.dart';
import 'package:achaytablereservation/features/reservation/ui/widget/payment_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:achaytablereservation/features/reservation/data/models/reservation_arguments.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Controller for ReservationConfirmationPage
/// Handles countdown timer and reservation data
class ReservationConfirmationController extends BaseController {
  final ReservationRepository _repository;

  ReservationConfirmationController({required ReservationRepository repository})
    : _repository = repository;

  // Timer
  Timer? _countdownTimer;
  final RxInt remainingSeconds = (10 * 60).obs; // 5 minutes
  // Policies
  final RxList<Policy> policies = <Policy>[].obs;
  final RxBool isPoliciesLoading = false.obs;
  // Terms and Conditions
  final RxBool isTermsAccepted = false.obs;
  String get termsUrl =>
      isArabic ? AppConstants.termsUrlAr : AppConstants.termsUrlEn;
  // Reservation data
  late final int restaurantId;
  late final RestaurantInfo? restaurantInfo;
  late final DateTime? selectedDate;
  late final String? selectedHijriDate;
  late final String selectedDateDisplay;
  late final SelectedTimeSlot? selectedTimeSlot;
  late final int? hallId;
  late final String? hallName;
  late final int guestCount;
  late final int tableCapacity;
  late final double pricePerPerson;
  late final double totalPrice;
  late final int availableTablesCount;
  late final List<AvailableTable> availableTables;
  late final int requiredTables;
  bool get isArabic => Get.locale?.languageCode == 'ar';

  /// Formatted time string (MM:SS)
  String get formattedTime {
    final minutes = (remainingSeconds.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds.value % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Get timer color based on remaining time
  Color getTimerColor(bool isDark) {
    if (remainingSeconds.value <= 60) {
      return isDark ? DarkTheme.errorColor : LightTheme.errorColor;
    } else if (remainingSeconds.value <= 120) {
      return isDark ? DarkTheme.warningColor : LightTheme.warningColor;
    }
    return isDark ? DarkTheme.successColor : LightTheme.successColor;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    _startCountdownTimer();
    _fetchPolicies();
  }

  /// Fetch restaurant policies from API
  Future<void> _fetchPolicies() async {
    isPoliciesLoading.value = true;
    final result = await _repository.getPolicies(restaurantId: restaurantId);
    result.fold(
      (failure) {
        // Silently fail - policies are not critical
        isPoliciesLoading.value = false;
      },
      (data) {
        policies.assignAll(data);
        isPoliciesLoading.value = false;
      },
    );
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  void _initializeData() {
    final args = Get.arguments as ReservationConfirmationArguments;
    restaurantId = args.restaurantId;
    restaurantInfo = args.restaurantInfo;
    selectedDate = args.selectedDate;
    selectedHijriDate = args.selectedHijriDate;
    selectedDateDisplay = args.selectedDateDisplay;
    selectedTimeSlot = args.selectedTimeSlot;
    hallId = args.hallId;
    hallName = args.hallName;
    guestCount = args.guestCount;
    tableCapacity = args.tableCapacity;
    pricePerPerson = args.pricePerPerson;
    totalPrice = args.totalPrice;
    availableTablesCount = args.availableTablesCount;
    availableTables = args.availableTables ?? [];
    requiredTables = args.requiredTables;
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
        _showTimeoutDialog();
      }
    });
  }

  void _showTimeoutDialog() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Get.isDarkMode
              ? DarkTheme.cardBackground
              : LightTheme.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
          ),
          title: Row(
            children: [
              Icon(
                Iconsax.timer,
                color: Get.isDarkMode
                    ? DarkTheme.warningColor
                    : LightTheme.warningColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isArabic ? 'انتهى الوقت' : 'Time Expired',
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
            children: [
              Icon(
                Iconsax.clock,
                size: 64,
                color: Get.isDarkMode
                    ? DarkTheme.warningColor.withValues(alpha: 0.7)
                    : LightTheme.warningColor.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic
                    ? 'انتهت مهلة الحجز.\nيرجى البدء من جديد لضمان توفر الطاولات.'
                    : 'Your reservation session has expired.\nPlease start again to ensure table availability.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: Get.isDarkMode
                      ? DarkTheme.textSecondary
                      : LightTheme.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToBranchInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.isDarkMode
                      ? DarkTheme.secondaryColor
                      : LightTheme.primaryColor,
                  foregroundColor: Get.isDarkMode
                      ? DarkTheme.textOnSecondary
                      : LightTheme.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      LightTheme.borderRadius,
                    ),
                  ),
                ),
                child: Text(
                  isArabic ? 'العودة للفرع' : 'Return to Branch',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _navigateToBranchInfo() {
    Get.back(); // Close dialog
    Get.offNamed(
      AppRoutes.branchinfor,
      arguments: {'restaurantId': restaurantId, 'refresh': true},
    );
  }

  /// Toggle terms acceptance
  void toggleTermsAccepted(bool? value) {
    isTermsAccepted.value = value ?? false;
  }

  /// Show terms and conditions dialog with WebView
  void showTermsDialog() {
    final webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(
        Get.isDarkMode ? DarkTheme.backgroundColor : LightTheme.backgroundColor,
      )
      ..loadRequest(Uri.parse(termsUrl));

    Get.dialog(
      Dialog(
        backgroundColor: Get.isDarkMode
            ? DarkTheme.cardBackground
            : LightTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SizedBox(
          width: double.maxFinite,
          height: Get.height * 0.75,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Get.isDarkMode
                          ? DarkTheme.borderColor
                          : LightTheme.borderColor,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.document_text,
                      color: Get.isDarkMode
                          ? DarkTheme.secondaryColor
                          : LightTheme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isArabic ? 'الشروط والأحكام' : 'Terms & Conditions',
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
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: Get.isDarkMode
                            ? DarkTheme.textSecondary
                            : LightTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // WebView
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: WebViewWidget(controller: webViewController),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // Loading state for payment process
  final RxBool isProcessingPayment = false.obs;

  /// Navigate to payment page with total price
  void goToPayment() {
    if (!isTermsAccepted.value) {
      Get.snackbar(
        isArabic ? 'تنبيه' : 'Notice',
        isArabic
            ? 'يرجى الموافقة على الشروط والأحكام'
            : 'Please accept the terms and conditions',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.isDarkMode
            ? DarkTheme.warningColor
            : LightTheme.warningColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    _showPaymentConfirmationDialog();
  }

  /// Show payment confirmation dialog with reservation details
  void _showPaymentConfirmationDialog() {
    final dialogData = PaymentConfirmationData(
      dateDisplay: selectedDateDisplay,
      timeDisplay: selectedTimeSlot?.timeSlot.displayText ?? '-',
      guestCount: guestCount,
      hallName: hallName,
      requiredTables: requiredTables,
      totalPrice: totalPrice,
      isArabic: isArabic,
    );

    PaymentConfirmationDialog.show(
      data: dialogData,
      isProcessing: isProcessingPayment,
      onConfirm: _proceedToPayment,
      onCancel: () => Get.back(),
    );
  }

  /// Proceed to payment after confirmation - calls createReservation API
  Future<void> _proceedToPayment() async {
    isProcessingPayment.value = true;

    try {
      // Format date for API (yyyy-MM-dd)
      final formattedDate = selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(selectedDate!)
          : '';

      // Get time from time slot
      final time = selectedTimeSlot?.timeSlot.time ?? '';

      // Create reservation request
      final request = CreateReservationRequest(
        restaurantId: restaurantId.toString(),
        hallId: (hallId ?? 0).toString(),
        date: formattedDate,
        time: time,
        numberOfGuests: guestCount.toString(),
        numberOfTables: requiredTables.toString(),
      );

      // Call API to create reservation
      final result = await _repository.createReservation(request);
      result.fold(
        (failure) {
          // Close dialog
          Get.back();
          isProcessingPayment.value = false;

          // Show error message
          Get.snackbar(
            isArabic ? 'خطأ' : 'Error',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.isDarkMode
                ? DarkTheme.errorColor
                : LightTheme.errorColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            icon: const Icon(Iconsax.warning_2, color: Colors.white),
          );
        },
        (reservationData) {
          // Close dialog
          Get.back();
          isProcessingPayment.value = false;

          // Navigate to payment page with reservation data
          // Navigate to payment page with reservation data
          final args = PaymentArguments(
            totalPrice: totalPrice,
            bookingId: reservationData.bookingId,
            paymentDeadline: reservationData.paymentDeadline,
            paymentWindowMinutes: reservationData.paymentWindowMinutes,
            assignedTables: reservationData.assignedTables,
            restaurantName:
                restaurantInfo?.fullName ?? restaurantInfo?.branchName ?? '',
            dateDisplay: selectedDateDisplay,
            timeDisplay: selectedTimeSlot?.timeSlot.displayText ?? '',
            guestCount: guestCount,
          );

          Get.toNamed(AppRoutes.paymentpage, arguments: args);
        },
      );
    } catch (e) {
      // Close dialog
      Get.back();
      isProcessingPayment.value = false;

      // Show generic error message
      Get.snackbar(
        isArabic ? 'خطأ' : 'Error',
        isArabic
            ? 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.'
            : 'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.isDarkMode
            ? DarkTheme.errorColor
            : LightTheme.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Iconsax.warning_2, color: Colors.white),
      );
    }
  }

  void confirmReservation() {
    goToPayment();
  }
}
