import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../app/themes/light_theme.dart';
import '../../../../app/themes/dark_theme.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/shared/model/user_model.dart';

/// Profile header widget for displaying user info
/// Integrates with UserModel and supports both Arabic and English display
///
/// Requirements implemented:
/// - 3.1: Display user's full name from UserModel
/// - 3.2: Show welcome message in current language
/// - 3.3: Navigate to profile page when tapped
/// - 3.4: Display default avatar when no user image available
/// - 3.5: Support both Arabic and English text display
class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;

  const ProfileHeader({super.key, required this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Get.locale?.languageCode == 'ar';

    return GestureDetector(
      onTap: onTap, // Requirement 3.3: Navigate to profile page when tapped
      child: Container(
        padding: EdgeInsets.all(
          context.spacing(
            isDark ? DarkTheme.spacingMedium : LightTheme.spacingMedium,
          ),
        ),
        child: Row(
          children: [
            // Avatar with placeholder support
            _buildAvatar(context, isDark),

            SizedBox(
              width: context.spacing(
                isDark ? DarkTheme.spacingMedium : LightTheme.spacingMedium,
              ),
            ),

            // Welcome message and name display
            Expanded(
              child: Column(
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
                    user.fullName, // Requirement 3.1: Display user's full name from UserModel
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
            ),

            // Navigation indicator (Requirement 3.3: Visual feedback for navigation)
            if (onTap != null)
              Icon(
                isArabic
                    ? Icons.arrow_back_ios
                    : Icons.arrow_forward_ios, // Requirement 3.5: RTL support
                size: context.responsive<double>(
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
                color: isDark
                    ? DarkTheme.textSecondary
                    : LightTheme.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  /// Builds avatar with placeholder support (Requirement 3.4)
  /// Shows default avatar when no user image is available
  Widget _buildAvatar(BuildContext context, bool isDark) {
    return Container(
      width: context.responsive<double>(
        mobile: 48.0,
        tablet: 56.0,
        desktop: 64.0,
      ),
      height: context.responsive<double>(
        mobile: 48.0,
        tablet: 56.0,
        desktop: 64.0,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? DarkTheme.primaryLight : LightTheme.primaryLight,
        border: Border.all(
          color: (isDark ? DarkTheme.primaryColor : LightTheme.primaryColor)
              .withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: ClipOval(child: _buildAvatarContent(context, isDark)),
    );
  }

  /// Builds avatar content with default placeholder when no user image is available (Requirement 3.4)
  Widget _buildAvatarContent(BuildContext context, bool isDark) {
    // Requirement 3.4: Display default avatar when no user image available
    // For now, always show placeholder since UserModel doesn't have image field
    // This can be extended when user image support is added to UserModel
    return Container(
      color: isDark ? DarkTheme.primaryLight : LightTheme.primaryLight,
      child: Icon(
        Iconsax.user,
        color: isDark ? DarkTheme.textOnPrimary : LightTheme.textOnPrimary,
        size: context.responsive<double>(mobile: 20, tablet: 24, desktop: 28),
      ),
    );
  }
}
