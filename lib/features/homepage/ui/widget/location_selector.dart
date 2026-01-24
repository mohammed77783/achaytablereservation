import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../app/themes/light_theme.dart';
import '../../../../app/themes/dark_theme.dart';
import '../../../../core/utils/responsive_utils.dart';

/// Location selector bottom sheet
class LocationSelector extends StatefulWidget {
  final String currentLocation;
  final Function(String name, double lat, double lng) onLocationSelected;

  const LocationSelector({
    super.key,
    required this.currentLocation,
    required this.onLocationSelected,
  });

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  bool _isGettingLocation = false;

  // Mock locations for Saudi Arabia
  final List<Map<String, dynamic>> _locations = [
    {'name': 'الرياض', 'nameEn': 'Riyadh', 'lat': 24.7136, 'lng': 46.6753},
    {'name': 'جدة', 'nameEn': 'Jeddah', 'lat': 21.5433, 'lng': 39.1728},
    {'name': 'مكة المكرمة', 'nameEn': 'Makkah', 'lat': 21.4225, 'lng': 39.8262},
    {
      'name': 'المدينة المنورة',
      'nameEn': 'Madinah',
      'lat': 24.5247,
      'lng': 39.5692,
    },
    {'name': 'بريدة', 'nameEn': 'Buraidah', 'lat': 26.3260, 'lng': 43.9750},
    {'name': 'الدمام', 'nameEn': 'Dammam', 'lat': 26.4207, 'lng': 50.0888},
    {'name': 'الخبر', 'nameEn': 'Khobar', 'lat': 26.2172, 'lng': 50.1971},
    {'name': 'الظهران', 'nameEn': 'Dhahran', 'lat': 26.2361, 'lng': 50.0393},
    {'name': 'تبوك', 'nameEn': 'Tabuk', 'lat': 28.3838, 'lng': 36.5550},
    {'name': 'أبها', 'nameEn': 'Abha', 'lat': 18.2164, 'lng': 42.5053},
    {'name': 'الطائف', 'nameEn': 'Taif', 'lat': 21.2703, 'lng': 40.4158},
  ];

  List<Map<String, dynamic>> _filteredLocations = [];

  @override
  void initState() {
    super.initState();
    _filteredLocations = _locations;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _filterLocations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLocations = _locations;
      } else {
        _filteredLocations = _locations.where((location) {
          return location['name'].toString().contains(query) ||
              location['nameEn'].toString().toLowerCase().contains(
                query.toLowerCase(),
              );
        }).toList();
      }
    });
  }

  bool get isArabic => Get.locale?.languageCode == 'ar';

  /// Get current location using GPS
  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) return;

    setState(() {
      _isGettingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          isArabic ? 'خطأ' : 'Error',
          isArabic
              ? 'خدمات الموقع غير مفعلة'
              : 'Location services are disabled',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            isArabic ? 'خطأ' : 'Error',
            isArabic ? 'تم رفض إذن الموقع' : 'Location permissions are denied',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          isArabic ? 'خطأ' : 'Error',
          isArabic
              ? 'إذن الموقع مرفوض نهائياً. يرجى تفعيله من الإعدادات'
              : 'Location permissions are permanently denied. Please enable them in settings',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Find the closest city to current location
      String closestCity = _findClosestCity(
        position.latitude,
        position.longitude,
      );

      // Call the callback with current location
      widget.onLocationSelected(
        closestCity,
        position.latitude,
        position.longitude,
      );
      Navigator.pop(context);
    } catch (e) {
      Get.snackbar(
        isArabic ? 'خطأ' : 'Error',
        isArabic
            ? 'فشل في الحصول على الموقع الحالي'
            : 'Failed to get current location',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  /// Find the closest city to given coordinates
  String _findClosestCity(double lat, double lng) {
    double minDistance = double.infinity;
    String closestCity = 'الرياض'; // Default to Riyadh

    for (var location in _locations) {
      double distance = Geolocator.distanceBetween(
        lat,
        lng,
        location['lat'],
        location['lng'],
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestCity = location['name'];
      }
    }

    return closestCity;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxHeight: context.screenHeight * 0.7),
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing(
          isDark ? DarkTheme.spacingMedium : LightTheme.spacingMedium,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: context.spacing(
              isDark ? DarkTheme.spacingLarge : LightTheme.spacingLarge,
            ),
          ),

          // Title
          Text(
            isArabic ? 'اختر الموقع' : 'Select Location',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: context.fontSize(20),
              fontWeight: FontWeight.bold,
              color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
            ),
          ),

          SizedBox(
            height: context.spacing(
              isDark ? DarkTheme.spacingLarge : LightTheme.spacingLarge,
            ),
          ),

          // Search field
          TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            onChanged: _filterLocations,
            decoration: InputDecoration(
              hintText: isArabic ? 'ابحث عن مدينة...' : 'Search for a city...',
              prefixIcon: Icon(
                Iconsax.search_normal,
                color: isDark
                    ? DarkTheme.textSecondary
                    : LightTheme.textSecondary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _filterLocations('');
                      },
                      icon: Icon(
                        Iconsax.close_circle,
                        color: isDark
                            ? DarkTheme.textSecondary
                            : LightTheme.textSecondary,
                      ),
                    )
                  : null,
            ),
          ),

          SizedBox(
            height: context.spacing(
              isDark ? DarkTheme.spacingLarge : LightTheme.spacingLarge,
            ),
          ),

          // Current location button
          _buildLocationTile(
            context: context,
            isDark: isDark,
            icon: _isGettingLocation ? Iconsax.refresh : Iconsax.gps,
            iconColor: isDark
                ? DarkTheme.primaryColor
                : LightTheme.primaryColor,
            title: isArabic ? 'موقعي الحالي' : 'Current Location',
            subtitle: _isGettingLocation
                ? (isArabic ? 'جاري تحديد الموقع...' : 'Getting location...')
                : (isArabic ? 'استخدم GPS' : 'Use GPS'),
            onTap: _isGettingLocation ? () {} : _getCurrentLocation,
          ),

          Divider(
            height: context.spacing(
              isDark ? DarkTheme.spacingXLarge : LightTheme.spacingXLarge,
            ),
          ),

          // Locations list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredLocations.length,
              itemBuilder: (context, index) {
                final location = _filteredLocations[index];
                final isSelected = widget.currentLocation == location['name'];

                return _buildLocationTile(
                  context: context,
                  isDark: isDark,
                  icon: Iconsax.location,
                  iconColor: isSelected
                      ? (isDark
                            ? DarkTheme.primaryColor
                            : LightTheme.primaryColor)
                      : (isDark
                            ? DarkTheme.textSecondary
                            : LightTheme.textSecondary),
                  title: isArabic ? location['name'] : location['nameEn'],
                  isSelected: isSelected,
                  onTap: () {
                    widget.onLocationSelected(
                      location['name'],
                      location['lat'],
                      location['lng'],
                    );
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),

          SizedBox(
            height: context.spacing(
              isDark ? DarkTheme.spacingLarge : LightTheme.spacingLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: context.responsive<double>(mobile: 44, tablet: 48, desktop: 52),
        height: context.responsive<double>(mobile: 44, tablet: 48, desktop: 52),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(
            isDark ? DarkTheme.borderRadiusLarge : LightTheme.borderRadiusLarge,
          ),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: context.responsive<double>(
            mobile: isDark
                ? DarkTheme.iconSizeMedium
                : LightTheme.iconSizeMedium,
            tablet:
                (isDark
                    ? DarkTheme.iconSizeMedium
                    : LightTheme.iconSizeMedium) *
                1.2,
            desktop:
                (isDark
                    ? DarkTheme.iconSizeMedium
                    : LightTheme.iconSizeMedium) *
                1.5,
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: context.fontSize(16),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected
              ? (isDark ? DarkTheme.primaryColor : LightTheme.primaryColor)
              : (isDark ? DarkTheme.textPrimary : LightTheme.textPrimary),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: context.fontSize(12),
                color: isDark
                    ? DarkTheme.textSecondary
                    : LightTheme.textSecondary,
              ),
            )
          : null,
      trailing: isSelected
          ? Icon(
              Iconsax.tick_circle5,
              color: isDark ? DarkTheme.primaryColor : LightTheme.primaryColor,
              size: context.responsive<double>(
                mobile: 20,
                tablet: 24,
                desktop: 28,
              ),
            )
          : null,
    );
  }
}
