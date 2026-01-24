/// Reservation detail response models
import 'package:achaytablereservation/core/errors/exceptions.dart';
import 'package:achaytablereservation/core/shared/model/api_response.dart';
import 'package:achaytablereservation/features/reservation/data/models/business_hour.dart';
import 'package:achaytablereservation/features/reservation/data/models/policy.dart';

/// Restaurant details model for reservation detail response
class ReservationDetailRestaurant {
  final int restaurantId;
  final String branchName;
  final String fullName;
  final String address;
  final String image;
  final String city;
  final double latitude;
  final double longitude;
  final List<BusinessHour> businessHours;
  final List<Policy> policies;

  const ReservationDetailRestaurant({
    required this.restaurantId,
    required this.branchName,
    required this.fullName,
    required this.address,
    required this.image,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.businessHours,
    required this.policies,
  });

  /// Creates a ReservationDetailRestaurant instance from JSON
  factory ReservationDetailRestaurant.fromJson(Map<String, dynamic> json) {
    try {
      // Parse business hours
      final businessHoursJson = json['businessHours'] as List<dynamic>;
      final businessHours = businessHoursJson
          .map((item) => BusinessHour.fromJson(item as Map<String, dynamic>))
          .toList();

      // Parse policies
      final policiesJson = json['policies'] as List<dynamic>;
      final policies = policiesJson
          .map((item) => Policy.fromJson(item as Map<String, dynamic>))
          .toList();

      return ReservationDetailRestaurant(
        restaurantId: json['restaurantId'] as int,
        branchName: json['branchName'] as String,
        fullName: json['fullName'] as String,
        address: json['address'] as String,
        image: json['image'] as String,
        city: json['city'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        businessHours: businessHours,
        policies: policies,
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse ReservationDetailRestaurant from JSON: ${e.toString()}. JSON keys: ${json.keys.toList()}',
      );
    }
  }

  /// Converts the ReservationDetailRestaurant instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'restaurantId': restaurantId,
      'branchName': branchName,
      'fullName': fullName,
      'address': address,
      'image': image,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'businessHours': businessHours.map((bh) => bh.toJson()).toList(),
      'policies': policies.map((p) => p.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReservationDetailRestaurant &&
        other.restaurantId == restaurantId &&
        other.branchName == branchName &&
        other.fullName == fullName &&
        other.address == address &&
        other.image == image &&
        other.city == city &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return Object.hash(
      restaurantId,
      branchName,
      fullName,
      address,
      image,
      city,
      latitude,
      longitude,
    );
  }

  @override
  String toString() {
    return 'ReservationDetailRestaurant(restaurantId: $restaurantId, branchName: $branchName, '
        'fullName: $fullName, city: $city)';
  }
}

/// Reservation detail response model containing full reservation information
class ReservationDetailResponse {
  final int bookingId;
  final String date;
  final String time;
  final int numberOfGuests;
  final String status;
  final double totalPrice;
  final String createdAt;
  final String paymentDeadline;
  final String hallName;
  final ReservationDetailRestaurant restaurant;

  const ReservationDetailResponse({
    required this.bookingId,
    required this.date,
    required this.time,
    required this.numberOfGuests,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.paymentDeadline,
    required this.hallName,
    required this.restaurant,
  });

  /// Creates a ReservationDetailResponse instance from JSON
  factory ReservationDetailResponse.fromJson(Map<String, dynamic> json) {
    try {
      return ReservationDetailResponse(
        bookingId: json['bookingId'] as int,
        date: json['date'] as String,
        time: json['time'] as String,
        numberOfGuests: json['numberOfGuests'] as int,
        status: json['status'] as String,
        totalPrice: (json['totalPrice'] as num).toDouble(),
        createdAt: json['createdAt'] as String,
        paymentDeadline: json['paymentDeadline'] as String,
        hallName: json['hallName'] as String,
        restaurant: ReservationDetailRestaurant.fromJson(
          json['restaurant'] as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse ReservationDetailResponse from JSON: ${e.toString()}. JSON keys: ${json.keys.toList()}',
      );
    }
  }

  /// Converts the ReservationDetailResponse instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'date': date,
      'time': time,
      'numberOfGuests': numberOfGuests,
      'status': status,
      'totalPrice': totalPrice,
      'createdAt': createdAt,
      'paymentDeadline': paymentDeadline,
      'hallName': hallName,
      'restaurant': restaurant.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReservationDetailResponse &&
        other.bookingId == bookingId &&
        other.date == date &&
        other.time == time &&
        other.numberOfGuests == numberOfGuests &&
        other.status == status &&
        other.totalPrice == totalPrice &&
        other.createdAt == createdAt &&
        other.paymentDeadline == paymentDeadline &&
        other.hallName == hallName &&
        other.restaurant == restaurant;
  }

  @override
  int get hashCode {
    return Object.hash(
      bookingId,
      date,
      time,
      numberOfGuests,
      status,
      totalPrice,
      createdAt,
      paymentDeadline,
      hallName,
      restaurant,
    );
  }

  @override
  String toString() {
    return 'ReservationDetailResponse(bookingId: $bookingId, date: $date, time: $time, '
        'numberOfGuests: $numberOfGuests, status: $status, totalPrice: $totalPrice, '
        'paymentDeadline: $paymentDeadline, hallName: $hallName, restaurant: ${restaurant.fullName})';
  }
}

/// Response model for reservation detail API endpoint
typedef ReservationDetailApiResponse = ApiResponse<ReservationDetailResponse>;
