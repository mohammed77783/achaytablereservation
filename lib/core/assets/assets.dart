/// Barrel file for assets module.
///
/// This file exports all asset-related classes to simplify imports.
/// Instead of importing multiple files, consumers can import this single file.
///
/// ## Usage
///
/// ### Before (multiple imports):
/// ```dart
/// import 'package:ajaihrapplication/core/assets/app_assets.dart';
/// import 'package:ajaihrapplication/core/assets/app_images.dart';
/// import 'package:ajaihrapplication/core/assets/app_icons.dart';
/// import 'package:ajaihrapplication/core/assets/asset_helper.dart';
/// ```
///
/// ### After (single import):
/// ```dart
/// import 'package:ajaihrapplication/core/assets/assets.dart';
/// ```
///
/// ## Exported Classes
///
/// - [AppAssets] - Main entry point for accessing all assets
/// - [AppImages] - Image asset constants
/// - [AppIcons] - Icon asset constants
/// - [AssetHelper] - Utility methods for loading assets


library;


export 'app_icons.dart';
export 'app_images.dart';
export 'asset_helper.dart';
