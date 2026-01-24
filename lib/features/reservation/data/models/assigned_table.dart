/// Assigned table model representing a table assigned to a reservation
import 'package:achaytablereservation/core/errors/exceptions.dart';

class AssignedTable {
  final int tableId;
  final String tableNumber;
  final int capacity;

  const AssignedTable({
    required this.tableId,
    required this.tableNumber,
    required this.capacity,
  });

  /// Creates an AssignedTable instance from JSON
  factory AssignedTable.fromJson(Map<String, dynamic> json) {
    try {
      return AssignedTable(
        tableId: json['tableId'] as int,
        tableNumber: json['tableNumber'] as String,
        capacity: json['capacity'] as int,
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse AssignedTable from JSON: ${e.toString()}. JSON: $json',
      );
    }
  }

  /// Converts the AssignedTable instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'tableNumber': tableNumber,
      'capacity': capacity,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssignedTable &&
        other.tableId == tableId &&
        other.tableNumber == tableNumber &&
        other.capacity == capacity;
  }

  @override
  int get hashCode {
    return Object.hash(tableId, tableNumber, capacity);
  }

  @override
  String toString() {
    return 'AssignedTable(tableId: $tableId, tableNumber: $tableNumber, capacity: $capacity)';
  }
}
