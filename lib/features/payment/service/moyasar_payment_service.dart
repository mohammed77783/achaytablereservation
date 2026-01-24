// ============================================================================
// STEP 2B: Moyasar Payment Service
// ============================================================================
// File: lib/core/services/moyasar_payment_service.dart
// ============================================================================

import 'dart:convert';
import 'package:achaytablereservation/features/payment/config/moyasar_config.dart';
import 'package:http/http.dart' as http;

/// Moyasar Payment Service
///
/// Handles all payment operations with Moyasar API:
/// - Credit card payments with 3DS
/// - Apple Pay payments
/// - Payment status checking
///
/// Flow:
/// 1. Create payment → Returns payment with status 'initiated' and transaction_url
/// 2. User completes 3DS in WebView
/// 3. WebView redirects to callback_url with payment status
/// 4. Verify payment status on backend via webhook
class MoyasarPaymentService {
  static final MoyasarPaymentService _instance =
      MoyasarPaymentService._internal();
  factory MoyasarPaymentService() => _instance;
  MoyasarPaymentService._internal();

  final String _baseUrl = MoyasarConfig.apiBaseUrl;
  final String _apiKey = MoyasarConfig.publishableKey;

  /// HTTP headers for Moyasar API
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Basic ${base64Encode(utf8.encode('$_apiKey:'))}',
  };

  // ============================================================================
  // CREATE CREDIT CARD PAYMENT
  // ============================================================================
  /// Creates a new payment with credit card
  ///
  /// Parameters:
  /// - [amount]: Amount in SAR (will be converted to halalas)
  /// - [cardNumber]: Full card number (spaces will be removed)
  /// - [expiryMonth]: Expiry month (MM)
  /// - [expiryYear]: Expiry year (YYYY)
  /// - [cvc]: Card security code
  /// - [cardHolderName]: Name on card
  /// - [description]: Payment description
  /// - [metadata]: Additional data (e.g., booking_id, user_id)
  ///
  /// Returns: [MoyasarPaymentResult]
  Future<MoyasarPaymentResult> createCardPayment({
    required double amount,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvc,
    required String cardHolderName,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Clean card number (remove spaces)
      final cleanCardNumber = cardNumber.replaceAll(RegExp(r'\s'), '');

      // Ensure year is 4 digits
      String fullYear = expiryYear;
      if (expiryYear.length == 2) {
        fullYear = '20$expiryYear';
      }

      final body = {
        'amount': MoyasarConfig.toHalalas(amount),
        'currency': MoyasarConfig.currency,
        'description': description,
        'callback_url': MoyasarConfig.callbackUrl,
        'source': {
          'type': 'creditcard',
          'name': cardHolderName,
          'number': cleanCardNumber,
          'month': expiryMonth,
          'year': fullYear,
          'cvc': cvc,
        },
        'metadata': metadata ?? {},
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/payments'),
        headers: _headers,
        body: jsonEncode(body),
      );

      return _parsePaymentResponse(response);
    } catch (e) {
      return MoyasarPaymentResult(
        success: false,
        errorMessage: 'Network error: ${e.toString()}',
        errorType: MoyasarErrorType.network,
      );
    }
  }

  // ============================================================================
  // CREATE APPLE PAY PAYMENT
  // ============================================================================
  /// Creates a new payment with Apple Pay token
  ///
  /// Parameters:
  /// - [amount]: Amount in SAR
  /// - [applePayToken]: Token received from Apple Pay
  /// - [description]: Payment description
  /// - [metadata]: Additional data
  ///
  /// Returns: [MoyasarPaymentResult]
  Future<MoyasarPaymentResult> createApplePayPayment({
    required double amount,
    required String applePayToken,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final body = {
        'amount': MoyasarConfig.toHalalas(amount),
        'currency': MoyasarConfig.currency,
        'description': description,
        'callback_url': MoyasarConfig.callbackUrl,
        'source': {'type': 'applepay', 'token': applePayToken},
        'metadata': metadata ?? {},
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/payments'),
        headers: _headers,
        body: jsonEncode(body),
      );

      return _parsePaymentResponse(response);
    } catch (e) {
      return MoyasarPaymentResult(
        success: false,
        errorMessage: 'Network error: ${e.toString()}',
        errorType: MoyasarErrorType.network,
      );
    }
  }

  // ============================================================================
  // FETCH PAYMENT STATUS
  // ============================================================================

  /// Fetches the current status of a payment
  /// Use this after 3DS completion to verify payment status
  ///
  /// Parameters:
  /// - [paymentId]: The Moyasar payment ID
  ///
  /// Returns: [MoyasarPaymentResult]
  Future<MoyasarPaymentResult> getPaymentStatus(String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/$paymentId'),
        headers: _headers,
      );

      return _parsePaymentResponse(response);
    } catch (e) {
      return MoyasarPaymentResult(
        success: false,
        errorMessage: 'Network error: ${e.toString()}',
        errorType: MoyasarErrorType.network,
      );
    }
  }

  // ============================================================================
  // PARSE RESPONSE
  // ============================================================================

  MoyasarPaymentResult _parsePaymentResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final status = data['status'] as String;
        final paymentId = data['id'] as String;
        // Extract transaction URL for 3DS (if present)
        String? transactionUrl;
        if (data['source'] != null &&
            data['source']['transaction_url'] != null) {
          transactionUrl = data['source']['transaction_url'];
        }
        // Extract card token if saved
        String? cardToken;
        if (data['source'] != null && data['source']['token'] != null) {
          cardToken = data['source']['token'];
        }
        return MoyasarPaymentResult(
          success: true,
          paymentId: paymentId,
          status: _parsePaymentStatus(status),
          transactionUrl: transactionUrl,
          cardToken: cardToken,
          rawResponse: data,
          message: data['source']?['message'],
        );
      } else {
        // Error response
        String errorMessage = 'Payment failed';
        if (data['message'] != null) {
          errorMessage = data['message'];
        } else if (data['errors'] != null) {
          errorMessage = (data['errors'] as List).join(', ');
        }
        return MoyasarPaymentResult(
          success: false,
          errorMessage: errorMessage,
          errorType: _parseErrorType(response.statusCode, data),
          rawResponse: data,
        );
      }
    } 
    catch (e) 
    {
      return MoyasarPaymentResult(
        success: false,
        errorMessage: 'Failed to parse response: ${e.toString()}',
        errorType: MoyasarErrorType.unknown,
      );
    }
  }

  MoyasarPaymentStatus _parsePaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'initiated':
        return MoyasarPaymentStatus.initiated;
      case 'paid':
        return MoyasarPaymentStatus.paid;
      case 'failed':
        return MoyasarPaymentStatus.failed;
      case 'authorized':
        return MoyasarPaymentStatus.authorized;
      case 'captured':
        return MoyasarPaymentStatus.captured;
      case 'refunded':
        return MoyasarPaymentStatus.refunded;
      case 'voided':
        return MoyasarPaymentStatus.voided;
      default:
        return MoyasarPaymentStatus.unknown;
    }
  }

  MoyasarErrorType _parseErrorType(int statusCode, Map<String, dynamic> data) {
    if (statusCode == 401) return MoyasarErrorType.authentication;
    if (statusCode == 422) return MoyasarErrorType.validation;
    if (statusCode == 400) return MoyasarErrorType.badRequest;
    if (statusCode >= 500) return MoyasarErrorType.server;
    return MoyasarErrorType.unknown;
  }
}

// ============================================================================
// MODELS
// ============================================================================

/// Payment result from Moyasar API
class MoyasarPaymentResult {
  final bool success;
  final String? paymentId;
  final MoyasarPaymentStatus? status;
  final String? transactionUrl; // URL for 3DS authentication
  final String? cardToken; // Token for saved card
  final String? errorMessage;
  final MoyasarErrorType? errorType;
  final String? message; // Bank/gateway message
  final Map<String, dynamic>? rawResponse;
  MoyasarPaymentResult({
    required this.success,
    this.paymentId,
    this.status,
    this.transactionUrl,
    this.cardToken,
    this.errorMessage,
    this.errorType,
    this.message,
    this.rawResponse,
  });

  /// Check if 3DS authentication is required
  bool get requires3DS =>
      status == MoyasarPaymentStatus.initiated && transactionUrl != null;

  /// Check if payment is complete and successful
  bool get isPaid => status == MoyasarPaymentStatus.paid;

  /// Check if payment failed
  bool get isFailed => status == MoyasarPaymentStatus.failed;

  @override
  String toString() {
    return 'MoyasarPaymentResult(success: $success, paymentId: $paymentId, status: $status, requires3DS: $requires3DS)';
  }
}

/// Payment status enum
enum MoyasarPaymentStatus {
  initiated, // Payment created, awaiting 3DS
  paid, // Payment successful
  failed, // Payment failed
  authorized, // Funds reserved (manual capture mode)
  captured, // Authorized funds captured
  refunded, // Payment refunded
  voided, // Transaction cancelled
  unknown,
}

/// Error type enum
enum MoyasarErrorType {
  network,
  authentication,
  validation,
  badRequest,
  server,
  unknown,
}

/// Extension for status display
extension MoyasarPaymentStatusExtension on MoyasarPaymentStatus {
  String get displayName {
    switch (this) {
      case MoyasarPaymentStatus.initiated:
        return 'Processing';
      case MoyasarPaymentStatus.paid:
        return 'Paid';
      case MoyasarPaymentStatus.failed:
        return 'Failed';
      case MoyasarPaymentStatus.authorized:
        return 'Authorized';
      case MoyasarPaymentStatus.captured:
        return 'Captured';
      case MoyasarPaymentStatus.refunded:
        return 'Refunded';
      case MoyasarPaymentStatus.voided:
        return 'Voided';
      case MoyasarPaymentStatus.unknown:
        return 'Unknown';
    }
  }

  String get displayNameAr {
    switch (this) {
      case MoyasarPaymentStatus.initiated:
        return 'جاري المعالجة';
      case MoyasarPaymentStatus.paid:
        return 'مدفوع';
      case MoyasarPaymentStatus.failed:
        return 'فشل';
      case MoyasarPaymentStatus.authorized:
        return 'مصرح به';
      case MoyasarPaymentStatus.captured:
        return 'تم الاستلام';
      case MoyasarPaymentStatus.refunded:
        return 'مسترد';
      case MoyasarPaymentStatus.voided:
        return 'ملغي';
      case MoyasarPaymentStatus.unknown:
        return 'غير معروف';
    }
  }
}
