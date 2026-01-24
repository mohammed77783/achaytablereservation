import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utility class for loading and managing application assets.
///
/// Provides convenient helper methods to load images, handle errors,
/// and validate asset existence. All methods are static and the class
/// cannot be instantiated.
///
/// Example usage:
/// ```dart
/// // Load an image with custom dimensions
/// AssetHelper.loadImage(
///   AppImages.ajalogo,
///   width: 100,
///   height: 100,
///   fit: BoxFit.cover,
/// );
///
/// // Load an AssetImage object
/// final assetImage = AssetHelper.loadAssetImage(AppImages.ajalogo);
///
/// // Check if an asset exists
/// final exists = await AssetHelper.assetExists(AppImages.ajalogo);
/// ```
class AssetHelper {
  /// Private constructor to prevent instantiation
  AssetHelper._();

  /// Loads an [Image] widget from the specified asset [path].
  ///
  /// This method provides a convenient way to load images with optional
  /// customization parameters and built-in error handling.
  ///
  /// Parameters:
  /// - [path]: The asset path (use constants from AppImages or AppIcons)
  /// - [width]: Optional width for the image
  /// - [height]: Optional height for the image
  /// - [fit]: How the image should be inscribed into the space (default: BoxFit.contain)
  /// - [color]: Color to blend with the image
  /// - [colorBlendMode]: The blend mode to apply when [color] is provided
  /// - [errorWidget]: Custom widget to display when image fails to load
  ///
  /// Returns an [Image] widget configured with the specified parameters.
  ///
  /// Example:
  /// ```dart
  /// AssetHelper.loadImage(
  ///   AppImages.ajalogo,
  ///   width: 200,
  ///   height: 200,
  ///   fit: BoxFit.cover,
  ///   color: Colors.blue,
  ///   colorBlendMode: BlendMode.modulate,
  /// );
  /// ```
  static Image loadImage(
    String path, {
    double? width,
    double? height,
    BoxFit? fit,
    Color? color,
    BlendMode? colorBlendMode,
    Widget? errorWidget,
  }) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      color: color,
      colorBlendMode: colorBlendMode,
      errorBuilder: (context, error, stackTrace) {
        // Log error for debugging
        debugPrint('Error loading asset: $path');
        debugPrint('Error: $error');

        // Return custom error widget or default broken image icon
        return errorWidget ??
            Center(
              child: Icon(
                Icons.broken_image,
                size: width ?? height ?? 50,
                color: Colors.grey,
              ),
            );
      },
    );
  }

  /// Creates an [AssetImage] object from the specified asset [path].
  ///
  /// Use this method when you need an [ImageProvider] rather than a widget,
  /// such as for [DecorationImage] in a [BoxDecoration].
  ///
  /// Parameters:
  /// - [path]: The asset path (use constants from AppImages or AppIcons)
  ///
  /// Returns an [AssetImage] object that can be used as an [ImageProvider].
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     image: DecorationImage(
  ///       image: AssetHelper.loadAssetImage(AppImages.ajalogo),
  ///       fit: BoxFit.cover,
  ///     ),
  ///   ),
  /// );
  /// ```
  /// 
  /// 
  static AssetImage loadAssetImage(String path) {
    return AssetImage(path);
  }

  /// Checks if an asset exists at the specified [path].
  ///
  /// This method attempts to load the asset to verify its existence.
  /// Useful for validation and error prevention before attempting to
  /// display an asset.
  ///
  /// Parameters:
  /// - [path]: The asset path to check
  ///
  /// Returns a [Future<bool>] that resolves to `true` if the asset exists,
  /// `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final exists = await AssetHelper.assetExists(AppImages.ajalogo);
  /// if (exists) {
  ///   // Safe to load the asset
  ///   Image.asset(AppImages.ajalogo);
  /// } else {
  ///   // Handle missing asset
  ///   print('Asset not found');
  /// }
  /// 
  /// 
  
  static Future<bool> assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (e) {
      debugPrint('Asset does not exist: $path');
      return false;
    }
  }


}
