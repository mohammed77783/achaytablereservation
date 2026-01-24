# Distance Calculation Feature

This document explains how the distance calculation feature works in the homepage.

## Overview

The app now calculates distances between the user's location and restaurant branches when the server doesn't provide this information. This ensures that users always see distance information, improving the user experience.

## Implementation

### 1. Distance Calculator Utility (`lib/core/utils/distance_calculator.dart`)

A utility class that implements the Haversine formula to calculate distances between geographical coordinates:

```dart
// Calculate distance between two points
double distance = DistanceCalculator.calculateDistance(
  userLat, userLng, branchLat, branchLng
);

// Get formatted distance string
String formatted = DistanceCalculator.calculateDistanceFormatted(
  userLat, userLng, branchLat, branchLng
); // Returns "5.2 km"
```

### 2. Location Service (`lib/core/services/location_service.dart`)

Manages user location using the `geolocator` package:

- Gets current GPS location
- Handles location permissions
- Stores user location for distance calculations
- Provides reactive location updates

### 3. Homepage Controller Integration

The `HomeController` now:

1. **Calculates Missing Distances**: When loading branches, if a branch doesn't have `distanceKm` from the server, it calculates the distance using the user's current location.

2. **Location Updates**: When the user selects a new location (city), it updates the location service and recalculates distances.

3. **GPS Location**: Provides a method to get the current GPS location and update branches accordingly.

### 4. Location Selector Enhancement

The location selector now uses the homepage controller's location methods instead of handling GPS directly, ensuring consistent location management.

## How It Works

### Flow Diagram

```
User opens homepage
       ↓
Load branches from API
       ↓
Check if branches have distanceKm
       ↓
If missing → Calculate using user location
       ↓
Display branches with distances
```

### Distance Calculation Process

1. **User Location**: Get from LocationService (GPS or manually selected city)
2. **Branch Location**: From branch.location (latitude, longitude)
3. **Calculation**: Use Haversine formula to calculate distance in kilometers
4. **Display**: Show in branch card as "X.X km"

## Usage Examples

### Getting Current Location

```dart
final homeController = Get.find<HomeController>();
await homeController.getCurrentLocationAndUpdateBranches();
```

### Manual Location Update

```dart
homeController.updateLocation('الرياض', 24.7136, 46.6753);
```

### Calculate Distance Manually

```dart
final distance = DistanceCalculator.calculateDistance(
  24.7136, 46.6753, // Riyadh
  21.5433, 39.1728, // Jeddah
); // Returns ~870 km
```

## Benefits

1. **Consistent UX**: Users always see distance information
2. **Fallback Mechanism**: Works even when server doesn't provide distances
3. **Accurate Calculations**: Uses precise Haversine formula
4. **Performance**: Calculations are done client-side, no additional API calls
5. **Location Flexibility**: Works with both GPS and manually selected locations

## Technical Details

### Haversine Formula

The distance calculation uses the Haversine formula, which is accurate for calculating distances on a sphere (Earth):

```
a = sin²(Δφ/2) + cos φ1 ⋅ cos φ2 ⋅ sin²(Δλ/2)
c = 2 ⋅ atan2( √a, √(1−a) )
d = R ⋅ c
```

Where:

- φ is latitude
- λ is longitude
- R is Earth's radius (6,371 km)
- d is the distance

### Error Handling

- **No Location**: If user location is unavailable, branches are shown without calculated distances
- **Permission Denied**: Graceful fallback to manual location selection
- **GPS Timeout**: 15-second timeout with error handling
- **Invalid Coordinates**: Validation ensures coordinates are within valid ranges

## Testing

Run the distance calculation tests:

```bash
flutter test test/core/utils/distance_calculator_test.dart
```

The tests verify:

- Correct distance calculations between known cities
- Zero distance for same coordinates
- Proper formatting of distance strings
- Custom precision handling
