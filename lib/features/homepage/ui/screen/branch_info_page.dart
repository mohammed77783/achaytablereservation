// lib/features/branch_info/presentation/pages/branch_info_page.dart

import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/features/homepage/data/model/media_grid.dart';
import 'package:achaytablereservation/features/homepage/logic/branch_info_controller.dart';
import 'package:achaytablereservation/features/homepage/ui/screen/MediaViewer.dart';
import 'package:achaytablereservation/features/homepage/ui/widget/branch_header.dart';
import 'package:achaytablereservation/features/homepage/ui/widget/primary_button.dart';
import 'package:achaytablereservation/features/homepage/ui/widget/business_hours_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';

import 'package:achaytablereservation/core/utils/responsive_utils.dart';

/// Branch info page with restaurant details
class BranchInfoPage extends GetView<BranchInfoController> {
  const BranchInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show media viewer if open
      if (controller.isMediaViewerOpen.value) {
        return MediaViewer(
          items: controller.mediaItems,
          initialIndex: controller.selectedMediaIndex.value,
          onClose: controller.closeMediaViewer,
        );
      }
      return Scaffold(
        backgroundColor: LightTheme.backgroundColor,
        body: _buildBody(context),
        bottomNavigationBar: _buildBottomBar(context),
      );
    });
  }

  Widget _buildBody(BuildContext context) {
    final branch = controller.branch.value;
    final theme = Theme.of(context);

    if (branch == null) {
      return Center(
        child: const CircularProgressIndicator(color: Colors.black),
      );
    }

    // Responsive app bar height
    final appBarExpandedHeight = ResponsiveUtils.value<double>(
      context,
      mobile: 250.0,
      tablet: 300.0,
      desktop: 350.0,
    );

    return CustomScrollView(
      slivers: [
        // Collapsing app bar with image
        SliverAppBar(
          expandedHeight: appBarExpandedHeight,
          pinned: true,
          backgroundColor: LightTheme.surfaceColor,
          leading: _buildBackButton(context),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Use primary image from gallery or branch
                Obx(() {
                  final imageUrl =
                      controller.primaryImageUrl ?? branch.primaryImage ?? '';
                  return CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: LightTheme.surfaceGray),
                    errorWidget: (context, url, error) => Container(
                      color: LightTheme.surfaceGray,
                      child: Icon(
                        Iconsax.image,
                        color: LightTheme.textHint,
                        size: ResponsiveUtils.value(
                          context,
                          mobile: 48.0,
                          tablet: 64.0,
                        ),
                      ),
                    ),
                  );
                }),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        LightTheme.primaryDark.withOpacity(0.3),
                        Colors.transparent,
                        LightTheme.primaryDark.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Container(
            color: LightTheme.surfaceColor,
            child: Padding(
              padding: EdgeInsets.all(
                ResponsiveUtils.spacing(context, LightTheme.spacingMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Branch header
                  BranchHeader(branch: branch, isArabic: controller.isArabic),

                  SizedBox(
                    height: ResponsiveUtils.spacing(
                      context,
                      LightTheme.spacingXLarge,
                    ),
                  ),

                  // Media grid with loading/error states
                  Obx(
                    () => MediaGrid(
                      items: controller.galleryPhotos,
                      isArabic: controller.isArabic,
                      isLoading: controller.isLoadingGallery.value,
                      errorMessage: controller.galleryError.value,
                      onRetry: controller.retryFetchGallery,
                      onItemTap: controller.openMediaViewer,
                    ),
                  ),

                  SizedBox(
                    height: ResponsiveUtils.spacing(
                      context,
                      LightTheme.spacingXLarge,
                    ),
                  ),

                  // Business hours section
                  Obx(
                    () => BusinessHoursWidget(
                      businessHours: controller.businessHours,
                      isExpanded: controller.isBusinessHoursExpanded.value,
                      isLoading: controller.isLoadingBusinessHours.value,
                      errorMessage: controller.businessHoursError.value,
                      isArabic: controller.isArabic,
                      onToggle: controller.toggleBusinessHours,
                      onRetry: controller.retryFetchBusinessHours,
                    ),
                  ),

                  // Bottom padding for button
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(
        ResponsiveUtils.spacing(context, LightTheme.spacingSmall),
      ),
      child: GestureDetector(
        onTap: controller.goBack,
        child: Container(
          decoration: BoxDecoration(
            color: LightTheme.primaryColor.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Iconsax.arrow_right_3,
            color: LightTheme.textOnPrimary,
            size: LightTheme.iconSizeMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.spacing(context, LightTheme.spacingMedium),
      ),
      decoration: BoxDecoration(
        color: LightTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: LightTheme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: PrimaryButton(
          text: controller.isArabic ? 'احجز طاولة' : 'Reserve a Table',
          icon: Iconsax.calendar_add,
          onPressed: controller.navigateToReservation,
        ),
      ),
    );
  }
}
