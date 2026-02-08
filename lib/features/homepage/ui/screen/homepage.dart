import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../app/themes/light_theme.dart';
import '../../../../app/themes/dark_theme.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../logic/homepage_controller.dart';
import '../widget/branch_card.dart';
import '../widget/location_selector.dart';
import '../widget/home_app_bar.dart';

/// Main homepage widget that displays user profile, branches, and location selector
///
/// Requirements implemented:
/// - 8.1: Main scaffold with proper layout using existing themes
/// - 8.2: Integrate ProfileHeader, BranchCard list, and LocationSelector
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Get.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: isDark
          ? DarkTheme.backgroundColor
          : LightTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Obx(() {
          // Show loading state during initial load
          if (controller.isInitialLoading) {
            return _buildLoadingState(context, isDark);
          }

          // Show error state if there's an error
          if (controller.hasError.value) {
            return _buildErrorState(context, controller, isDark);
          }

          // Show main content
          return _buildMainContent(context, controller, isDark, isArabic);
        }),
      ),
    );
  }

  /// Builds the app bar with profile and location
  PreferredSizeWidget _buildAppBar() {
    final controller = Get.find<HomeController>();
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Obx(
        () => HomeAppBar(
          userName: controller.user.value?.fullName ?? 'Guest',
          userAvatarUrl: null, // UserModel doesn't have profilePicture property
          locationText: controller.selectedLocation.value,
          onProfileTap: controller.navigateToProfile,
          onLocationTap: _showLocationSelector,
        ),
      ),
    );
  }

  /// Builds the main content with profile header and branches
  Widget _buildMainContent(
    BuildContext context,
    HomeController controller,
    bool isDark,
    bool isArabic,
  ) {
    return RefreshIndicator(
      onRefresh: controller.refreshBranches,
      color: isDark ? DarkTheme.primaryColor : LightTheme.primaryColor,
      child: CustomScrollView(
        slivers: [
          // Section title
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing(
                  isDark ? DarkTheme.spacingMedium : LightTheme.spacingMedium,
                ),
                vertical: context.spacing(
                  isDark ? DarkTheme.spacingSmall : LightTheme.spacingSmall,
                ),
              ),
              child: Text(
                "Available_Branches".tr,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: context.fontSize(20),
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? DarkTheme.textPrimary
                      : LightTheme.textPrimary,
                ),
              ),
            ),
          ),

          // Branches list
          Obx(() {
            if (controller.isLoadingBranches.value) {
              return SliverToBoxAdapter(
                child: _buildBranchesLoadingState(context, isDark),
              );
            }
            if (controller.branches.isEmpty) {
              return SliverToBoxAdapter(
                child: _buildEmptyState(context, isDark),
              );
            }
            return SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing(
                  isDark ? DarkTheme.spacingMedium : LightTheme.spacingMedium,
                ),
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final branch = controller.branches[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: context.spacing(
                        isDark
                            ? DarkTheme.spacingMedium
                            : LightTheme.spacingMedium,
                      ),
                    ),
                    child: BranchCard(
                      branch: branch,
                      onTap: () => controller.navigateToBranchInfo(branch),
                      isArabic: isArabic,
                      // Pass user's current location for distance calculation
                      userLatitude: controller.userLatitude.value,
                      userLongitude: controller.userLongitude.value,
                    ),
                  );
                }, childCount: controller.branches.length),
              ),
            );
          }),

          // Bottom padding
          SliverToBoxAdapter(
            child: SizedBox(
              height: context.spacing(
                isDark ? DarkTheme.spacingLarge : LightTheme.spacingLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows the location selector bottom sheet
  void _showLocationSelector() {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? DarkTheme.surfaceColor
              : LightTheme.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: LocationSelector(
          currentLocation: Get.find<HomeController>().selectedLocation.value,
          onLocationSelected: Get.find<HomeController>().updateLocation,
        ),
      ),
    );
  }

  /// Builds loading state for initial data load
  Widget _buildLoadingState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.black,
          ),
          SizedBox(
            height: context.spacing(
              isDark ? DarkTheme.spacingMedium : LightTheme.spacingMedium,
            ),
          ),
          Text(
            'loading'.tr,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: context.fontSize(16),
              color: isDark
                  ? DarkTheme.textSecondary
                  : LightTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds loading state for branches
  Widget _buildBranchesLoadingState(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(
        context.spacing(
          isDark ? DarkTheme.spacingMedium : LightTheme.spacingMedium,
        ),
      ),
      child: Center(
        child: const CircularProgressIndicator(
          color: Colors.black,
        ),
      ),
    );
  }

  /// Builds error state with retry functionality
  Widget _buildErrorState(
    BuildContext context,
    HomeController controller,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          context.spacing(
            isDark ? DarkTheme.spacingLarge : LightTheme.spacingLarge,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.warning_2,
              size: context.responsive<double>(
                mobile: 64,
                tablet: 80,
                desktop: 96,
              ),
              color: isDark ? DarkTheme.errorColor : LightTheme.errorColor,
            ),
            SizedBox(
              height: context.spacing(
                isDark ? DarkTheme.spacingMedium : LightTheme.spacingMedium,
              ),
            ),
            Text(
              "something_went_wrong".tr,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: context.fontSize(18),
                fontWeight: FontWeight.w600,
                color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
              ),
            ),
            SizedBox(
              height: context.spacing(
                isDark ? DarkTheme.spacingSmall : LightTheme.spacingSmall,
              ),
            ),
            Obx(
              () => Text(
                controller.errorMessage.value.isNotEmpty
                    ? controller.errorMessage.value
                    : "try_again".tr,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: context.fontSize(14),
                  color: isDark
                      ? DarkTheme.textSecondary
                      : LightTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: context.spacing(
                isDark ? DarkTheme.spacingLarge : LightTheme.spacingLarge,
              ),
            ),
            ElevatedButton(
              onPressed: controller.retryLoadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? DarkTheme.primaryColor
                    : LightTheme.primaryColor,
                foregroundColor: isDark
                    ? DarkTheme.textOnPrimary
                    : LightTheme.textOnPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing(
                    isDark ? DarkTheme.spacingLarge : LightTheme.spacingLarge,
                  ),
                  vertical: context.spacing(
                    isDark ? DarkTheme.spacingMedium : LightTheme.spacingMedium,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    isDark ? DarkTheme.borderRadius : LightTheme.borderRadius,
                  ),
                ),
              ),
              child: Text(
                'retry'.tr,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: context.fontSize(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds empty state when no branches are available
  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(
        context.spacing(
          isDark ? DarkTheme.spacingLarge : LightTheme.spacingLarge,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.shop,
              size: context.responsive<double>(
                mobile: 64,
                tablet: 80,
                desktop: 96,
              ),
              color: isDark
                  ? DarkTheme.textSecondary
                  : LightTheme.textSecondary,
            ),
            SizedBox(
              height: context.spacing(
                isDark ? DarkTheme.spacingMedium : LightTheme.spacingMedium,
              ),
            ),
            Text(
              "No_branches".tr,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: context.fontSize(18),
                fontWeight: FontWeight.w600,
                color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
              ),
            ),
            SizedBox(
              height: context.spacing(
                isDark ? DarkTheme.spacingSmall : LightTheme.spacingSmall,
              ),
            ),
            Text(
              "No_branches1".tr,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: context.fontSize(14),
                color: isDark
                    ? DarkTheme.textSecondary
                    : LightTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
