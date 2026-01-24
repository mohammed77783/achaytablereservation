import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/app/themes/dark_theme.dart';
import 'package:achaytablereservation/core/utils/responsive_utils.dart';

/// Price display and guest counter widget with table capacity pricing
///
/// Pricing Logic:
/// - 1-4 guests → charged for 4 people (minimum table)
/// - 5-8 guests → charged for 8 people
/// - 9-12 guests → charged for 12 people
class PriceDisplayWithCapacity extends StatelessWidget {
  final double pricePerPerson;
  final int guestCount;
  final int tableCapacity;
  final double totalPrice;
  final VoidCallback onIncreaseGuests;
  final VoidCallback onDecreaseGuests;
  final int minGuests;
  PriceDisplayWithCapacity({
    super.key,
    required this.pricePerPerson,
    required this.guestCount,
    required this.tableCapacity,
    required this.totalPrice,
    required this.onIncreaseGuests,
    required this.onDecreaseGuests,
    this.minGuests = 1,
  });

  bool get isArabic => Get.locale?.languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
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
      child: Column(
        children: [
          // Guest counter
          _buildGuestCounter(context, isDark),

          SizedBox(height: ResponsiveUtils.spacing(context, 12)),

          // Table capacity info
          _buildTableCapacityInfo(context, isDark),

          Divider(
            height: ResponsiveUtils.spacing(context, 32),
            color: isDark ? DarkTheme.dividerColor : LightTheme.dividerColor,
          ),

          // Price breakdown
          _buildPriceBreakdown(context, isDark),
        ],
      ),
    );
  }

  Widget _buildGuestCounter(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Label
        Row(
          children: [
            Icon(
              Iconsax.people,
              color: isDark
                  ? DarkTheme.textSecondary
                  : LightTheme.textSecondary,
              size: ResponsiveUtils.value(context, mobile: 20.0, tablet: 24.0),
            ),
            SizedBox(width: ResponsiveUtils.spacing(context, 8)),
            Text(
              isArabic ? 'عدد الضيوف' : 'Number of Guests',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: ResponsiveUtils.fontSize(context, 14),
                color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
              ),
            ),
          ],
        ),

        // Counter
        Row(
          children: [
            // Decrease button
            _buildCounterButton(
              context,
              isDark,
              icon: Iconsax.minus,
              onTap: onDecreaseGuests,
              isEnabled: guestCount > minGuests,
            ),
            // Count
            Container(
              width: ResponsiveUtils.value(context, mobile: 50.0, tablet: 60.0),
              alignment: Alignment.center,
              child: Text(
                '$guestCount',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: ResponsiveUtils.fontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? DarkTheme.textPrimary
                      : LightTheme.textPrimary,
                ),
              ),
            ),

            // Increase button
            _buildCounterButton(
              context,
              isDark,
              icon: Iconsax.add,
              onTap: onIncreaseGuests,
              isEnabled: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterButton(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    final primaryColor = isDark
        ? DarkTheme.secondaryColor
        : LightTheme.primaryColor;
    final disabledColor = isDark
        ? DarkTheme.borderColor
        : LightTheme.borderColor;
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: ResponsiveUtils.value(context, mobile: 36.0, tablet: 44.0),
        height: ResponsiveUtils.value(context, mobile: 36.0, tablet: 44.0),
        decoration: BoxDecoration(
          color: isEnabled ? primaryColor : disabledColor,
          borderRadius: BorderRadius.circular(LightTheme.borderRadius),
        ),
        child: Icon(
          icon,
          color: isEnabled
              ? (isDark ? DarkTheme.textOnSecondary : LightTheme.textOnPrimary)
              : (isDark ? DarkTheme.textHint : LightTheme.textHint),
          size: ResponsiveUtils.value(context, mobile: 18.0, tablet: 22.0),
        ),
      ),
    );
  }

  Widget _buildTableCapacityInfo(BuildContext context, bool isDark) {
    final primaryColor = isDark
        ? DarkTheme.secondaryColor
        : LightTheme.primaryColor;

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 12)),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(LightTheme.borderRadius),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.info_circle,
            size: ResponsiveUtils.value(context, mobile: 18.0, tablet: 22.0),
            color: primaryColor,
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 8)),
          Expanded(
            child: Text(
              isArabic
                  ? 'سيتم حجز طاولة لـ $tableCapacity أشخاص'
                  : 'A table for $tableCapacity people will be reserved',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: ResponsiveUtils.fontSize(context, 12),
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(BuildContext context, bool isDark) {
    final textSecondary = isDark
        ? DarkTheme.textSecondary
        : LightTheme.textSecondary;
    final textPrimary = isDark ? DarkTheme.textPrimary : LightTheme.textPrimary;
    final primaryColor = isDark
        ? DarkTheme.secondaryColor
        : LightTheme.primaryColor;
    final warningColor = isDark
        ? DarkTheme.warningColor
        : LightTheme.warningColor;

    return Column(
      children: [
        // Price per person
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isArabic ? 'سعر الطالة' : 'Price per table',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: ResponsiveUtils.fontSize(context, 14),
                color: textSecondary,
              ),
            ),
            Text(
              isArabic
                  ? '${(pricePerPerson * 4).toStringAsFixed(0)} ر.س'
                  : '${(pricePerPerson * 4).toStringAsFixed(0)} SAR',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: ResponsiveUtils.fontSize(context, 14),
                color: textSecondary,
              ),
            ),
          ],
        ),

        SizedBox(height: ResponsiveUtils.spacing(context, 8)),

        // Table capacity calculation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isArabic
                  ? '${pricePerPerson.toStringAsFixed(0)} × $tableCapacity (سعة الطاولة)'
                  : '${pricePerPerson.toStringAsFixed(0)} × $tableCapacity (table capacity)',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: ResponsiveUtils.fontSize(context, 14),
                color: textSecondary,
              ),
            ),
            Text(
              isArabic
                  ? '${totalPrice.toStringAsFixed(0)} ر.س'
                  : '${totalPrice.toStringAsFixed(0)} SAR',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: ResponsiveUtils.fontSize(context, 14),
                color: textSecondary,
              ),
            ),
          ],
        ),

        // Show capacity tier hint
        if (guestCount < tableCapacity) ...[
          SizedBox(height: ResponsiveUtils.spacing(context, 4)),
          Row(
            children: [
              Icon(
                Iconsax.lamp_charge,
                size: ResponsiveUtils.value(
                  context,
                  mobile: 14.0,
                  tablet: 16.0,
                ),
                color: warningColor,
              ),
              SizedBox(width: ResponsiveUtils.spacing(context, 4)),
              Expanded(
                child: Text(
                  isArabic
                      ? 'يمكنك إضافة ${tableCapacity - guestCount} ضيوف إضافيين بنفس السعر'
                      : 'You can add ${tableCapacity - guestCount} more guests at the same price',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: ResponsiveUtils.fontSize(context, 11),
                    color: warningColor,
                  ),
                ),
              ),
            ],
          ),
        ],

        SizedBox(height: ResponsiveUtils.spacing(context, 12)),

        // Total
        Container(
          padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 12)),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(LightTheme.borderRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'المجموع' : 'Total',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: ResponsiveUtils.fontSize(context, 16),
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    isArabic
                        ? 'لـ $guestCount ${guestCount == 1 ? 'ضيف' : 'ضيوف'}'
                        : 'for $guestCount ${guestCount == 1 ? 'guest' : 'guests'}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: ResponsiveUtils.fontSize(context, 12),
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                isArabic
                    ? '${totalPrice.toStringAsFixed(0)} ر.س'
                    : '${totalPrice.toStringAsFixed(0)} SAR',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: ResponsiveUtils.fontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),

        // Capacity tiers explanation
        SizedBox(height: ResponsiveUtils.spacing(context, 12)),
      ],
    );
  }

  Widget _buildTierRow(
    BuildContext context,
    bool isDark,
    String guestRange,
    int capacity,
  ) {
    final isCurrentTier = tableCapacity == capacity;
    final primaryColor = isDark
        ? DarkTheme.secondaryColor
        : LightTheme.primaryColor;
    final textSecondary = isDark
        ? DarkTheme.textSecondary
        : LightTheme.textSecondary;
    final textHint = isDark ? DarkTheme.textHint : LightTheme.textHint;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 8),
        vertical: ResponsiveUtils.spacing(context, 4),
      ),
      decoration: BoxDecoration(
        color: isCurrentTier
            ? primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isArabic ? '$guestRange ضيوف' : '$guestRange guests',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: ResponsiveUtils.fontSize(context, 12),
              color: isCurrentTier ? primaryColor : textSecondary,
              fontWeight: isCurrentTier ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Row(
            children: [
              Icon(
                Iconsax.arrow_right_3,
                size: ResponsiveUtils.value(
                  context,
                  mobile: 12.0,
                  tablet: 14.0,
                ),
                color: isCurrentTier ? primaryColor : textHint,
              ),
              SizedBox(width: ResponsiveUtils.spacing(context, 4)),
              Text(
                isArabic ? 'طاولة لـ $capacity أشخاص' : 'Table for $capacity',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: ResponsiveUtils.fontSize(context, 12),
                  color: isCurrentTier ? primaryColor : textSecondary,
                  fontWeight: isCurrentTier
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
