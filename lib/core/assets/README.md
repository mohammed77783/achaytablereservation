# Assets Management System

A centralized, type-safe system for managing and accessing application assets in Flutter. This system eliminates hardcoded string paths, provides compile-time safety, and improves developer experience through IDE autocomplete support.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Usage Examples](#usage-examples)
- [Adding New Assets](#adding-new-assets)
- [Naming Conventions](#naming-conventions)
- [GetX Integration](#getx-integration)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

The Assets Management System consists of four main components:

- **AppAssets** - Main entry point for accessing all assets
- **AppImages** - Constants for image assets (PNG, JPG, WebP, etc.)
- **AppIcons** - Constants for icon assets
- **AssetHelper** - Utility methods for loading and managing assets

### Benefits

✅ **Type Safety** - Compile-time verification of asset paths  
✅ **IDE Autocomplete** - Discover available assets easily  
✅ **No Typos** - Eliminate runtime errors from incorrect paths  
✅ **Organized** - Clear structure based on asset types  
✅ **Maintainable** - Easy to add, update, or remove assets

## Quick Start

### Import the Assets Module

```dart
import 'package:ajaihrapplication/core/assets/assets.dart';
```

### Display an Image

```dart
Image.asset(AppAssets.images.r)
```

### Use Helper Methods

```dart
AssetHelper.loadImage(
  AppAssets.images.r,
  width: 100,
  height: 100,
  fit: BoxFit.cover,
)
```

## Usage Examples

### Basic Image Display

```dart
// Simple image display
Image.asset(AppAssets.images.r)

// With custom dimensions
Image.asset(
  AppAssets.images.r,
  width: 200,
  height: 200,
  fit: BoxFit.cover,
)

// Using AssetHelper with error handling
AssetHelper.loadImage(
  AppAssets.images.r,
  width: 150,
  height: 150,
  fit: BoxFit.contain,
  errorWidget: Text('Failed to load image'),
)
```

### Using AssetImage in Decorations

```dart
Container(
  width: 300,
  height: 200,
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage(AppAssets.images.r),
      fit: BoxFit.cover,
    ),
    borderRadius: BorderRadius.circular(12),
  ),
)
```

### Using AssetHelper Methods

```dart
// Load AssetImage object
final assetImage = AssetHelper.loadAssetImage(AppAssets.images.r);

// Check if asset exists before loading
final exists = await AssetHelper.assetExists(AppAssets.images.r);
if (exists) {
  Image.asset(AppAssets.images.r);
} else {
  // Handle missing asset
  Text('Image not available');
}
```

### Custom Error Handling

```dart
AssetHelper.loadImage(
  AppAssets.images.r,
  width: 100,
  height: 100,
  errorWidget: Container(
    width: 100,
    height: 100,
    color: Colors.grey[300],
    child: Icon(Icons.image_not_supported),
  ),
)
```

### Color Tinting

```dart
AssetHelper.loadImage(
  AppAssets.images.r,
  color: Colors.blue,
  colorBlendMode: BlendMode.modulate,
)
```

## Adding New Assets

Follow these steps to add new assets to your application:

### Step 1: Add Asset File

Place your asset file in the appropriate directory:

```
assets/
├── icon/           # For icon assets
└── png_image/      # For image assets
```

### Step 2: Update pubspec.yaml

Ensure the asset directory is declared in `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/icon/
    - assets/png_image/
    # Add new directories here as needed
```

### Step 3: Add Constant to Appropriate Class

**For Images** - Add to `lib/core/assets/app_images.dart`:

```dart
class AppImages {
  const AppImages._();

  // Existing constants
  static const String r = 'assets/png_image/R.png';

  // Add your new image constant
  static const String logo = 'assets/png_image/logo.png';
  static const String background = 'assets/png_image/background.jpg';
}
```

**For Icons** - Add to `lib/core/assets/app_icons.dart`:

```dart
class AppIcons {
  const AppIcons._();

  // Add your icon constants
  static const String home = 'assets/icon/home.png';
  static const String settings = 'assets/icon/settings.png';
  static const String profile = 'assets/icon/profile.png';
}
```

### Step 4: Register Assets

Run the following command to register the new assets:

```bash
flutter pub get
```

### Step 5: Use in Code

```dart
// Use your new asset
Image.asset(AppAssets.images.logo)
Image.asset(AppAssets.icons.home)
```

## Naming Conventions

Follow these conventions when adding asset constants:

### File to Constant Conversion

| File Name          | Constant Name | Rule                               |
| ------------------ | ------------- | ---------------------------------- |
| `logo.png`         | `logo`        | Remove extension, use as-is        |
| `app-icon.png`     | `appIcon`     | Convert kebab-case to camelCase    |
| `user_profile.png` | `userProfile` | Convert snake_case to camelCase    |
| `icon-24px.svg`    | `icon24px`    | Remove special chars, keep numbers |
| `home icon.png`    | `homeIcon`    | Replace spaces with camelCase      |

### General Rules

1. **Use camelCase** for all constant names
2. **Remove file extensions** from constant names
3. **Replace special characters** (-, \_, spaces) with camelCase
4. **Keep names descriptive** and meaningful
5. **Be consistent** with naming patterns
6. **Avoid abbreviations** unless widely understood

### Examples

```dart
// Good naming
static const String userAvatar = 'assets/images/user_avatar.png';
static const String homeIcon = 'assets/icon/home-icon.png';
static const String splashBackground = 'assets/images/splash_background.jpg';

// Avoid
static const String ua = 'assets/images/user_avatar.png';  // Too abbreviated
static const String home_icon = 'assets/icon/home-icon.png';  // Use camelCase
static const String SPLASH = 'assets/images/splash.jpg';  // Use camelCase, not UPPER_CASE
```

## GetX Integration

The Assets Management System integrates seamlessly with GetX architecture.

### In GetX Controllers

```dart
import 'package:get/get.dart';
import 'package:ajaihrapplication/core/assets/assets.dart';

class HomeController extends GetxController {
  // Store asset path as property
  String get logoPath => AppAssets.images.r;

  // Use in reactive variables
  final RxString currentImage = AppAssets.images.r.obs;

  // Method to change image
  void updateImage(String newImagePath) {
    currentImage.value = newImagePath;
  }

  // Validate asset before using
  Future<bool> checkAssetAvailability() async {
    return await AssetHelper.assetExists(AppAssets.images.r);
  }
}
```

### In GetX Views

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ajaihrapplication/core/assets/assets.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Column(
        children: [
          // Direct asset usage
          Image.asset(AppAssets.images.r),

          // Using controller property
          Image.asset(controller.logoPath),

          // Reactive image with Obx
          Obx(() => Image.asset(controller.currentImage.value)),

          // With AssetHelper
          AssetHelper.loadImage(
            AppAssets.images.r,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
```

### In GetX Bindings

```dart
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());

    // Preload critical assets if needed
    Get.putAsync<void>(() async {
      await AssetHelper.assetExists(AppAssets.images.r);
      return;
    });
  }
}
```

### Complete GetX Feature Example

```dart
// Controller
class ProfileController extends GetxController {
  final RxString profileImage = AppAssets.images.r.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    validateAssets();
  }

  Future<void> validateAssets() async {
    isLoading.value = true;
    final exists = await AssetHelper.assetExists(profileImage.value);
    if (!exists) {
      // Handle missing asset
      profileImage.value = AppAssets.images.r; // Fallback
    }
    isLoading.value = false;
  }

  void changeProfileImage(String newPath) {
    profileImage.value = newPath;
  }
}

// View
class ProfileView extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() {
          if (controller.isLoading.value) {
            return CircularProgressIndicator();
          }

          return AssetHelper.loadImage(
            controller.profileImage.value,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          );
        }),
      ),
    );
  }
}
```

## Best Practices

### 1. Always Use Constants

```dart
// ✅ Good - Type-safe and autocomplete-friendly
Image.asset(AppAssets.images.r)

// ❌ Bad - Prone to typos and no autocomplete
Image.asset('assets/png_image/R.png')
```

### 2. Use AssetHelper for Complex Scenarios

```dart
// ✅ Good - Built-in error handling
AssetHelper.loadImage(
  AppAssets.images.r,
  width: 100,
  height: 100,
  errorWidget: Icon(Icons.error),
)

// ⚠️ Acceptable but no error handling
Image.asset(AppAssets.images.r, width: 100, height: 100)
```

### 3. Validate Assets in Critical Paths

```dart
// ✅ Good - Validate before displaying
Future<void> loadCriticalAsset() async {
  final exists = await AssetHelper.assetExists(AppAssets.images.r);
  if (exists) {
    // Safe to use
  } else {
    // Handle gracefully
  }
}
```

### 4. Organize Assets by Feature

```
assets/
├── icon/
│   ├── home.png
│   ├── settings.png
│   └── profile.png
├── png_image/
│   ├── R.png
│   └── logo.png
└── backgrounds/
    ├── splash.jpg
    └── login.jpg
```

### 5. Keep Asset Files Optimized

- Compress images before adding to assets
- Use appropriate formats (PNG for transparency, JPG for photos)
- Consider using WebP for better compression
- Remove unused assets regularly

### 6. Document Custom Assets

```dart
/// Logo image displayed on the splash screen and app bar.
/// Dimensions: 512x512px
/// Format: PNG with transparency
static const String logo = 'assets/png_image/logo.png';
```

## Troubleshooting

### Asset Not Found Error

**Problem:** `Unable to load asset: assets/png_image/image.png`

**Solutions:**

1. Verify the file exists in the correct directory
2. Check `pubspec.yaml` includes the asset directory
3. Run `flutter pub get` to register assets
4. Restart your app (hot reload may not pick up new assets)
5. Clean and rebuild: `flutter clean && flutter pub get`

### Constant Not Found

**Problem:** Cannot find `AppAssets.images.myImage`

**Solutions:**

1. Ensure you've added the constant to the appropriate class
2. Check your import statement includes the assets module
3. Verify the constant name matches the file name (following naming conventions)

### Image Not Displaying

**Problem:** Image widget shows but no image appears

**Solutions:**

1. Use `AssetHelper.assetExists()` to verify the asset is accessible
2. Check for error messages in the console
3. Verify the asset path in the constant is correct
4. Ensure the image format is supported by Flutter

### Build Errors After Adding Assets

**Problem:** Build fails after adding new assets

**Solutions:**

1. Verify `pubspec.yaml` syntax is correct (proper indentation)
2. Run `flutter clean` then `flutter pub get`
3. Check for duplicate asset declarations
4. Ensure asset paths don't have typos

### IDE Not Showing Autocomplete

**Problem:** IDE doesn't suggest asset constants

**Solutions:**

1. Restart your IDE
2. Run `flutter pub get`
3. Check that you've imported the assets module
4. Verify the constant is declared as `static const String`

---

## Additional Resources

- [Flutter Assets Documentation](https://docs.flutter.dev/development/ui/assets-and-images)
- [GetX Documentation](https://pub.dev/packages/get)
- [Image Optimization Guide](https://docs.flutter.dev/perf/rendering/best-practices#images)

## Contributing

When adding new assets or modifying the system:

1. Follow the naming conventions
2. Update relevant constant classes
3. Test asset loading in the app
4. Document any new patterns or conventions
5. Keep this README updated

---

**Last Updated:** November 2025  
**Maintained By:** Development Team
