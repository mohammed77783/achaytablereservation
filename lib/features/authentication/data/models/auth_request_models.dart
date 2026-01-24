/// Authentication request models for API communication
/// Contains all request models for authentication endpoints

/// Request model for user registration
class RegisterRequest {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? email;
  final String password;
  final String confirmPassword;

  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.email,
    required this.password,
    required this.confirmPassword,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }

  /// Create from JSON
  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      password: json['password'] as String,
      confirmPassword: json['confirmPassword'] as String,
    );
  }

  @override
  String toString() {
    return 'RegisterRequest(firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegisterRequest &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.password == password &&
        other.confirmPassword == confirmPassword;
  }

  @override
  int get hashCode {
    return Object.hash(
      firstName,
      lastName,
      phoneNumber,
      email,
      password,
      confirmPassword,
    );
  }
}

/// Request model for user login
class LoginRequest {
  final String phoneNumber;
  final String password;

  const LoginRequest({required this.phoneNumber, required this.password});

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {'phoneNumber': phoneNumber, 'password': password};
  }

  /// Create from JSON
  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      phoneNumber: json['phoneNumber'] as String,
      password: json['password'] as String,
    );
  }

  @override
  String toString() {
    return 'LoginRequest(phoneNumber: $phoneNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginRequest &&
        other.phoneNumber == phoneNumber &&
        other.password == password;
  }

  @override
  int get hashCode => Object.hash(phoneNumber, password);
}

/// Request model for OTP verification
class VerifyOtpRequest {
  final String phoneNumber;
  final String otpCode;

  const VerifyOtpRequest({required this.phoneNumber, required this.otpCode});

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {'phoneNumber': phoneNumber, 'otpCode': otpCode};
  }

  /// Create from JSON
  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) {
    return VerifyOtpRequest(
      phoneNumber: json['phoneNumber'] as String,
      otpCode: json['otpCode'] as String,
    );
  }

  @override
  String toString() {
    return 'VerifyOtpRequest(phoneNumber: $phoneNumber, otpCode: $otpCode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerifyOtpRequest &&
        other.phoneNumber == phoneNumber &&
        other.otpCode == otpCode;
  }

  @override
  int get hashCode => Object.hash(phoneNumber, otpCode);
}

/// Request model for forgot password
class ForgotPasswordRequest {
  final String phoneNumber;

  const ForgotPasswordRequest({required this.phoneNumber});

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {'phoneNumber': phoneNumber};
  }

  /// Create from JSON
  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordRequest(phoneNumber: json['phoneNumber'] as String);
  }

  @override
  String toString() {
    return 'ForgotPasswordRequest(phoneNumber: $phoneNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ForgotPasswordRequest && other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode => phoneNumber.hashCode;
}

/// Request model for password reset
class ResetPasswordRequest {
  final String phoneNumber;
  final String otpCode;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordRequest({
    required this.phoneNumber,
    required this.otpCode,
    required this.newPassword,
    required this.confirmPassword,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'otpCode': otpCode,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }

  /// Create from JSON
  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ResetPasswordRequest(
      phoneNumber: json['phoneNumber'] as String,
      otpCode: json['otpCode'] as String,
      newPassword: json['newPassword'] as String,
      confirmPassword: json['confirmPassword'] as String,
    );
  }

  @override
  String toString() {
    return 'ResetPasswordRequest(phoneNumber: $phoneNumber, otpCode: $otpCode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResetPasswordRequest &&
        other.phoneNumber == phoneNumber &&
        other.otpCode == otpCode &&
        other.newPassword == newPassword &&
        other.confirmPassword == confirmPassword;
  }

  @override
  int get hashCode {
    return Object.hash(phoneNumber, otpCode, newPassword, confirmPassword);
  }
}

/// Request model for token refresh
class RefreshTokenRequest {
  final String accessToken;
  final String refreshToken;

  const RefreshTokenRequest({
    required this.accessToken,
    required this.refreshToken,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {'accessToken': accessToken, 'refreshToken': refreshToken};
  }

  /// Create from JSON
  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) {
    return RefreshTokenRequest(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  @override
  String toString() {
    return 'RefreshTokenRequest(accessToken: ${accessToken.substring(0, 10)}..., refreshToken: ${refreshToken.substring(0, 10)}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RefreshTokenRequest &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode => Object.hash(accessToken, refreshToken);
}
