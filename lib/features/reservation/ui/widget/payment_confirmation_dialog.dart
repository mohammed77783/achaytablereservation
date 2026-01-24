import 'package:achaytablereservation/app/themes/dark_theme.dart';
import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// Payment confirmation dialog widget data model
class PaymentConfirmationData {
  final String dateDisplay;
  final String timeDisplay;
  final int guestCount;
  final String? hallName;
  final int requiredTables;
  final double totalPrice;
  final bool isArabic;

  const PaymentConfirmationData({
    required this.dateDisplay,
    required this.timeDisplay,
    required this.guestCount,
    this.hallName,
    required this.requiredTables,
    required this.totalPrice,
    required this.isArabic,
  });
}

/// Reusable payment confirmation dialog widget
class PaymentConfirmationDialog extends StatelessWidget {
  final PaymentConfirmationData data;
  final RxBool isProcessing;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const PaymentConfirmationDialog({
    super.key,
    required this.data,
    required this.isProcessing,
    required this.onConfirm,
    required this.onCancel,
  });

  /// Show the dialog
  static void show({
    required PaymentConfirmationData data,
    required RxBool isProcessing,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    Get.dialog(
      PaymentConfirmationDialog(
        data: data,
        isProcessing: isProcessing,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
      barrierDismissible: true,
    );
  }

  bool get isDark => Get.isDarkMode;

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveUtils.spacing(context, 24.0);
    final padding = ResponsiveUtils.spacing(context, 24.0);

    return PopScope(
      canPop: true,
      child: Dialog(
        backgroundColor: isDark
            ? DarkTheme.cardBackground
            : LightTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LightTheme.borderRadiusXLarge),
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.spacing(context, 20.0),
          vertical: ResponsiveUtils.spacing(context, 24.0),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                SizedBox(height: spacing),
                _buildReservationDetails(context),
                SizedBox(height: ResponsiveUtils.spacing(context, 16.0)),
                _buildTotalAmount(context),
                SizedBox(height: ResponsiveUtils.spacing(context, 16.0)),
                _buildTimerWarning(context),
                SizedBox(height: ResponsiveUtils.spacing(context, 16.0)),
                _buildRefundPolicy(context),
                SizedBox(height: spacing),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final iconSize = ResponsiveUtils.value(context, mobile: 72.0, tablet: 84.0);
    final titleSize = ResponsiveUtils.fontSize(context, 20.0);
    final subtitleSize = ResponsiveUtils.fontSize(context, 14.0);

    return Column(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [DarkTheme.secondaryColor, DarkTheme.secondaryDark]
                  : [LightTheme.secondaryColor, LightTheme.secondaryDark],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:
                    (isDark
                            ? DarkTheme.secondaryColor
                            : LightTheme.secondaryColor)
                        .withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Iconsax.ticket,
            size: iconSize * 0.5,
            color: isDark
                ? DarkTheme.textOnSecondary
                : LightTheme.textOnSecondary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, 16.0)),
        Text(
          data.isArabic ? 'تأكيد الحجز والدفع' : 'Confirm Reservation & Pay',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, 8.0)),
        Text(
          data.isArabic
              ? 'يرجى مراجعة تفاصيل حجزك قبل المتابعة'
              : 'Please review your reservation details before proceeding',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: subtitleSize,
            color: isDark ? DarkTheme.textSecondary : LightTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReservationDetails(BuildContext context) {
    final padding = ResponsiveUtils.spacing(context, 16.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: isDark ? DarkTheme.surfaceColor : LightTheme.surfaceGray,
        borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
        border: Border.all(
          color: isDark ? DarkTheme.borderColor : LightTheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            context,
            icon: Iconsax.calendar_1,
            label: data.isArabic ? 'التاريخ' : 'Date',
            value: data.dateDisplay,
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 12.0)),
          _buildDetailRow(
            context,
            icon: Iconsax.clock,
            label: data.isArabic ? 'الوقت' : 'Time',
            value: data.timeDisplay,
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 12.0)),
          _buildDetailRow(
            context,
            icon: Iconsax.people,
            label: data.isArabic ? 'عدد الضيوف' : 'Guests',
            value: '${data.guestCount} ${data.isArabic ? 'ضيف' : 'guests'}',
          ),
          if (data.hallName != null) ...[
            SizedBox(height: ResponsiveUtils.spacing(context, 12.0)),
            _buildDetailRow(
              context,
              icon: Iconsax.building,
              label: data.isArabic ? 'الصالة' : 'Hall',
              value: data.hallName!,
            ),
          ],
          SizedBox(height: ResponsiveUtils.spacing(context, 12.0)),
          _buildDetailRow(
            context,
            icon: Iconsax.directbox_receive,
            label: data.isArabic ? 'عدد الطاولات' : 'Tables',
            value:
                '${data.requiredTables} ${data.isArabic ? 'طاولة' : 'table(s)'}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final iconSize = ResponsiveUtils.value(context, mobile: 18.0, tablet: 22.0);
    final labelSize = ResponsiveUtils.fontSize(context, 13.0);
    final valueSize = ResponsiveUtils.fontSize(context, 14.0);

    return Row(
      children: [
        Icon(
          icon,
          size: iconSize,
          color: isDark ? DarkTheme.secondaryColor : LightTheme.primaryColor,
        ),
        SizedBox(width: ResponsiveUtils.spacing(context, 12.0)),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: labelSize,
              color: isDark
                  ? DarkTheme.textSecondary
                  : LightTheme.textSecondary,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: valueSize,
              fontWeight: FontWeight.w600,
              color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalAmount(BuildContext context) {
    final padding = ResponsiveUtils.spacing(context, 20.0);
    final priceSize = ResponsiveUtils.fontSize(context, 28.0);
    final labelSize = ResponsiveUtils.fontSize(context, 14.0);
    final smallLabelSize = ResponsiveUtils.fontSize(context, 12.0);

    // Calculate tax (15%) and subtotal
    final taxRate = 0.15;
    final subtotal = data.totalPrice / (1 + taxRate);
    final taxAmount = data.totalPrice - subtotal;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [DarkTheme.primaryColor, DarkTheme.primaryDark]
              : [LightTheme.primaryColor, LightTheme.primaryDark],
        ),
        borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: (isDark ? DarkTheme.primaryColor : LightTheme.primaryColor)
                .withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Subtotal row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.isArabic ? 'المبلغ الأساسي' : 'Subtotal',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: smallLabelSize,
                  color:
                      (isDark
                              ? DarkTheme.textOnPrimary
                              : LightTheme.textOnPrimary)
                          .withValues(alpha: 0.7),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    subtotal.toStringAsFixed(2),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: smallLabelSize,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? DarkTheme.textOnPrimary
                          : LightTheme.textOnPrimary,
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing(context, 4.0)),
                  Text(
                    data.isArabic ? 'ر.س' : 'SAR',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: ResponsiveUtils.fontSize(context, 10.0),
                      color:
                          (isDark
                                  ? DarkTheme.textOnPrimary
                                  : LightTheme.textOnPrimary)
                              .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 6.0)),
          // Tax row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.isArabic ? 'ضريبة القيمة المضافة (15%)' : 'VAT (15%)',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: smallLabelSize,
                  color:
                      (isDark
                              ? DarkTheme.textOnPrimary
                              : LightTheme.textOnPrimary)
                          .withValues(alpha: 0.7),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    taxAmount.toStringAsFixed(2),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: smallLabelSize,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? DarkTheme.textOnPrimary
                          : LightTheme.textOnPrimary,
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing(context, 4.0)),
                  Text(
                    data.isArabic ? 'ر.س' : 'SAR',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: ResponsiveUtils.fontSize(context, 10.0),
                      color:
                          (isDark
                                  ? DarkTheme.textOnPrimary
                                  : LightTheme.textOnPrimary)
                              .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 12.0)),
          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              color:
                  (isDark ? DarkTheme.textOnPrimary : LightTheme.textOnPrimary)
                      .withValues(alpha: 0.3),
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 12.0)),
          // Total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.isArabic ? 'المبلغ الإجمالي' : 'Total Amount',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: labelSize,
                      fontWeight: FontWeight.w600,
                      color:
                          (isDark
                                  ? DarkTheme.textOnPrimary
                                  : LightTheme.textOnPrimary)
                              .withValues(alpha: 0.9),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 2.0)),
                  Text(
                    data.isArabic ? 'شامل الضريبة' : 'Including tax',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: ResponsiveUtils.fontSize(context, 10.0),
                      color:
                          (isDark
                                  ? DarkTheme.textOnPrimary
                                  : LightTheme.textOnPrimary)
                              .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    data.totalPrice.toStringAsFixed(2),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: priceSize,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? DarkTheme.textOnPrimary
                          : LightTheme.textOnPrimary,
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing(context, 4.0)),
                  Text(
                    data.isArabic ? 'ر.س' : 'SAR',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: labelSize,
                      fontWeight: FontWeight.w600,
                      color:
                          (isDark
                                  ? DarkTheme.textOnPrimary
                                  : LightTheme.textOnPrimary)
                              .withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerWarning(BuildContext context) {
    final padding = ResponsiveUtils.spacing(context, 16.0);
    final iconBoxSize = ResponsiveUtils.value(
      context,
      mobile: 44.0,
      tablet: 52.0,
    );

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: (isDark ? DarkTheme.warningColor : LightTheme.warningColor)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
        border: Border.all(
          color: (isDark ? DarkTheme.warningColor : LightTheme.warningColor)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: iconBoxSize,
            height: iconBoxSize,
            decoration: BoxDecoration(
              color: (isDark ? DarkTheme.warningColor : LightTheme.warningColor)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Iconsax.timer_1,
              size: iconBoxSize * 0.55,
              color: isDark ? DarkTheme.warningColor : LightTheme.warningColor,
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 14.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.isArabic
                      ? 'لديك 10 دقائق فقط للدفع'
                      : 'You have only 10 minutes to pay',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: ResponsiveUtils.fontSize(context, 14.0),
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkTheme.warningColor
                        : LightTheme.warningColor,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.spacing(context, 2.0)),
                Text(
                  data.isArabic
                      ? 'سيتم إلغاء الحجز تلقائياً إذا لم يتم الدفع'
                      : 'Reservation will be automatically cancelled if not paid',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: ResponsiveUtils.fontSize(context, 12.0),
                    color: isDark
                        ? DarkTheme.textSecondary
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

  Widget _buildRefundPolicy(BuildContext context) {
    final padding = ResponsiveUtils.spacing(context, 16.0);
    final iconBoxSize = ResponsiveUtils.value(
      context,
      mobile: 44.0,
      tablet: 52.0,
    );

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: (isDark ? DarkTheme.errorColor : LightTheme.errorColor)
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
        border: Border.all(
          color: (isDark ? DarkTheme.errorColor : LightTheme.errorColor)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: iconBoxSize,
            height: iconBoxSize,
            decoration: BoxDecoration(
              color: (isDark ? DarkTheme.errorColor : LightTheme.errorColor)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Iconsax.info_circle,
              size: iconBoxSize * 0.55,
              color: isDark ? DarkTheme.errorColor : LightTheme.errorColor,
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 14.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.isArabic ? 'سياسة الاسترداد' : 'Refund Policy',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: ResponsiveUtils.fontSize(context, 14.0),
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkTheme.errorColor
                        : LightTheme.errorColor,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.spacing(context, 4.0)),
                Text(
                  data.isArabic
                      ? 'لن يتم استرداد المبلغ في حالة الإلغاء أو عدم الحضور إلى المطعم'
                      : 'Amount is non-refundable in case of cancellation or no-show at the restaurant',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: ResponsiveUtils.fontSize(context, 12.0),
                    color: isDark
                        ? DarkTheme.textSecondary
                        : LightTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final buttonHeight = ResponsiveUtils.value(
      context,
      mobile: 52.0,
      tablet: 56.0,
    );
    final cancelButtonHeight = ResponsiveUtils.value(
      context,
      mobile: 48.0,
      tablet: 52.0,
    );
    final buttonFontSize = ResponsiveUtils.fontSize(context, 16.0);

    return Obx(
      () => Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: isProcessing.value ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? DarkTheme.secondaryColor
                    : LightTheme.primaryColor,
                foregroundColor: isDark
                    ? DarkTheme.textOnSecondary
                    : LightTheme.textOnPrimary,
                disabledBackgroundColor:
                    (isDark
                            ? DarkTheme.secondaryColor
                            : LightTheme.primaryColor)
                        .withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(LightTheme.borderRadius),
                ),
                elevation: 0,
              ),
              child: isProcessing.value
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: isDark
                                ? DarkTheme.textOnSecondary
                                : LightTheme.textOnPrimary,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.spacing(context, 12.0)),
                        Text(
                          data.isArabic ? 'جارٍ التحميل...' : 'Processing...',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: buttonFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.card,
                          size: 20,
                          color: isDark
                              ? DarkTheme.textOnSecondary
                              : LightTheme.textOnPrimary,
                        ),
                        SizedBox(width: ResponsiveUtils.spacing(context, 10.0)),
                        Text(
                          data.isArabic ? 'متابعة للدفع' : 'Proceed to Payment',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: buttonFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 12.0)),
          SizedBox(
            width: double.infinity,
            height: cancelButtonHeight,
            child: OutlinedButton(
              onPressed: isProcessing.value ? null : onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark
                    ? DarkTheme.textSecondary
                    : LightTheme.textSecondary,
                side: BorderSide(
                  color: isDark
                      ? DarkTheme.borderColor
                      : LightTheme.borderColor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(LightTheme.borderRadius),
                ),
              ),
              child: Text(
                data.isArabic ? 'إلغاء' : 'Cancel',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
