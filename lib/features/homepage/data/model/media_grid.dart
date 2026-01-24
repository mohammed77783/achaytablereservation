// lib/features/branch_info/presentation/widgets/media_grid.dart

import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/features/homepage/data/model/gallery_photo_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';

import 'package:achaytablereservation/core/utils/responsive_utils.dart';

/// Media grid widget for displaying gallery photos from server
class MediaGrid extends StatelessWidget {
  final List<GalleryPhoto> items;
  final Function(int index) onItemTap;
  final int maxItems;
  final bool isArabic;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const MediaGrid({
    super.key,
    required this.items,
    required this.onItemTap,
    this.maxItems = 6,
    this.isArabic = true,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isArabic ? 'معرض الصور' : 'Gallery',
              style: theme.textTheme.titleMedium,
            ),
            if (!isLoading && items.isNotEmpty)
              Text(
                '${items.length} ${isArabic ? 'صورة' : 'items'}',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),

        SizedBox(
          height: ResponsiveUtils.spacing(context, LightTheme.spacingMedium),
        ),

        // Content based on state
        if (isLoading)
          _buildLoadingState(context)
        else if (errorMessage != null)
          _buildErrorState(context)
        else if (items.isEmpty)
          _buildEmptyState(context)
        else
          _buildGrid(context),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: ResponsiveUtils.spacing(
          context,
          LightTheme.spacingSmall,
        ),
        mainAxisSpacing: ResponsiveUtils.spacing(
          context,
          LightTheme.spacingSmall,
        ),
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: LightTheme.surfaceGray,
            borderRadius: BorderRadius.circular(LightTheme.borderRadius),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.spacing(context, LightTheme.spacingLarge),
      ),
      decoration: BoxDecoration(
        color: LightTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
      ),
      child: Column(
        children: [
          Icon(
            Iconsax.warning_2,
            color: LightTheme.errorColor,
            size: ResponsiveUtils.value(
              context,
              mobile: LightTheme.iconSizeLarge,
              tablet: LightTheme.iconSizeLarge * 1.2,
            ),
          ),
          SizedBox(
            height: ResponsiveUtils.spacing(context, LightTheme.spacingSmall),
          ),
          Text(
            errorMessage ?? (isArabic ? 'حدث خطأ' : 'An error occurred'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: LightTheme.errorColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(
              height: ResponsiveUtils.spacing(
                context,
                LightTheme.spacingMedium,
              ),
            ),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh),
              label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.spacing(context, LightTheme.spacingXLarge),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Iconsax.gallery,
              color: LightTheme.textHint,
              size: ResponsiveUtils.value(
                context,
                mobile: 48.0,
                tablet: 56.0,
                desktop: 64.0,
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.spacing(
                context,
                LightTheme.spacingMedium,
              ),
            ),
            Text(
              isArabic ? 'لا توجد صور' : 'No photos available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: LightTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final displayItems = items.take(maxItems).toList();
    final remainingCount = items.length - maxItems;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: ResponsiveUtils.spacing(
          context,
          LightTheme.spacingSmall,
        ),
        mainAxisSpacing: ResponsiveUtils.spacing(
          context,
          LightTheme.spacingSmall,
        ),
      ),
      itemCount: displayItems.length,
      itemBuilder: (context, index) {
        final item = displayItems[index];
        final isLast = index == displayItems.length - 1 && remainingCount > 0;

        return _buildMediaItem(
          context: context,
          item: item,
          index: index,
          showOverlay: isLast,
          overlayCount: remainingCount,
        );
      },
    );
  }

  /// Get cross axis count based on device type
  int _getCrossAxisCount(BuildContext context) {
    return ResponsiveUtils.value<int>(
      context,
      mobile: 3,
      tablet: 4,
      desktop: 5,
    );
  }

  Widget _buildMediaItem({
    required BuildContext context,
    required GalleryPhoto item,
    required int index,
    bool showOverlay = false,
    int overlayCount = 0,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onItemTap(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LightTheme.borderRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(LightTheme.borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image from server
              CachedNetworkImage(
                imageUrl: item.fileUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: LightTheme.surfaceGray,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: LightTheme.surfaceGray,
                  child: Icon(
                    Iconsax.image,
                    color: LightTheme.textHint,
                    size: LightTheme.iconSizeMedium,
                  ),
                ),
              ),

              // Video play icon
              if (item.isVideo)
                Center(
                  child: Container(
                    width: ResponsiveUtils.value(
                      context,
                      mobile: 40.0,
                      tablet: 48.0,
                    ),
                    height: ResponsiveUtils.value(
                      context,
                      mobile: 40.0,
                      tablet: 48.0,
                    ),
                    decoration: BoxDecoration(
                      color: LightTheme.primaryColor.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.play5,
                      color: LightTheme.textOnPrimary,
                      size: ResponsiveUtils.value(
                        context,
                        mobile: 20.0,
                        tablet: 24.0,
                      ),
                    ),
                  ),
                ),

              // Primary badge

              // Remaining count overlay
              if (showOverlay && overlayCount > 0)
                Container(
                  color: LightTheme.primaryColor.withOpacity(0.7),
                  child: Center(
                    child: Text(
                      '+$overlayCount',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: LightTheme.textOnPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
