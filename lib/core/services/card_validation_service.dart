import 'package:flutter/foundation.dart';

/// Service for validating credit card numbers using the Luhn algorithm
/// Requirements 3.1: Client-side card number validation using Luhn algorithm
class CardValidationService {
  /// Validate credit card number using Luhn algorithm
  /// Returns true if the card number is valid according to Luhn algorithm
  static bool validateCardNumber(String cardNumber) {
    if (cardNumber.isEmpty) return false;

    // Remove any spaces, dashes, or other non-digit characters
    String cleanedNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Card number must be between 13-19 digits
    if (cleanedNumber.length < 13 || cleanedNumber.length > 19) {
      return false;
    }

    return _luhnCheck(cleanedNumber);
  }

  /// Implement Luhn algorithm check
  /// The Luhn algorithm is used to validate credit card numbers
  ///
  /// Algorithm steps:
  /// 1. Starting from the rightmost digit, double every second digit
  /// 2. If doubling results in a number > 9, subtract 9 (or sum the two digits)
  /// 3. Sum all digits
  /// 4. If the total modulo 10 is 0, the card number is valid
  static bool _luhnCheck(String cardNumber) {
    int sum = 0;
    bool alternate = false;

    // Process digits from right to left
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return (sum % 10) == 0;
  }

  /// Get card type based on card number prefix
  /// Uses IIN (Issuer Identification Number) ranges
  static CardType getCardType(String cardNumber) {
    String cleanedNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanedNumber.isEmpty) return CardType.unknown;

    // Visa: starts with 4
    if (cleanedNumber.startsWith('4')) {
      return CardType.visa;
    }

    // Mastercard: starts with 5 or 2221-2720
    if (cleanedNumber.startsWith('5') ||
        (cleanedNumber.length >= 4 &&
            int.parse(cleanedNumber.substring(0, 4)) >= 2221 &&
            int.parse(cleanedNumber.substring(0, 4)) <= 2720)) {
      return CardType.mastercard;
    }

    // American Express: starts with 34 or 37
    if (cleanedNumber.startsWith('34') || cleanedNumber.startsWith('37')) {
      return CardType.amex;
    }

    // Discover: starts with 6011, 622126-622925, 644-649, or 65
    if (cleanedNumber.startsWith('6011') ||
        cleanedNumber.startsWith('65') ||
        (cleanedNumber.length >= 6 &&
            int.parse(cleanedNumber.substring(0, 6)) >= 622126 &&
            int.parse(cleanedNumber.substring(0, 6)) <= 622925) ||
        (cleanedNumber.length >= 3 &&
            int.parse(cleanedNumber.substring(0, 3)) >= 644 &&
            int.parse(cleanedNumber.substring(0, 3)) <= 649)) {
      return CardType.discover;
    }

    // Mada (Saudi Arabia): starts with specific BIN ranges
    if (_isMadaCard(cleanedNumber)) {
      return CardType.mada;
    }

    return CardType.unknown;
  }

  /// Check if card is a Mada card (Saudi Arabian debit card)
  static bool _isMadaCard(String cardNumber) {
    // Common Mada BIN prefixes (first 6 digits)
    const madaBins = [
      '440795',
      '440647',
      '421141',
      '474491',
      '588845',
      '968208',
      '457997',
      '457865',
      '468540',
      '468541',
      '468542',
      '468543',
      '417633',
      '446672',
      '484783',
      '446393',
      '439954',
      '458456',
      '462220',
      '455708',
      '410621',
      '455036',
      '486094',
      '486095',
      '486096',
      '504300',
      '440533',
      '489317',
      '489318',
      '489319',
      '445564',
      '968201',
      '968202',
      '407197',
      '445611',
      '532013',
    ];

    if (cardNumber.length >= 6) {
      final bin = cardNumber.substring(0, 6);
      return madaBins.contains(bin);
    }
    return false;
  }

  /// Format card number with spaces for display
  static String formatCardNumber(String cardNumber) {
    String cleanedNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanedNumber.isEmpty) return '';

    CardType cardType = getCardType(cleanedNumber);

    switch (cardType) {
      case CardType.amex:
        // American Express: XXXX XXXXXX XXXXX
        return _formatWithPattern(cleanedNumber, [4, 6, 5]);
      default:
        // Most cards: XXXX XXXX XXXX XXXX
        return _formatWithPattern(cleanedNumber, [4, 4, 4, 4]);
    }
  }

  /// Format card number with specific pattern
  static String _formatWithPattern(String number, List<int> pattern) {
    StringBuffer formatted = StringBuffer();
    int index = 0;

    for (int groupSize in pattern) {
      if (index >= number.length) break;

      if (formatted.isNotEmpty) {
        formatted.write(' ');
      }

      int endIndex = (index + groupSize).clamp(0, number.length);
      formatted.write(number.substring(index, endIndex));
      index = endIndex;
    }

    return formatted.toString();
  }

  /// Validate expiry date (MM/YY format)
  /// Returns true if the date is in correct format and not expired
  static bool validateExpiryDate(String expiryDate) {
    if (expiryDate.isEmpty) return false;

    // Remove any non-digit characters except /
    String cleaned = expiryDate.replaceAll(RegExp(r'[^\d/]'), '');

    // Check format MM/YY
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(cleaned)) {
      return false;
    }

    List<String> parts = cleaned.split('/');
    int month = int.parse(parts[0]);
    int year = int.parse(parts[1]) + 2000; // Convert YY to YYYY

    // Validate month
    if (month < 1 || month > 12) {
      return false;
    }

    // Check if not expired
    DateTime now = DateTime.now();
    DateTime expiryDateTime = DateTime(
      year,
      month + 1,
      0,
    ); // Last day of expiry month

    return expiryDateTime.isAfter(now);
  }

  /// Validate CVV code
  /// American Express: 4 digits
  /// Other cards: 3 digits
  static bool validateCvv(String cvv, CardType cardType) {
    if (cvv.isEmpty) return false;

    String cleanedCvv = cvv.replaceAll(RegExp(r'[^\d]'), '');

    switch (cardType) {
      case CardType.amex:
        return cleanedCvv.length == 4;
      default:
        return cleanedCvv.length == 3;
    }
  }

  /// Get validation error message for card number
  static String? getCardNumberError(String cardNumber) {
    if (cardNumber.isEmpty) {
      return 'Card number is required';
    }

    String cleanedNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanedNumber.length < 13) {
      return 'Card number is too short';
    }

    if (cleanedNumber.length > 19) {
      return 'Card number is too long';
    }

    if (!_luhnCheck(cleanedNumber)) {
      return 'Invalid card number';
    }

    return null; // No error
  }

  /// Get validation error message for expiry date
  static String? getExpiryDateError(String expiryDate) {
    if (expiryDate.isEmpty) {
      return 'Expiry date is required';
    }

    String cleaned = expiryDate.replaceAll(RegExp(r'[^\d/]'), '');

    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(cleaned)) {
      return 'Invalid format (MM/YY)';
    }

    List<String> parts = cleaned.split('/');
    int month = int.parse(parts[0]);
    int year = int.parse(parts[1]) + 2000;

    if (month < 1 || month > 12) {
      return 'Invalid month';
    }

    DateTime now = DateTime.now();
    DateTime expiryDateTime = DateTime(year, month + 1, 0);

    if (!expiryDateTime.isAfter(now)) {
      return 'Card has expired';
    }

    return null; // No error
  }

  /// Get validation error message for CVV
  static String? getCvvError(String cvv, CardType cardType) {
    if (cvv.isEmpty) {
      return 'CVV is required';
    }

    String cleanedCvv = cvv.replaceAll(RegExp(r'[^\d]'), '');
    int requiredLength = cardType == CardType.amex ? 4 : 3;

    if (cleanedCvv.length != requiredLength) {
      return 'CVV must be $requiredLength digits';
    }

    return null; // No error
  }

  /// Log validation attempt (for debugging)
  static void logValidation(String cardNumber, bool isValid) {
    if (kDebugMode) {
      String maskedNumber = _maskCardNumber(cardNumber);
      print('Card validation - Number: $maskedNumber, Valid: $isValid');
    }
  }

  /// Mask card number for logging (show only first 4 and last 4 digits)
  static String _maskCardNumber(String cardNumber) {
    String cleanedNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanedNumber.length <= 8) {
      return '*' * cleanedNumber.length;
    }

    String first4 = cleanedNumber.substring(0, 4);
    String last4 = cleanedNumber.substring(cleanedNumber.length - 4);
    String middle = '*' * (cleanedNumber.length - 8);

    return '$first4$middle$last4';
  }

  /// Get masked card number for display in UI
  static String getMaskedCardNumber(String cardNumber) {
    return _maskCardNumber(cardNumber);
  }
}

/// Enum for different card types
enum CardType {
  visa,
  mastercard,
  amex,
  discover,
  mada, // Saudi Arabian debit card
  unknown,
}

/// Extension to get card type display name and icon
extension CardTypeExtension on CardType {
  String get displayName {
    switch (this) {
      case CardType.visa:
        return 'Visa';
      case CardType.mastercard:
        return 'Mastercard';
      case CardType.amex:
        return 'American Express';
      case CardType.discover:
        return 'Discover';
      case CardType.mada:
        return 'Mada';
      case CardType.unknown:
        return 'Unknown';
    }
  }

  String get iconPath {
    switch (this) {
      case CardType.visa:
        return 'assets/icons/visa.png';
      case CardType.mastercard:
        return 'assets/icons/mastercard.png';
      case CardType.amex:
        return 'assets/icons/amex.png';
      case CardType.discover:
        return 'assets/icons/discover.png';
      case CardType.mada:
        return 'assets/icons/mada.png';
      case CardType.unknown:
        return 'assets/icons/card.png';
    }
  }

  /// Get card type abbreviation for payment gateway
  String get paymentCode {
    switch (this) {
      case CardType.visa:
        return 'VISA';
      case CardType.mastercard:
        return 'MC';
      case CardType.amex:
        return 'AMEX';
      case CardType.discover:
        return 'DISC';
      case CardType.mada:
        return 'MADA';
      case CardType.unknown:
        return 'UNKNOWN';
    }
  }
}
