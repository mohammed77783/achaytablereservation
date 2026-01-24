/// Time slot model representing available reservation times
import 'package:achaytablereservation/core/errors/exceptions.dart';

class TimeSlot {
  final String time;
  final String displayText;
  final double price;
  final int availableTables;
  final bool isAvailable;
  TimeSlot({
    required this.time,
    required this.displayText,
    required this.price,
    required this.availableTables,
    required this.isAvailable,
  });

  /// Creates a TimeSlot instance from JSON
  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    try {
      return TimeSlot(
        time: json['time'] as String,
        displayText: json['displayText'] as String,
        price: (json['price'] as num).toDouble(),
        availableTables: json['availableTables'] as int,
        isAvailable: json['isAvailable'] as bool,
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse TimeSlot from JSON: ${e.toString()}. JSON: $json',
      );
    }
  }

  /// Converts the TimeSlot instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'displayText': displayText,
      'price': price,
      'availableTables': availableTables,
      'isAvailable': isAvailable,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeSlot &&
        other.time == time &&
        other.displayText == displayText &&
        other.price == price &&
        other.availableTables == availableTables &&
        other.isAvailable == isAvailable;
  }

  @override
  int get hashCode {
    return Object.hash(time, displayText, price, availableTables, isAvailable);
  }

  @override
  String toString() {
    return 'TimeSlot(time: $time, displayText: $displayText, price: $price, '
        'availableTables: $availableTables, isAvailable: $isAvailable)';
  }
}
