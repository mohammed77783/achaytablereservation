import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/themes/light_theme.dart';
import '../../../../app/themes/dark_theme.dart';

/// NotificationsPage - Placeholder page for notifications feature
///
/// Requirements implemented:
/// - 5.1: Display notifications page when navigation item is selected
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? DarkTheme.backgroundColor
          : LightTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'notifications'.tr,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
          ),
        ),
        backgroundColor: isDark
            ? DarkTheme.surfaceColor
            : LightTheme.surfaceColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Notifications Page',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            color: isDark ? DarkTheme.textSecondary : LightTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
