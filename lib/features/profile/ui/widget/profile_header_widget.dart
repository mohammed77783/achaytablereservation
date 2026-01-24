import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/features/profile/data/model/profile_model.dart';
import 'package:flutter/material.dart';

/// Profile header widget showing avatar and name
class ProfileHeaderWidget extends StatelessWidget {
  final ProfileModel profile;

  const ProfileHeaderWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LightTheme.secondaryColor,
              boxShadow: [
                BoxShadow(
                  color: LightTheme.shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getInitials(profile.fullName),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: LightTheme.textOnSecondary,
                ),
              ),
            ),
          ),

          const SizedBox(height: LightTheme.spacingMedium),

          // Full Name
          Text(
            profile.fullName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: LightTheme.spacingXSmall),

          // Username
          Text(
            '@${profile.username}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: LightTheme.textSecondary),
          ),

          const SizedBox(height: LightTheme.spacingSmall),

          // Active Status Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: LightTheme.spacingMedium,
              vertical: LightTheme.spacingXSmall,
            ),
            decoration: BoxDecoration(
              color: profile.isActive
                  ? LightTheme.successColor.withOpacity(0.1)
                  : LightTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: profile.isActive
                        ? LightTheme.successColor
                        : LightTheme.errorColor,
                  ),
                ),
                const SizedBox(width: LightTheme.spacingSmall),
                Text(
                  profile.isActive ? 'نشط' : 'غير نشط',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: profile.isActive
                        ? LightTheme.successColor
                        : LightTheme.errorColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
