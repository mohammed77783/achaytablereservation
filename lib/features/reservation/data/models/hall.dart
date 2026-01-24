/// Hall model representing a dining hall with available time slots
import 'package:achaytablereservation/core/errors/exceptions.dart';
import 'package:achaytablereservation/features/reservation/data/models/time_slot.dart';

class Hall {
  final int hallId;
  final String hallName;
  final List<TimeSlot> timeSlots;

  const Hall({
    required this.hallId,
    required this.hallName,
    required this.timeSlots,
  });

  /// Creates a Hall instance from JSON
  factory Hall.fromJson(Map<String, dynamic> json) {
    try {
      // Parse time slots
      final timeSlotsJson = json['timeSlots'] as List<dynamic>;
      final timeSlots = timeSlotsJson
          .map((item) => TimeSlot.fromJson(item as Map<String, dynamic>))
          .toList();

      return Hall(
        hallId: json['hallId'] as int,
        hallName: json['hallName'] as String,
        timeSlots: timeSlots,
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse Hall from JSON: ${e.toString()}. JSON: $json',
      );
    }
  }

  /// Converts the Hall instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'hallId': hallId,
      'hallName': hallName,
      'timeSlots': timeSlots.map((slot) => slot.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Hall &&
        other.hallId == hallId &&
        other.hallName == hallName &&
        _listEquals(other.timeSlots, timeSlots);
  }

  /// Helper method to compare two lists of TimeSlots
  bool _listEquals(List<TimeSlot> a, List<TimeSlot> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(hallId, hallName, timeSlots);
  }

  @override
  String toString() {
    return 'Hall(hallId: $hallId, hallName: $hallName, '
        'timeSlots: ${timeSlots.length} slots)';
  }
}
