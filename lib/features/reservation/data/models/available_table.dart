import 'package:achaytablereservation/core/errors/exceptions.dart';
import 'package:achaytablereservation/core/shared/model/api_response.dart';

/// Table model representing an available table
class AvailableTable {
  final int tableId;
  final String tableNumber;
  final int capacity;
  final String shape;
  final double? positionX;
  final double? positionY;

  const AvailableTable({
    required this.tableId,
    required this.tableNumber,
    required this.capacity,
    required this.shape,
    this.positionX,
    this.positionY,
  });

  /// Creates an AvailableTable instance from JSON
  factory AvailableTable.fromJson(Map<String, dynamic> json) {
    try {
      return AvailableTable(
        tableId: json['tableId'] as int,
        tableNumber: json['tableNumber'] as String,
        capacity: json['capacity'] as int,
        shape: json['shape'] as String,
        positionX: (json['positionX'] as num?)?.toDouble(),
        positionY: (json['positionY'] as num?)?.toDouble(),
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse AvailableTable from JSON: ${e.toString()}. JSON: $json',
      );
    }
  }

  /// Converts the AvailableTable instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'tableNumber': tableNumber,
      'capacity': capacity,
      'shape': shape,
      if (positionX != null) 'positionX': positionX,
      if (positionY != null) 'positionY': positionY,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AvailableTable &&
        other.tableId == tableId &&
        other.tableNumber == tableNumber &&
        other.capacity == capacity &&
        other.shape == shape &&
        other.positionX == positionX &&
        other.positionY == positionY;
  }

  @override
  int get hashCode {
    return Object.hash(
      tableId,
      tableNumber,
      capacity,
      shape,
      positionX,
      positionY,
    );
  }

  @override
  String toString() {
    return 'AvailableTable(tableId: $tableId, tableNumber: $tableNumber, '
        'capacity: $capacity, shape: $shape, positionX: $positionX, positionY: $positionY)';
  }
}

/// Check table availability response model
class CheckTableAvailabilityResponse {
  final List<AvailableTable> availableTables;
  final int totalCapacity;
  final int availableTablesCount;
  final String hallName;

  const CheckTableAvailabilityResponse({
    required this.availableTables,
    required this.totalCapacity,
    required this.availableTablesCount,
    required this.hallName,
  });

  /// Creates a CheckTableAvailabilityResponse instance from JSON
  factory CheckTableAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Parse available tables
      final tablesJson = json['availableTables'] as List<dynamic>;
      final availableTables = tablesJson
          .map((item) => AvailableTable.fromJson(item as Map<String, dynamic>))
          .toList();

      return CheckTableAvailabilityResponse(
        availableTables: availableTables,
        totalCapacity: json['totalCapacity'] as int? ?? 0,
        availableTablesCount: json['availableTablesCount'] as int? ?? 0,
        hallName:
            json['hallname'] as String? ??
            'Unknown Hall', // Note: API uses 'hallname' not 'hallName'
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse CheckTableAvailabilityResponse from JSON: ${e.toString()}. JSON keys: ${json.keys.toList()}',
      );
    }
  }

  /// Converts the CheckTableAvailabilityResponse instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'availableTables': availableTables
          .map((table) => table.toJson())
          .toList(),
      'totalCapacity': totalCapacity,
      'availableTablesCount': availableTablesCount,
      'hallname': hallName,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CheckTableAvailabilityResponse &&
        other.totalCapacity == totalCapacity &&
        other.availableTablesCount == availableTablesCount &&
        other.hallName == hallName &&
        _listEquals(other.availableTables, availableTables);
  }

  /// Helper method to compare two lists
  bool _listEquals(List<AvailableTable> a, List<AvailableTable> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      availableTables,
      totalCapacity,
      availableTablesCount,
      hallName,
    );
  }

  @override
  String toString() {
    return 'CheckTableAvailabilityResponse(availableTablesCount: $availableTablesCount, '
        'totalCapacity: $totalCapacity, hallName: $hallName, '
        'availableTables: ${availableTables.length} tables)';
  }
}

/// Response model for check availability API endpoint
typedef CheckTableAvailabilityApiResponse =
    ApiResponse<CheckTableAvailabilityResponse>;
