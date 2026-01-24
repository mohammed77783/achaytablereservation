/// AppImages class provides type-safe access to all image assets in the application.
///
/// This class contains constants for all image assets organized by their location
/// in the assets directory structure. Using these constants instead of hardcoded
/// strings provides compile-time safety and IDE autocomplete support.
///
/// Usage:
/// ```dart
/// // Basic usage with Image.asset
/// Image.asset(AppImages.r)
///
/// // With custom properties
/// Image.asset(
///   AppImages.r,
///   width: 100,
///   height: 100,
///   fit: BoxFit.cover,
/// )
///
/// // With AssetImage
/// Container(
///   decoration: BoxDecoration(
///     image: DecorationImage(
///       image: AssetImage(AppImages.r),
///     ),
///   ),
/// )
/// ```
class AppImages {

  const AppImages._();
  static const String root='assets/images/';

  static const String LOGO = '${root}logo.png';


}
