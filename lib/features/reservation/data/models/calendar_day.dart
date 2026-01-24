/// Calendar day model representing a single day in the availability calendar
import 'package:achaytablereservation/core/errors/exceptions.dart';

class CalendarDay {
  final String date;
  final int day;
  final String dayName;
  final bool hasAvailability;
  final bool isSelected;
  final bool isToday;

  const CalendarDay({
    required this.date,
    required this.day,
    required this.dayName,
    required this.hasAvailability,
    required this.isSelected,
    required this.isToday,
  });

  /// Creates a CalendarDay instance from JSON
  factory CalendarDay.fromJson(Map<String, dynamic> json) {
    try {
      return CalendarDay(
        date: json['date'] as String,
        day: json['day'] as int,
        dayName: json['dayName'] as String,
        hasAvailability: json['hasAvailability'] as bool,
        isSelected: json['isSelected'] as bool,
        isToday: json['isToday'] as bool,
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse CalendarDay from JSON: ${e.toString()}. JSON: $json',
      );
    }
  }

  /// Converts the CalendarDay instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': day,
      'dayName': dayName,
      'hasAvailability': hasAvailability,
      'isSelected': isSelected,
      'isToday': isToday,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarDay &&
        other.date == date &&
        other.day == day &&
        other.dayName == dayName &&
        other.hasAvailability == hasAvailability &&
        other.isSelected == isSelected &&
        other.isToday == isToday;
  }

  @override
  int get hashCode {
    return Object.hash(
      date,
      day,
      dayName,
      hasAvailability,
      isSelected,
      isToday,
    );
  }

  @override
  String toString() {
    return 'CalendarDay(date: $date, day: $day, dayName: $dayName, '
        'hasAvailability: $hasAvailability, isSelected: $isSelected, isToday: $isToday)';
  }
}
