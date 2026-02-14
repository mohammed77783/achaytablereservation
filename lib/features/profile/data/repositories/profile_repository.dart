import 'package:achaytablereservation/core/errors/failures.dart';
import 'package:achaytablereservation/core/errors/error_handler.dart';
import 'package:achaytablereservation/features/profile/data/model/profile_model.dart';
import 'package:achaytablereservation/features/profile/data/model/profile_request_models.dart';
import 'package:achaytablereservation/features/profile/data/model/profile_response_models.dart';
import 'package:dartz/dartz.dart';
import '../datasources/profile_data_source.dart';

/// Repository for managing Profile operations
/// Provides a clean abstraction layer between data sources and use cases
class ProfileRepository {
  final ProfileDataSource _profileDataSource;

  ProfileRepository({required ProfileDataSource profileDataSource})
    : _profileDataSource = profileDataSource;

  /// Retrieves user profile from the API
  /// Returns Either<Failure, ProfileModel> for proper error handling
  Future<Either<Failure, ProfileModel>> getProfile() async {
    try {
      final response = await _profileDataSource.getProfile();
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        final errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to fetch profile';
        ErrorHandler.logError(
          'API returned unsuccessful response',
          StackTrace.current,
          context: 'ProfileRepository.getProfile',
          additionalData: {
            'success': response.success,
            'message': response.message,
            'errors': response.errors,
          },
        );
        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      final failure = ErrorHandler.exceptionToFailure(e as Exception);

      ErrorHandler.logFailure(
        failure,
        context: 'ProfileRepository.getProfile',
        additionalData: {
          'operation': 'getProfile',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return Left(failure);
    }
  }

  /// Updates user profile
  /// Returns Either<Failure, ProfileModel> with updated profile data
  ///
  /// Parameters:
  /// - [username]: Optional new username (3-200 characters)
  /// - [email]: Optional new email
  /// - [firstName]: Optional new first name (2-100 characters)
  /// - [lastName]: Optional new last name (2-100 characters)
  Future<Either<Failure, ProfileModel>> updateProfile({
    String? username,
    String? email,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final request = UpdateProfileRequest(
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
      );

      final response = await _profileDataSource.updateProfile(request);

      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        final errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to update profile';

        ErrorHandler.logError(
          'API returned unsuccessful response',
          StackTrace.current,
          context: 'ProfileRepository.updateProfile',
          additionalData: {
            'success': response.success,
            'message': response.message,
            'errors': response.errors,
            'request': request.toString(),
          },
        );

        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      final failure = ErrorHandler.exceptionToFailure(e as Exception);

      ErrorHandler.logFailure(
        failure,
        context: 'ProfileRepository.updateProfile',
        additionalData: {
          'operation': 'updateProfile',
          'username': username,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return Left(failure);
    }
  }

  /// Updates user password
  /// Returns Either<Failure, PasswordUpdateResponse> indicating success
  ///
  /// Parameters:
  /// - [oldPassword]: Current password
  /// - [newPassword]: New password (8-100 characters)
  /// - [confirmPassword]: Confirmation of new password (must match)
  Future<Either<Failure, PasswordUpdateResponse>> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final request = UpdatePasswordRequest(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final response = await _profileDataSource.updatePassword(request);

      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        final errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to update password';

        ErrorHandler.logError(
          'API returned unsuccessful response',
          StackTrace.current,
          context: 'ProfileRepository.updatePassword',
          additionalData: {
            'success': response.success,
            'message': response.message,
            'errors': response.errors,
          },
        );

        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      final failure = ErrorHandler.exceptionToFailure(e as Exception);

      ErrorHandler.logFailure(
        failure,
        context: 'ProfileRepository.updatePassword',
        additionalData: {
          'operation': 'updatePassword',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return Left(failure);
    }
  }

  /// Requests phone number change (sends OTP to new number)
  /// Returns Either<Failure, PhoneChangeOtpResponse> with OTP info
  ///
  /// Parameters:
  /// - [newPhoneNumber]: New phone number (Saudi format: 05xxxxxxxx or 5xxxxxxxx)
  Future<Either<Failure, PhoneChangeOtpResponse>> changePhoneNumber({
    required String newPhoneNumber,
  }) async {
    try {
      final request = ChangePhoneNumberRequest(newPhoneNumber: newPhoneNumber);

      final response = await _profileDataSource.changePhoneNumber(request);

      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        final errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to request phone number change';
        ErrorHandler.logError(
          'API returned unsuccessful response',
          StackTrace.current,
          context: 'ProfileRepository.changePhoneNumber',
          additionalData: {
            'success': response.success,
            'message': response.message,
            'errors': response.errors,
            'newPhoneNumber': newPhoneNumber,
          },
        );
        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      final failure = ErrorHandler.exceptionToFailure(e as Exception);
      ErrorHandler.logFailure(
        failure,
        context: 'ProfileRepository.changePhoneNumber',
        additionalData: {
          'operation': 'changePhoneNumber',
          'newPhoneNumber': newPhoneNumber,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return Left(failure);
    }
  }

  /// Deletes user account
  /// Returns Either<Failure, DeleteAccountResponse> indicating success
  ///
  /// Parameters:
  /// - [password]: User's current password for confirmation
  Future<Either<Failure, DeleteAccountResponse>> deleteAccount({
    required String password,
  }) async {
    try {
      final request = DeleteAccountRequest(password: password);

      final response = await _profileDataSource.deleteAccount(request);

      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        final errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to delete account';

        ErrorHandler.logError(
          'API returned unsuccessful response',
          StackTrace.current,
          context: 'ProfileRepository.deleteAccount',
          additionalData: {
            'success': response.success,
            'message': response.message,
            'errors': response.errors,
          },
        );

        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      final failure = ErrorHandler.exceptionToFailure(e as Exception);

      ErrorHandler.logFailure(
        failure,
        context: 'ProfileRepository.deleteAccount',
        additionalData: {
          'operation': 'deleteAccount',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return Left(failure);
    }
  }

  /// Verifies phone number change with OTP
  /// Returns Either<Failure, ProfileModel> with updated profile
  ///
  /// Parameters:
  /// - [newPhoneNumber]: The new phone number being verified
  /// - [otpCode]: 6-digit OTP code received via SMS
  Future<Either<Failure, ProfileModel>> verifyPhoneChange({
    required String newPhoneNumber,
    required String otpCode,
  }) async {
    try {
      final request = VerifyPhoneChangeRequest(
        newPhoneNumber: newPhoneNumber,
        otpCode: otpCode,
      );
      final response = await _profileDataSource.verifyPhoneChange(request);
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        final errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to verify phone number change';
        ErrorHandler.logError(
          'API returned unsuccessful response',
          StackTrace.current,
          context: 'ProfileRepository.verifyPhoneChange',
          additionalData: {
            'success': response.success,
            'message': response.message,
            'errors': response.errors,
            'newPhoneNumber': newPhoneNumber,
          },
        );
        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      final failure = ErrorHandler.exceptionToFailure(e as Exception);
      ErrorHandler.logFailure(
        failure,
        context: 'ProfileRepository.verifyPhoneChange',
        additionalData: {
          'operation': 'verifyPhoneChange',
          'newPhoneNumber': newPhoneNumber,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return Left(failure);
    }
  }
}
