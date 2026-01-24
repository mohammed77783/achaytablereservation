import 'dart:math';

/// Utility class for distance calculations
class DistanceUtils {
  /// Calculates the distance between two geographic coordinates using the Haversine formula
  /// 
  /// [lat1] - Latitude of the first point in degrees
  /// [lon1] - Longitude of the first point in degrees
  /// [lat2] - Latitude of the second point in degrees
  /// [lon2] - Longitude of the second point in degrees
  /// 
  /// Returns the distance in kilometers
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    // Convert degrees to radians
    double lat1Rad = lat1 * pi / 180;
    double lat2Rad = lat2 * pi / 180;
    double deltaLat = (lat2 - lat1) * pi / 180;
    double deltaLon = (lon2 - lon1) * pi / 180;
    
    // Haversine formula
    double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
               cos(lat1Rad) * cos(lat2Rad) *
               sin(deltaLon / 2) * sin(deltaLon / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    double distance = earthRadius * c; // Distance in kilometers
    
    return distance;
  }
  
  /// Formats distance for display
  /// 
  /// [distanceKm] - Distance in kilometers
  /// [isArabic] - Whether to use Arabic formatting
  /// 
  /// Returns formatted distance string (e.g., "1.5 km" or "500 m")
  static String formatDistance(double distanceKm, {bool isArabic = false}) {
    if (distanceKm < 1) {
      // Show in meters if less than 1 km
      int meters = (distanceKm * 1000).round();
      return isArabic ? '$meters م' : '$meters m';
    } else {
      // Show in kilometers
      return isArabic 
          ? '${distanceKm.toStringAsFixed(1)} كم' 
          : '${distanceKm.toStringAsFixed(1)} km';
    }
  }
}