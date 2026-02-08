// lib/features/branch_info/presentation/widgets/common/primary_button.dart

import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:achaytablereservation/core/utils/responsive_utils.dart';

/// Primary action button with consistent styling
class PrimaryButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;

  const PrimaryButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: ResponsiveUtils.value<double>(
        context,
        mobile: LightTheme.buttonHeight,
        tablet: LightTheme.buttonHeight * 1.1,
      ),
      child: ElevatedButton(
        onPressed: isLoading || isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: LightTheme.primaryColor,
          foregroundColor: LightTheme.textOnPrimary,
          disabledBackgroundColor: LightTheme.primaryColor.withOpacity(0.5),
          disabledForegroundColor: LightTheme.textOnPrimary.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LightTheme.borderRadius),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: LightTheme.iconSizeMedium,
                height: LightTheme.iconSizeMedium,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: LightTheme.iconSizeMedium),
                    SizedBox(
                      width: ResponsiveUtils.spacing(
                        context,
                        LightTheme.spacingSmall,
                      ),
                    ),
                  ],
                  Text(
                    text,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: LightTheme.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
