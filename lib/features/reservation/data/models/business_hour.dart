/// Business hour model for reservation detail
import 'package:achaytablereservation/core/errors/exceptions.dart';

class BusinessHour {
  final int dayOfWeek;
  final String dayName;
  final String openTime;
  final String closeTime;

  const BusinessHour({
    required this.dayOfWeek,
    required this.dayName,
    required this.openTime,
    required this.closeTime,
  });

  /// Creates a BusinessHour instance from JSON
  factory BusinessHour.fromJson(Map<String, dynamic> json) {
    try {
      return BusinessHour(
        dayOfWeek: json['dayOfWeek'] as int,
        dayName: json['dayName'] as String,
        openTime: json['openTime'] as String,
        closeTime: json['closeTime'] as String,
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse BusinessHour from JSON: ${e.toString()}. JSON: $json',
      );
    }
  }

  /// Converts the BusinessHour instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'dayName': dayName,
      'openTime': openTime,
      'closeTime': closeTime,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusinessHour &&
        other.dayOfWeek == dayOfWeek &&
        other.dayName == dayName &&
        other.openTime == openTime &&
        other.closeTime == closeTime;
  }

  @override
  int get hashCode {
    return Object.hash(dayOfWeek, dayName, openTime, closeTime);
  }

  @override
  String toString() {
    return 'BusinessHour(dayOfWeek: $dayOfWeek, dayName: $dayName, '
        'openTime: $openTime, closeTime: $closeTime)';
  }
}
