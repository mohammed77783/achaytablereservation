import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../app/themes/light_theme.dart';
import '../../../../app/themes/dark_theme.dart';
import '../../../../core/utils/responsive_utils.dart';

/// Home app bar with profile and location
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String? userAvatarUrl;
  final String? locationText;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLocationTap;

  const HomeAppBar({
    super.key,
    required this.userName,
    this.userAvatarUrl,
    this.locationText,
    this.onProfileTap,
    this.onLocationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark
          ? DarkTheme.surfaceColor
          : LightTheme.surfaceColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          // Profile section
          GestureDetector(
            onTap: onProfileTap,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isDark
                      ? DarkTheme.primaryLight
                      : LightTheme.primaryLight,
                  backgroundImage: userAvatarUrl != null
                      ? NetworkImage(userAvatarUrl!)
                      : null,
                  child: userAvatarUrl == null
                      ? Icon(
                          Iconsax.user,
                          color: isDark
                              ? DarkTheme.textOnPrimary
                              : LightTheme.textOnPrimary,
                          size: 20,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Welcome message in current language (Requirements 3.2, 3.5)
                    Text(
                      'welcome'
                          .tr, // Requirement 3.2: Welcome message in current language
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: context.fontSize(12),
                        color: isDark
                            ? DarkTheme.textSecondary
                            : LightTheme.textSecondary,
                      ),
                    ),
                    // User's full name from UserModel (Requirement 3.1)
                    Text(
                      userName, // Requirement 3.1: Display user's full name from UserModel
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: context.fontSize(16),
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? DarkTheme.textPrimary
                            : LightTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Location button
        GestureDetector(
          onTap: onLocationTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isDark ? DarkTheme.surfaceGray : LightTheme.surfaceGray,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? DarkTheme.borderColor : LightTheme.borderColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.location,
                  color: isDark
                      ? DarkTheme.primaryColor
                      : LightTheme.primaryColor,
                  size: 16,
                ),
                if (locationText != null) ...[
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 100),
                    child: Text(
                      locationText!,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? DarkTheme.textPrimary
                            : LightTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: isDark
                      ? DarkTheme.textSecondary
                      : LightTheme.textSecondary,
                  size: 16,
                ),
             
              ],
            ),
          ),
        ), SizedBox(width: 20,)
      ],
    );
  }
}
