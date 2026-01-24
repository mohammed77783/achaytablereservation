import 'package:achaytablereservation/core/shared/model/user_model.dart';
import 'package:achaytablereservation/features/homepage/data/datasources/homepage_data_sources.dart';
import 'package:achaytablereservation/features/homepage/data/model/branch_models.dart';
import 'package:achaytablereservation/core/errors/failures.dart';
import 'package:achaytablereservation/core/errors/error_handler.dart';
import 'package:achaytablereservation/features/homepage/data/model/gallery_photo_model.dart';
import 'package:achaytablereservation/features/homepage/data/model/business_hour_model.dart';
import 'package:dartz/dartz.dart';

class HomepageRepository {
  final HomepageDataSources _homepageDatabaseSources;

  HomepageRepository({required HomepageDataSources homepageData})
    : _homepageDatabaseSources = homepageData;

  /// Retrieves user data from local storage
  /// Returns Either<Failure, UserModel?> for proper error handling
  Future<Either<Failure, UserModel?>> userdata() async {
    try {
      final userData = await _homepageDatabaseSources.getUserData();
      if (userData != null) {
        return Right(userData);
      } else {
        return Left(StorageFailure('No user data found in local storage'));
      }
    } catch (e) {
      final failure = ErrorHandler.exceptionToFailure(e as Exception);
      ErrorHandler.logFailure(
        failure,
        context: 'HomepageRepository.userdata',
        additionalData: {
          'operation': 'getUserData',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return Left(failure);
    }
  }

  /// Retrieves branches data from the API
  /// Returns Either<Failure, BranchesData> for proper error handling
  ///
  /// Parameters:
  /// - [city]: Optional city filter (e.g., 'بريدة', 'الرياض')
  /// - [sortBy]: Sort criteria (e.g., 'distance', 'name', 'rating')
  /// - [pageNumber]: Page number for pagination (default: 1)
  /// - [pageSize]: Number of items per page (default: 7)
  Future<Either<Failure, BranchesData>> getBranches({
    String? city,
    String sortBy = 'distance',
    int pageNumber = 1,
    int pageSize = 7,
  }) async {
    try {
      final branchesResponse = await _homepageDatabaseSources.getBranches(
        city: city,
        sortBy: sortBy,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      // Extract the data from the API response
      if (branchesResponse.success && branchesResponse.data != null) {
        return Right(branchesResponse.data!);
      } else {
        final errorMessage = branchesResponse.message.isNotEmpty
            ? branchesResponse.message
            : 'Failed to fetch branches';
        ErrorHandler.logError(
          'API returned unsuccessful response',
          StackTrace.current,
          context: 'HomepageRepository.getBranches',
          additionalData: {
            'success': branchesResponse.success,
            'message': branchesResponse.message,
            'errors': branchesResponse.errors,
          },
        );
        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      final failure = ErrorHandler.exceptionToFailure(e as Exception);
      ErrorHandler.logFailure(
        failure,
        context: 'HomepageRepository.getBranches',
        additionalData: {
          'operation': 'getBranches',
          'city': city,
          'sortBy': sortBy,
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return Left(failure);
    }
  }

  Future<Either<Failure, List<GalleryPhoto>>> getGalleryPhotos(
    int restaurantId,
  ) async {
    try {
      final photos = await _homepageDatabaseSources.getGalleryPhotos(
        restaurantId,
      );
      return Right(photos);
    } catch (e) {
      final failure = ErrorHandler.exceptionToFailure(e as Exception);
      ErrorHandler.logFailure(
        failure,
        context: 'BranchInfoRepository.getGalleryPhotos',
        additionalData: {
          'restaurantId': restaurantId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return Left(failure);
    }
  }

  /// Retrieves business hours for a restaurant from the API
  /// Returns Either<Failure, List<BusinessHour>> for proper error handling
  ///
  /// Parameters:
  /// - [restaurantId]: The ID of the restaurant to get business hours for
  Future<Either<Failure, List<BusinessHour>>> getBusinessHours(
    int restaurantId,
  ) async {
    try {
      final businessHours = await _homepageDatabaseSources.getBusinessHours(
        restaurantId,
      );
      return Right(businessHours);
    } catch (e) {
      final failure = ErrorHandler.exceptionToFailure(e as Exception);
      ErrorHandler.logFailure(
        failure,
        context: 'HomepageRepository.getBusinessHours',
        additionalData: {
          'restaurantId': restaurantId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return Left(failure);
    }
  }
}
