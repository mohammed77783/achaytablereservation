/// My reservations list model
import 'package:achaytablereservation/core/errors/exceptions.dart';
import 'package:achaytablereservation/core/shared/model/api_response.dart';

/// Model representing a single reservation item in the my-reservations list
class MyReservationItem {
  final int bookingId;
  final String date;
  final String time;
  final int numberOfGuests;
  final String status;
  final String restaurantName;
  final String restaurantAddress;
  final String restaurantImage;
  final String paymentDeadline;

  const MyReservationItem({
    required this.bookingId,
    required this.date,
    required this.time,
    required this.numberOfGuests,
    required this.status,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.restaurantImage,
    required this.paymentDeadline,
  });

  /// Creates a MyReservationItem instance from JSON
  factory MyReservationItem.fromJson(Map<String, dynamic> json) {
    try {
      return MyReservationItem(
        bookingId: json['bookingId'] as int,
        date: json['date'] as String,
        time: json['time'] as String,
        numberOfGuests: json['numberOfGuests'] as int,
        status: json['status'] as String,
        restaurantName: json['restaurantName'] as String,
        restaurantAddress: json['restaurantAddress'] as String,
        restaurantImage: json['restaurantImage'] as String,
        paymentDeadline: json['paymentDeadline'] as String,
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse MyReservationItem from JSON: ${e.toString()}. JSON: $json',
      );
    }
  }

  /// Converts the MyReservationItem instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'date': date,
      'time': time,
      'numberOfGuests': numberOfGuests,
      'status': status,
      'restaurantName': restaurantName,
      'restaurantAddress': restaurantAddress,
      'restaurantImage': restaurantImage,
      'paymentDeadline': paymentDeadline,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MyReservationItem &&
        other.bookingId == bookingId &&
        other.date == date &&
        other.time == time &&
        other.numberOfGuests == numberOfGuests &&
        other.status == status &&
        other.restaurantName == restaurantName &&
        other.restaurantAddress == restaurantAddress &&
        other.restaurantImage == restaurantImage &&
        other.paymentDeadline == paymentDeadline;
  }

  @override
  int get hashCode {
    return Object.hash(
      bookingId,
      date,
      time,
      numberOfGuests,
      status,
      restaurantName,
      restaurantAddress,
      restaurantImage,
      paymentDeadline,
    );
  }

  @override
  String toString() {
    return 'MyReservationItem(bookingId: $bookingId, date: $date, time: $time, '
        'numberOfGuests: $numberOfGuests, status: $status, restaurantName: $restaurantName, '
        'paymentDeadline: $paymentDeadline)';
  }
}

/// Response model for my-reservations API endpoint
typedef MyReservationsApiResponse = ApiResponse<List<MyReservationItem>>;
