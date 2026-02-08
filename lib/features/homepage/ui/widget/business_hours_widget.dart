import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/core/utils/responsive_utils.dart';
import 'package:achaytablereservation/features/homepage/data/model/business_hour_model.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Expandable widget to display restaurant business hours
class BusinessHoursWidget extends StatelessWidget {
  final List<BusinessHour> businessHours;
  final bool isExpanded;
  final bool isLoading;
  final String? errorMessage;
  final bool isArabic;
  final VoidCallback onToggle;
  final VoidCallback? onRetry;

  const BusinessHoursWidget({
    super.key,
    required this.businessHours,
    required this.isExpanded,
    required this.isLoading,
    required this.isArabic,
    required this.onToggle,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LightTheme.surfaceColor,
        borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
        border: Border.all(color: LightTheme.borderColor),
      ),
      child: Column(
        children: [
          // Header - Always visible
          _buildHeader(context),
          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildContent(context),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
      child: Padding(
        padding: EdgeInsets.all(
          ResponsiveUtils.spacing(context, LightTheme.spacingMedium),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: LightTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(LightTheme.borderRadius),
              ),
              child: Icon(
                Iconsax.clock,
                color: LightTheme.secondaryDark,
                size: LightTheme.iconSizeMedium,
              ),
            ),
            SizedBox(
              width: ResponsiveUtils.spacing(context, LightTheme.spacingSmall),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'ساعات العمل' : 'Working Hours',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!isExpanded && businessHours.isNotEmpty)
                    Text(
                      _getTodayHours(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: LightTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Iconsax.arrow_down_1,
                color: LightTheme.textSecondary,
                size: LightTheme.iconSizeMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.all(
          ResponsiveUtils.spacing(context, LightTheme.spacingMedium),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: EdgeInsets.all(
          ResponsiveUtils.spacing(context, LightTheme.spacingMedium),
        ),
        child: Column(
          children: [
            Text(
              errorMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: LightTheme.errorColor),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
              ),
          ],
        ),
      );
    }

    if (businessHours.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(
          ResponsiveUtils.spacing(context, LightTheme.spacingMedium),
        ),
        child: Text(
          isArabic ? 'لا توجد ساعات عمل متاحة' : 'No working hours available',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: LightTheme.textSecondary),
        ),
      );
    }

    return Column(
      children: [
        const Divider(height: 1),
        Padding(
          padding: EdgeInsets.all(
            ResponsiveUtils.spacing(context, LightTheme.spacingMedium),
          ),
          child: Column(
            children: businessHours
                .map((hour) => _buildHourRow(context, hour))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHourRow(BuildContext context, BusinessHour hour) {
    final isToday = _isToday(hour.dayOfWeek);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.spacing(context, LightTheme.spacingXSmall),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              hour.dayName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                color: isToday
                    ? LightTheme.secondaryDark
                    : LightTheme.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: LightTheme.secondaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isArabic ? 'اليوم' : 'Today',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: LightTheme.secondaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  '${hour.openTime} - ${hour.closeTime}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                    color: isToday
                        ? LightTheme.secondaryDark
                        : LightTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTodayHours() {
    final today =
        DateTime.now().weekday % 7; // Convert to 0-6 (Sunday-Saturday)
    final todayHour = businessHours.firstWhere(
      (hour) => hour.dayOfWeek == today,
      orElse: () => businessHours.first,
    );
    return '${todayHour.openTime} - ${todayHour.closeTime}';
  }

  bool _isToday(int dayOfWeek) {
    final today =
        DateTime.now().weekday % 7; // Convert to 0-6 (Sunday-Saturday)
    return dayOfWeek == today;
  }
}
