import 'package:flutter/material.dart';

/// Simplified responsive utility class
class ResponsiveUtils {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  
  /// Get current device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }
  
  /// Get responsive value based on device type
  static T value<T>(
  BuildContext context, {
  required T mobile,
  T? tablet,
  T? desktop,
  double tabletScale = 1.2,  // 20% larger than mobile
  double desktopScale = 1.5, // 50% larger than mobile
}) {
  final deviceType = getDeviceType(context);
  
  // Helper function to scale the value
  T scaleValue(T value, double scale) {
    if (value is num) {
      return (value * scale) as T;
    } else if (value is EdgeInsets) {
      return (value * scale) as T;
    } else if (value is Size) {
      return Size(value.width * scale, value.height * scale) as T;
    }
    // Add more types as needed
    return value; // Return original if type doesn't support scaling
  }
  
  return switch (deviceType) {
    DeviceType.desktop => desktop ?? scaleValue(tablet ?? mobile, desktopScale / (tablet != null ? tabletScale : 1.0)),
    DeviceType.tablet => tablet ?? scaleValue(mobile, tabletScale),
    DeviceType.mobile => mobile,
  };
}
  
  
  /// Get screen dimensions
  static Size screenSize(BuildContext context) => MediaQuery.of(context).size;
  static double screenWidth(BuildContext context) => screenSize(context).width;
  static double screenHeight(BuildContext context) => screenSize(context).height;
  
  /// Get safe area padding
  static EdgeInsets safeArea(BuildContext context) => MediaQuery.of(context).padding;
  
  /// Check keyboard visibility
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
  
  /// Simplified font sizing with default multipliers
  static double fontSize(BuildContext context, double baseSize) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.desktop:
        return baseSize * 1.5;
      case DeviceType.tablet:
        return baseSize * 1.25;
      case DeviceType.mobile:
        return baseSize;
    }
  }
  
  /// Simplified spacing with default multipliers
  static double spacing(BuildContext context, double baseSpacing) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.desktop:
        return baseSpacing * 1.5;
      case DeviceType.tablet:
        return baseSpacing * 1.25;
      case DeviceType.mobile:
        return baseSpacing;
    }
  }
}





enum DeviceType { mobile, tablet, desktop }

/// Extension for easier access
extension ResponsiveContext on BuildContext {
  DeviceType get deviceType => ResponsiveUtils.getDeviceType(this);
  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;
  
  double get screenWidth => ResponsiveUtils.screenWidth(this);
  double get screenHeight => ResponsiveUtils.screenHeight(this);
  
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) => ResponsiveUtils.value(
    this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  );
  
  double fontSize(double baseSize) => ResponsiveUtils.fontSize(this, baseSize);
  
  double spacing(double baseSpacing) => ResponsiveUtils.spacing(this, baseSpacing);
}