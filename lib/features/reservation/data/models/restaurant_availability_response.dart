/// Restaurant availability response model containing all reservation data
import 'package:achaytablereservation/core/errors/exceptions.dart';
import 'package:achaytablereservation/core/shared/model/api_response.dart';
import 'package:achaytablereservation/features/reservation/data/models/calendar_day.dart';
import 'package:achaytablereservation/features/reservation/data/models/hall.dart';
import 'package:achaytablereservation/features/reservation/data/models/restaurant_info.dart';

class RestaurantAvailabilityResponse {
  final RestaurantInfo restaurant;
  final List<CalendarDay> calendar;
  final String selectedDate;
  final String selectedDateDisplay;
  final String monthName;
  final int year;
  final List<Hall> halls;

  const RestaurantAvailabilityResponse({
    required this.restaurant,
    required this.calendar,
    required this.selectedDate,
    required this.selectedDateDisplay,
    required this.monthName,
    required this.year,
    required this.halls,
  });

  /// Creates a RestaurantAvailabilityResponse instance from JSON
  factory RestaurantAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Parse restaurant info
      final restaurant = RestaurantInfo.fromJson(
        json['restaurant'] as Map<String, dynamic>,
      );

      // Parse calendar days
      final calendarJson = json['calendar'] as List<dynamic>;
      final calendar = calendarJson
          .map((item) => CalendarDay.fromJson(item as Map<String, dynamic>))
          .toList();

      // Parse halls
      final hallsJson = json['halls'] as List<dynamic>;
      final halls = hallsJson
          .map((item) => Hall.fromJson(item as Map<String, dynamic>))
          .toList();

      return RestaurantAvailabilityResponse(
        restaurant: restaurant,
        calendar: calendar,
        selectedDate: json['selectedDate'] as String,
        selectedDateDisplay: json['selectedDateDisplay'] as String,
        monthName: json['monthName'] as String,
        year: json['year'] as int,
        halls: halls,
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse RestaurantAvailabilityResponse from JSON: ${e.toString()}. JSON keys: ${json.keys.toList()}',
      );
    }
  }

  /// Converts the RestaurantAvailabilityResponse instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'restaurant': restaurant.toJson(),
      'calendar': calendar.map((day) => day.toJson()).toList(),
      'selectedDate': selectedDate,
      'selectedDateDisplay': selectedDateDisplay,
      'monthName': monthName,
      'year': year,
      'halls': halls.map((hall) => hall.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RestaurantAvailabilityResponse &&
        other.restaurant == restaurant &&
        _listEquals(other.calendar, calendar) &&
        other.selectedDate == selectedDate &&
        other.selectedDateDisplay == selectedDateDisplay &&
        other.monthName == monthName &&
        other.year == year &&
        _listEquals(other.halls, halls);
  }

  /// Helper method to compare two lists
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      restaurant,
      calendar,
      selectedDate,
      selectedDateDisplay,
      monthName,
      year,
      halls,
    );
  }

  @override
  String toString() {
    return 'RestaurantAvailabilityResponse(restaurant: $restaurant, '
        'calendar: ${calendar.length} days, selectedDate: $selectedDate, '
        'selectedDateDisplay: $selectedDateDisplay, monthName: $monthName, '
        'year: $year, halls: ${halls.length} halls)';
  }
}

/// Response model for restaurant availability API endpoint
typedef RestaurantAvailabilityApiResponse =
    ApiResponse<RestaurantAvailabilityResponse>;
