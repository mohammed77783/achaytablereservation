/// Restaurant information model
import 'package:achaytablereservation/core/errors/exceptions.dart';

class RestaurantInfo {
  final int restaurantId;
  final String branchName;
  final String fullName;
  final String address;
  final String city;
  final String phone;
  final String email;
  final double latitude;
  final double longitude;

  const RestaurantInfo({
    required this.restaurantId,
    required this.branchName,
    required this.fullName,
    required this.address,
    required this.city,
    required this.phone,
    required this.email,
    required this.latitude,
    required this.longitude,
  });

  /// Creates a RestaurantInfo instance from JSON
  factory RestaurantInfo.fromJson(Map<String, dynamic> json) {
    try {
      return RestaurantInfo(
        restaurantId: json['restaurantId'] as int,
        branchName: json['branchName'] as String,
        fullName: json['fullName'] as String,
        address: json['address'] as String,
        city: json['city'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse RestaurantInfo from JSON: ${e.toString()}. JSON: $json',
      );
    }
  }

  /// Converts the RestaurantInfo instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'restaurantId': restaurantId,
      'branchName': branchName,
      'fullName': fullName,
      'address': address,
      'city': city,
      'phone': phone,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RestaurantInfo &&
        other.restaurantId == restaurantId &&
        other.branchName == branchName &&
        other.fullName == fullName &&
        other.address == address &&
        other.city == city &&
        other.phone == phone &&
        other.email == email &&
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
      city,
      phone,
      email,
      latitude,
      longitude,
    );
  }

  @override
  String toString() {
    return 'RestaurantInfo(restaurantId: $restaurantId, branchName: $branchName, '
        'fullName: $fullName, address: $address, city: $city, phone: $phone, '
        'email: $email, latitude: $latitude, longitude: $longitude)';
  }
}
