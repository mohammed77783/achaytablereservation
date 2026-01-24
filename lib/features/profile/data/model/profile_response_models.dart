/// Response model for password update
class PasswordUpdateResponse {
  final bool passwordUpdated;

  PasswordUpdateResponse({
    required this.passwordUpdated,
  });

  factory PasswordUpdateResponse.fromJson(Map<String, dynamic> json) {
    return PasswordUpdateResponse(
      passwordUpdated: json['passwordUpdated'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passwordUpdated': passwordUpdated,
    };
  }

  @override
  String toString() {
    return 'PasswordUpdateResponse(passwordUpdated: $passwordUpdated)';
  }
}

/// Response model for phone change request (OTP sent)
class PhoneChangeOtpResponse {
  final bool requiresOtp;
  final String? otpCode; // Only included in development/testing

  PhoneChangeOtpResponse({
    required this.requiresOtp,
    this.otpCode,
  });

  factory PhoneChangeOtpResponse.fromJson(Map<String, dynamic> json) {
    return PhoneChangeOtpResponse(
      requiresOtp: json['requiresOtp'] as bool,
      otpCode: json['otpCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requiresOtp': requiresOtp,
      if (otpCode != null) 'otpCode': otpCode,
    };
  }

  @override
  String toString() {
    return 'PhoneChangeOtpResponse(requiresOtp: $requiresOtp, otpCode: $otpCode)';
  }
}