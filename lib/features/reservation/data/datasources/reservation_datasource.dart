/// Reservation data source for API communication
/// Handles all reservation-related API calls and response parsing
library;

import 'package:achaytablereservation/core/constants/api_constants.dart';
import 'package:achaytablereservation/core/errors/exceptions.dart';
import 'package:achaytablereservation/core/errors/error_handler.dart';
import 'package:achaytablereservation/core/network/api_client.dart';
import 'package:achaytablereservation/core/shared/model/api_response.dart';
import 'package:achaytablereservation/features/reservation/data/models/available_table.dart';
import 'package:achaytablereservation/features/reservation/data/models/reservation_models.dart';

/// Remote data source for reservation operations
/// Handles API communication for restaurant availability and reservation data
class ReservationDataSource {
  final ApiClient _apiClient;

  /// Creates a new instance of ReservationDataSource
  ///
  /// Requires [apiClient] for making HTTP requests to the reservation API
  ReservationDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  /// Parse API response into typed ApiResponse object
  ///
  /// Handles the standard API response format and converts data
  /// using the provided fromJson function
  ///
  /// Throws [ParsingException] for invalid response format or structure
  ApiResponse<T> _parseApiResponse<T>(
    dynamic response,
    T Function(dynamic) fromJsonT,
  ) {
    try {
      if (response == null) {
        ErrorHandler.logError(
          'Null response received from API',
          StackTrace.current,
          context: 'ReservationDataSource - _parseApiResponse',
        );
        throw ParsingException('Response is null');
      }
      if (response is! Map<String, dynamic>) {
        ErrorHandler.logError(
          'Invalid response format received from API',
          StackTrace.current,
          context: 'ReservationDataSource - _parseApiResponse',
          additionalData: {'response_type': response.runtimeType.toString()},
        );
        throw ParsingException('Response is not a valid JSON object');
      }
      // Validate required fields in API response
      if (!response.containsKey('success')) {
        ErrorHandler.logError(
          'API response missing required success field',
          StackTrace.current,
          context: 'ReservationDataSource - _parseApiResponse',
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
        context: 'ReservationDataSource - _parseApiResponse',
        additionalData: {
          'error': e.toString(),
          'response': response?.toString(),
        },
      );
      throw ParsingException('Failed to parse API response: $e');
    }
  }

  /// Handle and convert exceptions to appropriate types
  ///
  /// Maps generic exceptions to specific reservation exceptions
  /// Preserves original exception types when appropriate
  ///
  /// Logs all exceptions with context information for debugging
  Exception _handleException(dynamic error) {
    // Log the exception for debugging with full context
    ErrorHandler.logException(
      error is Exception ? error : Exception(error.toString()),
      stackTrace: StackTrace.current,
      context: 'ReservationDataSource',
      additionalData: {
        'error_type': error.runtimeType.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Preserve original AppException types
    if (error is AppException) {
      return error;
    }

    // Handle parsing-related errors
    if (error is FormatException) {
      return ParsingException('Invalid response format: ${error.message}');
    }

    if (error is TypeError) {
      return ParsingException('Type error in response parsing: $error');
    }

    // Handle network-related errors by examining error message
    final errorString = error.toString().toLowerCase();

    // Timeout errors
    if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return TimeoutException('Request timeout: $error');
    }

    // Network connectivity errors
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return NetworkException('Network error: $error');
    }

    // DNS resolution errors
    if (errorString.contains('host lookup') || errorString.contains('dns')) {
      return NetworkException('DNS resolution failed: $error');
    }

    // HTTP client errors
    if (errorString.contains('http') || errorString.contains('client')) {
      return NetworkException('HTTP client error: $error');
    }

    // For any other unexpected errors, treat as server exception
    return ServerException('Unexpected error occurred: $error');
  }

  /// Fetch restaurant availability data from the API
  ///
  /// Retrieves restaurant information, calendar availability, and time slots
  /// for the specified restaurant. Optionally filters by date.
  ///
  /// [restaurantId] - Required restaurant identifier
  /// [date] - Optional date filter in YYYY-MM-DD format
  ///
  /// Returns [ApiResponse<RestaurantAvailabilityResponse>] containing all availability data
  /// Throws [ValidationException] for invalid parameters
  /// Throws [NetworkException] for network-related errors
  /// Throws [ServerException] for server-side errors
  /// Throws [ParsingException] for response parsing errors
  Future<ApiResponse<RestaurantAvailabilityResponse>>
  getRestaurantAvailability({required int restaurantId, String? date}) async {
    try {
      // Build query parameters map with restaurantId (required)
      final queryParameters = <String, String>{
        'restaurantId': restaurantId.toString(),
      };

      // Add date parameter conditionally when provided and non-empty
      if (date != null && date.isNotEmpty) {
        queryParameters['date'] = date;
      }

      // Make GET request to /Restaurant endpoint with query parameters
      final response = await _apiClient.get(
        ApiConstants.Restaurant,
        queryParameters: queryParameters,
      );

      // Parse response using _parseApiResponse helper method
      return _parseApiResponse<RestaurantAvailabilityResponse>(
        response,
        (data) => RestaurantAvailabilityResponse.fromJson(
          data as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Check table availability for a specific hall, date, and time slot
  ///
  /// Verifies if tables are available for reservation at the specified
  /// hall, date, time and number of guests.
  ///
  /// [hallId] - Required hall identifier within the restaurant
  /// [date] - Required date in YYYY-MM-DD format
  /// [time] - Required time slot (e.g., "20:00")
  /// [numberOfGuests] - Required number of guests
  ///
  /// Returns [ApiResponse<CheckTableAvailabilityResponse>] containing availability details
  /// Throws [ValidationException] for invalid parameters
  /// Throws [NetworkException] for network-related errors
  /// Throws [ServerException] for server-side errors
  /// Throws [ParsingException] for response parsing errors
  Future<ApiResponse<CheckTableAvailabilityResponse>> checkTableAvailability({
    required int hallId,
    required String date,
    required String time,
  }) async {
    try {
      // Validate required parameters
      if (date.isEmpty) {
        throw ValidationException('Date is required');
      }

      if (time.isEmpty) {
        throw ValidationException('Time is required');
      }

      // if (numberOfGuests <= 0) {
      //   throw ValidationException('Number of guests must be greater than 0');
      // }

      // Build request body
      final requestBody = {
        'hallId': hallId.toString(),
        'date': date,
        'time': time,
        // 'numberOfGuests': numberOfGuests.toString(),
      };

      // Make POST request to /Reservation/create endpoint
      final response = await _apiClient.post(
        ApiConstants.checkTableAvailability,
        body: requestBody,
      );

      // Parse response using _parseApiResponse helper method
      return _parseApiResponse<CheckTableAvailabilityResponse>(
        response,
        (data) => CheckTableAvailabilityResponse.fromJson(
          data as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Fetch restaurant policies from the API
  ///
  /// Retrieves the list of policies for a specific restaurant.
  ///
  /// [restaurantId] - Required restaurant identifier
  ///
  /// Returns [ApiResponse<List<Policy>>] containing the list of policies
  /// Throws [NetworkException] for network-related errors
  /// Throws [ServerException] for server-side errors
  /// Throws [ParsingException] for response parsing errors
  Future<ApiResponse<List<Policy>>> getPolicies({
    required int restaurantId,
  }) async {
    try {
      // Build query parameters map with restaurantId
      final queryParameters = <String, String>{
        'restaurantId': restaurantId.toString(),
      };

      // Make GET request to /Restaurant/policies endpoint
      final response = await _apiClient.get(
        ApiConstants.policies,
        queryParameters: queryParameters,
      );

      // Parse response using _parseApiResponse helper method
      return _parseApiResponse<List<Policy>>(
        response,
        (data) => (data as List<dynamic>)
            .map((item) => Policy.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Create a new reservation
  ///
  /// Creates a reservation with the specified details and returns booking information
  /// including assigned tables and payment deadline.
  ///
  /// [request] - Required CreateReservationRequest containing:
  ///   - restaurantId: Restaurant identifier
  ///   - hallId: Hall identifier within the restaurant
  ///   - date: Reservation date in YYYY-MM-DD format
  ///   - time: Reservation time (e.g., "22:00")
  ///   - numberOfGuests: Number of guests
  ///   - numberOfTables: Number of tables requested
  ///
  /// Returns [ApiResponse<CreateReservationData>] containing booking details
  /// Throws [ValidationException] for invalid parameters
  /// Throws [NetworkException] for network-related errors
  /// Throws [ServerException] for server-side errors (including no tables available)
  /// Throws [ParsingException] for response parsing errors

  /// Create a new reservation
  ///
  /// Sends a POST request to the create reservation endpoint with the given request data.
  /// Returns an ApiResponse containing CreateReservationData on success.
  Future<ApiResponse<CreateReservationData>> createReservation(
    CreateReservationRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.createReservation,
        body: request.toJson(),
      );
      return _parseApiResponse<CreateReservationData>(
        response,
        (data) => CreateReservationData.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Confirm a reservation with payment details
  ///
  /// Sends a POST request to confirm a reservation after payment.
  /// Returns an ApiResponse containing ConfirmReservationData on success.
  ///
  /// [request] - Required ConfirmReservationRequest containing:
  ///   - bookingId: The booking identifier to confirm
  ///   - paymentMethod: Payment method used (e.g., "moyasser")
  ///   - transactionReference: Transaction reference from payment provider
  ///   - amountPaid: Amount paid for the reservation
  ///
  /// Returns [ApiResponse<ConfirmReservationData>] containing confirmation details
  /// Throws [ValidationException] for invalid parameters
  /// Throws [NetworkException] for network-related errors
  /// Throws [ServerException] for server-side errors (e.g., already confirmed)
  /// Throws [ParsingException] for response parsing errors
  Future<ApiResponse<ConfirmReservationData>> confirmReservation(
    ConfirmReservationRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.confirmReservation,
        body: request.toJson(),
      );
      return _parseApiResponse<ConfirmReservationData>(
        response,
        (data) => ConfirmReservationData.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Fetch user's reservations list
  ///
  /// Retrieves all reservations for the authenticated user.
  ///
  /// Returns [ApiResponse<List<MyReservationItem>>] containing the list of user's reservations
  /// Throws [NetworkException] for network-related errors
  /// Throws [ServerException] for server-side errors
  /// Throws [ParsingException] for response parsing errors
  Future<ApiResponse<List<MyReservationItem>>> getMyReservations() async {
    try {
      final response = await _apiClient.get(ApiConstants.myReservations);

      return _parseApiResponse<List<MyReservationItem>>(
        response,
        (data) => (data as List<dynamic>)
            .map(
              (item) =>
                  MyReservationItem.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Fetch reservation details by booking ID
  ///
  /// Retrieves detailed information for a specific reservation.
  ///
  /// [bookingId] - Required booking identifier
  ///
  /// Returns [ApiResponse<ReservationDetailResponse>] containing reservation details
  /// Throws [NetworkException] for network-related errors
  /// Throws [ServerException] for server-side errors
  /// Throws [ParsingException] for response parsing errors
  Future<ApiResponse<ReservationDetailResponse>> getReservationDetail({
    required int bookingId,
  }) async {
    try {
      // Build the endpoint with bookingId path parameter
      final endpoint = '${ApiConstants.reservationDetail}/$bookingId';

      final response = await _apiClient.get(endpoint);

      return _parseApiResponse<ReservationDetailResponse>(
        response,
        (data) =>
            ReservationDetailResponse.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      throw _handleException(e);
    }
  }
}
