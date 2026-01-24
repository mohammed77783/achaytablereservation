import 'package:achaytablereservation/app/themes/dark_theme.dart';
import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/core/utils/responsive_utils.dart';
import 'package:achaytablereservation/features/reservation/logic/controller/booking_detail_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Booking details page with QR code
/// QR Code Format: YYYYMMID
/// - First 4 characters: Year (e.g., 2026)
/// - Next 2 characters: Month (e.g., 03)
/// - Remaining characters: Reservation ID (any length)
/// Examples: 2026031, 20260312345678
class BookingDetails extends GetView<BookingDetailController> {
  const BookingDetails({super.key});

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
            controller.reservationDetail.value == null) {
          return _buildErrorState(context, isDark);
        }

        if (controller.reservationDetail.value == null) {
          return _buildErrorState(context, isDark);
        }

        return _buildContent(context, isDark);
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
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'booking_details'.tr,
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
              controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : (controller.isArabic
                        ? 'حدث خطأ أثناء تحميل تفاصيل الحجز'
                        : 'Error loading booking details'),
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

  Widget _buildContent(BuildContext context, bool isDark) {
    final detail = controller.reservationDetail.value!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QR Code Card
          _buildQRCodeCard(context, isDark),
          SizedBox(height: ResponsiveUtils.spacing(context, 20)),

          // Status Card
          _buildStatusCard(context, isDark, detail.status),
          SizedBox(height: ResponsiveUtils.spacing(context, 20)),

          // Payment Timer Card (only for Pending status)
          Obx(() {
            if (controller.isPending) {
              return Column(
                children: [
                  _buildPaymentTimerCard(context, isDark),
                  SizedBox(height: ResponsiveUtils.spacing(context, 20)),
                ],
              );
            }
            return const SizedBox.shrink();
          }),

          // Restaurant Info Card
          _buildRestaurantCard(context, isDark),
          SizedBox(height: ResponsiveUtils.spacing(context, 20)),

          // Reservation Details Card
          _buildDetailsCard(context, isDark),
          SizedBox(height: ResponsiveUtils.spacing(context, 20)),

          // Price Card
          _buildPriceCard(context, isDark),
          SizedBox(height: ResponsiveUtils.spacing(context, 32)),
        ],
      ),
    );
  }

  Widget _buildQRCodeCard(BuildContext context, bool isDark) {
    final qrValue = controller.qrCodeValue;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 24)),
      decoration: BoxDecoration(
        color: isDark ? DarkTheme.cardBackground : LightTheme.cardBackground,
        borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
        border: Border.all(
          color: isDark ? DarkTheme.borderColor : LightTheme.borderColor,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: LightTheme.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          Text(
            controller.isArabic ? 'رمز الحجز' : 'Booking QR Code',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: ResponsiveUtils.fontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 16)),
          // QR Code
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(LightTheme.borderRadius),
            ),
            child: QrImageView(
              data: qrValue,
              version: QrVersions.auto,
              size: ResponsiveUtils.value(
                context,
                mobile: 180.0,
                tablet: 220.0,
              ),
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 12)),
          // QR Code Value
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacing(context, 16),
              vertical: ResponsiveUtils.spacing(context, 8),
            ),
            decoration: BoxDecoration(
              color: (isDark ? DarkTheme.surfaceGray : LightTheme.surfaceGray),
              borderRadius: BorderRadius.circular(LightTheme.borderRadius),
            ),
            child: Text(
              qrValue,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: ResponsiveUtils.fontSize(context, 14),
                fontWeight: FontWeight.w600,
                color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
                letterSpacing: 2,
              ),
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 8)),
          Text(
            controller.isArabic
                ? 'قدم هذا الرمز عند الوصول'
                : 'Show this code upon arrival',
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
    );
  }

  Widget _buildStatusCard(BuildContext context, bool isDark, String status) {
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'confirmed':
        statusColor = isDark ? DarkTheme.successColor : LightTheme.successColor;
        statusIcon = Iconsax.tick_circle;
        break;
      case 'pending':
        statusColor = isDark ? DarkTheme.warningColor : LightTheme.warningColor;
        statusIcon = Iconsax.clock;
        break;
      case 'cancelled':
        statusColor = isDark ? DarkTheme.errorColor : LightTheme.errorColor;
        statusIcon = Iconsax.close_circle;
        break;
      case 'completed':
        statusColor = isDark ? DarkTheme.infoColor : LightTheme.infoColor;
        statusIcon = Iconsax.verify;
        break;
      default:
        statusColor = isDark
            ? DarkTheme.textSecondary
            : LightTheme.textSecondary;
        statusIcon = Iconsax.info_circle;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 28),
          SizedBox(width: ResponsiveUtils.spacing(context, 12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.isArabic ? 'حالة الحجز' : 'Booking Status',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: ResponsiveUtils.fontSize(context, 12),
                  color: statusColor.withValues(alpha: 0.8),
                ),
              ),
              Text(
                controller.getStatusText(status),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: ResponsiveUtils.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTimerCard(BuildContext context, bool isDark) {
    return Obx(() {
      final showTimer = controller.shouldShowTimer;
      final isExpired = controller.isDeadlineExpired.value;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isExpired
                ? [
                    (isDark ? DarkTheme.errorColor : LightTheme.errorColor)
                        .withValues(alpha: 0.15),
                    (isDark ? DarkTheme.errorColor : LightTheme.errorColor)
                        .withValues(alpha: 0.05),
                  ]
                : [
                    (isDark ? DarkTheme.warningColor : const Color(0xFFFF8C00))
                        .withValues(alpha: 0.15),
                    (isDark ? DarkTheme.warningColor : const Color(0xFFFFB300))
                        .withValues(alpha: 0.05),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
          border: Border.all(
            color: isExpired
                ? (isDark ? DarkTheme.errorColor : LightTheme.errorColor)
                      .withValues(alpha: 0.3)
                : (isDark ? DarkTheme.warningColor : const Color(0xFFFF8C00))
                      .withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            // Timer Section (only show if not expired)
            if (showTimer) ...[
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(
                      ResponsiveUtils.spacing(context, 10),
                    ),
                    decoration: BoxDecoration(
                      color:
                          (isDark
                                  ? DarkTheme.warningColor
                                  : const Color(0xFFFF8C00))
                              .withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.timer_1,
                      color: isDark
                          ? DarkTheme.warningColor
                          : const Color(0xFFFF8C00),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing(context, 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.isArabic
                              ? 'الوقت المتبقي للدفع'
                              : 'Time Remaining for Payment',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: ResponsiveUtils.fontSize(context, 12),
                            color: isDark
                                ? DarkTheme.textSecondary
                                : LightTheme.textSecondary,
                          ),
                        ),
                        Text(
                          controller.formattedRemainingTime,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: ResponsiveUtils.fontSize(context, 22),
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? DarkTheme.warningColor
                                : const Color(0xFFFF8C00),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.spacing(context, 16)),
            ],

            // Expired Message (show if deadline has passed)
            if (isExpired) ...[
              Row(
                children: [
                  Icon(
                    Icons.timer_off_outlined,
                    color: isDark
                        ? DarkTheme.errorColor
                        : LightTheme.errorColor,
                    size: 20,
                  ),
                  SizedBox(width: ResponsiveUtils.spacing(context, 8)),
                  Expanded(
                    child: Text(
                      controller.isArabic
                          ? 'انتهت مهلة الدفع'
                          : 'Payment deadline has expired',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: ResponsiveUtils.fontSize(context, 14),
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? DarkTheme.errorColor
                            : LightTheme.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.spacing(context, 12)),
            ],

            // Go to Payment Button (always show for Pending status)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isExpired ? null : () => controller.goToPayment(),
                icon: Icon(
                  Iconsax.card,
                  size: 20,
                  color: isExpired
                      ? (isDark ? DarkTheme.textHint : LightTheme.textHint)
                      : Colors.white,
                ),
                label: Text(
                  controller.isArabic ? 'الذهاب للدفع' : 'Go to Payment',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: ResponsiveUtils.fontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: isExpired
                        ? (isDark ? DarkTheme.textHint : LightTheme.textHint)
                        : Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isExpired
                      ? (isDark
                            ? DarkTheme.surfaceGray
                            : LightTheme.surfaceGray)
                      : (isDark
                            ? DarkTheme.secondaryColor
                            : LightTheme.primaryColor),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: isDark
                      ? DarkTheme.surfaceGray
                      : LightTheme.surfaceGray,
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveUtils.spacing(context, 14),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      LightTheme.borderRadius,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRestaurantCard(BuildContext context, bool isDark) {
    final detail = controller.reservationDetail.value!;
    final restaurant = detail.restaurant;

    return Container(
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
          // Restaurant image
          ClipRRect(
            borderRadius: BorderRadius.circular(LightTheme.borderRadius),
            child: CachedNetworkImage(
              imageUrl: restaurant.image,
              width: ResponsiveUtils.value(context, mobile: 70.0, tablet: 90.0),
              height: ResponsiveUtils.value(
                context,
                mobile: 70.0,
                tablet: 90.0,
              ),
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: isDark ? DarkTheme.surfaceGray : LightTheme.surfaceGray,
                child: Icon(
                  Iconsax.image,
                  color: isDark ? DarkTheme.textHint : LightTheme.textHint,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: isDark ? DarkTheme.surfaceGray : LightTheme.surfaceGray,
                child: Icon(
                  Iconsax.building_4,
                  color: isDark ? DarkTheme.textHint : LightTheme.textHint,
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 12)),
          // Restaurant info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.fullName,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: ResponsiveUtils.fontSize(context, 16),
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkTheme.textPrimary
                        : LightTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ResponsiveUtils.spacing(context, 4)),
                Row(
                  children: [
                    Icon(
                      Iconsax.location,
                      size: 14,
                      color: isDark
                          ? DarkTheme.textSecondary
                          : LightTheme.textSecondary,
                    ),
                    SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                    Expanded(
                      child: Text(
                        restaurant.address,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: ResponsiveUtils.fontSize(context, 12),
                          color: isDark
                              ? DarkTheme.textSecondary
                              : LightTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, bool isDark) {
    final detail = controller.reservationDetail.value!;

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
      decoration: BoxDecoration(
        color: isDark ? DarkTheme.cardBackground : LightTheme.cardBackground,
        borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
        border: Border.all(
          color: isDark ? DarkTheme.borderColor : LightTheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.isArabic ? 'تفاصيل الحجز' : 'Reservation Details',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: ResponsiveUtils.fontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 16)),
          // Date
          _buildDetailRow(
            context,
            isDark,
            icon: Iconsax.calendar,
            label: controller.isArabic ? 'التاريخ' : 'Date',
            value: detail.date,
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 12)),
          // Time
          _buildDetailRow(
            context,
            isDark,
            icon: Iconsax.clock,
            label: controller.isArabic ? 'الوقت' : 'Time',
            value: detail.time,
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 12)),
          // Guests
          _buildDetailRow(
            context,
            isDark,
            icon: Iconsax.people,
            label: controller.isArabic ? 'عدد الضيوف' : 'Guests',
            value: '${detail.numberOfGuests}',
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 12)),
          // Hall
          _buildDetailRow(
            context,
            isDark,
            icon: Iconsax.building,
            label: controller.isArabic ? 'القاعة' : 'Hall',
            value: detail.hallName,
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 12)),
          // Booking ID
          _buildDetailRow(
            context,
            isDark,
            icon: Iconsax.receipt_1,
            label: controller.isArabic ? 'رقم الحجز' : 'Booking ID',
            value: '#${detail.bookingId}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 8)),
          decoration: BoxDecoration(
            color: (isDark ? DarkTheme.primaryLight : LightTheme.primaryColor)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(LightTheme.borderRadius),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? DarkTheme.primaryLight : LightTheme.primaryColor,
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing(context, 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: ResponsiveUtils.fontSize(context, 12),
                  color: isDark
                      ? DarkTheme.textSecondary
                      : LightTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: ResponsiveUtils.fontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? DarkTheme.textPrimary
                      : LightTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard(BuildContext context, bool isDark) {
    final detail = controller.reservationDetail.value!;

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
      decoration: BoxDecoration(
        color: (isDark ? DarkTheme.secondaryColor : LightTheme.secondaryColor)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
        border: Border.all(
          color: (isDark ? DarkTheme.secondaryColor : LightTheme.secondaryColor)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.isArabic ? 'المبلغ الإجمالي' : 'Total Amount',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: ResponsiveUtils.fontSize(context, 14),
                  color: isDark
                      ? DarkTheme.textSecondary
                      : LightTheme.textSecondary,
                ),
              ),
              Text(
                '${detail.totalPrice.toStringAsFixed(2)} ${controller.isArabic ? 'ر.س' : 'SAR'}',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: ResponsiveUtils.fontSize(context, 22),
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? DarkTheme.secondaryColor
                      : LightTheme.primaryColor,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 12)),
            decoration: BoxDecoration(
              color:
                  (isDark
                          ? DarkTheme.secondaryColor
                          : LightTheme.secondaryColor)
                      .withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.money_recive,
              color: isDark
                  ? DarkTheme.secondaryColor
                  : LightTheme.primaryColor,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
