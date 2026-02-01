// ============================================================================
// STEP 4: Updated PaymentController with Moyasar Integration
// ============================================================================
// File: lib/features/payment/logic/payment_controller.dart
// ============================================================================

import 'dart:async';
import 'dart:io';
import 'package:achaytablereservation/app/routes/app_routes.dart';
import 'package:achaytablereservation/app/themes/dark_theme.dart';
import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/core/services/ocr_services.dart';
import 'package:achaytablereservation/features/payment/config/moyasar_config.dart';

import 'package:achaytablereservation/features/payment/logic/payment_validator.dart';
import 'package:achaytablereservation/features/payment/service/moyasar_payment_service.dart';
import 'package:achaytablereservation/features/payment/ui/widget/three_ds_webview.dart';

import 'package:achaytablereservation/features/reservation/data/models/reservation_models.dart';
import 'package:achaytablereservation/features/reservation/data/models/reservation_arguments.dart';
import 'package:achaytablereservation/features/reservation/data/repositories/ReservationRepository.dart';
import 'package:camera/camera.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// Moyasar SDK imports (for Apple Pay)
import 'package:moyasar/moyasar.dart' as moyasar;

class PaymentController extends GetxController {
  // ============================================================================
  // REACTIVE STATE VARIABLES
  // ============================================================================

  // Card image and data
  final Rx<File?> cardImage = Rx<File?>(null);
  final RxString cardNumber = ''.obs;
  final RxString expirationDate = ''.obs;
  final RxString cvv = ''.obs;
  final RxString cardHolderName = ''.obs; // NEW: Added cardholder name

  // Processing states
  final RxBool isScanning = false.obs;
  final RxBool isProcessing = false.obs;
  final RxBool isLiveScanActive = false.obs;
  final RxString scanStatus = ''.obs;

  // Payment method selection
  final RxString selectedPaymentMethod = 'card'.obs; // 'card' or 'apple_pay'
  final RxBool isApplePayAvailable = false.obs;

  // Payment status
  final Rx<MoyasarPaymentStatus?> paymentStatus = Rx<MoyasarPaymentStatus?>(
    null,
  );
  final RxString paymentErrorMessage = ''.obs;

  // Payment timer
  final Rx<Duration?> remainingDuration = Rx<Duration?>(null);
  final RxBool isDeadlineExpired = false.obs;
  Timer? _countdownTimer;
  String? _paymentDeadline;
  bool _deadlineDialogShown = false;

  // Invoice/Reservation details
  final RxString restaurantName = ''.obs;
  final RxString dateDisplay = ''.obs;
  final RxString timeDisplay = ''.obs;
  final RxInt guestCount = 0.obs;
  final RxDouble totalPrice = 0.0.obs;
  final RxInt bookingId = 0.obs;

  // Track payment source for back navigation
  PaymentSource _paymentSource = PaymentSource.reservationConfirmation;

  // Validator for payment fields
  final PaymentValidator validator = PaymentValidator();

  // ============================================================================
  // DEPENDENCIES
  // ============================================================================
  PaymentController({required ReservationRepository reservationRepository})
    : _reservationRepository = reservationRepository;

  final ReservationRepository _reservationRepository;
  final MoyasarPaymentService _moyasarService = MoyasarPaymentService();
  // Image picker & scanner
  final ImagePicker _imagePicker = ImagePicker();
  // late final CardScanner _scanner;

  // Moyasar SDK PaymentConfig (for Apple Pay)
  moyasar.PaymentConfig? _moyasarConfig;
  // ============================================================================
  // GETTERS
  // ============================================================================
  // Expose validator errors for UI binding
  RxnString get cardNumberError => validator.cardNumberError;
  RxnString get expiryDateError => validator.expiryDateError;
  RxnString get cvvError => validator.cvvError;

  // ============================================================================
  // LIFECYCLE
  // ============================================================================
  @override
  void onInit() {
    super.onInit();
    // Initialize invoice details from arguments
    _initializeInvoiceDetails();
    // Initialize scanner
    // _initializeScanner();
    // Check Apple Pay availability
    _checkApplePayAvailability();
  }

  // void _initializeScanner() {
  //   _scanner = CardScanner();
  //   _scanner.onResult = (data) {
  //     cardNumber.value = data.formattedCardNumber;
  //     expirationDate.value = data.expirationDate;

  //     if (data.isComplete) {
  //       Future.delayed(const Duration(milliseconds: 600), () {
  //         isLiveScanActive.value = false;
  //         Get.snackbar(
  //           'success'.tr,
  //           'card_details_captured'.tr,
  //           snackPosition: SnackPosition.BOTTOM,
  //         );
  //       });
  //     }
  //   };
  //   _scanner.onStatus = (status) => scanStatus.value = status;
  //   _scanner.onError = (error) => Get.snackbar('error'.tr, error);
  // }

  void _initializeInvoiceDetails() {
    final args = Get.arguments;
    if (args is PaymentArguments) {
      restaurantName.value = args.restaurantName;
      dateDisplay.value = args.dateDisplay;
      timeDisplay.value = args.timeDisplay;
      guestCount.value = args.guestCount;
      totalPrice.value = args.totalPrice;
      bookingId.value = args.bookingId;
      _paymentSource = args.source;
      _paymentDeadline = args.paymentDeadline;
      // Initialize Moyasar config with actual amount
      _initializeMoyasarConfig();
      // Start payment deadline timer if deadline is provided
      if (_paymentDeadline != null && _paymentDeadline!.isNotEmpty) {
        _startCountdownTimer();
      }
    }
  }

  void _initializeMoyasarConfig() {
    _moyasarConfig = moyasar.PaymentConfig(
      publishableApiKey: MoyasarConfig.publishableKey,
      amount: MoyasarConfig.toHalalas(totalPrice.value),
      description: 'Reservation #${bookingId.value} at ${restaurantName.value}',
      metadata: {
        'booking_id': bookingId.value.toString(),
        'restaurant_name': restaurantName.value,
      },
      creditCard: moyasar.CreditCardConfig(
        saveCard: false,
        manual: false, // Auto-capture payment
      ),
      applePay: moyasar.ApplePayConfig(
        merchantId: MoyasarConfig.appleMerchantId,
        label: MoyasarConfig.applePayDisplayName,
        manual: false,
        saveCard: true,
      ),
    );
  }

  Future<void> _checkApplePayAvailability() async {
    // Apple Pay is only available on iOS real devices
    if (Platform.isIOS && !kDebugMode) {
      // In production, check if device supports Apple Pay
      // For now, we'll assume it's available on iOS
      isApplePayAvailable.value = true;
    } else if (Platform.isIOS && kDebugMode) {
      // In debug mode, show Apple Pay button but warn about simulator
      isApplePayAvailable.value = true;
    }
  }

  // ============================================================================
  // PAYMENT DEADLINE TIMER
  // ============================================================================

  /// Check if Arabic locale
  bool get isArabic => Get.locale?.languageCode == 'ar';

  /// Check if timer should be shown (deadline exists and not expired)
  bool get shouldShowTimer =>
      _paymentDeadline != null &&
      _paymentDeadline!.isNotEmpty &&
      !isDeadlineExpired.value;

  /// Start countdown timer based on payment deadline
  void _startCountdownTimer() {
    if (_paymentDeadline == null || _paymentDeadline!.isEmpty) return;

    // Parse payment deadline
    final DateTime? deadline = _parseDeadline(_paymentDeadline!);
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
        _showDeadlineExpiredDialog();
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

  /// Show dialog when payment deadline expires
  void _showDeadlineExpiredDialog() {
    if (_deadlineDialogShown) return;
    _deadlineDialogShown = true;

    final isDark = Get.isDarkMode;

    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor:
              isDark ? DarkTheme.cardBackground : LightTheme.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                Icons.timer_off_outlined,
                color: isDark ? DarkTheme.errorColor : LightTheme.errorColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isArabic ? 'انتهى وقت الدفع' : 'Payment Time Expired',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            isArabic
                ? 'لقد انتهى الوقت المحدد لإتمام الدفع. قد يتم إلغاء حجزك تلقائياً.'
                : 'The payment deadline has passed. Your reservation may be cancelled automatically.',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: isDark ? DarkTheme.textSecondary : LightTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close dialog first
                // Navigate after dialog is closed
                Future.delayed(const Duration(milliseconds: 100), () {
                  onBackPressed();
                });
              },
              child: Text(
                isArabic ? 'حسناً' : 'OK',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color:
                      isDark ? DarkTheme.primaryLight : LightTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ============================================================================
  // NAVIGATION
  // ============================================================================
  void onBackPressed() {
    if (_paymentSource == PaymentSource.bookingDetails) {
      Get.back();
    } else {
      Get.offAllNamed(AppRoutes.MAIN_NAVIGATION);
    }
  }

  // ============================================================================
  // PAYMENT METHOD SELECTION
  // ============================================================================

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
    paymentErrorMessage.value = '';
  }

  // ============================================================================
  // CAMERA METHODS (unchanged)
  // ============================================================================
  // CameraController? get cameraController => _scanner.cameraController;
  // Future<void> startLiveScanning() async {
  //   final hasPermission = await _requestCameraPermission();
  //   if (!hasPermission) {
  //     Get.snackbar(
  //       'permission_denied'.tr,
  //       'camera_permission_required'.tr,
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //     return;
  //   }
  //   final success = await _scanner.initCamera();
  //   if (!success) {
  //     Get.snackbar(
  //       'error'.tr,
  //       'camera_init_failed'.tr,
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //     return;
  //   }
  //   isLiveScanActive.value = true;
  //   await _scanner.startScan();
  // }

  // void stopLiveScanning() {
  //   _scanner.stopScan();
  //   isLiveScanActive.value = false;
  // }

  // Future<bool> _requestCameraPermission() async {
  //   final status = await Permission.camera.status;
  //   if (status.isGranted) return true;
  //   if (status.isDenied) {
  //     final result = await Permission.camera.request();
  //     return result.isGranted;
  //   }
  //   if (status.isPermanentlyDenied) {
  //     Get.snackbar(
  //       'permission_required'.tr,
  //       'camera_permission_settings'.tr,
  //       snackPosition: SnackPosition.BOTTOM,
  //       duration: const Duration(seconds: 4),
  //     );
  //     await openAppSettings();
  //   }
  //   return false;
  // }

  // Future<void> pickImageFromGallery() async {
  //   try {
  //     final XFile? image = await _imagePicker.pickImage(
  //       source: ImageSource.gallery,
  //       imageQuality: 85,
  //     );

  //     if (image != null) {
  //       cardImage.value = File(image.path);
  //       isScanning.value = true;

  //       final data = await _scanner.scanImage(image.path);
  //       cardNumber.value = data.formattedCardNumber;
  //       expirationDate.value = data.expirationDate;

  //       isScanning.value = false;

  //       Get.snackbar(
  //         data.hasCardNumber ? 'success'.tr : 'partial_data'.tr,
  //         data.hasCardNumber
  //             ? 'card_details_extracted'.tr
  //             : 'please_fill_missing_fields'.tr,
  //         snackPosition: SnackPosition.BOTTOM,
  //       );
  //     }
  //   } catch (e) {
  //     isScanning.value = false;
  //     Get.snackbar('error'.tr, 'failed_to_pick_image'.tr);
  //   }
  // }

  // ============================================================================
  // FIELD UPDATE METHODS
  // ==========================1==================================================

  void updateCardNumber(String value) {
    cardNumber.value = validator.formatCardNumber(value);
    validator.clearCardNumberError();
    paymentErrorMessage.value = '';
  }

  void updateExpirationDate(String value) {
    expirationDate.value = validator.formatExpiryDate(value);
    validator.clearExpiryDateError();
    paymentErrorMessage.value = '';
  }

  void updateCvv(String value) {
    cvv.value = value.replaceAll(RegExp(r'\D'), '');
    validator.clearCvvError();
    paymentErrorMessage.value = '';
  }

  void updateCardHolderName(String value) {
    cardHolderName.value = value;
    paymentErrorMessage.value = '';
  }

  // ============================================================================
  // VALIDATION GETTERS
  // ============================================================================

  bool get isCardNumberValid => validator.validateCardNumber(cardNumber.value);
  bool get isExpirationValid =>
      validator.validateExpiryDate(expirationDate.value);
  bool get isCvvValid => validator.validateCvv(cvv.value, cardNumber.value);

  bool get isFormValid =>
      validator.isFormComplete(
        cardNumber.value,
        expirationDate.value,
        cvv.value,
      ) &&
      cardHolderName.value.trim().split(' ').length >= 2; // Require full name

  String get cardTypeDisplayName =>
      validator.getCardType(cardNumber.value).displayName;
  String get maskedCardNumber => validator.maskCardNumber(cardNumber.value);

  // ============================================================================
  // CREDIT CARD PAYMENT PROCESSING
  // ============================================================================

  Future<void> processPayment() async {
    // Check if payment deadline has expired
    if (isDeadlineExpired.value) {
      Get.snackbar(
        isArabic ? 'انتهى الوقت' : 'Time Expired',
        isArabic
            ? 'انتهى الوقت المحدد للدفع. يرجى إجراء حجز جديد.'
            : 'Payment deadline has expired. Please make a new reservation.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:
            Get.isDarkMode ? DarkTheme.errorColor : LightTheme.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    if (selectedPaymentMethod.value == 'apple_pay') {
      await processApplePayPayment();
      return;
    }

    await processCardPayment();
  }

  Future<void> processCardPayment() async {
    // Clear previous errors
    paymentErrorMessage.value = '';

    // Validate all fields
    final isValid = validator.validateAll(
      cardNumber: cardNumber.value,
      expiryDate: expirationDate.value,
      cvv: cvv.value,
    );

    if (!isValid) {
      Get.snackbar(
        'validation_error'.tr,
        'please_check_card_details'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Validate cardholder name (must have first and last name)
    if (cardHolderName.value.trim().split(' ').length < 2) {
      Get.snackbar(
        'validation_error'.tr,
        'please_enter_full_name'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (bookingId.value == 0) {
      Get.snackbar(
        'error'.tr,
        'no_booking_found'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isProcessing.value = true;
    paymentStatus.value = null;

    try {
      // Parse expiration date
      final expiryParts = expirationDate.value.split('/');
      final expiryMonth = expiryParts[0];
      final expiryYear = expiryParts[1];

      // Step 1: Create payment with Moyasar
      final paymentResult = await _moyasarService.createCardPayment(
        amount: totalPrice.value,
        cardNumber: cardNumber.value,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvc: cvv.value,
        
        cardHolderName: cardHolderName.value.trim(),
        description:
            'Reservation #${bookingId.value} at ${restaurantName.value}',
        metadata: {
          'booking_id': bookingId.value.toString(),
          'restaurant_name': restaurantName.value,
          'date': dateDisplay.value,
          'time': timeDisplay.value,
          'guests': guestCount.value.toString(),
        },
      );

      if (!paymentResult.success) {
        _handlePaymentError(paymentResult.errorMessage ?? 'Payment failed');
        return;
      }

      // Step 2: Check if 3DS is required
      if (paymentResult.requires3DS) {
        await _handle3DSAuthentication(paymentResult);
      } else if (paymentResult.isPaid) {
        // Payment successful without 3DS (rare)
        await _confirmReservationWithPayment(paymentResult.paymentId!);
      } else {
        _handlePaymentError(paymentResult.message ?? 'Payment failed');
      }
    } 
    catch (e) {
      _handlePaymentError(e.toString());
    }
  }

  // ============================================================================
  // 3DS AUTHENTICATION HANDLING
  // ============================================================================

  Future<void> _handle3DSAuthentication(
    MoyasarPaymentResult paymentResult,
  ) async {
    // Navigate to 3DS WebView
    final threeDSResult = 
    await Get.to<ThreeDSResult>(() => ThreeDSWebView(
        transactionUrl: paymentResult.transactionUrl!,
        paymentId: paymentResult.paymentId!,
      ),
      transition: Transition.rightToLeft,
    );

    if (threeDSResult == null) {
      // User closed WebView without completing
      _handlePaymentError('payment_cancelled'.tr);
      return;
    }

    if (threeDSResult.cancelled) {
      _handlePaymentError('payment_cancelled'.tr);
      return;
    }

    if (threeDSResult.success) {
      // 3DS successful, verify payment status and confirm reservation
      await _verifyAndConfirmPayment(threeDSResult.paymentId);
    } else {
      // 3DS failed
      _handlePaymentError(
        threeDSResult.message ?? '3ds_authentication_failed'.tr,
      );
    }
  }

  Future<void> _verifyAndConfirmPayment(String paymentId) async {
    // Verify payment status with Moyasar
    final statusResult = await _moyasarService.getPaymentStatus(paymentId);

    if (statusResult.success && statusResult.isPaid) {
      await _confirmReservationWithPayment(paymentId);
    } else {
      _handlePaymentError(
        statusResult.message ?? 'payment_verification_failed'.tr,
      );
    }
  }

  // ============================================================================
  // APPLE PAY PAYMENT PROCESSING
  // ============================================================================

  Future<void> processApplePayPayment() async {
    if (_moyasarConfig == null) {
      _handlePaymentError('payment_not_configured'.tr);
      return;
    }

    isProcessing.value = true;
    paymentErrorMessage.value = '';
    paymentStatus.value = null;

    // Note: Apple Pay must be triggered from a button press
    // The actual Apple Pay flow is handled by the ApplePay widget
    // This method is called after the Apple Pay widget processes the payment
  }

  /// Called by Apple Pay widget when payment is successful
  void onApplePayResult(moyasar.PaymentResponse result) async {
    isProcessing.value = true;

    if (result.status == moyasar.PaymentStatus.paid) {
      await _confirmReservationWithPayment(result.id);
    } else if (result.status == moyasar.PaymentStatus.initiated) {
      // This shouldn't happen with Apple Pay but handle it
      _handlePaymentError('payment_pending'.tr);
    } else {
      _handlePaymentError(result.source?.message ?? 'apple_pay_failed'.tr);
    }
  }

  /// Called when Apple Pay encounters an error
  void onApplePayError(dynamic error) {
    isProcessing.value = false;

    if (error is moyasar.PaymentCanceledError) {
      paymentErrorMessage.value = 'payment_cancelled'.tr;
    } else if (error is moyasar.UnprocessableTokenError) {
      // This happens on simulator
      paymentErrorMessage.value = 'apple_pay_simulator_error'.tr;
    } else {
      paymentErrorMessage.value = error.toString();
    }

    Get.snackbar(
      'error'.tr,
      paymentErrorMessage.value,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Get Moyasar PaymentConfig for Apple Pay widget
  moyasar.PaymentConfig? get moyasarPaymentConfig => _moyasarConfig;

  // ============================================================================
  // CONFIRM RESERVATION WITH BACKEND
  // ============================================================================

  Future<void> _confirmReservationWithPayment(
    String transactionReference,
  ) async {

    paymentStatus.value = MoyasarPaymentStatus.paid;
    final request = ConfirmReservationRequest(
      bookingId: bookingId.value.toString(),
      paymentMethod: selectedPaymentMethod.value == 'apple_pay'
          ? 'applepay'
          : 'creditcard',
      transactionReference: transactionReference,
      amountPaid: totalPrice.value.toStringAsFixed(2),
    );

    final result = await _reservationRepository.confirmReservation(request);
    isProcessing.value = false;
    result.fold(
      (failure) {
        // Payment was successful but backend confirmation failed
        // The webhook should handle this, but inform user
        Get.snackbar(
          'warning'.tr,
          'payment_success_confirmation_pending'.tr,
          snackPosition: SnackPosition.TOP,
          
          duration: const Duration(seconds: 5),
        );
        // Still navigate to success since payment went through
        _navigateToSuccess(transactionReference);
      },
      (data) {
        Get.snackbar(
          'success'.tr,
          'payment_successful'.tr,
          snackPosition: SnackPosition.TOP,
        );
        _navigateToSuccess(transactionReference);
      },
    );
  }

  void _navigateToSuccess(String transactionReference) {
    // Navigate to main page or success page
    Get.offAllNamed(AppRoutes.MAIN_NAVIGATION);
  }


  // ============================================================================
  // ERROR HANDLING
  // ============================================================================

  void _handlePaymentError(String message) {
    isProcessing.value = false;
    paymentStatus.value = MoyasarPaymentStatus.failed;
    paymentErrorMessage.value = message;

    Get.snackbar(
      'payment_failed'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.isDarkMode
          ? Colors.red.shade900
          : Colors.red.shade50,
      colorText: Get.isDarkMode ? Colors.white : Colors.red.shade900,
      duration: const Duration(seconds: 4),
    );
  }

  // ============================================================================
  // CLEANUP
  // ============================================================================

  @override
  void onClose() {
    _countdownTimer?.cancel();
    // _scanner.dispose();
    super.onClose();
  }
}

// Add this import at the top for Colors
// import 'package:flutter/material.dart' show Colors;
