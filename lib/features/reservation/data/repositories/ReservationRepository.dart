import 'package:achaytablereservation/core/errors/error_handler.dart';
import 'package:achaytablereservation/core/errors/failures.dart';
import 'package:achaytablereservation/features/reservation/data/datasources/reservation_datasource.dart';
import 'package:achaytablereservation/features/reservation/data/models/available_table.dart';
import 'package:achaytablereservation/features/reservation/data/models/reservation_models.dart'
    show
        RestaurantAvailabilityResponse,
        Policy,
        CreateReservationRequest,
        CreateReservationData,
        ConfirmReservationRequest,
        ConfirmReservationData,
        MyReservationItem,
        ReservationDetailResponse;
import 'package:dartz/dartz.dart';

/// Repository for reservation-related operations
/// Handles business logic and error conversion for reservation data
class ReservationRepository {
  final ReservationDataSource _reservationDataSource;

  ReservationRepository({required ReservationDataSource reservationDataSource})
    : _reservationDataSource = reservationDataSource;

  /// Retrieves restaurant availability data from the API
  /// Returns Either<Failure, RestaurantAvailabilityResponse> for proper error handling
  /// Parameters:
  /// - [restaurantId]: Required restaurant identifier
  /// - [date]: Optional date filter in YYYY-MM-DD format
  /// Returns:
  /// - Right(RestaurantAvailabilityResponse): On successful data retrieval
  /// - Left(Failure): On error (NetworkFailure, ServerFailure, ParsingFailure, etc.)
  Future<Either<Failure, RestaurantAvailabilityResponse>>
  getRestaurantAvailability({required int restaurantId, String? date}) async {
    try {
      final response = await _reservationDataSource.getRestaurantAvailability(
        restaurantId: restaurantId,
        date: date,
      );
      // Validate API response success status
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        // Handle unsuccessful API response
        final errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to fetch restaurant availability';
        ErrorHandler.logError(
          'API returned unsuccessful response',
          StackTrace.current,
          context: 'ReservationRepository.getRestaurantAvailability',
          additionalData: {
            'success': response.success,
            'message': response.message,
            'errors': response.errors,
            'restaurantId': restaurantId,
            'date': date,
          },
        );
        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      // Convert exception to appropriate Failure type
      final failure = ErrorHandler.exceptionToFailure(e as Exception);
      ErrorHandler.logFailure(
        failure,
        context: 'ReservationRepository.getRestaurantAvailability',
        additionalData: {
          'operation': 'getRestaurantAvailability',
          'restaurantId': restaurantId,
          'date': date,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return Left(failure);
    }
  }

  /// Checks table availability for a specific hall, date, time, and number of guests
  ///
  /// Verifies if tables are available for reservation at the specified
  /// hall, date, time and number of guests.
  ///
  /// Returns Either<Failure, CheckTableAvailabilityResponse> for proper error handling
  ///
  /// Parameters:
  /// - [hallId]: Required hall identifier within the restaurant
  /// - [date]: Required date in YYYY-MM-DD format
  /// - [time]: Required time slot (e.g., "20:00")
  /// - [numberOfGuests]: Required number of guests
  ///
  /// Returns:
  /// - Right(CheckTableAvailabilityResponse): On successful availability check
  /// - Left(Failure): On error (ValidationFailure, NetworkFailure, ServerFailure, ParsingFailure, etc.)
  Future<Either<Failure, CheckTableAvailabilityResponse>>
  checkTableAvailability({
    required int hallId,
    required String date,
    required String time,
  }) async {
    try {
      // Validate input parameters
      if (date.isEmpty) {
        ErrorHandler.logError(
          'Date parameter is empty',
          StackTrace.current,
          context: 'ReservationRepository.checkTableAvailability',
          additionalData: {
            'hallId': hallId,
            'time': time,
            // 'numberOfGuests': numberOfGuests,
          },
        );
        return const Left(ValidationFailure('Date is required'));
      }

      if (time.isEmpty) {
        ErrorHandler.logError(
          'Time parameter is empty',
          StackTrace.current,
          context: 'ReservationRepository.checkTableAvailability',
          additionalData: {
            'hallId': hallId,
            'date': date,
            // 'numberOfGuests': numberOfGuests,
          },
        );
        return const Left(ValidationFailure('Time is required'));
      }

      // if (numberOfGuests <= 0) {
      //   ErrorHandler.logError(
      //     'Number of guests parameter is invalid',
      //     StackTrace.current,
      //     context: 'ReservationRepository.checkTableAvailability',
      //     additionalData: {
      //       'hallId': hallId,
      //       'date': date,
      //       'time': time,
      //       'numberOfGuests': numberOfGuests,
      //     },
      //   );
      //   return const Left(
      //     ValidationFailure('Number of guests must be greater than 0'),
      //   );
      // }

      // Call data source to check availability
      final response = await _reservationDataSource.checkTableAvailability(
        hallId: hallId,
        date: date,
        time: time,
        // numberOfGuests: numberOfGuests,
      );

      // Validate API response success status
      if (response.success && response.data != null) {
        // Log successful operation for monitoring
        ErrorHandler.logInfo(
          'Table availability check successful',
          context: 'ReservationRepository.checkTableAvailability',
          additionalData: {
            'hallId': hallId,
            'date': date,
            'time': time,
            // 'numberOfGuests': numberOfGuests,
            'availableTablesCount': response.data!.availableTablesCount,
            'totalCapacity': response.data!.totalCapacity,
            'hallName': response.data!.hallName,
          },
        );
        return Right(response.data!);
      } else {
        // Handle unsuccessful API response
        final errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to check table availability';

        ErrorHandler.logError(
          'API returned unsuccessful response for table availability check',
          StackTrace.current,
          context: 'ReservationRepository.checkTableAvailability',
          additionalData: {
            'success': response.success,
            'message': response.message,
            'errors': response.errors,
            'hallId': hallId,
            'date': date,
            'time': time,
            // 'numberOfGuests': numberOfGuests,
          },
        );
        // Check if it's a not found error based on message
        if (response.message.contains('غير موجودة') ||
            response.message.contains('غير متاح')) {
          return Left(UnknownFailure(errorMessage));
        }
        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      // Convert exception to appropriate Failure type
      final failure = ErrorHandler.exceptionToFailure(e as Exception);
      ErrorHandler.logFailure(
        failure,
        context: 'ReservationRepository.checkTableAvailability',
        additionalData: {
          'operation': 'checkTableAvailability',
          'hallId': hallId,
          'date': date,
          'time': time,
          // 'numberOfGuests': numberOfGuests,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return Left(failure);
    }
  }

  /// Retrieves restaurant policies from the API
  ///
  /// Returns Either<Failure, List<Policy>> for proper error handling
  ///
  /// Parameters:
  /// - [restaurantId]: Required restaurant identifier
  ///
  /// Returns:
  /// - Right(List<Policy>): On successful data retrieval
  /// - Left(Failure): On error (NetworkFailure, ServerFailure, ParsingFailure, etc.)
  Future<Either<Failure, List<Policy>>> getPolicies({
    required int restaurantId,
  }) async {
    try {
      final response = await _reservationDataSource.getPolicies(
        restaurantId: restaurantId,
      );

      // Validate API response success status
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        // Handle unsuccessful API response
        final errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to fetch restaurant policies';
        ErrorHandler.logError(
          'API returned unsuccessful response',
          StackTrace.current,
          context: 'ReservationRepository.getPolicies',
          additionalData: {
            'success': response.success,
            'message': response.message,
            'errors': response.errors,
            'restaurantId': restaurantId,
          },
        );
        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      // Convert exception to appropriate Failure type
      final failure = ErrorHandler.exceptionToFailure(e as Exception);
      ErrorHandler.logFailure(
        failure,
        context: 'ReservationRepository.getPolicies',
        additionalData: {
          'operation': 'getPolicies',
          'restaurantId': restaurantId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return Left(failure);
    }
  }

  /// Creates a new reservation
  ///
  /// Creates a reservation with the specified details and returns booking information
  /// including assigned tables and payment deadline.
  ///
  /// Returns Either<Failure, CreateReservationData> for proper error handling
  ///
  /// Parameters:
  /// - [request]: Required CreateReservationRequest containing all reservation details
  ///
  /// Returns:
  /// - Right(CreateReservationData): On successful reservation creation with booking details
  /// - Left(Failure): On error (ValidationFailure, NetworkFailure, ServerFailure, etc.)
  ///   - ServerFailure with message "Not enough tables available..." when tables unavailable

  /// Creates a new reservation
  Future<Either<Failure, CreateReservationData>> createReservation(
    CreateReservationRequest request,
  ) async {
    try {
      final response = await _reservationDataSource.createReservation(request);
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        final errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to create reservation';
        ErrorHandler.logError(
          'API returned unsuccessful response for reservation creation',
          StackTrace.current,
          context: 'ReservationRepository.createReservation',
          additionalData: {
            'success': response.success,
            'message': response.message,
            'errors': response.errors,
            'request': request.toJson(),
          },
        );

        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      final failure = ErrorHandler.exceptionToFailure(e as Exception);
      ErrorHandler.logFailure(
        failure,
        context: 'ReservationRepository.createReservation',
        additionalData: {
          'operation': 'createReservation',
          'request': request.toJson(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return Left(failure);
    }
  }

  /// Confirms a reservation with payment details
  /// Confirms a reservation after successful payment processing.
  ///
  /// Returns Either<Failure, ConfirmReservationData> for proper error handling
  ///
  /// Parameters:
  /// - [request]: Required ConfirmReservationRequest containing payment details:
  ///   - bookingId: The booking identifier to confirm
  ///   - paymentMethod: Payment method used (e.g., "moyasser")
  ///   - transactionReference: Transaction reference from payment provider
  ///   - amountPaid: Amount paid for the reservation
  ///
  /// Returns:
  /// - Right(ConfirmReservationData): On successful confirmation with booking details
  /// - Left(Failure): On error:
  ///   - ServerFailure with message like "Cannot confirm booking. Current status: Confirmed"
  ///     when booking is already confirmed
  ///   - ValidationFailure when request data is invalid
  ///   - NetworkFailure for network-related errors
  Future<Either<Failure, ConfirmReservationData>> confirmReservation(
    ConfirmReservationRequest request,
  ) async {
    try {
      final response = await _reservationDataSource.confirmReservation(request);

      if (response.success && response.data != null) {
        // Log successful confirmation for monitoring
        ErrorHandler.logInfo(
          'Reservation confirmed successfully',
          context: 'ReservationRepository.confirmReservation',
          additionalData: {
            'bookingId': response.data!.bookingId,
            'status': response.data!.status,
            'smsSent': response.data!.smsSent,
          },
        );
        return Right(response.data!);
      } else {
        // Handle unsuccessful API response
        final errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to confirm reservation';

        ErrorHandler.logError(
          'API returned unsuccessful response for reservation confirmation',
          StackTrace.current,
          context: 'ReservationRepository.confirmReservation',
          additionalData: {
            'success': response.success,
            'message': response.message,
            'errors': response.errors,
            'request': request.toJson(),
          },
        );

        // Check for validation errors
        if (response.errors != null && response.errors!.isNotEmpty) {
          return Left(ValidationFailure(response.errors!.join(', ')));
        }

        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      final failure = ErrorHandler.exceptionToFailure(e as Exception);
      ErrorHandler.logFailure(
        failure,
        context: 'ReservationRepository.confirmReservation',
        additionalData: {
          'operation': 'confirmReservation',
          'request': request.toJson(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return Left(failure);
    }
  }

  /// Retrieves user's reservations list
  ///
  /// Returns Either<Failure, List<MyReservationItem>> for proper error handling
  ///
  /// Returns:
  /// - Right(List<MyReservationItem>): On successful data retrieval
  /// - Left(Failure): On error (NetworkFailure, ServerFailure, ParsingFailure, etc.)
  Future<Either<Failure, List<MyReservationItem>>> getMyReservations() async {
    try {
      final response = await _reservationDataSource.getMyReservations();

      if (response.success && response.data != null) {
        // Log successful operation for monitoring
        ErrorHandler.logInfo(
          'My reservations fetched successfully',
          context: 'ReservationRepository.getMyReservations',
          additionalData: {'reservationsCount': response.data!.length},
        );
        return Right(response.data!);
      } else {
        // Handle unsuccessful API response
        final errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to fetch reservations';

        ErrorHandler.logError(
          'API returned unsuccessful response for my reservations',
          StackTrace.current,
          context: 'ReservationRepository.getMyReservations',
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
        context: 'ReservationRepository.getMyReservations',
        additionalData: {
          'operation': 'getMyReservations',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return Left(failure);
    }
  }

  /// Retrieves reservation details by booking ID
  ///
  /// Returns Either<Failure, ReservationDetailResponse> for proper error handling
  ///
  /// Parameters:
  /// - [bookingId]: Required booking identifier
  ///
  /// Returns:
  /// - Right(ReservationDetailResponse): On successful data retrieval
  /// - Left(Failure): On error (NetworkFailure, ServerFailure, ParsingFailure, etc.)
  Future<Either<Failure, ReservationDetailResponse>> getReservationDetail({
    required int bookingId,
  }) async {
    try {
      final response = await _reservationDataSource.getReservationDetail(
        bookingId: bookingId,
      );

      if (response.success && response.data != null) {
        // Log successful operation for monitoring
        ErrorHandler.logInfo(
          'Reservation detail fetched successfully',
          context: 'ReservationRepository.getReservationDetail',
          additionalData: {
            'bookingId': bookingId,
            'status': response.data!.status,
            'restaurantName': response.data!.restaurant.fullName,
          },
        );
        return Right(response.data!);
      } else {
        // Handle unsuccessful API response
        final errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to fetch reservation details';

        ErrorHandler.logError(
          'API returned unsuccessful response for reservation detail',
          StackTrace.current,
          context: 'ReservationRepository.getReservationDetail',
          additionalData: {
            'success': response.success,
            'message': response.message,
            'errors': response.errors,
            'bookingId': bookingId,
          },
        );

        // Check if it's a not found error
        if (response.message.contains('not found') ||
            response.message.contains('غير موجود')) {
          return Left(UnknownFailure(errorMessage));
        }

        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      final failure = ErrorHandler.exceptionToFailure(e as Exception);
      ErrorHandler.logFailure(
        failure,
        context: 'ReservationRepository.getReservationDetail',
        additionalData: {
          'operation': 'getReservationDetail',
          'bookingId': bookingId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return Left(failure);
    }
  }
}
