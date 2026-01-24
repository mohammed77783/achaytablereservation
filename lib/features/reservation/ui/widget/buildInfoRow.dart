import 'package:achaytablereservation/app/themes/dark_theme.dart';
import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Helper method to build info rows in dialog
Widget buildInfoRow({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Row(
    children: [
      Icon(
        icon,
        size: 16,
        color: Get.isDarkMode
            ? DarkTheme.textSecondary
            : LightTheme.textSecondary,
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          color: Get.isDarkMode
              ? DarkTheme.textSecondary
              : LightTheme.textSecondary,
        ),
      ),
      const SizedBox(width: 4),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Get.isDarkMode
                ? DarkTheme.textPrimary
                : LightTheme.textPrimary,
          ),
        ),
      ),
    ],
  );
}
