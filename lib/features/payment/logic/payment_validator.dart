import 'package:get/get.dart';

/// Simple validator class for payment form fields
/// Keeps validation logic separate from controller for cleaner architecture
class PaymentValidator {
  // Reactive error messages
  final RxnString cardNumberError = RxnString(null);
  final RxnString expiryDateError = RxnString(null);
  final RxnString cvvError = RxnString(null);

  /// Validate card number using Luhn algorithm
  bool validateCardNumber(String cardNumber) {
    final error = _getCardNumberError(cardNumber);
    cardNumberError.value = error;
    return error == null;
  }

  /// Validate expiry date (MM/YY format)
  bool validateExpiryDate(String expiryDate) {
    final error = _getExpiryDateError(expiryDate);
    expiryDateError.value = error;
    return error == null;
  }

  /// Validate CVV based on card type
  bool validateCvv(String cvv, String cardNumber) {
    final error = _getCvvError(cvv, cardNumber);
    cvvError.value = error;
    return error == null;
  }

  /// Validate all fields at once
  bool validateAll({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
  }) {
    final isCardValid = validateCardNumber(cardNumber);
    final isExpiryValid = validateExpiryDate(expiryDate);
    final isCvvValid = validateCvv(cvv, cardNumber);
    return isCardValid && isExpiryValid && isCvvValid;
  }

  /// Check if form is complete (quick check without full validation)
  bool isFormComplete(String cardNumber, String expiryDate, String cvv) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 13 && expiryDate.contains('/') && cvv.length >= 3;
  }

  /// Clear all errors (when user starts editing)
  void clearCardNumberError() => cardNumberError.value = null;
  void clearExpiryDateError() => expiryDateError.value = null;
  void clearCvvError() => cvvError.value = null;
  
  void clearAllErrors() {
    cardNumberError.value = null;
    expiryDateError.value = null;
    cvvError.value = null;
  }

  /// Get card type for display
  CardBrand getCardType(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (cleaned.isEmpty) return CardBrand.unknown;

    if (cleaned.startsWith('4')) return CardBrand.visa;
    if (cleaned.startsWith('5') || _isMastercardRange(cleaned)) {
      return CardBrand.mastercard;
    }
    if (cleaned.startsWith('34') || cleaned.startsWith('37')) {
      return CardBrand.amex;
    }
    if (_isDiscoverCard(cleaned)) return CardBrand.discover;
    if (_isMadaCard(cleaned)) return CardBrand.mada;

    return CardBrand.unknown;
  }

  /// Format card number with spaces
  String formatCardNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    final cardType = getCardType(digits);

    // Amex: 4-6-5 pattern, others: 4-4-4-4 pattern
    final pattern = cardType == CardBrand.amex ? [4, 6, 5] : [4, 4, 4, 4];
    int index = 0;

    for (int groupSize in pattern) {
      if (index >= digits.length) break;
      if (buffer.isNotEmpty) buffer.write(' ');
      final end = (index + groupSize).clamp(0, digits.length);
      buffer.write(digits.substring(index, end));
      index = end;
    }
    return buffer.toString();
  }

  /// Format expiry date with slash
  String formatExpiryDate(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 2) return digits;
    final month = digits.substring(0, 2);
    final year = digits.substring(2, digits.length > 4 ? 4 : digits.length);
    return '$month/$year';
  }

  /// Mask card number for display (show first 4 and last 4)
  String maskCardNumber(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length <= 8) return '*' * cleaned.length;
    final first4 = cleaned.substring(0, 4);
    final last4 = cleaned.substring(cleaned.length - 4);
    return '$first4${'*' * (cleaned.length - 8)}$last4';
  }

  // ==================== Private Validation Methods ====================

  String? _getCardNumberError(String cardNumber) {
    if (cardNumber.isEmpty) return 'card_number_required'.tr;

    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 13) return 'card_number_too_short'.tr;
    if (cleaned.length > 19) return 'card_number_too_long'.tr;
    if (!_luhnCheck(cleaned)) return 'invalid_card_number'.tr;

    return null;
  }

  String? _getExpiryDateError(String expiryDate) {
    if (expiryDate.isEmpty) return 'expiry_date_required'.tr;
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDate)) {
      return 'invalid_expiry_format'.tr;
    }

    final parts = expiryDate.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse(parts[1]) + 2000;

    if (month < 1 || month > 12) return 'invalid_month'.tr;

    final now = DateTime.now();
    final expiry = DateTime(year, month + 1, 0);
    if (!expiry.isAfter(now)) return 'card_expired'.tr;

    return null;
  }

  String? _getCvvError(String cvv, String cardNumber) {
    if (cvv.isEmpty) return 'cvv_required'.tr;

    final cardType = getCardType(cardNumber);
    final requiredLength = cardType == CardBrand.amex ? 4 : 3;

    if (cvv.length != requiredLength) {
      return 'cvv_must_be_digits'.trParams({
        'count': requiredLength.toString(),
      });
    }

    return null;
  }

  /// Luhn algorithm for card number validation
  bool _luhnCheck(String cardNumber) {
    int sum = 0;
    bool alternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit = (digit % 10) + 1;
      }
      sum += digit;
      alternate = !alternate;
    }

    return (sum % 10) == 0;
  }

  bool _isMastercardRange(String number) {
    if (number.length < 4) return false;
    final prefix = int.tryParse(number.substring(0, 4)) ?? 0;
    return prefix >= 2221 && prefix <= 2720;
  }

  bool _isDiscoverCard(String number) {
    if (number.startsWith('6011') || number.startsWith('65')) return true;
    if (number.length >= 6) {
      final prefix6 = int.tryParse(number.substring(0, 6)) ?? 0;
      if (prefix6 >= 622126 && prefix6 <= 622925) return true;
    }
    if (number.length >= 3) {
      final prefix3 = int.tryParse(number.substring(0, 3)) ?? 0;
      if (prefix3 >= 644 && prefix3 <= 649) return true;
    }
    return false;
  }


  bool _isMadaCard(String number) {
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
    ];
    if (number.length >= 6) {
      return madaBins.contains(number.substring(0, 6));
    }
    return false;
  }
}

/// Card brand enum
enum CardBrand { visa, mastercard, amex, discover, mada, unknown }

/// Extension for card brand display
extension CardBrandExtension on CardBrand {
  String get displayName {
    switch (this) {
      case CardBrand.visa:
        return 'Visa';
      case CardBrand.mastercard:
        return 'Mastercard';
      case CardBrand.amex:
        return 'American Express';
      case CardBrand.discover:
        return 'Discover';
      case CardBrand.mada:
        return 'Mada';
      case CardBrand.unknown:
        return '';
    }
  }

  String get iconAsset {
    switch (this) {
      case CardBrand.visa:
        return 'assets/icons/visa.png';
      case CardBrand.mastercard:
        return 'assets/icons/mastercard.png';
      case CardBrand.amex:
        return 'assets/icons/amex.png';
      case CardBrand.discover:
        return 'assets/icons/discover.png';
      case CardBrand.mada:
        return 'assets/icons/mada.png';
      case CardBrand.unknown:
        return 'assets/icons/card.png';
    }
  }
}
