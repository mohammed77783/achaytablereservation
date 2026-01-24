import 'dart:convert';
import 'package:achaytablereservation/core/constants/storage_constants.dart';
import 'package:achaytablereservation/core/services/storage_service.dart';
import 'package:achaytablereservation/core/shared/model/api_response.dart';
import 'package:achaytablereservation/core/shared/model/user_model.dart';
import 'package:achaytablereservation/core/errors/exceptions.dart';
import 'package:achaytablereservation/core/errors/error_handler.dart';
import 'package:achaytablereservation/core/network/api_client.dart';
import 'package:achaytablereservation/core/constants/api_constants.dart';
import 'package:achaytablereservation/features/homepage/data/model/branch_models.dart';
import 'package:achaytablereservation/features/authentication/data/models/auth_response_models.dart';
import 'package:achaytablereservation/features/homepage/data/model/gallery_photo_model.dart';
import 'package:achaytablereservation/features/homepage/data/model/business_hour_model.dart';
import 'package:get/get.dart';

class HomepageDataSources {
  final StorageService _storageService = Get.find<StorageService>();
  final ApiClient _apiClient;

  HomepageDataSources({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get user data from local storage
  Future<UserModel?> getUserData() async {
    try {
      final response = await _apiClient.get(ApiConstants.profile);
      final user = ApiResponse<UserModel>.fromJson(
        response as Map<String, dynamic>,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );
      return user.data;
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

  /// Fetch branches data from the API
  ///
  /// Retrieves paginated list of restaurant branches with optional sorting and filtering
  ///
  /// Parameters:
  /// - [city]: Optional city filter (e.g., 'بريدة', 'الرياض')
  /// - [sortBy]: Sort criteria (e.g., 'distance', 'name', 'rating')
  /// - [pageNumber]: Page number for pagination (default: 1)
  /// - [pageSize]: Number of items per page (default: 7)
  ///
  /// Returns [BranchesResponse] containing paginated branch data
  ///
  /// Throws [ValidationException] for invalid parameters
  /// Throws [ServerException] for server errors
  /// Throws [NetworkException] for network issues
  Future<BranchesResponse> getBranches({
    String? city,
    String sortBy = 'distance',
    int pageNumber = 1,
    int pageSize = 7,
  }) async {
    try {
      final queryParameters = <String, String>{
        'SortBy': sortBy,
        'PageNumber': pageNumber.toString(),
        'PageSize': pageSize.toString(),
      };

      // Add city parameter if provided
      if (city != null && city.isNotEmpty) {
        queryParameters['City'] = city;
      }

      final response = await _apiClient.get(
        ApiConstants.homeIndex,
        queryParameters: queryParameters,
      );

      return _parseApiResponse<BranchesData>(
        response,
        (data) => BranchesData.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Parse API response into typed ApiResponse object
  ///
  /// Handles the standard API response format and converts data
  /// using the provided fromJson function
  ApiResponse<T> _parseApiResponse<T>(
    dynamic response,
    T Function(dynamic) fromJsonT,
  ) {
    try {
      if (response == null) {
        ErrorHandler.logError(
          'Null response received from API',
          StackTrace.current,
          context: 'HomepageDataSources - _parseApiResponse',
        );
        throw ParsingException('Response is null');
      }
      if (response is! Map<String, dynamic>) {
        ErrorHandler.logError(
          'Invalid response format received from API',
          StackTrace.current,
          context: 'HomepageDataSources - _parseApiResponse',
          additionalData: {'response_type': response.runtimeType.toString()},
        );
        throw ParsingException('Response is not a valid JSON object');
      }

      // Validate required fields in API response
      if (!response.containsKey('success')) {
        ErrorHandler.logError(
          'API response missing required success field',
          StackTrace.current,
          context: 'HomepageDataSources - _parseApiResponse',
          additionalData: {'response': response},
        );
        throw ParsingException('Response missing required success field');
      }

      return ApiResponse<T>.fromJson(response, fromJsonT);
    } catch (e) {
      if (e is ParsingException) rethrow;

      ErrorHandler.logError(
        'Failed to parse API response',
        StackTrace.current,
        context: 'HomepageDataSources - _parseApiResponse',
        additionalData: {
          'error': e.toString(),
          'response': response?.toString(),
        },
      );

      throw ParsingException('Failed to parse API response: $e');
    }
  }

  Future<List<GalleryPhoto>> getGalleryPhotos(int restaurantId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.branchGellery.replaceAll(
          "{restaurantId}",
          restaurantId.toString(),
        ),
      );

      return _parseGalleryResponse(response);
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Parse gallery API response
  List<GalleryPhoto> _parseGalleryResponse(dynamic response) {
    try {
      if (response == null) {
        ErrorHandler.logError(
          'Null response received from Gallery API',
          StackTrace.current,
          context: 'BranchInfoDataSource - _parseGalleryResponse',
        );
        throw ParsingException('Response is null');
      }

      if (response is! Map<String, dynamic>) {
        throw ParsingException('Response is not a valid JSON object');
      }

      // Check success field
      final success = response['success'] as bool? ?? false;
      if (!success) {
        final message = response['message'] as String? ?? 'Unknown error';
        throw ServerException(message);
      }

      // Parse data array
      final dataList = response['data'] as List<dynamic>?;
      if (dataList == null) {
        return []; // Return empty list if no data
      }
      final photos = <GalleryPhoto>[];
      for (int i = 0; i < dataList.length; i++) {
        try {
          final photo = GalleryPhoto.fromJson(
            dataList[i] as Map<String, dynamic>,
          );
          photos.add(photo);
        } catch (e) {
          // Log individual photo parsing error but continue
          ErrorHandler.logError(
            'Failed to parse gallery photo at index $i',
            StackTrace.current,
            context: 'BranchInfoDataSource',
            additionalData: {'error': e.toString()},
          );
        }
      }

      return photos;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ParsingException('Failed to parse gallery response: $e');
    }
  }

  /// Fetch business hours for a restaurant
  ///
  /// Parameters:
  /// - [restaurantId]: The ID of the restaurant to get business hours for
  ///
  /// Returns [List<BusinessHour>] containing the business hours for each day
  ///
  /// Throws [ServerException] for server errors
  /// Throws [NetworkException] for network issues
  Future<List<BusinessHour>> getBusinessHours(int restaurantId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.businessHours,
        queryParameters: {'restaurantId': restaurantId.toString()},
      );

      return _parseBusinessHoursResponse(response);
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Parse business hours API response
  List<BusinessHour> _parseBusinessHoursResponse(dynamic response) {
    try {
      if (response == null) {
        ErrorHandler.logError(
          'Null response received from Business Hours API',
          StackTrace.current,
          context: 'HomepageDataSources - _parseBusinessHoursResponse',
        );
        throw ParsingException('Response is null');
      }

      if (response is! Map<String, dynamic>) {
        throw ParsingException('Response is not a valid JSON object');
      }

      // Check success field
      final success = response['success'] as bool? ?? false;
      if (!success) {
        final message = response['message'] as String? ?? 'Unknown error';
        throw ServerException(message);
      }

      // Parse data array
      final dataList = response['data'] as List<dynamic>?;
      if (dataList == null) {
        return []; // Return empty list if no data
      }

      final businessHours = <BusinessHour>[];
      for (int i = 0; i < dataList.length; i++) {
        try {
          final businessHour = BusinessHour.fromJson(
            dataList[i] as Map<String, dynamic>,
          );
          businessHours.add(businessHour);
        } catch (e) {
          // Log individual business hour parsing error but continue
          ErrorHandler.logError(
            'Failed to parse business hour at index $i',
            StackTrace.current,
            context: 'HomepageDataSources',
            additionalData: {'error': e.toString()},
          );
        }
      }

      return businessHours;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ParsingException('Failed to parse business hours response: $e');
    }
  }

  /// Handle and convert exceptions to appropriate types
  ///
  /// Maps generic exceptions to specific homepage exceptions
  /// Preserves original exception types when appropriate
  Exception _handleException(dynamic error) {
    // Log the exception for debugging
    ErrorHandler.logException(
      error is Exception ? error : Exception(error.toString()),
      context: 'HomepageDataSources',
    );

    if (error is AppException) {
      return error;
    }

    if (error is FormatException) {
      return ParsingException('Invalid response format: ${error.message}');
    }

    if (error is TypeError) {
      return ParsingException('Type error in response parsing: $error');
    }

    // Handle network-related errors
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return TimeoutException('Request timeout: $error');
    }

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return NetworkException('Network error: $error');
    }

    if (errorString.contains('host lookup') || errorString.contains('dns')) {
      return NetworkException('DNS resolution failed: $error');
    }

    // For any other unexpected errors
    return ServerException('Unexpected error occurred: $error');
  }
}
