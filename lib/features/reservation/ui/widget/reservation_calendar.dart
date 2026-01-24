import 'package:achaytablereservation/features/reservation/logic/class/SelectedTimeSlot.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';
import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/app/themes/dark_theme.dart';
import 'package:achaytablereservation/core/utils/responsive_utils.dart';

/// Custom calendar widget with availability indicators
class ReservationCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final AvailabilityStatus Function(DateTime) getDateStatus;
  final bool Function(DateTime) isDateSelectable;

  ReservationCalendar({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.getDateStatus,
    required this.isDateSelectable,
  });

  bool get isArabic => Get.locale?.languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkTheme.cardBackground : LightTheme.cardBackground,
        borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: isDark ? DarkTheme.shadowLight : LightTheme.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 1)),
        lastDay: DateTime.now().add(const Duration(days: 30)),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        headerStyle: _buildHeaderStyle(context, isDark),
        calendarStyle: _buildCalendarStyle(context, isDark),
        daysOfWeekStyle: _buildDaysOfWeekStyle(context, isDark),
        onDaySelected: (selected, focused) {
          if (isDateSelectable(selected)) {
            onDaySelected(selected);
          }
        },
        onPageChanged: onPageChanged,
        enabledDayPredicate: isDateSelectable,
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focused) =>
              _buildDayCell(context, isDark, day, focused),
          selectedBuilder: (context, day, focused) =>
              _buildSelectedDayCell(context, isDark, day, focused),
          todayBuilder: (context, day, focused) =>
              _buildTodayCell(context, isDark, day, focused),
          disabledBuilder: (context, day, focused) =>
              _buildDisabledDayCell(context, isDark, day, focused),
        ),
      ),
    );
  }

  HeaderStyle _buildHeaderStyle(BuildContext context, bool isDark) {
    final primaryColor = isDark
        ? DarkTheme.secondaryColor
        : LightTheme.primaryColor;
    final textPrimary = isDark ? DarkTheme.textPrimary : LightTheme.textPrimary;

    return HeaderStyle(
      formatButtonVisible: false,
      titleCentered: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: ResponsiveUtils.fontSize(context, 16),
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      leftChevronIcon: Icon(Icons.chevron_left, color: primaryColor),
      rightChevronIcon: Icon(Icons.chevron_right, color: primaryColor),
      headerPadding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.spacing(context, 12),
      ),
    );
  }

  CalendarStyle _buildCalendarStyle(BuildContext context, bool isDark) {
    final primaryColor = isDark
        ? DarkTheme.secondaryColor
        : LightTheme.primaryColor;
    final textPrimary = isDark ? DarkTheme.textPrimary : LightTheme.textPrimary;
    final textHint = isDark ? DarkTheme.textHint : LightTheme.textHint;

    return CalendarStyle(
      outsideDaysVisible: false,
      weekendTextStyle: TextStyle(fontFamily: 'Cairo', color: textPrimary),
      defaultTextStyle: TextStyle(fontFamily: 'Cairo', color: textPrimary),
      todayDecoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      todayTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      selectedDecoration: BoxDecoration(
        color: primaryColor,
        shape: BoxShape.circle,
      ),
      selectedTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.w600,
        color: isDark ? DarkTheme.textOnSecondary : LightTheme.textOnPrimary,
      ),
      disabledTextStyle: TextStyle(fontFamily: 'Cairo', color: textHint),
      cellMargin: const EdgeInsets.all(4),
    );
  }

  DaysOfWeekStyle _buildDaysOfWeekStyle(BuildContext context, bool isDark) {
    final textSecondary = isDark
        ? DarkTheme.textSecondary
        : LightTheme.textSecondary;

    return DaysOfWeekStyle(
      weekdayStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: ResponsiveUtils.fontSize(context, 12),
        fontWeight: FontWeight.w600,
        color: textSecondary,
      ),
      weekendStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: ResponsiveUtils.fontSize(context, 12),
        fontWeight: FontWeight.w600,
        color: textSecondary,
      ),
    );
  }

  Widget? _buildDayCell(
    BuildContext context,
    bool isDark,
    DateTime day,
    DateTime focused,
  ) {
    final status = getDateStatus(day);
    return _buildDayCellContent(context, isDark, day, status, false, false);
  }

  Widget? _buildSelectedDayCell(
    BuildContext context,
    bool isDark,
    DateTime day,
    DateTime focused,
  ) {
    return _buildDayCellContent(
      context,
      isDark,
      day,
      AvailabilityStatus.available,
      true,
      false,
    );
  }

  Widget? _buildTodayCell(
    BuildContext context,
    bool isDark,
    DateTime day,
    DateTime focused,
  ) {
    final status = getDateStatus(day);
    final isSelected = isSameDay(selectedDay, day);
    return _buildDayCellContent(context, isDark, day, status, isSelected, true);
  }

  Widget? _buildDisabledDayCell(
    BuildContext context,
    bool isDark,
    DateTime day,
    DateTime focused,
  ) {
    return _buildDayCellContent(
      context,
      isDark,
      day,
      AvailabilityStatus.unavailable,
      false,
      false,
    );
  }

  Widget _buildDayCellContent(
    BuildContext context,
    bool isDark,
    DateTime day,
    AvailabilityStatus status,
    bool isSelected,
    bool isToday,
  ) {
    final primaryColor = isDark
        ? DarkTheme.secondaryColor
        : LightTheme.primaryColor;
    final textPrimary = isDark ? DarkTheme.textPrimary : LightTheme.textPrimary;
    final textHint = isDark ? DarkTheme.textHint : LightTheme.textHint;
    final successColor = isDark
        ? DarkTheme.successColor
        : LightTheme.successColor;

    // Determine dot color for availability indicator
    Color? dotColor;
    if (!isSelected && status == AvailabilityStatus.available) {
      dotColor = successColor;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: ResponsiveUtils.value(context, mobile: 40.0, tablet: 48.0),
            height: ResponsiveUtils.value(context, mobile: 40.0, tablet: 48.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor
                  : isToday
                  ? primaryColor.withValues(alpha: 0.2)
                  : null,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: ResponsiveUtils.fontSize(context, 14),
                  fontWeight: isSelected || isToday
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: isSelected
                      ? (isDark
                            ? DarkTheme.textOnSecondary
                            : LightTheme.textOnPrimary)
                      : status == AvailabilityStatus.unavailable
                      ? textHint
                      : textPrimary,
                ),
              ),
            ),
          ),
          // Availability dot (متاح indicator)
          if (dotColor != null)
            Positioned(
              bottom: ResponsiveUtils.value(context, mobile: 4.0, tablet: 6.0),
              child: Container(
                width: ResponsiveUtils.value(context, mobile: 5.0, tablet: 6.0),
                height: ResponsiveUtils.value(
                  context,
                  mobile: 5.0,
                  tablet: 6.0,
                ),
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
