import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../app/themes/light_theme.dart';
import '../../../../app/themes/dark_theme.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/distance_utils.dart';
import '../../data/model/branch_models.dart';

/// Branch card widget for displaying restaurant info
class BranchCard extends StatelessWidget {
  final Branch branch;
  final VoidCallback? onTap;
  final bool isArabic;
  final double? userLatitude;
  final double? userLongitude;

  const BranchCard({
    super.key,
    required this.branch,
    this.onTap,
    this.isArabic = true,
    this.userLatitude,
    this.userLongitude,
  });

  /// Calculate distance between user and branch using Haversine formula
  double? _calculateDistanceToBranch() {
    if (userLatitude == null || userLongitude == null) {
      return null;
    }
  
    return DistanceUtils.calculateDistance(
      userLatitude!,
      userLongitude!,
      branch.location.latitude,
      branch.location.longitude,
    );
  }

  /// Get formatted distance string
  String? _getFormattedDistance() {
    final distance = _calculateDistanceToBranch();
    if (distance == null) return null;
    
    return DistanceUtils.formatDistance(distance, isArabic: isArabic);
  }

  /// Get current day's business hours
  String _getCurrentDayHours() {
    final now = DateTime.now();
    final currentDayOfWeek = now.weekday % 7; // Convert to Sunday=0 format

    final todayHours = branch.getBusinessHoursForDay(currentDayOfWeek);

    if (todayHours == null) {
      return isArabic ? 'غير متوفر' : 'Not available';
    }

    return '${todayHours.openTime} - ${todayHours.closeTime}';
  }

  /// Check if business hours should be displayed
  bool get _shouldShowBusinessHours {
    return branch.hasBusinessHours;
  }

  /// Check if distance should be displayed
  bool get _shouldShowDistance {
    return userLatitude != null && userLongitude != null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedDistance = _getFormattedDistance();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: context.responsive<double>(
          mobile: 200.0,
          tablet: 240.0,
          desktop: 280.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            isDark ? DarkTheme.borderRadiusLarge : LightTheme.borderRadiusLarge,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? DarkTheme.shadowColor : LightTheme.shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            isDark ? DarkTheme.borderRadiusLarge : LightTheme.borderRadiusLarge,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              CachedNetworkImage(
                imageUrl: branch.primaryImage ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: isDark
                      ? DarkTheme.surfaceGray
                      : LightTheme.surfaceGray,
                  child: Center(
                    child: const CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: isDark
                      ? DarkTheme.surfaceGray
                      : LightTheme.surfaceGray,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.image,
                          color: isDark
                              ? DarkTheme.textSecondary
                              : LightTheme.textSecondary,
                          size: context.responsive<double>(
                            mobile: 48,
                            tablet: 56,
                            desktop: 64,
                          ),
                        ),
                        SizedBox(height: context.spacing(8)),
                        Text(
                          isArabic ? 'لا توجد صورة' : 'No Image',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: context.fontSize(12),
                            color: isDark
                                ? DarkTheme.textSecondary
                                : LightTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Gradient overlay
              Container(
                  decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      (isDark ? DarkTheme.textPrimary : LightTheme.textPrimary)
                          .withValues(alpha: 0.6),
                    ],
                  ),
                
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(
                  context.spacing(
                    isDark ? DarkTheme.spacingMedium : LightTheme.spacingMedium,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant name
                    Text(
                      branch.branchName,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: context.fontSize(18),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(
                      height: context.spacing(
                        isDark
                            ? DarkTheme.spacingSmall
                            : LightTheme.spacingSmall,
                      ),
                    ),

                    // Business hours (if available)
                    if (_shouldShowBusinessHours)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: context.spacing(
                            isDark
                                ? DarkTheme.spacingSmall
                                : LightTheme.spacingSmall,
                          ),
                        ),
                        child: Row(
                          textDirection: isArabic
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          children: [
                            Icon(
                              Iconsax.clock,
                              size: context.responsive<double>(
                                mobile: 12,
                                tablet: 14,
                                desktop: 16,
                              ),
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            SizedBox(width: context.spacing(4)),
                            Text(
                              _getCurrentDayHours(),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: context.fontSize(12),
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Info row
                    Row(
                      children: [
                        // Distance from user location (calculated using Haversine formula)
                        if (_shouldShowDistance && formattedDistance != null)
                          _buildInfoChip(
                            context: context,
                            icon: Iconsax.location,
                            iconColor: isDark
                                ? DarkTheme.secondaryColor
                                : LightTheme.secondaryColor,
                            text: formattedDistance,
                          ),

                        // Show rating if distance is not available
                        if (!_shouldShowDistance)
                          _buildInfoChip(
                            context: context,
                            icon: Iconsax.star1,
                            iconColor: isDark
                                ? DarkTheme.secondaryColor
                                : LightTheme.secondaryColor,
                            text: branch.averageRating.toStringAsFixed(1),
                          ),

                        SizedBox(
                          width: context.spacing(
                            isDark
                                ? DarkTheme.spacingMedium
                                : LightTheme.spacingMedium,
                          ),
                        ),

                        // Rating chip (secondary position when distance is shown)
                        if (_shouldShowDistance)
                          _buildInfoChip(
                            context: context,
                            icon: Iconsax.star1,
                            iconColor: Colors.white.withValues(alpha: 0.8),
                            text: branch.averageRating.toStringAsFixed(1),
                          ),

                        const Spacer(),

                        // Open status
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.spacing(
                              isDark
                                  ? DarkTheme.spacingSmall
                                  : LightTheme.spacingSmall,
                            ),
                            vertical: context.spacing(
                              isDark
                                  ? DarkTheme.spacingXSmall
                                  : LightTheme.spacingXSmall,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: branch.isOpenNow
                                ? (isDark
                                          ? DarkTheme.successColor
                                          : LightTheme.successColor)
                                      .withValues(alpha: 0.9)
                                : (isDark
                                          ? DarkTheme.errorColor
                                          : LightTheme.errorColor)
                                      .withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(
                              isDark
                                  ? DarkTheme.borderRadius
                                  : LightTheme.borderRadius,
                            ),
                          ),
                          child: Text(
                            branch.isOpenNow
                                ? (isArabic ? 'مفتوح' : 'Open')
                                : (isArabic ? 'مغلق' : 'Closed'),
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: context.fontSize(10),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Rating badge
            //   Positioned(
            //     top: context.spacing(
            //       isDark ? DarkTheme.spacingMedium : LightTheme.spacingMedium,
            //     ),
            //     left: isArabic
            //         ? null
            //         : context.spacing(
            //             isDark
            //                 ? DarkTheme.spacingMedium
            //                 : LightTheme.spacingMedium,
            //           ),
            //     right: isArabic
            //         ? context.spacing(
            //             isDark
            //                 ? DarkTheme.spacingMedium
            //                 : LightTheme.spacingMedium,
            //           )
            //         : null,
            //     child: Container(
            //       padding: EdgeInsets.symmetric(
            //         horizontal: context.spacing(
            //           isDark
            //               ? DarkTheme.spacingMedium
            //               : LightTheme.spacingMedium,
            //         ),
            //         vertical: context.spacing(
            //           isDark
            //               ? DarkTheme.spacingXSmall
            //               : LightTheme.spacingXSmall,
            //         ),
            //       ),
            //       decoration: BoxDecoration(
            //         color:
            //             (isDark
            //                     ? DarkTheme.primaryColor
            //                     : LightTheme.primaryColor)
            //                 .withValues(alpha: 0.9),
            //         borderRadius: BorderRadius.circular(
            //           isDark ? DarkTheme.borderRadius : LightTheme.borderRadius,
            //         ),
            //       ),
            //       child: Text(
            //         '${branch.totalReviews} ${isArabic ? 'تقييم' : 'reviews'}',
            //         style: TextStyle(
            //           fontFamily: 'Cairo',
            //           fontSize: context.fontSize(12),
            //           fontWeight: FontWeight.w600,
            //           color: Colors.white,
            //         ),
            //       ),
            //     ),
            //   ),
            ]
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: context.responsive<double>(mobile: 14, tablet: 16, desktop: 18),
          color: iconColor,
        ),
        SizedBox(width: context.spacing(4)),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: context.fontSize(12),
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}