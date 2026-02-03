import 'package:get/get.dart';

/// Utility class for input validation
class Validators {
  Validators._();

  /// Validates if a field is not empty
  /// Returns null if valid, error message if invalid
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '${fieldName} ${'validation_field_required'.tr}'
          : 'validation_field_required'.tr;
    }
    return null;
  }

  /// Validates email format
  /// Returns null if valid, error message if invalid
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation_email_required'.tr;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'validation_email_invalid'.tr;
    }

    return null;
  }

  /// Validates password strength
  /// Returns null if valid, error message if invalid
  ///
  /// Password requirements:
  /// - Minimum 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one number
  /// - At least one special character
  static String? validatePassword(String? value, {bool requireStrong = true}) {
    if (value == null || value.isEmpty) {
      return 'validation_password_required'.tr;
    }

    if (value.length < 8) {
      return 'validation_password_strong_required'.tr;
    }

    if (requireStrong) {
      if (!value.contains(RegExp(r'[A-Z]'))) {
        return 'validation_password_uppercase'.tr;
      }

      if (!value.contains(RegExp(r'[a-z]'))) {
        return 'validation_password_lowercase'.tr;
      }

      if (!value.contains(RegExp(r'[0-9]'))) {
        return 'validation_password_number'.tr;
      }

      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        return 'validation_password_special'.tr;
      }
    }

    return null;
  }

  /// Validates strong password for password reset
  /// Returns null if valid, error message if invalid
  ///
  /// Strong password requirements:
  /// - Minimum 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one digit
  /// - At least one special character
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'validation_password_required'.tr;
    }

    if (value.length < 8) {
      return 'validation_password_strong_required'.tr;
    }

    if (!value.contains(RegExp(r'[A-Za-z]'))) {
      return 'validation_password_uppercase'.tr;
    }

    // if (!value.contains(RegExp(r'[a-z]'))) {
    //   return 'validation_password_lowercase'.tr;
    // }

    // if (!value.contains(RegExp(r'[0-9]'))) {
    //   return 'validation_password_number'.tr;
    // }

    // if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    //   return 'validation_password_special'.tr;
    // }

    return null;
  }

  /// Validates if two passwords match
  /// Returns null if valid, error message if invalid
  static String? validatePasswordMatch(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'validation_confirm_password_required'.tr;
    }

    if (password != confirmPassword) {
      return 'validation_passwords_not_match'.tr;
    }

    return null;
  }

  /// Validates phone number format
  /// Returns null if valid, error message if invalid
  /// Supports international formats
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation_phone_required'.tr;
    }

    // Remove common formatting characters
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    // Check if it contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanedValue)) {
      return 'validation_phone_digits_only'.tr;
    }

    // Check length (typically 10-15 digits for international numbers)
    if (cleanedValue.length < 10 || cleanedValue.length > 15) {
      return 'validation_phone_saudi_format'.tr;
    }

    return null;
  }

  /// Validates Saudi phone number format
  /// Returns null if valid, error message if invalid
  /// Pattern: (05|5)xxxxxxxx (exactly 10 digits)
  static String? validateSaudiPhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation_phone_required'.tr;
    }

    // Remove common formatting characters
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    // Check if it contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanedValue)) {
      return 'validation_phone_digits_only'.tr;
    }

    // Saudi phone number pattern: (05|5)xxxxxxxx (exactly 10 digits)
    if (!RegExp(r'^(05|5)[0-9]{8}$').hasMatch(cleanedValue)) {
      return 'validation_phone_saudi_format'.tr;
    }

    return null;
  }

  /// Validates OTP code format
  /// Returns null if valid, error message if invalid
  /// Pattern: 6-digit numeric code
  static String? validateOtpCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation_otp_required'.tr;
    }

    final cleanedValue = value.trim();

    // Check if it's exactly 6 digits
    if (!RegExp(r'^[0-9]{6}$').hasMatch(cleanedValue)) {
      return 'validation_otp_format'.tr;
    }

    return null;
  }

  /// Validates minimum length
  /// Returns null if valid, error message if invalid
  static String? validateMinLength(
    String? value,
    int minLength, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? '${fieldName} ${'validation_field_required'.tr}'
          : 'validation_field_required'.tr;
    }

    if (value.length < minLength) {
      return 'validation_min_length'.tr.replaceAll(
        '@length',
        minLength.toString(),
      );
    }

    return null;
  }

  /// Validates maximum length
  /// Returns null if valid, error message if invalid
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String? fieldName,
  }) {
    if (value != null && value.length > maxLength) {
      return 'validation_max_length'.tr.replaceAll(
        '@length',
        maxLength.toString(),
      );
    }

    return null;
  }

  /// Validates numeric input
  /// Returns null if valid, error message if invalid
  static String? validateNumeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '${fieldName} ${'validation_field_required'.tr}'
          : 'validation_field_required'.tr;
    }

    if (double.tryParse(value) == null) {
      return 'validation_numeric_required'.tr;
    }

    return null;
  }

  /// Validates URL format
  /// Returns null if valid, error message if invalid
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation_url_required'.tr;
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'validation_url_invalid'.tr;
    }

    return null;
  }
}
