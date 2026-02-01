import 'dart:async';
import 'package:achaytablereservation/app/routes/app_routes.dart';
import 'package:achaytablereservation/app/themes/dark_theme.dart';
import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/core/base/base_controller.dart';
import 'package:achaytablereservation/features/reservation/data/models/reservation_arguments.dart';
import 'package:achaytablereservation/features/reservation/data/models/reservation_detail.dart';
import 'package:achaytablereservation/features/reservation/data/repositories/ReservationRepository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controller for managing booking detail page
class BookingDetailController extends BaseController {
  final ReservationRepository _repository;

  BookingDetailController({required ReservationRepository repository})
    : _repository = repository;

  /// Reservation detail data
  final reservationDetail = Rxn<ReservationDetailResponse>();

  /// Loading state
  final isInitialLoading = true.obs;

  /// Timer for countdown
  Timer? _countdownTimer;

  /// Remaining time until payment deadline
  final remainingDuration = Rx<Duration?>(null);

  /// Whether the deadline has passed
  final isDeadlineExpired = false.obs;

  /// Whether the deadline dialog has been shown
  bool _deadlineDialogShown = false;

  /// Booking ID passed from arguments
  int? _bookingId;

  /// Check if Arabic locale
  bool get isArabic => Get.locale?.languageCode == 'ar';

  /// Check if reservation is pending
  bool get isPending =>
      reservationDetail.value?.status.toLowerCase() == 'pending';

  /// Check if timer should be shown (Pending status AND deadline not passed)
  bool get shouldShowTimer => isPending && !isDeadlineExpired.value;

  @override
  void onInit() {
    super.onInit();
    _bookingId = Get.arguments?['bookingId'] as int?;
    if (_bookingId != null) {
      fetchReservationDetail();
    } else {
      showError(isArabic ? 'معرف الحجز غير صالح' : 'Invalid booking ID');
      isInitialLoading.value = false;
    }
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }
  /// Start countdown timer based on payment deadline
  void _startCountdownTimer() {
    final detail = reservationDetail.value;
    if (detail == null) return;
    // Parse payment deadline (expected format: ISO 8601)
    final DateTime? deadline = _parseDeadline(detail.paymentDeadline);
    if (deadline == null) return;
    // Calculate remaining time
    final now = DateTime.now();
    final remaining = deadline.difference(now);
    // Check if already expired
    if (remaining.isNegative || remaining.inSeconds <= 0) {
      isDeadlineExpired.value = true;
      remainingDuration.value = Duration.zero;
      return;
    }
    // Set initial remaining duration
    remainingDuration.value = remaining;
    isDeadlineExpired.value = false;
    // Start timer that updates every second
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final remaining = deadline.difference(now);
      if (remaining.isNegative || remaining.inSeconds <= 0) {
        remainingDuration.value = Duration.zero;
        isDeadlineExpired.value = true;
        timer.cancel();
        // _showDeadlineExpiredDialog();
      } else {
        remainingDuration.value = remaining;
      }
    });
  }

  /// Parse deadline string to DateTime
  /// Server returns UTC timestamps without 'Z' suffix, so we append it
  /// to ensure correct timezone handling.
  DateTime? _parseDeadline(String deadlineStr) {
    try {
      String normalized = deadlineStr.trim();
      // If no timezone info present, treat as UTC by appending 'Z'
      if (!normalized.endsWith('Z') &&
          !RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(normalized)) {
        normalized = '${normalized}Z';
      }
      return DateTime.parse(normalized).toLocal();
    } catch (e) {
      try {
        String normalized = deadlineStr.replaceAll(' ', 'T').trim();
        if (!normalized.endsWith('Z') &&
            !RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(normalized)) {
          normalized = '${normalized}Z';
        }
        return DateTime.parse(normalized).toLocal();
      } catch (e) {
        return null;
      }
    }
  }

  /// Show dialog when payment deadline expires
  // void _showDeadlineExpiredDialog() {
  //   if (_deadlineDialogShown) return;
  //   _deadlineDialogShown = true;
  //   final isDark = Get.isDarkMode;
  //   Get.dialog(
  //     AlertDialog(
  //       backgroundColor: isDark
  //           ? DarkTheme.cardBackground
  //           : LightTheme.cardBackground,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       title: Row(
  //         children: [
  //           Icon(
  //             Icons.timer_off_outlined,
  //             color: isDark ? DarkTheme.errorColor : LightTheme.errorColor,
  //           ),
  //           const SizedBox(width: 8),
  //           Expanded(
  //             child: Text(
  //               isArabic ? 'انتهى وقت الدفع' : 'Payment Time Expired',
  //               style: TextStyle(
  //                 fontFamily: 'Cairo',
  //                 fontWeight: FontWeight.bold,
  //                 color: isDark
  //                     ? DarkTheme.textPrimary
  //                     : LightTheme.textPrimary,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //       content: Text(
  //         isArabic
  //             ? 'لقد انتهى الوقت المحدد لإتمام الدفع. قد يتم إلغاء حجزك تلقائياً.'
  //             : 'The payment deadline has passed. Your reservation may be cancelled automatically.',
  //         style: TextStyle(
  //           fontFamily: 'Cairo',
  //           color: isDark ? DarkTheme.textSecondary : LightTheme.textSecondary,
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Get.back(),
  //           child: Text(
  //             isArabic ? 'حسناً' : 'OK',
  //             style: TextStyle(
  //               fontFamily: 'Cairo',
  //               color: isDark
  //                   ? DarkTheme.primaryLight
  //                   : LightTheme.primaryColor,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //     barrierDismissible: false,
  //   );
  // }

  /// Navigate to payment page with full booking details
  void goToPayment() {
    final detail = reservationDetail.value;
    if (detail == null) return;
    final args = PaymentArguments(
      totalPrice: detail.totalPrice,
      bookingId: detail.bookingId,
      paymentDeadline: detail.paymentDeadline,
      paymentWindowMinutes: null, // Not available from detail API
      assignedTables: null, // Not available from detail API
      restaurantName: detail.restaurant.fullName,
      dateDisplay: detail.date,
      timeDisplay: detail.time,
      guestCount: detail.numberOfGuests,
      source: PaymentSource.bookingDetails, // Mark source for back navigation
    );
    Get.toNamed(AppRoutes.paymentpage, arguments: args);
  }

  /// Format remaining duration for display
  String get formattedRemainingTime {
    final duration = remainingDuration.value;
    if (duration == null || duration.inSeconds <= 0) {
      return isArabic ? 'انتهى الوقت' : 'Time Expired';
    }
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Fetch reservation detail from API
  Future<void> fetchReservationDetail() async {
    if (_bookingId == null) return;

    clearError();
    isInitialLoading.value = true;

    final result = await _repository.getReservationDetail(
      bookingId: _bookingId!,
    );

    result.fold(
      (failure) {
        showErrorFromFailure(failure);
        isInitialLoading.value = false;
      },
      (data) {
        reservationDetail.value = data;
        isInitialLoading.value = false;
        // Start countdown timer if status is Pending
        if (data.status.toLowerCase() == 'pending') {
          _startCountdownTimer();
        }
      },
    );
  }

  /// Retry fetching data
  void retry() {
    fetchReservationDetail();
  }

  /// Generate QR code value in format: YYYYMMID
  /// Example: 2026031 (Year 2026, Month 03, ID 1)
  /// Example: 20260312345678 (Year 2026, Month 03, ID 12345678)
  String get qrCodeValue {
    final detail = reservationDetail.value;
    if (detail == null) return '';

    // Parse date to extract year and month
    // Expected date format: "YYYY-MM-DD" or similar
    try {
      final dateParts = detail.date.split('-');
      if (dateParts.length >= 2) {
        final year = dateParts[0]; // e.g., "2026"
        final month = dateParts[1].padLeft(2, '0'); // e.g., "03"
        final id = detail.bookingId.toString();
        return '$year$month$id';
      }
    } catch (e) {
      // Fallback: just use booking ID
    }
    return detail.bookingId.toString();
  }

  /// Get formatted date for display
  String get formattedDate {
    final detail = reservationDetail.value;
    if (detail == null) return '';
    return detail.date;
  }

  /// Get formatted time for display
  String get formattedTime {
    final detail = reservationDetail.value;
    if (detail == null) return '';
    return detail.time;
  }

  /// Get status display text
  String getStatusText(String status) {
    if (isArabic) {
      switch (status.toLowerCase()) {
        case 'confirmed':
          return 'مؤكد';
        case 'pending':
          return 'قيد الانتظار';
        case 'cancelled':
          return 'ملغي';
        case 'completed':
          return 'مكتمل';
        default:
          return status;
      }
    }
    return status;
  }
}
