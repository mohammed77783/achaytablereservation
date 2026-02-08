import 'package:achaytablereservation/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../app/themes/light_theme.dart';
import '../../../app/themes/dark_theme.dart';
import '../../homepage/ui/screen/homepage.dart';
import '../../reservation/ui/screen/bookings_page.dart';
import '../../notification/ui/screen/notifications_page.dart';
import '../../more/ui/screen/more_page.dart';
import '../logic/main_navigation_controller.dart';

/// Main navigation scaffold with bottom navigation bar
/// Manages navigation between Home, Bookings, Notifications, and More pages
///
/// Requirements implemented:
/// - 1.1: Bottom navigation bar displayed at bottom of screen
/// - 1.2: Four navigation items with distinct icons and labels
/// - 1.4: Navigation bar remains visible across main pages
/// - 1.5: Distinct icons for visual clarity
/// - 2.1: Tap navigation items to switch pages
/// - 2.2: Update visual state when item selected
/// - 2.3: Active item has distinct visual style
/// - 8.1: Uses app theme colors
/// - 8.2: Active item visually distinct from inactive
/// - 8.3: Icons and labels for each item
/// - 8.4: Supports light and dark themes
class MainNavigationScaffold extends StatelessWidget {
  const MainNavigationScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainNavigationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // List of pages to display
    final List<Widget> pages = [
      const HomePage(),
      const BookingsPage(),
      const NotificationsPage(),
      const MorePage(),
    ];
    return Scaffold(
      body: Obx(
        () =>
            IndexedStack(index: controller.currentIndex.value, children: pages),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.spacing(context, 10),
            vertical: ResponsiveUtils.spacing(context, 10),
          ),
          decoration: BoxDecoration(
            color: isDark ? DarkTheme.surfaceColor : LightTheme.surfaceColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(20),
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(20),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
              ),
              child: BottomNavigationBar(
                currentIndex: controller.currentIndex.value,
                onTap: controller.changePage,
                type: BottomNavigationBarType.fixed,
                enableFeedback: false,

                // Updated Background Logic
                backgroundColor: isDark
                    ? DarkTheme
                          .cardBackground // Slightly lighter than surface for better depth
                    : LightTheme.surfaceColor,

                // Black icons and labels for navigation bar
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.black.withValues(alpha: 0.6),

                selectedFontSize: ResponsiveUtils.fontSize(context, 12),
                unselectedFontSize: ResponsiveUtils.fontSize(context, 10),
                elevation: 0,

                selectedLabelStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.normal,
                ),
                items: [
                  _buildNavItem(
                    Iconsax.home,
                    Iconsax.home_15,
                    'home'.tr,
                    context,
                  ),
                  _buildNavItem(
                    Iconsax.calendar,
                    Iconsax.calendar_1,
                    'bookings'.tr,
                    context,
                  ),
                  _buildNavItem(
                    Iconsax.notification,
                    Iconsax.notification_1,
                    'notifications'.tr,
                    context,
                  ),
                  _buildNavItem(
                    Iconsax.menu,
                    Iconsax.menu_1,
                    'more'.tr,
                    context,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    BuildContext context,
  ) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(
          top: ResponsiveUtils.spacing(context, 8),
          bottom: ResponsiveUtils.spacing(context, 4),
        ),
        child: Icon(icon),
      ),
      activeIcon: Padding(
        padding: EdgeInsets.only(
          top: ResponsiveUtils.spacing(context, 8),
          bottom: ResponsiveUtils.spacing(context, 4),
        ),
        child: Icon(activeIcon),
      ),
      label: label,
    );
  }
}
