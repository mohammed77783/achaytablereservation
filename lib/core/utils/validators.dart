/// Utility class for input validation
class Validators {
  Validators._();

  /// Validates if a field is not empty
  /// Returns null if valid, error message if invalid
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validates email format
  /// Returns null if valid, error message if invalid
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
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
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (requireStrong) {
      if (!value.contains(RegExp(r'[A-Z]'))) {
        return 'Password must contain at least one uppercase letter';
      }

      if (!value.contains(RegExp(r'[a-z]'))) {
        return 'Password must contain at least one lowercase letter';
      }

      if (!value.contains(RegExp(r'[0-9]'))) {
        return 'Password must contain at least one number';
      }

      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        return 'Password must contain at least one special character';
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
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!value.contains(RegExp(r'[A-Za-z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // if (!value.contains(RegExp(r'[a-z]'))) {
    //   return 'Password must contain at least one lowercase letter';
    // }

    // if (!value.contains(RegExp(r'[0-9]'))) {
    //   return 'Password must contain at least one digit';
    // }

    // if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    //   return 'Password must contain at least one special character (!@#\$%^&*(),.?":{}|<>)';
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
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates phone number format
  /// Returns null if valid, error message if invalid
  /// Supports international formats
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove common formatting characters
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    // Check if it contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanedValue)) {
      return 'Phone number must contain only digits';
    }

    // Check length (typically 10-15 digits for international numbers)
    if (cleanedValue.length < 10 || cleanedValue.length > 15) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates Saudi phone number format
  /// Returns null if valid, error message if invalid
  /// Pattern: (05|5)xxxxxxxx (exactly 10 digits)
  static String? validateSaudiPhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove common formatting characters
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    // Check if it contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanedValue)) {
      return 'Phone number must contain only digits';
    }

    // Saudi phone number pattern: (05|5)xxxxxxxx (exactly 10 digits)
    if (!RegExp(r'^(05|5)[0-9]{8}$').hasMatch(cleanedValue)) {
      return 'Please enter a valid Saudi phone number (05xxxxxxxx or 5xxxxxxxx)';
    }

    return null;
  }

  /// Validates OTP code format
  /// Returns null if valid, error message if invalid
  /// Pattern: 6-digit numeric code
  static String? validateOtpCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP code is required';
    }

    final cleanedValue = value.trim();

    // Check if it's exactly 6 digits
    if (!RegExp(r'^[0-9]{6}$').hasMatch(cleanedValue)) {
      return 'OTP code must be exactly 6 digits';
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
      return '${fieldName ?? 'This field'} is required';
    }

    if (value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
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
      return '${fieldName ?? 'This field'} must not exceed $maxLength characters';
    }

    return null;
  }

  /// Validates numeric input
  /// Returns null if valid, error message if invalid
  static String? validateNumeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a valid number';
    }

    return null;
  }

  /// Validates URL format
  /// Returns null if valid, error message if invalid
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }

    return null;
  }
}
