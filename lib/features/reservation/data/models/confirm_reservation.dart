/// Confirm reservation request and response models
import 'package:achaytablereservation/core/errors/exceptions.dart';
import 'package:achaytablereservation/core/shared/model/api_response.dart';

/// Request model for confirming a reservation with payment details
class ConfirmReservationRequest {
  final String bookingId;
  final String paymentMethod;
  final String transactionReference;
  final String amountPaid;

  const ConfirmReservationRequest({
    required this.bookingId,
    required this.paymentMethod,
    required this.transactionReference,
    required this.amountPaid,
  });

  /// Converts the ConfirmReservationRequest instance to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'paymentMethod': paymentMethod,
      'transactionReference': transactionReference,
      'amountPaid': amountPaid,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConfirmReservationRequest &&
        other.bookingId == bookingId &&
        other.paymentMethod == paymentMethod &&
        other.transactionReference == transactionReference &&
        other.amountPaid == amountPaid;
  }

  @override
  int get hashCode {
    return Object.hash(
      bookingId,
      paymentMethod,
      transactionReference,
      amountPaid,
    );
  }

  @override
  String toString() {
    return 'ConfirmReservationRequest(bookingId: $bookingId, paymentMethod: $paymentMethod, '
        'transactionReference: $transactionReference, amountPaid: $amountPaid)';
  }
}

/// Detailed booking information returned after confirmation
class ConfirmReservationDetails {
  final int bookingId;
  final String restaurantName;
  final String branchName;
  final String hallName;
  final String date;
  final String time;
  final int numberOfGuests;
  final int numberOfTables;
  final List<String> tableNumbers;
  final double totalPrice;
  final String status;
  final String createdAt;
  final String updatedAt;
  final double latitude;
  final double longitude;

  const ConfirmReservationDetails({
    required this.bookingId,
    required this.restaurantName,
    required this.branchName,
    required this.hallName,
    required this.date,
    required this.time,
    required this.numberOfGuests,
    required this.numberOfTables,
    required this.tableNumbers,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.latitude,
    required this.longitude,
  });

  /// Creates a ConfirmReservationDetails instance from JSON
  factory ConfirmReservationDetails.fromJson(Map<String, dynamic> json) {
    try {
      // Parse table numbers list
      final tableNumbersJson = json['tableNumbers'] as List<dynamic>;
      final tableNumbers = tableNumbersJson
          .map((item) => item.toString())
          .toList();

      return ConfirmReservationDetails(
        bookingId: json['bookingId'] as int,
        restaurantName: json['restaurantName'] as String,
        branchName: json['branchName'] as String,
        hallName: json['hallName'] as String,
        date: json['date'] as String,
        time: json['time'] as String,
        numberOfGuests: json['numberOfGuests'] as int,
        numberOfTables: json['numberOfTables'] as int,
        tableNumbers: tableNumbers,
        totalPrice: (json['totalPrice'] as num).toDouble(),
        status: json['status'] as String,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse ConfirmReservationDetails from JSON: ${e.toString()}. JSON keys: ${json.keys.toList()}',
      );
    }
  }

  /// Converts the ConfirmReservationDetails instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'restaurantName': restaurantName,
      'branchName': branchName,
      'hallName': hallName,
      'date': date,
      'time': time,
      'numberOfGuests': numberOfGuests,
      'numberOfTables': numberOfTables,
      'tableNumbers': tableNumbers,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConfirmReservationDetails &&
        other.bookingId == bookingId &&
        other.restaurantName == restaurantName &&
        other.branchName == branchName &&
        other.hallName == hallName &&
        other.date == date &&
        other.time == time &&
        other.numberOfGuests == numberOfGuests &&
        other.numberOfTables == numberOfTables &&
        other.totalPrice == totalPrice &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return Object.hash(
      bookingId,
      restaurantName,
      branchName,
      hallName,
      date,
      time,
      numberOfGuests,
      numberOfTables,
      totalPrice,
      status,
      createdAt,
      updatedAt,
      latitude,
      longitude,
    );
  }

  @override
  String toString() {
    return 'ConfirmReservationDetails(bookingId: $bookingId, restaurantName: $restaurantName, '
        'branchName: $branchName, hallName: $hallName, date: $date, time: $time, '
        'numberOfGuests: $numberOfGuests, numberOfTables: $numberOfTables, '
        'tableNumbers: $tableNumbers, totalPrice: $totalPrice, status: $status)';
  }
}

/// Response data model for successful reservation confirmation
class ConfirmReservationData {
  final int bookingId;
  final String status;
  final bool smsSent;
  final ConfirmReservationDetails details;

  const ConfirmReservationData({
    required this.bookingId,
    required this.status,
    required this.smsSent,
    required this.details,
  });

  /// Creates a ConfirmReservationData instance from JSON
  factory ConfirmReservationData.fromJson(Map<String, dynamic> json) {
    try {
      return ConfirmReservationData(
        bookingId: json['bookingId'] as int,
        status: json['status'] as String,
        smsSent: json['smsSent'] as bool,
        details: ConfirmReservationDetails.fromJson(
          json['details'] as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse ConfirmReservationData from JSON: ${e.toString()}. JSON keys: ${json.keys.toList()}',
      );
    }
  }

  /// Converts the ConfirmReservationData instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'status': status,
      'smsSent': smsSent,
      'details': details.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConfirmReservationData &&
        other.bookingId == bookingId &&
        other.status == status &&
        other.smsSent == smsSent &&
        other.details == details;
  }

  @override
  int get hashCode {
    return Object.hash(bookingId, status, smsSent, details);
  }

  @override
  String toString() {
    return 'ConfirmReservationData(bookingId: $bookingId, status: $status, '
        'smsSent: $smsSent, details: $details)';
  }
}

/// Response model for confirm reservation API endpoint
typedef ConfirmReservationApiResponse = ApiResponse<ConfirmReservationData>;
