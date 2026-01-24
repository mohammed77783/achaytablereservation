import 'package:achaytablereservation/app/themes/dark_theme.dart';
import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/features/reservation/logic/controller/reservation_controller.dart';
import 'package:achaytablereservation/features/reservation/ui/widget/price_display_with_capacity.dart';
import 'package:achaytablereservation/features/reservation/ui/widget/reservation_calendar.dart';
import 'package:achaytablereservation/features/reservation/ui/widget/time_slot_grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:achaytablereservation/core/utils/responsive_utils.dart';

/// Reservation page for selecting date, time, and guests
class ReservationPage extends GetView<ReservationController> {
  const ReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? DarkTheme.backgroundColor
          : LightTheme.backgroundColor,
      appBar: _buildAppBar(context, isDark),
      body: Obx(() {
        // Show initial loading state
        if (controller.isInitialLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark
                  ? DarkTheme.secondaryColor
                  : LightTheme.secondaryColor,
            ),
          );
        }
        // Show error state with retry
        if (controller.errorMessage.value != null &&
            controller.groupedTimeSlots.isEmpty) {
          return _buildErrorState(context, isDark);
        }
        return _buildBody(context, isDark);
      }),
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
        controller.isArabic ? 'احجز طاولة' : 'Reserve a Table',
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: ResponsiveUtils.fontSize(context, 18),
          fontWeight: FontWeight.w600,
          color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.warning_2,
              size: ResponsiveUtils.value(context, mobile: 64.0, tablet: 80.0),
              color: isDark ? DarkTheme.errorColor : LightTheme.errorColor,
            ),
            SizedBox(height: ResponsiveUtils.spacing(context, 24)),
            Text(
              controller.errorMessage.value ?? '',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: ResponsiveUtils.fontSize(context, 16),
                color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.spacing(context, 32)),
            ElevatedButton.icon(
              onPressed: controller.retry,
              icon: const Icon(Iconsax.refresh),
              label: Text(
                'retry'.tr,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? DarkTheme.secondaryColor
                    : LightTheme.primaryColor,
                foregroundColor: isDark
                    ? DarkTheme.textOnSecondary
                    : LightTheme.textOnPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.spacing(context, 24),
                  vertical: ResponsiveUtils.spacing(context, 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant name
          _buildRestaurantInfo(context, isDark),
          SizedBox(height: ResponsiveUtils.spacing(context, 24)),
          // Select date section
          _buildSectionTitle(
            context,
            isDark,
            icon: Iconsax.calendar,
            title: 'select_date'.tr,
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 12)),
          // Calendar
          Obx(
            () => ReservationCalendar(
              focusedDay: controller.focusedDate.value,
              selectedDay: controller.selectedDate.value,
              onDaySelected: controller.selectDate,
              onPageChanged: (date) => controller.focusedDate.value = date,
              getDateStatus: controller.getDateStatus,
              isDateSelectable: controller.isDateSelectable,
            ),
          ),

          SizedBox(height: ResponsiveUtils.spacing(context, 12)),

          // Legend
          _buildLegend(context, isDark),

          SizedBox(height: ResponsiveUtils.spacing(context, 32)),

          // Select time section (only show if date selected)
          Obx(() {
            if (controller.selectedDate.value == null) {
              return _buildSelectDatePrompt(context, isDark);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(
                  context,
                  isDark,
                  icon: Iconsax.clock,
                  title: "select_time".tr,
                ),

                SizedBox(height: ResponsiveUtils.spacing(context, 12)),

                // Error message for time slots
                Obx(() {
                  if (controller.errorMessage.value != null) {
                    return _buildInlineError(context, isDark);
                  }
                  return const SizedBox.shrink();
                }),

                // Time slots
                Obx(() {
                  if (controller.isLoadingSlots.value) {
                    return Padding(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.spacing(context, 24),
                      ),
                      child: const TimeSlotsShimmer(),
                    );
                  }

                  return TimeSlotGrid(
                    groupedSlots: controller.groupedTimeSlots,
                    selectedSlot: controller.selectedTimeSlot.value,
                    onSlotSelected: controller.selectTimeSlot,
                  );
                }),
                SizedBox(height: ResponsiveUtils.spacing(context, 32)),
                // Price section (only show if time slot selected)
                Obx(() {
                  if (controller.selectedTimeSlot.value == null) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(
                        context,
                        isDark,
                        icon: Iconsax.money,
                        title: controller.isArabic ? 'التفاصيل' : 'Details',
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, 12)),
                      Obx(
                        () => PriceDisplayWithCapacity(
                          pricePerPerson: controller.pricePerPerson,
                          guestCount: controller.guestCount.value,
                          tableCapacity: controller.tableCapacity,
                          totalPrice: controller.totalPrice,
                          onIncreaseGuests: controller.increaseGuests,
                          onDecreaseGuests: controller.decreaseGuests,
                          minGuests: controller.minGuests,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            );
          }),

          // Bottom padding for button
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSelectDatePrompt(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 24)),
      decoration: BoxDecoration(
        color: isDark ? DarkTheme.cardBackground : LightTheme.cardBackground,
        borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
        border: Border.all(
          color: isDark ? DarkTheme.borderColor : LightTheme.borderColor,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.calendar_tick,
            size: ResponsiveUtils.value(context, mobile: 32.0, tablet: 40.0),
            color: (isDark ? DarkTheme.primaryColor : LightTheme.primaryColor)
                .withValues(alpha: 0.5),
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 12)),
          Expanded(
            child: Text(
              'select_date_message'.tr,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: ResponsiveUtils.fontSize(context, 14),
                color: isDark
                    ? DarkTheme.textSecondary
                    : LightTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineError(BuildContext context, bool isDark) {
    final errorColor = isDark ? DarkTheme.errorColor : LightTheme.errorColor;

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.spacing(context, 12)),
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 12)),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(LightTheme.borderRadius),
        border: Border.all(color: errorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.warning_2, size: 20, color: errorColor),
          SizedBox(width: ResponsiveUtils.spacing(context, 8)),
          Expanded(
            child: Text(
              controller.errorMessage.value ?? '',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: ResponsiveUtils.fontSize(context, 12),
                color: errorColor,
              ),
            ),
          ),
          GestureDetector(
            onTap: controller.retry,
            child: Icon(Iconsax.refresh, size: 20, color: errorColor),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantInfo(BuildContext context, bool isDark) {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
        decoration: BoxDecoration(
          color: isDark ? DarkTheme.cardBackground : LightTheme.cardBackground,
          borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
          border: Border.all(
            color: isDark ? DarkTheme.borderColor : LightTheme.borderColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.building_4,
              color: isDark ? DarkTheme.primaryLight : LightTheme.primaryColor,
              size: ResponsiveUtils.value(context, mobile: 24.0, tablet: 28.0),
            ),
            SizedBox(width: ResponsiveUtils.spacing(context, 12)),
            Expanded(
              child: Text(
                controller.displayName,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: ResponsiveUtils.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? DarkTheme.textPrimary
                      : LightTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: ResponsiveUtils.fontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
          ),
        ),

        SizedBox(width: ResponsiveUtils.spacing(context, 8)),

        Icon(
          icon,
          color: isDark ? DarkTheme.primaryLight : LightTheme.primaryColor,
          size: ResponsiveUtils.value(context, mobile: 20.0, tablet: 24.0),
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          context,
          isDark,
          color: isDark ? DarkTheme.successColor : LightTheme.successColor,
          label: 'available'.tr,
        ),
        SizedBox(width: ResponsiveUtils.spacing(context, 24)),
        _buildLegendItem(
          context,
          isDark,
          color: isDark ? DarkTheme.textHint : LightTheme.textHint,
          label: 'unavailable'.tr,
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    bool isDark, {
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: ResponsiveUtils.value(context, mobile: 10.0, tablet: 12.0),
          height: ResponsiveUtils.value(context, mobile: 10.0, tablet: 12.0),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: ResponsiveUtils.spacing(context, 6)),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: ResponsiveUtils.fontSize(context, 12),
            color: isDark ? DarkTheme.textSecondary : LightTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDark) {
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
        child: Obx(() {
          final canProceed = controller.canProceed;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show selection summary
              if (controller.selectedTimeSlot.value != null) ...[
                _buildSelectionSummary(context, isDark),
                SizedBox(height: ResponsiveUtils.spacing(context, 12)),
              ],

              // Continue button
              SizedBox(
                width: double.infinity,
                height: LightTheme.buttonHeight,
                child: Obx(() {
                  final isChecking = controller.isCheckingAvailability.value;

                  return ElevatedButton(
                    onPressed: canProceed && !isChecking
                        ? controller.navigateToConfirmation
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canProceed
                          ? (isDark
                                ? DarkTheme.secondaryColor
                                : LightTheme.primaryColor)
                          : (isDark
                                ? DarkTheme.borderColor
                                : LightTheme.borderColor),
                      foregroundColor: canProceed
                          ? (isDark
                                ? DarkTheme.textOnSecondary
                                : LightTheme.textOnPrimary)
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
                        Text(
                          'continue_booking'.tr,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: ResponsiveUtils.fontSize(context, 16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.spacing(context, 8)),
                        Icon(
                          controller.isArabic
                              ? Iconsax.arrow_left_2
                              : Iconsax.arrow_right_3,
                          size: 20,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSelectionSummary(BuildContext context, bool isDark) {
    final successColor = isDark
        ? DarkTheme.successColor
        : LightTheme.successColor;

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 8)),
      decoration: BoxDecoration(
        color: successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(LightTheme.borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Date
          _buildSummaryItem(
            context,
            isDark,
            icon: Iconsax.calendar,
            value: _formatSelectedDate(),
          ),

          Container(
            width: 1,
            height: 20,
            color: isDark ? DarkTheme.borderColor : LightTheme.borderColor,
          ),

          // Time
          _buildSummaryItem(
            context,
            isDark,
            icon: Iconsax.clock,
            value:
                controller.selectedTimeSlot.value?.timeSlot.displayText ?? '',
          ),

          Container(
            width: 1,
            height: 20,
            color: isDark ? DarkTheme.borderColor : LightTheme.borderColor,
          ),

          // Guests
          _buildSummaryItem(
            context,
            isDark,
            icon: Iconsax.people,
            value: '${controller.guestCount.value}',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String value,
  }) {
    final successColor = isDark
        ? DarkTheme.successColor
        : LightTheme.successColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: successColor),
        SizedBox(width: ResponsiveUtils.spacing(context, 4)),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: ResponsiveUtils.fontSize(context, 12),
            fontWeight: FontWeight.w600,
            color: successColor,
          ),
        ),
      ],
    );
  }

  String _formatSelectedDate() {
    final date = controller.selectedDate.value;
    if (date == null) return '';

    final day = date.day;
    final month = date.month;

    if (controller.isArabic) {
      return '$day/$month';
    }
    return '$month/$day';
  }
}
