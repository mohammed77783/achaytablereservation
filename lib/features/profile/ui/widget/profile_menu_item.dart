import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:flutter/material.dart';

/// Menu item widget for profile settings
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LightTheme.borderRadius),
      child: Padding(
        padding: const EdgeInsets.all(LightTheme.spacingMedium),
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(LightTheme.spacingSmall),
              decoration: BoxDecoration(
                color: (iconColor ?? LightTheme.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(LightTheme.borderRadius),
              ),
              child: Icon(
                icon,
                size: 22,
                color: iconColor ?? LightTheme.primaryColor,
              ),
            ),

            const SizedBox(width: LightTheme.spacingMedium),

            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: LightTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Trailing
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: LightTheme.textHint,
                ),
          ],
        ),
      ),
    );
  }
}
