// lib/features/branch_info/presentation/widgets/branch_header.dart

import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:achaytablereservation/core/utils/responsive_utils.dart';
import 'package:achaytablereservation/features/homepage/data/model/branch_models.dart';
import 'package:url_launcher/url_launcher.dart';

/// Header widget displaying branch name, rating, and info
class BranchHeader extends StatelessWidget {
  final Branch branch;
  final bool isArabic;

  const BranchHeader({super.key, required this.branch, this.isArabic = true});

  /// Launch phone dialer with the branch phone number
  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      debugPrint('Could not launch phone dialer for $phoneNumber');
    }
  }

  /// Launch maps with the branch address
  Future<void> _launchMaps(String address) async {
    // Encode the address for URL
    final encodedAddress = Uri.encodeComponent(address);
    // Try Google Maps URL first (works on both iOS and Android)
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
    );
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch maps for $address');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Branch name
        Text(
          branch.fullName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: ResponsiveUtils.spacing(context, LightTheme.spacingSmall),
        ),
        // Rating and reviews row
        Row(
          children: [
            // Rating
            _buildRatingChip(context),

            SizedBox(
              width: ResponsiveUtils.spacing(context, LightTheme.spacingMedium),
            ),

            // Reviews count
            Text(
              '(${branch.totalReviews} ${isArabic ? 'تقييم' : 'reviews'})',
              style: theme.textTheme.bodySmall,
            ),

            const Spacer(),

            // Open/Closed status
            _buildStatusChip(context),
          ],
        ),

        SizedBox(
          height: ResponsiveUtils.spacing(context, LightTheme.spacingMedium),
        ),
        // Address row (clickable - opens maps)
        _buildClickableInfoRow(
          context: context,
          icon: Iconsax.location,
          text: branch.address,
          onTap: () => _launchMaps(branch.address),
        ),

        SizedBox(
          height: ResponsiveUtils.spacing(context, LightTheme.spacingSmall),
        ),

        // Phone row (clickable - opens phone dialer)
        _buildClickableInfoRow(
          context: context,
          icon: Iconsax.call,
          text: branch.phone,
          onTap: () => _launchPhone(branch.phone),
        ),

        // Distance (if available)
        if (branch.distanceKm != null) ...[
          SizedBox(
            height: ResponsiveUtils.spacing(context, LightTheme.spacingSmall),
          ),
          _buildInfoRow(
            context: context,
            icon: Iconsax.routing,
            text: isArabic
                ? '${branch.distanceKm!.toStringAsFixed(1)} كم'
                : '${branch.distanceKm!.toStringAsFixed(1)} km away',
          ),
        ],
      ],
    );
  }

  Widget _buildRatingChip(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, LightTheme.spacingSmall),
        vertical: LightTheme.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: LightTheme.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(LightTheme.borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.star1,
            color: LightTheme.warningColor,
            size: LightTheme.iconSizeSmall,
          ),
          SizedBox(width: LightTheme.spacingXSmall),
          Text(
            branch.averageRating.toStringAsFixed(1),
            style: theme.textTheme.labelLarge?.copyWith(
              color: LightTheme.warningColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    final isOpen = branch.isOpenNow;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, LightTheme.spacingSmall),
        vertical: LightTheme.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: isOpen
            ? LightTheme.successColor.withOpacity(0.1)
            : LightTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(LightTheme.borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOpen ? LightTheme.successColor : LightTheme.errorColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: LightTheme.spacingXSmall),
          Text(
            isOpen
                ? (isArabic ? 'مفتوح' : 'Open')
                : (isArabic ? 'مغلق' : 'Closed'),
            style: theme.textTheme.labelMedium?.copyWith(
              color: isOpen ? LightTheme.successColor : LightTheme.errorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Clickable info row widget with tap feedback
  Widget _buildClickableInfoRow({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LightTheme.borderRadius),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveUtils.spacing(context, LightTheme.spacingXSmall),
        ),
        child: Row(
          children: [
            SizedBox(
              width: ResponsiveUtils.spacing(context, LightTheme.spacingSmall),
            ),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: LightTheme.primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Non-clickable info row widget
  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          color: LightTheme.textSecondary,
          size: LightTheme.iconSizeSmall,
        ),
        SizedBox(
          width: ResponsiveUtils.spacing(context, LightTheme.spacingSmall),
        ),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: LightTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
