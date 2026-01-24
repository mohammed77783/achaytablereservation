import 'package:achaytablereservation/features/reservation/logic/class/SelectedTimeSlot.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/app/themes/dark_theme.dart';
import 'package:achaytablereservation/core/utils/responsive_utils.dart';
import 'package:achaytablereservation/features/reservation/data/models/reservation_models.dart';

/// Grid widget for displaying time slots grouped by hall
class TimeSlotGrid extends StatelessWidget {
  final Map<String, List<TimeSlot>> groupedSlots;
  final SelectedTimeSlot? selectedSlot;
  final Function(TimeSlot slot, String hallName) onSlotSelected;

  const TimeSlotGrid({
    super.key,
    required this.groupedSlots,
    this.selectedSlot,
    required this.onSlotSelected,
  });

  bool get isArabic => Get.locale?.languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (groupedSlots.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedSlots.entries.map((entry) {
        return _buildHallSection(context, isDark, entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 24)),
      decoration: BoxDecoration(
        color: isDark ? DarkTheme.cardBackground : LightTheme.cardBackground,
        borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
        border: Border.all(
          color: isDark ? DarkTheme.borderColor : LightTheme.borderColor,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.calendar_remove,
            size: ResponsiveUtils.value(context, mobile: 48.0, tablet: 56.0),
            color: isDark ? DarkTheme.textHint : LightTheme.textHint,
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 12)),
          Text(
            isArabic
                ? 'لا توجد أوقات متاحة لهذا التاريخ'
                : 'No available times for this date',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: ResponsiveUtils.fontSize(context, 14),
              color: isDark
                  ? DarkTheme.textSecondary
                  : LightTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 8)),
          Text(
            isArabic ? 'يرجى اختيار تاريخ آخر' : 'Please select another date',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: ResponsiveUtils.fontSize(context, 12),
              color: isDark ? DarkTheme.textHint : LightTheme.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHallSection(
    BuildContext context,
    bool isDark,
    String hallName,
    List<TimeSlot> slots,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hall name header
        Padding(
          padding: EdgeInsets.only(
            bottom: ResponsiveUtils.spacing(context, 8),
            top: ResponsiveUtils.spacing(context, 12),
          ),
          child: Row(
            children: [
              Icon(
                Iconsax.building,
                size: ResponsiveUtils.value(
                  context,
                  mobile: 16.0,
                  tablet: 18.0,
                ),
                color: isDark
                    ? DarkTheme.textSecondary
                    : LightTheme.textSecondary,
              ),
              SizedBox(width: ResponsiveUtils.spacing(context, 4)),
              Text(
                hallName,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: ResponsiveUtils.fontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? DarkTheme.textSecondary
                      : LightTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Time slots grid
        Wrap(
          spacing: ResponsiveUtils.spacing(context, 8),
          runSpacing: ResponsiveUtils.spacing(context, 8),
          children: slots.map((slot) {
            return _buildTimeSlotChip(context, isDark, slot, hallName);
          }).toList(),
        ),

        SizedBox(height: ResponsiveUtils.spacing(context, 12)),
      ],
    );
  }

  Widget _buildTimeSlotChip(
    BuildContext context,
    bool isDark,
    TimeSlot slot,
    String hallName,
  ) {
    final isSelected =
        selectedSlot != null &&
        selectedSlot!.timeSlot.time == slot.time &&
        selectedSlot!.hall.hallName == hallName;

    final isAvailable = slot.isAvailable;

    // Colors based on state
    final primaryColor = isDark
        ? DarkTheme.secondaryColor
        : LightTheme.primaryColor;
    final surfaceColor = isDark
        ? DarkTheme.cardBackground
        : LightTheme.cardBackground;
    final borderColor = isDark ? DarkTheme.borderColor : LightTheme.borderColor;
    final textPrimary = isDark ? DarkTheme.textPrimary : LightTheme.textPrimary;
    final textHint = isDark ? DarkTheme.textHint : LightTheme.textHint;
    final successColor = isDark
        ? DarkTheme.successColor
        : LightTheme.successColor;

    return GestureDetector(
      onTap: isAvailable ? () => onSlotSelected(slot, hallName) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.spacing(context, 12),
          vertical: ResponsiveUtils.spacing(context, 8),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : isAvailable
              ? surfaceColor
              : borderColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(LightTheme.borderRadius),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : isAvailable
                ? borderColor
                : borderColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Time display
            Text(
              slot.displayText,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: ResponsiveUtils.fontSize(context, 14),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? (isDark
                          ? DarkTheme.textOnSecondary
                          : LightTheme.textOnPrimary)
                    : isAvailable
                    ? textPrimary
                    : textHint,
              ),
            ),

            // Availability indicator
            if (isAvailable && !isSelected) ...[
              SizedBox(height: ResponsiveUtils.spacing(context, 2)),
              Text(
                isArabic ? 'متاح' : 'Available',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: ResponsiveUtils.fontSize(context, 10),
                  color: successColor,
                ),
              ),
            ],

            if (!isAvailable) ...[
              SizedBox(height: ResponsiveUtils.spacing(context, 2)),
              Text(
                isArabic ? 'غير متاح' : 'Unavailable',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: ResponsiveUtils.fontSize(context, 10),
                  color: textHint,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading widget for time slots
class TimeSlotsShimmer extends StatelessWidget {
  const TimeSlotsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDark
        ? DarkTheme.borderColor
        : LightTheme.borderColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fake hall header
        Container(
          width: 100,
          height: 16,
          decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, 12)),

        // Fake time slots
        Wrap(
          spacing: ResponsiveUtils.spacing(context, 8),
          runSpacing: ResponsiveUtils.spacing(context, 8),
          children: List.generate(8, (index) {
            return Container(
              width: ResponsiveUtils.value(
                context,
                mobile: 80.0,
                tablet: 100.0,
              ),
              height: ResponsiveUtils.value(
                context,
                mobile: 50.0,
                tablet: 60.0,
              ),
              decoration: BoxDecoration(
                color: shimmerColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(LightTheme.borderRadius),
              ),
            );
          }),
        ),
      ],
    );
  }
}
