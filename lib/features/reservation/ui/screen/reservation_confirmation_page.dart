import 'package:achaytablereservation/app/themes/dark_theme.dart';
import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/core/utils/responsive_utils.dart';
import 'package:achaytablereservation/features/reservation/logic/controller/reservation_confirmation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// Reservation confirmation page displaying all reservation details
/// with a 5-minute countdown timer using GetX controller
class ReservationConfirmationpage
    extends GetView<ReservationConfirmationController> {
  const ReservationConfirmationpage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? DarkTheme.backgroundColor
          : LightTheme.backgroundColor,
      appBar: _buildAppBar(context, isDark),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer Card
            _buildTimerCard(context, isDark),
            SizedBox(height: ResponsiveUtils.spacing(context, 24)),
            // Restaurant Info Card
            _buildRestaurantCard(context, isDark),
            SizedBox(height: ResponsiveUtils.spacing(context, 16)),
            // Reservation Details Card
            _buildReservationDetailsCard(context, isDark),
            SizedBox(height: ResponsiveUtils.spacing(context, 16)),
            // Table Info Card
            _buildTableInfoCard(context, isDark),
            SizedBox(height: ResponsiveUtils.spacing(context, 16)),
            // Policies Card
            _buildPoliciesCard(context, isDark),
            SizedBox(height: ResponsiveUtils.spacing(context, 16)),
            // Price Summary Card
            _buildPriceSummaryCard(context, isDark),
            // Bottom padding for button
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, isDark),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark
          ? DarkTheme.surfaceColor
          : LightTheme.surfaceColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'confirm_reservation'.tr,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: ResponsiveUtils.fontSize(context, 18),
          fontWeight: FontWeight.w600,
          color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTimerCard(BuildContext context, bool isDark) {
    return Obx(() {
      final timerColor = controller.getTimerColor(isDark);
      return Container(
        padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
        decoration: BoxDecoration(
          color: timerColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
          border: Border.all(color: timerColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 12)),
              decoration: BoxDecoration(
                color: timerColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.timer_1,
                color: timerColor,
                size: ResponsiveUtils.value(
                  context,
                  mobile: 28.0,
                  tablet: 32.0,
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing(context, 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'time_remaining'.tr,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: ResponsiveUtils.fontSize(context, 12),
                      color: isDark
                          ? DarkTheme.textSecondary
                          : LightTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.formattedTime,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: ResponsiveUtils.fontSize(context, 28),
                      fontWeight: FontWeight.bold,
                      color: timerColor,
                    ),
                  ),
                ],
              ),
            ),
            if (controller.remainingSeconds.value <= 60)
              Icon(Iconsax.warning_2, color: timerColor, size: 24),
          ],
        ),
      );
    });
  }

  Widget _buildRestaurantCard(BuildContext context, bool isDark) {
    return _buildCard(
      context,
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            context,
            isDark,
            icon: Iconsax.building_4,
            title: 'restaurant_info'.tr,
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 12)),
          Text(
            controller.restaurantInfo?.fullName ??
                controller.restaurantInfo?.branchName ??
                '',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: ResponsiveUtils.fontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
            ),
          ),
          if (controller.restaurantInfo?.address != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Iconsax.location,
                  size: 16,
                  color: isDark
                      ? DarkTheme.textSecondary
                      : LightTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${controller.restaurantInfo!.address}, ${controller.restaurantInfo!.city}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: ResponsiveUtils.fontSize(context, 13),
                      color: isDark
                          ? DarkTheme.textSecondary
                          : LightTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReservationDetailsCard(BuildContext context, bool isDark) {
    return _buildCard(
      context,
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            context,
            isDark,
            icon: Iconsax.calendar_tick,
            title: 'reservation_details'.tr,
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 16)),

          // Date
          _buildDetailRow(
            context,
            isDark,
            icon: Iconsax.calendar,
            label: 'date'.tr,
            value: controller.selectedDateDisplay,
          ),

          _buildDivider(isDark),

          // Hall
          _buildDetailRow(
            context,
            isDark,
            icon: Iconsax.building,
            label: 'hall'.tr,
            value: controller.hallName ?? '',
          ),

          _buildDivider(isDark),

          // Time
          _buildDetailRow(
            context,
            isDark,
            icon: Iconsax.clock,
            label: "time".tr,
            value: controller.selectedTimeSlot?.timeSlot.displayText ?? '',
          ),

          _buildDivider(isDark),

          // Guests
          _buildDetailRow(
            context,
            isDark,
            icon: Iconsax.people,
            label: 'number_of_guests'.tr,
            value: '${controller.guestCount} ${'guests'.tr}',
          ),
        ],
      ),
    );
  }

  Widget _buildTableInfoCard(BuildContext context, bool isDark) {
    final primaryColor = isDark
        ? DarkTheme.secondaryColor
        : LightTheme.primaryColor;

    return _buildCard(
      context,
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            context,
            isDark,
            icon: Iconsax.category,
            title: 'table_information'.tr,
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 16)),

          // Required tables
          _buildDetailRow(
            context,
            isDark,
            icon: Iconsax.element_3,
            label: 'required_tables'.tr,
            value: '${controller.requiredTables}',
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummaryCard(BuildContext context, bool isDark) {
    final primaryColor = isDark
        ? DarkTheme.secondaryColor
        : LightTheme.primaryColor;

    return _buildCard(
      context,
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _buildSectionHeader(
          //   context,
          //   isDark,
          //   icon: Iconsax.money,
          //   title: controller.isArabic ? 'ملخص السعر' : 'Price Summary',
          // ),
          // SizedBox(height: ResponsiveUtils.spacing(context, 16)),
          // // Price per person
          // _buildPriceRow(
          //   context,
          //   isDark,
          //   label: controller.isArabic ? 'السعر للشخص' : 'Price per person',
          //   value:
          //       '${controller.pricePerPerson.toStringAsFixed(0)} ${controller.isArabic ? 'ر.س' : 'SAR'}',
          // ),
          // SizedBox(height: ResponsiveUtils.spacing(context, 8)),
          // // Calculation info
          // _buildPriceRow(
          //   context,
          //   isDark,
          //   label: controller.isArabic
          //       ? 'سعة الطاولة × السعر'
          //       : 'Table capacity × Price',
          //   value:
          //       '${controller.tableCapacity} × ${controller.pricePerPerson.toStringAsFixed(0)}',
          //   isSubtle: true,
          // ),

          // SizedBox(height: ResponsiveUtils.spacing(context, 12)),

          // Container(
          //   height: 1,
          //   color: isDark ? DarkTheme.borderColor : LightTheme.borderColor,
          // ),

          // SizedBox(height: ResponsiveUtils.spacing(context, 12)),

          // Total price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'total_amount'.tr,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: ResponsiveUtils.fontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? DarkTheme.textPrimary
                      : LightTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(LightTheme.borderRadius),
                ),
                child: Text(
                  '${controller.totalPrice.toStringAsFixed(0)} ${'currency'.tr}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: ResponsiveUtils.fontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPoliciesCard(BuildContext context, bool isDark) {
    final warningColor = isDark
        ? DarkTheme.warningColor
        : LightTheme.warningColor;

    return Obx(() {
      // Show loading state
      if (controller.isPoliciesLoading.value) {
        return _buildCard(
          context,
          isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                context,
                isDark,
                icon: Iconsax.document_text,
                title: 'reservation_policies'.tr,
              ),
              SizedBox(height: ResponsiveUtils.spacing(context, 16)),
              Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark
                        ? DarkTheme.secondaryColor
                        : LightTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // Don't show card if no policies
      if (controller.policies.isEmpty) {
        return const SizedBox.shrink();
      }

      return _buildCard(
        context,
        isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              isDark,
              icon: Iconsax.document_text,
              title: "reservation_policies".tr,
            ),
            SizedBox(height: ResponsiveUtils.spacing(context, 16)),

            // Warning notice
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 12)),
              decoration: BoxDecoration(
                color: warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(LightTheme.borderRadius),
                border: Border.all(color: warningColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.warning_2, size: 20, color: warningColor),
                  SizedBox(width: ResponsiveUtils.spacing(context, 8)),
                  Expanded(
                    child: Text(
                      'read_policies'.tr,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: ResponsiveUtils.fontSize(context, 12),
                        color: warningColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: ResponsiveUtils.spacing(context, 12)),

            // Policies list
            ...controller.policies.map(
              (policy) => Padding(
                padding: EdgeInsets.only(
                  bottom: ResponsiveUtils.spacing(context, 8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        top: ResponsiveUtils.spacing(context, 4),
                      ),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDark
                            ? DarkTheme.secondaryColor
                            : LightTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.spacing(context, 10)),
                    Expanded(
                      child: Text(
                        policy.policyText,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: ResponsiveUtils.fontSize(context, 13),
                          color: isDark
                              ? DarkTheme.textSecondary
                              : LightTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTermsCheckbox(BuildContext context, bool isDark) {
    final primaryColor = isDark
        ? DarkTheme.secondaryColor
        : LightTheme.primaryColor;

    return Obx(
      () => _buildCard(
        context,
        isDark,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: controller.isTermsAccepted.value,
                onChanged: controller.toggleTermsAccepted,
                activeColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(
                  color: isDark
                      ? DarkTheme.textSecondary
                      : LightTheme.textSecondary,
                  width: 1.5,
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing(context, 12)),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.toggleTermsAccepted(
                  !controller.isTermsAccepted.value,
                ),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: ResponsiveUtils.fontSize(context, 13),
                      color: isDark
                          ? DarkTheme.textSecondary
                          : LightTheme.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: controller.isArabic
                            ? 'أوافق على '
                            : 'I agree to the ',
                      ),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: controller.showTermsDialog,
                          child: Text(
                            controller.isArabic
                                ? 'الشروط والأحكام'
                                : 'Terms & Conditions',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: ResponsiveUtils.fontSize(context, 13),
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // View terms button
            IconButton(
              onPressed: controller.showTermsDialog,
              icon: Icon(Iconsax.export_3, size: 20, color: primaryColor),
              tooltip: controller.isArabic ? 'عرض الشروط' : 'View Terms',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    bool isDark, {
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
      decoration: BoxDecoration(
        color: isDark ? DarkTheme.cardBackground : LightTheme.cardBackground,
        borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
        border: Border.all(
          color: isDark ? DarkTheme.borderColor : LightTheme.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? DarkTheme.shadowLight : LightTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
  }) {
    final primaryColor = isDark
        ? DarkTheme.secondaryColor
        : LightTheme.primaryColor;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        SizedBox(width: ResponsiveUtils.spacing(context, 12)),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: ResponsiveUtils.fontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.spacing(context, 12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? DarkTheme.textSecondary : LightTheme.textSecondary,
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 12)),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: ResponsiveUtils.fontSize(context, 14),
                color: isDark
                    ? DarkTheme.textSecondary
                    : LightTheme.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: ResponsiveUtils.fontSize(context, 14),
              fontWeight: FontWeight.w600,
              color:
                  valueColor ??
                  (isDark ? DarkTheme.textPrimary : LightTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    bool isDark, {
    required String label,
    required String value,
    bool isSubtle = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: ResponsiveUtils.fontSize(context, isSubtle ? 12 : 14),
            color: isDark
                ? (isSubtle ? DarkTheme.textHint : DarkTheme.textSecondary)
                : (isSubtle ? LightTheme.textHint : LightTheme.textSecondary),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: ResponsiveUtils.fontSize(context, isSubtle ? 12 : 14),
            fontWeight: isSubtle ? FontWeight.normal : FontWeight.w500,
            color: isDark
                ? (isSubtle ? DarkTheme.textHint : DarkTheme.textPrimary)
                : (isSubtle ? LightTheme.textHint : LightTheme.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 1,
      color: (isDark ? DarkTheme.borderColor : LightTheme.borderColor)
          .withValues(alpha: 0.5),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDark) {
    final primaryColor = isDark
        ? DarkTheme.secondaryColor
        : LightTheme.primaryColor;
    final textOnPrimary = isDark
        ? DarkTheme.textOnSecondary
        : LightTheme.textOnPrimary;

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
      decoration: BoxDecoration(
        color: isDark ? DarkTheme.surfaceColor : LightTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: isDark ? DarkTheme.shadowColor : LightTheme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Terms and Conditions Checkbox
            _buildTermsCheckbox(context, isDark),

            SizedBox(height: ResponsiveUtils.spacing(context, 12)),

            // Confirm button
            Obx(() {
              final isEnabled = controller.isTermsAccepted.value;
              return SizedBox(
                width: double.infinity,
                height: LightTheme.buttonHeight,
                child: ElevatedButton(
                  onPressed: isEnabled
                      ? controller.confirmReservation
                      : () {
                          Get.snackbar(
                            controller.isArabic ? 'تنبيه' : 'Notice',
                            controller.isArabic
                                ? 'يرجى الموافقة على الشروط والأحكام للمتابعة'
                                : 'Please accept the Terms & Conditions to proceed',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: isDark? DarkTheme.warningColor.withValues(alpha: 0.9) : LightTheme.warningColor.withValues(
                                    alpha: 0.9,
                                  ),
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 8,
                            icon: const Icon(
                              Iconsax.warning_2,
                              color: Colors.white,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEnabled
                        ? primaryColor
                        : (isDark
                              ? DarkTheme.textHint.withValues(alpha: 0.3)
                              : LightTheme.textHint.withValues(alpha: 0.3)),
                    foregroundColor: isEnabled
                        ? textOnPrimary
                        : (isDark ? DarkTheme.textHint : LightTheme.textHint),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        LightTheme.borderRadius,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.tick_circle,
                        size: 20,
                        color: isEnabled
                            ? textOnPrimary
                            : (isDark
                                  ? DarkTheme.textHint
                                  : LightTheme.textHint),
                      ),
                      SizedBox(width: ResponsiveUtils.spacing(context, 8)),
                      Text(
                        'confirm_reservation'.tr,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: ResponsiveUtils.fontSize(context, 16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
