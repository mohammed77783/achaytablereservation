import 'package:achaytablereservation/core/errors/exceptions.dart';

/// Model representing a business hour entry from the server
class BusinessHour {
  final int id;
  final int dayOfWeek;
  final String dayName;
  final String openTime;
  final String closeTime;

  const BusinessHour({
    required this.id,
    required this.dayOfWeek,
    required this.dayName,
    required this.openTime,
    required this.closeTime,
  });

  factory BusinessHour.fromJson(Map<String, dynamic> json) {
    try {
      return BusinessHour(
        id: json['id'] as int,
        dayOfWeek: json['dayOfWeek'] as int,
        dayName: json['dayName'] as String,
        openTime: json['openTime'] as String,
        closeTime: json['closeTime'] as String,
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse BusinessHour from JSON: ${e.toString()}',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dayOfWeek': dayOfWeek,
      'dayName': dayName,
      'openTime': openTime,
      'closeTime': closeTime,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusinessHour && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BusinessHour(id: $id, dayName: $dayName, openTime: $openTime, closeTime: $closeTime)';
  }
}
