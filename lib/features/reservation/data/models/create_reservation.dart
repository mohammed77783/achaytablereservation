/// Create reservation request and response models
import 'package:achaytablereservation/core/errors/exceptions.dart';
import 'package:achaytablereservation/core/shared/model/api_response.dart';
import 'package:achaytablereservation/features/reservation/data/models/assigned_table.dart';

/// Request model for creating a reservation
class CreateReservationRequest {
  final String restaurantId;
  final String hallId;
  final String date;
  final String time;
  final String numberOfGuests;
  final String numberOfTables;

  const CreateReservationRequest({
    required this.restaurantId,
    required this.hallId,
    required this.date,
    required this.time,
    required this.numberOfGuests,
    required this.numberOfTables,
  });

  /// Converts the CreateReservationRequest instance to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'restaurantId': restaurantId,
      'hallId': hallId,
      'date': date,
      'time': time,
      'numberOfGuests': numberOfGuests,
      'numberOfTables': numberOfTables,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreateReservationRequest &&
        other.restaurantId == restaurantId &&
        other.hallId == hallId &&
        other.date == date &&
        other.time == time &&
        other.numberOfGuests == numberOfGuests &&
        other.numberOfTables == numberOfTables;
  }

  @override
  int get hashCode {
    return Object.hash(
      restaurantId,
      hallId,
      date,
      time,
      numberOfGuests,
      numberOfTables,
    );
  }

  @override
  String toString() {
    return 'CreateReservationRequest(restaurantId: $restaurantId, hallId: $hallId, '
        'date: $date, time: $time, numberOfGuests: $numberOfGuests, numberOfTables: $numberOfTables)';
  }
}

/// Response data model for successful reservation creation
class CreateReservationData {
  final int bookingId;
  final String status;
  final String paymentDeadline;
  final double totalPrice;
  final int paymentWindowMinutes;
  final List<AssignedTable> assignedTables;

  const CreateReservationData({
    required this.bookingId,
    required this.status,
    required this.paymentDeadline,
    required this.totalPrice,
    required this.paymentWindowMinutes,
    required this.assignedTables,
  });

  /// Creates a CreateReservationData instance from JSON
  factory CreateReservationData.fromJson(Map<String, dynamic> json) {
    try {
      // Parse assigned tables
      final tablesJson = json['assignedTables'] as List<dynamic>;
      final assignedTables = tablesJson
          .map((item) => AssignedTable.fromJson(item as Map<String, dynamic>))
          .toList();

      return CreateReservationData(
        bookingId: json['bookingId'] as int,
        status: json['status'] as String,
        paymentDeadline: json['paymentDeadline'] as String,
        totalPrice: (json['totalPrice'] as num).toDouble(),
        paymentWindowMinutes: json['paymentWindowMinutes'] as int,
        assignedTables: assignedTables,
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse CreateReservationData from JSON: ${e.toString()}. JSON keys: ${json.keys.toList()}',
      );
    }
  }

  /// Converts the CreateReservationData instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'status': status,
      'paymentDeadline': paymentDeadline,
      'totalPrice': totalPrice,
      'paymentWindowMinutes': paymentWindowMinutes,
      'assignedTables': assignedTables.map((table) => table.toJson()).toList(),
    };
  }

  /// Helper method to compare two lists of AssignedTable
  bool _listEquals(List<AssignedTable> a, List<AssignedTable> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreateReservationData &&
        other.bookingId == bookingId &&
        other.status == status &&
        other.paymentDeadline == paymentDeadline &&
        other.totalPrice == totalPrice &&
        other.paymentWindowMinutes == paymentWindowMinutes &&
        _listEquals(other.assignedTables, assignedTables);
  }

  @override
  int get hashCode {
    return Object.hash(
      bookingId,
      status,
      paymentDeadline,
      totalPrice,
      paymentWindowMinutes,
      assignedTables,
    );
  }

  @override
  String toString() {
    return 'CreateReservationData(bookingId: $bookingId, status: $status, '
        'paymentDeadline: $paymentDeadline, totalPrice: $totalPrice, '
        'paymentWindowMinutes: $paymentWindowMinutes, assignedTables: ${assignedTables.length} tables)';
  }
}

/// Response model for create reservation API endpoint
typedef CreateReservationApiResponse = ApiResponse<CreateReservationData>;
