import 'package:achaytablereservation/core/services/card_validation_service.dart';

/// =============================================================================
/// PaymentValidationService
/// =============================================================================
///
/// A comprehensive service for validating all payment-related information
/// before processing a payment or confirming a reservation.
///
/// This class acts as a facade that combines:
/// - Card validation (using CardValidationService)
/// - Form validation results
/// - Payment data model
///
/// =============================================================================
/// USAGE EXAMPLE:
/// =============================================================================
/// ```dart
/// final validation = PaymentValidationService.validatePaymentData(
///   PaymentData(
///     cardNumber: '4539 1488 0343 6467',
///     expiryDate: '12/25',
///     cvv: '123',
///     cardHolderName: 'John Doe',
///   ),
/// );
///
/// if (validation.isValid) {
///   // Proceed with payment
/// } else {
///   // Show errors: validation.errors
/// }
/// ```
/// =============================================================================

class PaymentValidationService {
  /// ==========================================================================
  /// validatePaymentData
  /// ==========================================================================
  /// Main entry point for validating all payment information at once.
  ///
  /// Parameters:
  /// - [data]: PaymentData object containing all card details
  ///
  /// Returns:
  /// - PaymentValidationResult with isValid flag and list of errors
  /// ==========================================================================
  static PaymentValidationResult validatePaymentData(PaymentData data) {
    final List<PaymentFieldError> errors = [];

    // 1. Validate Card Number
    final cardNumberError = CardValidationService.getCardNumberError(
      data.cardNumber,
    );
    if (cardNumberError != null) {
      errors.add(
        PaymentFieldError(
          field: PaymentField.cardNumber,
          message: cardNumberError,
        ),
      );
    }

    // 2. Validate Expiry Date
    final expiryError = CardValidationService.getExpiryDateError(
      data.expiryDate,
    );
    if (expiryError != null) {
      errors.add(
        PaymentFieldError(field: PaymentField.expiryDate, message: expiryError),
      );
    }

    // 3. Validate CVV
    final cardType = CardValidationService.getCardType(data.cardNumber);
    final cvvError = CardValidationService.getCvvError(data.cvv, cardType);
    if (cvvError != null) {
      errors.add(PaymentFieldError(field: PaymentField.cvv, message: cvvError));
    }

    // 4. Validate Card Holder Name (if provided)
    if (data.cardHolderName != null && data.cardHolderName!.isNotEmpty) {
      final nameError = _validateCardHolderName(data.cardHolderName!);
      if (nameError != null) {
        errors.add(
          PaymentFieldError(
            field: PaymentField.cardHolderName,
            message: nameError,
          ),
        );
      }
    }

    return PaymentValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      cardType: cardType,
      maskedCardNumber: CardValidationService.getMaskedCardNumber(
        data.cardNumber,
      ),
    );
  }

  /// ==========================================================================
  /// validateCardNumber
  /// ==========================================================================
  /// Validates only the card number field.
  ///
  /// Returns:
  /// - null if valid
  /// - Error message string if invalid
  /// ==========================================================================
  static String? validateCardNumber(String cardNumber) {
    return CardValidationService.getCardNumberError(cardNumber);
  }

  /// ==========================================================================
  /// validateExpiryDate
  /// ==========================================================================
  /// Validates only the expiry date field.
  ///
  /// Returns:
  /// - null if valid
  /// - Error message string if invalid
  /// ==========================================================================
  static String? validateExpiryDate(String expiryDate) {
    return CardValidationService.getExpiryDateError(expiryDate);
  }

  /// ==========================================================================
  /// validateCvv
  /// ==========================================================================
  /// Validates only the CVV field based on card type.
  ///
  /// Parameters:
  /// - [cvv]: The CVV code
  /// - [cardNumber]: Used to determine card type (for CVV length)
  ///
  /// Returns:
  /// - null if valid
  /// - Error message string if invalid
  /// ==========================================================================
  static String? validateCvv(String cvv, String cardNumber) {
    final cardType = CardValidationService.getCardType(cardNumber);
    return CardValidationService.getCvvError(cvv, cardType);
  }

  /// ==========================================================================
  /// validateCardHolderName (Private)
  /// ==========================================================================
  /// Validates the card holder name field.
  ///
  /// Rules:
  /// - Minimum 2 characters
  /// - Only letters and spaces allowed
  /// - No consecutive spaces
  /// ==========================================================================
  static String? _validateCardHolderName(String name) {
    if (name.trim().length < 2) {
      return 'Name is too short';
    }

    // Only letters and spaces (including Arabic)
    if (!RegExp(r'^[\u0600-\u06FFa-zA-Z\s]+$').hasMatch(name)) {
      return 'Name can only contain letters';
    }

    // No consecutive spaces
    if (name.contains('  ')) {
      return 'Invalid name format';
    }

    return null; // Valid
  }

  /// ==========================================================================
  /// isFormComplete
  /// ==========================================================================
  /// Quick check if all required fields are filled (not necessarily valid).
  /// Useful for enabling/disabling the submit button.
  /// ==========================================================================
  static bool isFormComplete(PaymentData data) {
    return data.cardNumber.replaceAll(' ', '').length >= 13 &&
        data.expiryDate.contains('/') &&
        data.cvv.length >= 3;
  }

  /// ==========================================================================
  /// getCardType
  /// ==========================================================================
  /// Determines the card type from the card number.
  /// ==========================================================================
  static CardType getCardType(String cardNumber) {
    return CardValidationService.getCardType(cardNumber);
  }

  /// ==========================================================================
  /// formatCardNumber
  /// ==========================================================================
  /// Formats the card number with appropriate spacing.
  /// ==========================================================================
  static String formatCardNumber(String cardNumber) {
    return CardValidationService.formatCardNumber(cardNumber);
  }
}

/// =============================================================================
/// PaymentData Model
/// =============================================================================
/// Holds all payment card information for validation.
///
/// Fields:
/// - cardNumber: The full card number (may include spaces)
/// - expiryDate: Expiry date in MM/YY format
/// - cvv: The security code (3-4 digits)
/// - cardHolderName: Optional name on the card
/// =============================================================================
class PaymentData {
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String? cardHolderName;

  const PaymentData({
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    this.cardHolderName,
  });

  /// Create a copy with updated values
  PaymentData copyWith({
    String? cardNumber,
    String? expiryDate,
    String? cvv,
    String? cardHolderName,
  }) {
    return PaymentData(
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      cardHolderName: cardHolderName ?? this.cardHolderName,
    );
  }

  /// Check if data is empty
  bool get isEmpty {
    return cardNumber.isEmpty && expiryDate.isEmpty && cvv.isEmpty;
  }

  @override
  String toString() {
    return 'PaymentData(cardNumber: ***masked***, expiryDate: $expiryDate, cvv: ***, cardHolderName: $cardHolderName)';
  }
}

/// =============================================================================
/// PaymentValidationResult Model
/// =============================================================================
/// Contains the result of payment validation.
///
/// Fields:
/// - isValid: Whether all validations passed
/// - errors: List of field-specific errors
/// - cardType: Detected card type (Visa, Mastercard, etc.)
/// - maskedCardNumber: Card number with middle digits hidden
/// =============================================================================
class PaymentValidationResult {
  final bool isValid;
  final List<PaymentFieldError> errors;
  final CardType cardType;
  final String maskedCardNumber;

  const PaymentValidationResult({
    required this.isValid,
    required this.errors,
    required this.cardType,
    required this.maskedCardNumber,
  });

  /// Get error message for a specific field
  String? getErrorFor(PaymentField field) {
    try {
      return errors.firstWhere((e) => e.field == field).message;
    } catch (_) {
      return null;
    }
  }

  /// Check if a specific field has an error
  bool hasErrorFor(PaymentField field) {
    return errors.any((e) => e.field == field);
  }

  /// Get all error messages as a single string
  String get allErrorMessages {
    return errors.map((e) => e.message).join(', ');
  }

  @override
  String toString() {
    return 'PaymentValidationResult(isValid: $isValid, errors: ${errors.length}, cardType: ${cardType.displayName})';
  }
}

/// =============================================================================
/// PaymentFieldError Model
/// =============================================================================
/// Represents an error for a specific payment field.
/// =============================================================================
class PaymentFieldError {
  final PaymentField field;
  final String message;

  const PaymentFieldError({required this.field, required this.message});

  @override
  String toString() {
    return 'PaymentFieldError(field: ${field.name}, message: $message)';
  }
}

/// =============================================================================
/// PaymentField Enum
/// =============================================================================
/// Enum representing payment form fields for error mapping.
/// =============================================================================
enum PaymentField { cardNumber, expiryDate, cvv, cardHolderName }

/// Extension to get display names for PaymentField
extension PaymentFieldExtension on PaymentField {
  String get displayName {
    switch (this) {
      case PaymentField.cardNumber:
        return 'Card Number';
      case PaymentField.expiryDate:
        return 'Expiry Date';
      case PaymentField.cvv:
        return 'CVV';
      case PaymentField.cardHolderName:
        return 'Card Holder Name';
    }
  }
}
