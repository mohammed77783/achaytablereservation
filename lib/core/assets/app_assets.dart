import 'app_icons.dart';
import 'app_images.dart';


class AppAssets {

  AppAssets._();
  /// Access to all image assets in the application.
  ///
  /// Contains constants for images organized by subdirectory.
  /// Use this for photos, backgrounds, logos, and other image resources.
  ///
  /// Example:
  /// ```dart
  /// Image.asset(AppAssets.images.r)
  /// ```
  static const images = AppImages;
  /// Access to all icon assets in the application.
  ///
  /// Contains constants for icon assets used in UI elements.
  /// Icons are kept separate from general images for better organization.
  ///
  /// Example:
  /// ```dart
  /// Image.asset(AppAssets.icons.home)
  /// ```
  static const icons = AppIcons;
}
