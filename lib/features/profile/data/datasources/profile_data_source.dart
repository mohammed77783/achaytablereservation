import 'package:achaytablereservation/core/constants/api_constants.dart';
import 'package:achaytablereservation/core/errors/error_handler.dart';
import 'package:achaytablereservation/core/network/api_client.dart';
import 'package:achaytablereservation/core/shared/model/api_response.dart';
import 'package:achaytablereservation/features/profile/data/model/profile_model.dart';
import 'package:achaytablereservation/features/profile/data/model/profile_request_models.dart';
import 'package:achaytablereservation/features/profile/data/model/profile_response_models.dart';

/// Abstract interface for Profile data source
abstract class ProfileDataSource {
  /// Get user profile
  Future<ApiResponse<ProfileModel>> getProfile();

  /// Update user profile
  Future<ApiResponse<ProfileModel>> updateProfile(UpdateProfileRequest request);

  /// Update user password
  Future<ApiResponse<PasswordUpdateResponse>> updatePassword(
    UpdatePasswordRequest request,
  );

  /// Request phone number change (sends OTP)
  Future<ApiResponse<PhoneChangeOtpResponse>> changePhoneNumber(
    ChangePhoneNumberRequest request,
  );

  /// Verify phone number change with OTP
  Future<ApiResponse<ProfileModel>> verifyPhoneChange(
    VerifyPhoneChangeRequest request,
  );
}

/// Implementation of Profile data source using API client
class ProfileDataSourceImpl implements ProfileDataSource {
  final ApiClient _apiClient;

  ProfileDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<ApiResponse<ProfileModel>> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.profile);
      return ApiResponse<ProfileModel>.fromJson(
        response as Map<String, dynamic>,
        (data) => ProfileModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      ErrorHandler.logError(
        'Failed to get profile',
        StackTrace.current,
        context: 'ProfileDataSourceImpl.getProfile',
        additionalData: {
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      rethrow;
    }
  }

  @override
  Future<ApiResponse<ProfileModel>> updateProfile(
    UpdateProfileRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.profile,
        body: request.toJson(),
      );

      return ApiResponse<ProfileModel>.fromJson(
        response as Map<String, dynamic>,
        (data) => ProfileModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      ErrorHandler.logError(
        'Failed to update profile',
        StackTrace.current,
        context: 'ProfileDataSourceImpl.updateProfile',
        additionalData: {
          'request': request.toString(),
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      rethrow;
    }
  }

  @override
  Future<ApiResponse<PasswordUpdateResponse>> updatePassword(
    UpdatePasswordRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.profilePassword,
        body: request.toJson(),
      );

      return ApiResponse<PasswordUpdateResponse>.fromJson(
        response as Map<String, dynamic>,
        (data) => PasswordUpdateResponse.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      ErrorHandler.logError(
        'Failed to update password',
        StackTrace.current,
        context: 'ProfileDataSourceImpl.updatePassword',
        additionalData: {
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      rethrow;
    }
  }

  @override
  Future<ApiResponse<PhoneChangeOtpResponse>> changePhoneNumber(
    ChangePhoneNumberRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.profilePhoneChange,
        body: request.toJson(),
      );

      return ApiResponse<PhoneChangeOtpResponse>.fromJson(
        response as Map<String, dynamic>,
        (data) => PhoneChangeOtpResponse.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      ErrorHandler.logError(
        'Failed to request phone change',
        StackTrace.current,
        context: 'ProfileDataSourceImpl.changePhoneNumber',
        additionalData: {
          'newPhoneNumber': request.newPhoneNumber,
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      rethrow;
    }
  }

  @override
  Future<ApiResponse<ProfileModel>> verifyPhoneChange(
    VerifyPhoneChangeRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.profilePhoneVerify,
        body: request.toJson(),
      );

      return ApiResponse<ProfileModel>.fromJson(
        response as Map<String, dynamic>,
        (data) => ProfileModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      ErrorHandler.logError(
        'Failed to verify phone change',
        StackTrace.current,
        context: 'ProfileDataSourceImpl.verifyPhoneChange',
        additionalData: {
          'newPhoneNumber': request.newPhoneNumber,
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      rethrow;
    }
  }
}
