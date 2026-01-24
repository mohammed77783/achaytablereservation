/// Authentication response models for API communication
/// Contains all response models for authentication endpoints
library;

import 'package:achaytablereservation/core/shared/model/user_model.dart';

/// Generic API response wrapper

/// Authentication response containing tokens and user data
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiration;
  final DateTime refreshTokenExpiration;
  final UserModel user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiration,
    required this.refreshTokenExpiration,
    required this.user,
  });

  /// Create from JSON
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      accessTokenExpiration: DateTime.parse(
        json['accessTokenExpiration'] as String,
      ),
      refreshTokenExpiration: DateTime.parse(
        json['refreshTokenExpiration'] as String,
      ),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accessTokenExpiration': accessTokenExpiration.toIso8601String(),
      'refreshTokenExpiration': refreshTokenExpiration.toIso8601String(),
      'user': user.toJson(),
    };
  }

  @override
  String toString() {
    return 'AuthResponse(accessToken: ${accessToken.substring(0, 10)}..., refreshToken: ${refreshToken.substring(0, 10)}..., user: $user)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthResponse &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.accessTokenExpiration == accessTokenExpiration &&
        other.refreshTokenExpiration == refreshTokenExpiration &&
        other.user == user;
  }

  @override
  int get hashCode {
    return Object.hash(
      accessToken,
      refreshToken,
      accessTokenExpiration,
      refreshTokenExpiration,
      user,
    );
  }
}

/// OTP response indicating whether OTP verification is required
class OtpResponse {
  final bool requiresOtp;
  final String? otp;
  const OtpResponse({required this.requiresOtp, this.otp});

  /// Create from JSON
  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      requiresOtp: json['requiresOtp'] as bool? ?? false,
      otp: json['otp'] as String? ?? "0",
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'requiresOtp': requiresOtp, "otp": otp};
  }

  @override
  String toString() {
    return 'OtpResponse(requiresOtp: $requiresOtp, otp: $otp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OtpResponse &&
        other.requiresOtp == requiresOtp &&
        other.otp == otp;
  }

  @override
  int get hashCode => Object.hash(requiresOtp, otp);
}

/// User model representing user profile data
