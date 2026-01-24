import '../../../core/utils/validators.dart';

/// Authentication-specific validation utilities
/// Provides validation methods for authentication-related inputs
class AuthValidators {
  AuthValidators._();

  /// Validates registration phone number using Saudi format
  /// Returns null if valid, error message if invalid
  /// Pattern: (05|5)xxxxxxxx (exactly 10 digits)
  static String? validateRegistrationPhoneNumber(String? value) {
    return Validators.validateSaudiPhoneNumber(value);
  }

  /// Validates login phone number using Saudi format
  /// Returns null if valid, error message if invalid
  /// Pattern: (05|5)xxxxxxxx (exactly 10 digits)
  static String? validateLoginPhoneNumber(String? value) {
    return Validators.validateSaudiPhoneNumber(value);
  }

  /// Validates password reset phone number using Saudi format
  /// Returns null if valid, error message if invalid
  /// Pattern: (05|5)xxxxxxxx (exactly 10 digits)
  static String? validatePasswordResetPhoneNumber(String? value) {
    return Validators.validateSaudiPhoneNumber(value);
  }

  /// Validates registration password
  /// Returns null if valid, error message if invalid
  /// Uses standard password validation (6-100 characters)
  static String? validateRegistrationPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    if (value.length > 100) {
      return 'Password must not exceed 100 characters';
    }

    return null;
  }

  /// Validates login password
  /// Returns null if valid, error message if invalid
  /// Basic validation for login (just required check)
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    return null;
  }

  /// Validates password reset new password using strong password requirements
  /// Returns null if valid, error message if invalid
  /// Strong password pattern: minimum 8 characters, uppercase, lowercase, digit, special character
  static String? validatePasswordResetNewPassword(String? value) {
    return Validators.validateStrongPassword(value);
  }

  /// Validates password confirmation matches the original password
  /// Returns null if valid, error message if invalid
  static String? validatePasswordConfirmation(
    String? password,
    String? confirmPassword,
  ) {
    return Validators.validatePasswordMatch(password, confirmPassword);
  }

  /// Validates OTP code format for verification
  /// Returns null if valid, error message if invalid
  /// Pattern: exactly 6 digits
  static String? validateOtpCode(String? value) {
    return Validators.validateOtpCode(value);
  }

  /// Validates registration OTP code
  /// Returns null if valid, error message if invalid
  /// Pattern: exactly 6 digits
  static String? validateRegistrationOtpCode(String? value) {
    return Validators.validateOtpCode(value);
  }

  /// Validates login OTP code
  /// Returns null if valid, error message if invalid
  /// Pattern: exactly 6 digits
  static String? validateLoginOtpCode(String? value) {
    return Validators.validateOtpCode(value);
  }

  /// Validates password reset OTP code
  /// Returns null if valid, error message if invalid
  /// Pattern: exactly 6 digits
  static String? validatePasswordResetOtpCode(String? value) {
    return Validators.validateOtpCode(value);
  }

  /// Validates first name for registration
  /// Returns null if valid, error message if invalid
  /// Requirements: 2-100 characters
  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return 'First name must be at least 2 characters long';
    }

    if (trimmedValue.length > 100) {
      return 'First name must not exceed 100 characters';
    }

    return null;
  }

  /// Validates last name for registration
  /// Returns null if valid, error message if invalid
  /// Requirements: 2-100 characters
  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last name is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return 'Last name must be at least 2 characters long';
    }

    if (trimmedValue.length > 100) {
      return 'Last name must not exceed 100 characters';
    }

    return null;
  }

  /// Validates email for registration (optional field)
  /// Returns null if valid or empty, error message if invalid
  static String? validateRegistrationEmail(String? value) {
    // Email is optional, so null or empty is valid
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return Validators.validateEmail(value);
  }

  /// Validates complete registration form
  /// Returns a map of field names to error messages
  /// Only includes fields that have validation errors
  static Map<String, String> validateRegistrationForm({
    required String? firstName,
    required String? lastName,
    required String? phoneNumber,
    String? email,
    required String? password,
    required String? confirmPassword,
  }) {
    final errors = <String, String>{};

    final firstNameError = validateFirstName(firstName);
    if (firstNameError != null) {
      errors['firstName'] = firstNameError;
    }

    final lastNameError = validateLastName(lastName);
    if (lastNameError != null) {
      errors['lastName'] = lastNameError;
    }

    final phoneError = validateRegistrationPhoneNumber(phoneNumber);
    if (phoneError != null) {
      errors['phoneNumber'] = phoneError;
    }

    final emailError = validateRegistrationEmail(email);
    if (emailError != null) {
      errors['email'] = emailError;
    }

    final passwordError = validateRegistrationPassword(password);
    if (passwordError != null) {
      errors['password'] = passwordError;
    }

    final confirmPasswordError = validatePasswordConfirmation(
      password,
      confirmPassword,
    );
    if (confirmPasswordError != null) {
      errors['confirmPassword'] = confirmPasswordError;
    }

    return errors;
  }

  /// Validates complete login form
  /// Returns a map of field names to error messages
  /// Only includes fields that have validation errors
  static Map<String, String> validateLoginForm({
    required String? phoneNumber,
    required String? password,
  }) {
    final errors = <String, String>{};

    final phoneError = validateLoginPhoneNumber(phoneNumber);
    if (phoneError != null) {
      errors['phoneNumber'] = phoneError;
    }

    final passwordError = validateLoginPassword(password);
    if (passwordError != null) {
      errors['password'] = passwordError;
    }

    return errors;
  }

  /// Validates complete password reset form
  /// Returns a map of field names to error messages
  /// Only includes fields that have validation errors
  static Map<String, String> validatePasswordResetForm({
    required String? phoneNumber,
    required String? otpCode,
    required String? newPassword,
    required String? confirmPassword,
  }) {
    final errors = <String, String>{};

    final phoneError = validatePasswordResetPhoneNumber(phoneNumber);
    if (phoneError != null) {
      errors['phoneNumber'] = phoneError;
    }

    final otpError = validatePasswordResetOtpCode(otpCode);
    if (otpError != null) {
      errors['otpCode'] = otpError;
    }

    final passwordError = validatePasswordResetNewPassword(newPassword);
    if (passwordError != null) {
      errors['newPassword'] = passwordError;
    }

    final confirmPasswordError = validatePasswordConfirmation(
      newPassword,
      confirmPassword,
    );
    if (confirmPasswordError != null) {
      errors['confirmPassword'] = confirmPasswordError;
    }

    return errors;
  }
}
