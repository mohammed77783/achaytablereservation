/// AppIcons provides type-safe access to all icon assets in the application.
///
/// This class contains constants for all icon assets located in the assets/icon/
/// directory. Icons are kept separate from general images for better organization
/// and discoverability.
///
/// Usage:
/// ```dart
/// // In a widget
/// Image.asset(AppIcons.home);
///
/// // With Icon widget (for PNG icons)
/// ImageIcon(AssetImage(AppIcons.settings));
/// ```
///
/// To add new icons:
/// 1. Place the icon file in assets/icon/ directory
/// 2. Ensure the directory is declared in pubspec.yaml under flutter.assets
/// 3. Add a constant here following the naming convention
/// 4. Run `flutter pub get` to register the asset
///
/// Supported formats: PNG, SVG (with flutter_svg package)
class AppIcons {
  /// Private constructor to prevent instantiation
  const AppIcons._();

  // Icon constants will be added here as icons are placed in assets/icon/
  // Follow this pattern when adding new icons:
  //
  // Example for PNG icons:
  // static const String home = 'assets/icon/home.png';
  // static const String settings = 'assets/icon/settings.png';
  // static const String profile = 'assets/icon/profile.png';
  //
  // Example for SVG icons:
  // static const String homeIcon = 'assets/icon/home.svg';
  // static const String settingsIcon = 'assets/icon/settings.svg';
  //
  // Naming convention:
  // - Use camelCase for constant names
  // - Remove file extension from the name
  // - Replace special characters and spaces with valid identifiers
  // - Keep names descriptive and consistent
}
