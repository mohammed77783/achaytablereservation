/// Data models for branch-related API responses
library;

import 'package:flutter/foundation.dart';
import 'package:achaytablereservation/core/shared/model/api_response.dart';
import 'package:achaytablereservation/core/errors/exceptions.dart';

/// Exception thrown when business hours validation fails
class BusinessHoursValidationException extends ValidationException {
  final String field;
  final dynamic originalValue;

  BusinessHoursValidationException(
    String message,
    this.field,
    this.originalValue,
  ) : super(
        'Business hours validation failed for field "$field": $message. Original value: $originalValue',
      );
}

/// Exception thrown when time format validation fails
class TimeFormatException extends ValidationException {
  final String timeValue;

  TimeFormatException(String message, this.timeValue)
    : super(
        'Time format validation failed: $message. Time value: "$timeValue"',
      );
}

/// Exception thrown when branch validation fails
class BranchValidationException extends ValidationException {
  final String field;
  final dynamic originalValue;

  BranchValidationException(String message, this.field, this.originalValue)
    : super(
        'Branch validation failed for field "$field": $message. Original value: $originalValue',
      );
}

/// Exception thrown when location validation fails
class LocationValidationException extends ValidationException {
  final String field;
  final double value;

  LocationValidationException(String message, this.field, this.value)
    : super(
        'Location validation failed for field "$field": $message. Value: $value',
      );
}

/// Comprehensive validator for Branch and related models
class BranchValidator {
  /// Validates location coordinates
  /// [latitude] must be between -90 and 90 degrees
  /// [longitude] must be between -180 and 180 degrees
  static void validateLocation(double latitude, double longitude) {
    // Validate latitude range
    if (latitude < -90.0 || latitude > 90.0) {
      throw LocationValidationException(
        'Latitude must be between -90 and 90 degrees',
        'latitude',
        latitude,
      );
    }

    // Validate longitude range
    if (longitude < -180.0 || longitude > 180.0) {
      throw LocationValidationException(
        'Longitude must be between -180 and 180 degrees',
        'longitude',
        longitude,
      );
    }
  }

  /// Validates a list of business hours
  /// Ensures all business hours have valid day of week and time formats
  static void validateBusinessHours(List<BusinessHours> hours) {
    if (hours.isEmpty) {
      throw BusinessHoursValidationException(
        'Business hours list cannot be empty',
        'businessHours',
        hours,
      );
    }

    // Validate each business hours entry
    for (int i = 0; i < hours.length; i++) {
      final businessHours = hours[i];

      // Validate day of week
      if (!businessHours.isValidDayOfWeek) {
        throw BusinessHoursValidationException(
          'Invalid day of week at index $i. Must be between 0 and 6 (Sunday=0)',
          'businessHours[$i].dayOfWeek',
          businessHours.dayOfWeek,
        );
      }

      // Validate time format
      if (!businessHours.isValidTimeFormat) {
        throw BusinessHoursValidationException(
          'Invalid time format at index $i. Expected HH:mm format (24-hour)',
          'businessHours[$i]',
          '${businessHours.openTime} - ${businessHours.closeTime}',
        );
      }
    }

    // Check for duplicate days
    final dayOfWeekSet = <int>{};
    for (int i = 0; i < hours.length; i++) {
      final dayOfWeek = hours[i].dayOfWeek;
      if (dayOfWeekSet.contains(dayOfWeek)) {
        throw BusinessHoursValidationException(
          'Duplicate day of week found at index $i',
          'businessHours[$i].dayOfWeek',
          dayOfWeek,
        );
      }
      dayOfWeekSet.add(dayOfWeek);
    }
  }

  /// Validates time format (HH:mm in 24-hour format)
  static void validateTimeFormat(String time) {
    if (time.isEmpty) {
      throw TimeFormatException('Time cannot be empty', time);
    }

    // Check format: HH:mm
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(time)) {
      throw TimeFormatException(
        'Invalid time format. Expected HH:mm format (24-hour)',
        time,
      );
    }

    // Additional validation: parse to ensure it's a valid time
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (hour < 0 || hour > 23) {
        throw TimeFormatException('Hour must be between 0 and 23', time);
      }

      if (minute < 0 || minute > 59) {
        throw TimeFormatException('Minute must be between 0 and 59', time);
      }
    } catch (e) {
      throw TimeFormatException('Failed to parse time components', time);
    }
  }

  /// Validates day of week value
  /// [day] must be between 0 and 6 (Sunday=0)
  static void validateDayOfWeek(int day) {
    if (day < 0 || day > 6) {
      throw BusinessHoursValidationException(
        'Day of week must be between 0 and 6 (Sunday=0)',
        'dayOfWeek',
        day,
      );
    }
  }

  /// Validates required fields for Branch model
  static void validateBranchRequiredFields(Map<String, dynamic> json) {
    final requiredFields = [
      'id',
      'branchName',
      'fullName',
      'address',
      'phone',
      'isActive',
      'averageRating',
      'totalReviews',
      'location',
      'isOpenNow',
    ];

    for (final field in requiredFields) {
      if (!json.containsKey(field) || json[field] == null) {
        throw BranchValidationException(
          'Required field is missing or null',
          field,
          json[field],
        );
      }
    }

    // Validate location sub-fields
    final location = json['location'];
    if (location is! Map<String, dynamic>) {
      throw BranchValidationException(
        'Location must be a valid object',
        'location',
        location,
      );
    }

    if (!location.containsKey('latitude') || location['latitude'] == null) {
      throw BranchValidationException(
        'Location latitude is required',
        'location.latitude',
        location['latitude'],
      );
    }

    if (!location.containsKey('longitude') || location['longitude'] == null) {
      throw BranchValidationException(
        'Location longitude is required',
        'location.longitude',
        location['longitude'],
      );
    }
  }

  /// Validates optional fields for Branch model
  /// Ensures optional fields have correct types when present
  static void validateBranchOptionalFields(Map<String, dynamic> json) {
    // Validate city (optional string)
    if (json.containsKey('city') && json['city'] != null) {
      if (json['city'] is! String) {
        throw BranchValidationException(
          'City must be a string when provided',
          'city',
          json['city'],
        );
      }
    }

    // Validate primaryImage (optional string)
    if (json.containsKey('primaryImage') && json['primaryImage'] != null) {
      if (json['primaryImage'] is! String) {
        throw BranchValidationException(
          'Primary image must be a string when provided',
          'primaryImage',
          json['primaryImage'],
        );
      }
    }

    // Validate distanceKm (optional number)
    if (json.containsKey('distanceKm') && json['distanceKm'] != null) {
      if (json['distanceKm'] is! num) {
        throw BranchValidationException(
          'Distance must be a number when provided',
          'distanceKm',
          json['distanceKm'],
        );
      }
    }

    // Validate businessHours (optional array)
    if (json.containsKey('businessHours') && json['businessHours'] != null) {
      if (json['businessHours'] is! List) {
        throw BranchValidationException(
          'Business hours must be an array when provided',
          'businessHours',
          json['businessHours'],
        );
      }
    }
  }

  /// Validates data integrity before creating Branch objects
  /// Performs comprehensive validation of all fields and their relationships
  static void validateBranchDataIntegrity(Map<String, dynamic> json) {
    // Validate required fields
    validateBranchRequiredFields(json);

    // Validate optional fields
    validateBranchOptionalFields(json);

    // Validate location coordinates
    final location = json['location'] as Map<String, dynamic>;
    final latitude = (location['latitude'] as num).toDouble();
    final longitude = (location['longitude'] as num).toDouble();
    validateLocation(latitude, longitude);

    // Validate business hours if present
    if (json['businessHours'] != null) {
      final businessHoursList = json['businessHours'] as List<dynamic>;
      if (businessHoursList.isNotEmpty) {
        final businessHours = businessHoursList
            .map((item) => BusinessHours.fromJson(item as Map<String, dynamic>))
            .toList();
        validateBusinessHours(businessHours);
      }
    }

    // Validate numeric ranges
    final averageRating = (json['averageRating'] as num).toDouble();
    if (averageRating < 0.0 || averageRating > 5.0) {
      throw BranchValidationException(
        'Average rating must be between 0.0 and 5.0',
        'averageRating',
        averageRating,
      );
    }

    final totalReviews = json['totalReviews'] as int;
    if (totalReviews < 0) {
      throw BranchValidationException(
        'Total reviews must be non-negative',
        'totalReviews',
        totalReviews,
      );
    }

    // Validate distance if present
    if (json['distanceKm'] != null) {
      final distance = (json['distanceKm'] as num).toDouble();
      if (distance < 0.0) {
        throw BranchValidationException(
          'Distance must be non-negative',
          'distanceKm',
          distance,
        );
      }
    }
  }
}

/// Business hours model representing daily operating hours for a branch
class BusinessHours {
  final int dayOfWeek;
  final String dayName;
  final String openTime;
  final String closeTime;
  const BusinessHours({
    required this.dayOfWeek,
    required this.dayName,
    required this.openTime,
    required this.closeTime,
  });

  /// Creates a BusinessHours instance from JSON with comprehensive validation
  factory BusinessHours.fromJson(Map<String, dynamic> json) {
    try {
      // Validate and extract dayOfWeek
      final dayOfWeekValue = json['dayOfWeek'];
      if (dayOfWeekValue == null) {
        throw BusinessHoursValidationException(
          'dayOfWeek is required',
          'dayOfWeek',
          dayOfWeekValue,
        );
      }

      int dayOfWeek;
      if (dayOfWeekValue is int) {
        dayOfWeek = dayOfWeekValue;
      } else if (dayOfWeekValue is num) {
        dayOfWeek = dayOfWeekValue.toInt();
      } else {
        throw BusinessHoursValidationException(
          'dayOfWeek must be a number',
          'dayOfWeek',
          dayOfWeekValue,
        );
      }

      // Validate dayOfWeek range
      if (dayOfWeek < 0 || dayOfWeek > 6) {
        throw BusinessHoursValidationException(
          'dayOfWeek must be between 0 and 6 (Sunday=0)',
          'dayOfWeek',
          dayOfWeek,
        );
      }

      // Validate and extract dayName
      final dayName = json['dayName'];
      if (dayName == null || dayName is! String || dayName.isEmpty) {
        throw BusinessHoursValidationException(
          'dayName is required and must be a non-empty string',
          'dayName',
          dayName,
        );
      }

      // Validate and extract openTime
      final openTime = json['openTime'];
      if (openTime == null || openTime is! String) {
        throw BusinessHoursValidationException(
          'openTime is required and must be a string',
          'openTime',
          openTime,
        );
      }

      // Validate and extract closeTime
      final closeTime = json['closeTime'];
      if (closeTime == null || closeTime is! String) {
        throw BusinessHoursValidationException(
          'closeTime is required and must be a string',
          'closeTime',
          closeTime,
        );
      }

      // Create instance and validate time formats
      final businessHours = BusinessHours(
        dayOfWeek: dayOfWeek,
        dayName: dayName,
        openTime: openTime,
        closeTime: closeTime,
      );

      // Validate time formats
      if (!businessHours.isValidTimeFormat) {
        throw TimeFormatException(
          'Invalid time format. Expected HH:mm format (24-hour)',
          'openTime: ${businessHours.openTime}, closeTime: ${businessHours.closeTime}',
        );
      }

      return businessHours;
    } catch (e) {
      if (e is BusinessHoursValidationException || e is TimeFormatException) {
        rethrow;
      }
      throw ParsingException(
        'Failed to parse BusinessHours from JSON: ${e.toString()}. JSON: $json',
      );
    }
  }

  /// Converts the BusinessHours instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'dayName': dayName,
      'openTime': openTime,
      'closeTime': closeTime,
    };
  }

  /// Validates if the time format is correct (HH:mm in 24-hour format)
  bool get isValidTimeFormat {
    return _isValidTimeString(openTime) && _isValidTimeString(closeTime);
  }

  /// Validates if the day of week is in valid range (0-6)
  bool get isValidDayOfWeek {
    return dayOfWeek >= 0 && dayOfWeek <= 6;
  }

  /// Helper method to validate time string format
  bool _isValidTimeString(String time) {
    if (time.isEmpty) return false;

    // Check format: HH:mm
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(time)) return false;

    // Additional validation: parse to ensure it's a valid time
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
    } catch (e) {
      return false;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusinessHours &&
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
    return 'BusinessHours(dayOfWeek: $dayOfWeek, dayName: $dayName, '
        'openTime: $openTime, closeTime: $closeTime)';
  }
}

/// Location coordinates for a branch
class BranchLocation {
  final double latitude;
  final double longitude;

  const BranchLocation({required this.latitude, required this.longitude});

  factory BranchLocation.fromJson(Map<String, dynamic> json) {
    final latitude = (json['latitude'] as num).toDouble();
    final longitude = (json['longitude'] as num).toDouble();

    // Validate location coordinates
    BranchValidator.validateLocation(latitude, longitude);

    return BranchLocation(latitude: latitude, longitude: longitude);
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BranchLocation &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() {
    return 'BranchLocation(latitude: $latitude, longitude: $longitude)';
  }
}

/// Branch model representing a restaurant branch
class Branch {
  final int id;
  final String branchName;
  final String fullName;
  final String address;
  final String? city;
  final String phone;
  final bool isActive;
  final String? primaryImage;
  final double averageRating;
  final int totalReviews;
  final double? distanceKm;
  final BranchLocation location;
  final bool isOpenNow;
  final List<BusinessHours>? businessHours;

  const Branch({
    required this.id,
    required this.branchName,
    required this.fullName,
    required this.address,
    this.city,
    required this.phone,
    required this.isActive,
    this.primaryImage,
    required this.averageRating,
    required this.totalReviews,
    this.distanceKm,
    required this.location,
    required this.isOpenNow,
    this.businessHours,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    try {
      // Validate data integrity before parsing
      BranchValidator.validateBranchDataIntegrity(json);

      // Parse business hours if present
      List<BusinessHours>? businessHours;
      if (json['businessHours'] != null) {
        try {
          final businessHoursList = json['businessHours'] as List<dynamic>;
          businessHours = businessHoursList
              .map(
                (item) => BusinessHours.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } catch (e) {
          // Log error but continue parsing without business hours
          // This maintains backward compatibility and graceful degradation
          businessHours = null;
        }
      }

      return Branch(
        id: json['id'] as int,
        branchName: json['branchName'] as String,
        fullName: json['fullName'] as String,
        address: json['address'] as String,
        city: json['city'] as String?,
        phone: json['phone'] as String,
        isActive: json['isActive'] as bool,
        primaryImage: json['primaryImage'] as String?,
        averageRating: (json['averageRating'] as num).toDouble(),
        totalReviews: json['totalReviews'] as int,
        distanceKm: json['distanceKm'] != null
            ? (json['distanceKm'] as num).toDouble()
            : null,
        location: BranchLocation.fromJson(
          json['location'] as Map<String, dynamic>,
        ),
        isOpenNow: json['isOpenNow'] as bool,
        businessHours: businessHours,
      );
    } catch (e) {
      if (e is BranchValidationException ||
          e is BusinessHoursValidationException ||
          e is LocationValidationException ||
          e is TimeFormatException) {
        rethrow;
      }
      throw ParsingException(
        'Failed to parse Branch from JSON: ${e.toString()}. JSON keys: ${json.keys.toList()}',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchName': branchName,
      'fullName': fullName,
      'address': address,
      'city': city,
      'phone': phone,
      'isActive': isActive,
      'primaryImage': primaryImage,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'distanceKm': distanceKm,
      'location': location.toJson(),
      'isOpenNow': isOpenNow,
      'businessHours': businessHours?.map((bh) => bh.toJson()).toList(),
    };
  }

  /// Returns the business hours for a specific day of the week
  /// [dayOfWeek] should be 0-6 where Sunday=0
  /// Returns null if no business hours are available for the specified day
  BusinessHours? getBusinessHoursForDay(int dayOfWeek) {
    if (businessHours == null) return null;

    try {
      return businessHours!.firstWhere((bh) => bh.dayOfWeek == dayOfWeek);
    } catch (e) {
      // No business hours found for this day
      return null;
    }
  }

  /// Returns true if this branch has business hours data available
  bool get hasBusinessHours {
    return businessHours != null && businessHours!.isNotEmpty;
  }

  /// Returns true if the branch is open on the specified day of the week
  /// [dayOfWeek] should be 0-6 where Sunday=0
  /// Returns false if no business hours are available for the specified day
  bool isOpenOnDay(int dayOfWeek) {
    final hoursForDay = getBusinessHoursForDay(dayOfWeek);
    return hoursForDay != null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Branch &&
        other.id == id &&
        other.branchName == branchName &&
        other.fullName == fullName &&
        other.address == address &&
        other.city == city &&
        other.phone == phone &&
        other.isActive == isActive &&
        other.primaryImage == primaryImage &&
        other.averageRating == averageRating &&
        other.totalReviews == totalReviews &&
        other.distanceKm == distanceKm &&
        other.location == location &&
        other.isOpenNow == isOpenNow &&
        _listEquals(other.businessHours, businessHours);
  }

  /// Helper method to compare two lists of BusinessHours
  bool _listEquals(List<BusinessHours>? a, List<BusinessHours>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      branchName,
      fullName,
      address,
      city,
      phone,
      isActive,
      primaryImage,
      averageRating,
      totalReviews,
      distanceKm,
      location,
      isOpenNow,
      businessHours,
    );
  }

  @override
  String toString() {
    return 'Branch(id: $id, branchName: $branchName, fullName: $fullName, '
        'address: $address, city: $city, phone: $phone, isActive: $isActive, '
        'primaryImage: $primaryImage, averageRating: $averageRating, '
        'totalReviews: $totalReviews, distanceKm: $distanceKm, '
        'location: $location, isOpenNow: $isOpenNow, '
        'businessHours: ${businessHours?.length ?? 0} hours)';
  }
}

/// Paginated data container for branches
class BranchesData {
  final List<Branch> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const BranchesData({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory BranchesData.fromJson(Map<String, dynamic> json) {
    try {
      final items = <Branch>[];
      final itemsList = json['items'] as List<dynamic>;

      // Parse each branch with individual error handling
      for (int i = 0; i < itemsList.length; i++) {
        try {
          final branch = Branch.fromJson(itemsList[i] as Map<String, dynamic>);
          items.add(branch);
        } catch (e) {
          print('Warning: Failed to parse branch at index $i: $e');
          print('Branch data: ${itemsList[i]}');
          // Continue parsing other branches instead of failing completely
        }
      }

      return BranchesData(
        items: items,
        totalCount: json['totalCount'] as int,
        pageNumber: json['pageNumber'] as int,
        pageSize: json['pageSize'] as int,
        totalPages: json['totalPages'] as int,
        hasPreviousPage: json['hasPreviousPage'] as bool,
        hasNextPage: json['hasNextPage'] as bool,
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse BranchesData from JSON: ${e.toString()}. JSON keys: ${json.keys.toList()}',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((branch) => branch.toJson()).toList(),
      'totalCount': totalCount,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'totalPages': totalPages,
      'hasPreviousPage': hasPreviousPage,
      'hasNextPage': hasNextPage,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BranchesData &&
        other.items.length == items.length &&
        other.items.every((branch) => items.contains(branch)) &&
        other.totalCount == totalCount &&
        other.pageNumber == pageNumber &&
        other.pageSize == pageSize &&
        other.totalPages == totalPages &&
        other.hasPreviousPage == hasPreviousPage &&
        other.hasNextPage == hasNextPage;
  }

  @override
  int get hashCode {
    return Object.hash(
      items,
      totalCount,
      pageNumber,
      pageSize,
      totalPages,
      hasPreviousPage,
      hasNextPage,
    );
  }

  @override
  String toString() {
    return 'BranchesData(items: ${items.length} branches, totalCount: $totalCount, '
        'pageNumber: $pageNumber, pageSize: $pageSize, totalPages: $totalPages, '
        'hasPreviousPage: $hasPreviousPage, hasNextPage: $hasNextPage)';
  }
}

/// Response model for branches API endpoint
typedef BranchesResponse = ApiResponse<BranchesData>;
