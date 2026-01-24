import 'package:achaytablereservation/app/themes/dark_theme.dart';
import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/core/utils/responsive_utils.dart';
import 'package:achaytablereservation/features/reservation/data/models/my_reservation_item.dart';
import 'package:achaytablereservation/features/reservation/logic/controller/booking_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// Bookings page displaying user's reservations list
class BookingsPage extends GetView<BookingsController> {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? DarkTheme.backgroundColor
          : LightTheme.backgroundColor,
      appBar: _buildAppBar(context, isDark),
      body: Obx(() {
        if (controller.isInitialLoading.value) {
          return _buildLoadingState(context, isDark);
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.reservations.isEmpty) {
          return _buildErrorState(context, isDark);
        }

        if (controller.reservations.isEmpty) {
          return _buildEmptyState(context, isDark);
        }

        return _buildReservationsList(context, isDark);
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark
          ? DarkTheme.surfaceColor
          : LightTheme.surfaceColor,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        'my_bookings'.tr,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: ResponsiveUtils.fontSize(context, 18),
          fontWeight: FontWeight.w600,
          color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, bool isDark) {
    return Center(
      child: CircularProgressIndicator(
        color: isDark ? DarkTheme.secondaryColor : LightTheme.secondaryColor,
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDark) {
    return RefreshIndicator(
      onRefresh: controller.refreshReservations,
      color: isDark ? DarkTheme.secondaryColor : LightTheme.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height:
              MediaQuery.of(context).size.height -
              kToolbarHeight -
              MediaQuery.of(context).padding.top,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.warning_2,
                    size: ResponsiveUtils.value(
                      context,
                      mobile: 64.0,
                      tablet: 80.0,
                    ),
                    color: isDark
                        ? DarkTheme.errorColor
                        : LightTheme.errorColor,
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 24)),
                  Text(
                    controller.errorMessage.value,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: ResponsiveUtils.fontSize(context, 16),
                      color: isDark
                          ? DarkTheme.textPrimary
                          : LightTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 32)),
                  ElevatedButton.icon(
                    onPressed: controller.refreshReservations,
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
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return RefreshIndicator(
      onRefresh: controller.refreshReservations,
      color: isDark ? DarkTheme.secondaryColor : LightTheme.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height:
              MediaQuery.of(context).size.height -
              kToolbarHeight -
              MediaQuery.of(context).padding.top,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 32)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.calendar_tick,
                    size: ResponsiveUtils.value(
                      context,
                      mobile: 80.0,
                      tablet: 100.0,
                    ),
                    color:
                        (isDark
                                ? DarkTheme.textSecondary
                                : LightTheme.textSecondary)
                            .withValues(alpha: 0.5),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 24)),
                  Text(
                    'no_bookings'.tr,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: ResponsiveUtils.fontSize(context, 18),
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? DarkTheme.textPrimary
                          : LightTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 8)),
                  Text(
                    'no_bookings_desc'.tr,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: ResponsiveUtils.fontSize(context, 14),
                      color: isDark
                          ? DarkTheme.textSecondary
                          : LightTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReservationsList(BuildContext context, bool isDark) {
    return RefreshIndicator(
      onRefresh: controller.refreshReservations,
      color: isDark ? DarkTheme.secondaryColor : LightTheme.primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
        itemCount: controller.reservations.length,
        itemBuilder: (context, index) {
          final reservation = controller.reservations[index];
          return _buildReservationCard(context, isDark, reservation);
        },
      ),
    );
  }

  Widget _buildReservationCard(
    BuildContext context,
    bool isDark,
    MyReservationItem reservation,
  ) {
    return GestureDetector(
      onTap: () => controller.navigateToDetails(reservation.bookingId),
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveUtils.spacing(context, 12)),
        padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 12)),
        decoration: BoxDecoration(
          color: isDark ? DarkTheme.cardBackground : LightTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Restaurant image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: reservation.restaurantImage,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 80,
                  color: isDark
                      ? DarkTheme.surfaceGray
                      : LightTheme.surfaceGray,
                  child: Icon(
                    Iconsax.image,
                    color: isDark ? DarkTheme.textHint : LightTheme.textHint,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  color: isDark
                      ? DarkTheme.surfaceGray
                      : LightTheme.surfaceGray,
                  child: Icon(
                    Iconsax.building_4,
                    color: isDark ? DarkTheme.textHint : LightTheme.textHint,
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing(context, 12)),
            // Info section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant name
                  Text(
                    reservation.restaurantName,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: ResponsiveUtils.fontSize(context, 15),
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? DarkTheme.textPrimary
                          : LightTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 6)),
                  // Date & Time
                  Row(
                    children: [
                      Icon(
                        Iconsax.calendar,
                        size: 14,
                        color: isDark
                            ? DarkTheme.textSecondary
                            : LightTheme.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        reservation.date,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: ResponsiveUtils.fontSize(context, 12),
                          color: isDark
                              ? DarkTheme.textSecondary
                              : LightTheme.textSecondary,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(
                        Iconsax.clock,
                        size: 14,
                        color: isDark
                            ? DarkTheme.textSecondary
                            : LightTheme.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        reservation.time,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: ResponsiveUtils.fontSize(context, 12),
                          color: isDark
                              ? DarkTheme.textSecondary
                              : LightTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 6)),
                  // Guests & Status
                  Row(
                    children: [
                      Icon(
                        Iconsax.people,
                        size: 14,
                        color: isDark
                            ? DarkTheme.textSecondary
                            : LightTheme.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${reservation.numberOfGuests} ${'guests'.tr}',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: ResponsiveUtils.fontSize(context, 12),
                          color: isDark
                              ? DarkTheme.textSecondary
                              : LightTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      _buildStatusBadge(context, isDark, reservation.status),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing(context, 8)),
            // Arrow
            Icon(
              controller.isArabic
                  ? Iconsax.arrow_left_2
                  : Iconsax.arrow_right_3,
              color: isDark
                  ? DarkTheme.textSecondary
                  : LightTheme.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isDark, String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'confirmed':
        backgroundColor =
            (isDark ? DarkTheme.successColor : LightTheme.successColor)
                .withValues(alpha: 0.15);
        textColor = isDark ? DarkTheme.successColor : LightTheme.successColor;
        break;
      case 'pending':
        backgroundColor =
            (isDark ? DarkTheme.warningColor : LightTheme.warningColor)
                .withValues(alpha: 0.15);
        textColor = isDark ? DarkTheme.warningColor : LightTheme.warningColor;
        break;
      case 'cancelled':
        backgroundColor =
            (isDark ? DarkTheme.errorColor : LightTheme.errorColor).withValues(
              alpha: 0.15,
            );
        textColor = isDark ? DarkTheme.errorColor : LightTheme.errorColor;
        break;
      case 'completed':
        backgroundColor = (isDark ? DarkTheme.infoColor : LightTheme.infoColor)
            .withValues(alpha: 0.15);
        textColor = isDark ? DarkTheme.infoColor : LightTheme.infoColor;
        break;
      default:
        backgroundColor =
            (isDark ? DarkTheme.textSecondary : LightTheme.textSecondary)
                .withValues(alpha: 0.15);
        textColor = isDark ? DarkTheme.textSecondary : LightTheme.textSecondary;
    }

    String statusText;
    if (controller.isArabic) {
      switch (status.toLowerCase()) {
        case 'confirmed':
          statusText = 'مؤكد';
          break;
        case 'pending':
          statusText = 'قيد الانتظار';
          break;
        case 'cancelled':
          statusText = 'ملغي';
          break;
        case 'completed':
          statusText = 'مكتمل';
          break;
        default:
          statusText = status;
      }
    } else {
      statusText = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 8),
        vertical: ResponsiveUtils.spacing(context, 4),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(LightTheme.borderRadius),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: ResponsiveUtils.fontSize(context, 10),
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
