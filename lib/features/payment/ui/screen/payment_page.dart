import 'dart:io';

import 'package:achaytablereservation/app/themes/dark_theme.dart';
import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/core/utils/responsive_utils.dart';
import 'package:achaytablereservation/features/payment/logic/payment_controller.dart'
    show PaymentController;
import 'package:achaytablereservation/features/payment/ui/widget/apple_pay_button_widget.dart';

import 'package:achaytablereservation/features/payment/ui/widget/horizontal_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';

/// Payment Screen with live card scanner
class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  // Helper getters for theme-aware colors
  bool get isDark => Get.isDarkMode;

  Color get backgroundColor =>
      isDark ? DarkTheme.backgroundColor : LightTheme.backgroundColor;

  Color get cardBackground =>
      isDark ? DarkTheme.cardBackground : LightTheme.cardBackground;

  Color get surfaceColor =>
      isDark ? DarkTheme.surfaceColor : LightTheme.surfaceGray;

  Color get primaryColor =>
      isDark ? DarkTheme.secondaryColor : LightTheme.primaryColor;

  Color get textPrimary =>
      isDark ? DarkTheme.textPrimary : LightTheme.textPrimary;

  Color get textSecondary =>
      isDark ? DarkTheme.textSecondary : LightTheme.textSecondary;

  Color get borderColor =>
      isDark ? DarkTheme.borderColor : LightTheme.borderColor;

  Color get successColor =>
      isDark ? DarkTheme.successColor : LightTheme.successColor;

  Color get errorColor => isDark ? DarkTheme.errorColor : LightTheme.errorColor;

  Color get textOnPrimary =>
      isDark ? DarkTheme.textOnSecondary : LightTheme.textOnPrimary;

  @override
  Widget build(BuildContext context) {
    final PaymentController controller = Get.find<PaymentController>();

    return PopScope(
      canPop:
          false, // Always prevent default back to handle navigation manually
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // If live scan is active, stop it instead of navigating back
        if (controller.isLiveScanActive.value) {
          // controller.stopLiveScanning();
        } else {
          // Use controller to handle back navigation based on source
          controller.onBackPressed();
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: textPrimary),
            onPressed: () {
              if (controller.isLiveScanActive.value) {
                // controller.stopLiveScanning();
              } else {
                // Use controller to handle back navigation based on source
                controller.onBackPressed();
              }
            },
          ),
          title: Builder(
            builder: (context) => Text(
              'payment'.tr,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: context.fontSize(20),
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: Obx(() {
          if (controller.isLiveScanActive.value) {
            return _buildLiveScannerView(controller);
          }
          return _buildMainContent(controller);
        }),
      ),
    );
  }

  /// Main payment content
  Widget _buildMainContent(PaymentController controller) {
    return Builder(
      builder: (context) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.spacing(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Invoice Summary Card
              _buildInvoiceSummaryCard(controller, context),

              SizedBox(height: context.spacing(24)),

              // Card Preview (horizontal)
              // _buildCardPreview(controller),

              const SizedBox(height: 32),
              // Show Apple Pay button if available (iOS only)
              Obx(() {
                if (controller.isApplePayAvailable.value && Platform.isIOS) {
                  return Column(
                    children: [
                      _buildApplePaySection(controller, context),
                      SizedBox(height: context.spacing(24)),
                      _buildPaymentMethodDivider(context),
                      SizedBox(height: context.spacing(24)),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),

              // ============ CREDIT CARD SECTION ============
              // Payment method header
              Text(
                'pay_with_card'.tr,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: textPrimary,
                  fontSize: context.fontSize(18),
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: context.spacing(16)),
              // Live Scan Button
              // _buildLiveScanButton(controller, context),

              SizedBox(height: context.spacing(24)),

              // Or divider
              _buildOrDivider(context),

              SizedBox(height: context.spacing(24)),

              // Card Details Form
              Text(
                'card_details'.tr,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: textPrimary,
                  fontSize: context.fontSize(18),
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: context.spacing(16)),

              // Card Number Input
              _buildCardNumberInput(controller, context),

              SizedBox(height: context.spacing(16)),

              // Cardholder Name Input
              _buildCardHolderNameInput(controller, context),

              SizedBox(height: context.spacing(16)),
              // Expiration and CVV Row
              Row(
                children: [
                  Expanded(child: _buildExpirationInput(controller, context)),
                  SizedBox(width: context.spacing(16)),
                  Expanded(child: _buildCVVInput(controller, context)),
                ],
              ),
              SizedBox(height: context.spacing(32)),

              // Pay Now Button
              _buildPayButton(controller, context),

              SizedBox(height: context.spacing(40)),
            ],
          ),
        ),
      ),
    );
  }

  /// Live scanner fullscreen view
  Widget _buildLiveScannerView(PaymentController controller) {
    return Builder(
      builder: (context) => Stack(
        children: [
          // Camera preview
          // if (controller.cameraController != null &&
          //     controller.cameraController!.value.isInitialized)
          //   SizedBox.expand(child: CameraPreview(controller.cameraController!)),

          // Overlay
          Container(color: Colors.black.withValues(alpha: 0.3)),

          // Scan frame (horizontal)
          Center(
            child: Container(
              width: context.responsive(
                mobile: 320.0,
                tablet: 400.0,
                desktop: 480.0,
              ),
              height: context.responsive(
                mobile: 200.0,
                tablet: 250.0,
                desktop: 300.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -2,
                    left: -2,
                    child: _buildCorner(true, true),
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: _buildCorner(true, false),
                  ),
                  Positioned(
                    bottom: -2,
                    left: -2,
                    child: _buildCorner(false, true),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: _buildCorner(false, false),
                  ),
                ],
              ),
            ),
          ),

          // Status text
          Positioned(
            bottom: context.spacing(150),
            left: 0,
            right: 0,
            child: Column(
              children: [
                Obx(
                  () => Text(
                    controller.scanStatus.value,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontSize: context.fontSize(18),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: context.spacing(8)),
                Text(
                  'align_card_frame'.tr,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white70,
                    fontSize: context.fontSize(14),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Close button
        //   Positioned(
        //     bottom: context.spacing(60),
        //     left: 0,
        //     right: 0,
        //     child: Center(
        //       child: GestureDetector(
        //         onTap: controller.stopLiveScanning,
        //         child: Container(
        //           padding: EdgeInsets.symmetric(
        //             horizontal: context.spacing(32),
        //             vertical: context.spacing(16),
        //           ),
        //           decoration: BoxDecoration(
        //             color: Colors.white,
        //             borderRadius: BorderRadius.circular(30),
        //           ),
        //           child: Text(
        //             'cancel'.tr,
        //             style: TextStyle(
        //               fontFamily: 'Cairo',
        //               color: Colors.black,
        //               fontSize: context.fontSize(16),
        //               fontWeight: FontWeight.bold,
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        ],
      ),
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }

  /// Card preview widget (horizontal only)
  // Widget _buildCardPreview(PaymentController controller) {
  //   return Obx(() {
  //     return Center(
  //       child: HorizontalCardWidget(
  //         cardImage: controller.cardImage.value,
  //         cardNumber: controller.cardNumber.value,
  //         expirationDate: controller.expirationDate.value,
  //         cardHolderName: controller.cardHolderName.value,
  //         onTap: controller.pickImageFromGallery,
  //       ),
  //     );
  //   });
  // }

  /// Live scan button
  // Widget _buildLiveScanButton(
  //   PaymentController controller,
  //   BuildContext context,
  // ) {
  //   return GestureDetector(
  //     onTap: controller.startLiveScanning,
  //     child: Container(
  //       width: double.infinity,
  //       padding: EdgeInsets.symmetric(vertical: context.spacing(16)),
  //       decoration: BoxDecoration(
  //         color: primaryColor,
  //         borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
  //         boxShadow: [
  //           BoxShadow(
  //             color: primaryColor.withValues(alpha: 0.3),
  //             blurRadius: 10,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             Icons.camera_alt_outlined,
  //             color: textOnPrimary,
  //             size: context.fontSize(24),
  //           ),
  //           SizedBox(width: context.spacing(12)),
  //           Text(
  //             'scan_card_live'.tr,
  //             style: TextStyle(
  //               fontFamily: 'Cairo',
  //               color: textOnPrimary,
  //               fontSize: context.fontSize(16),
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  /// Or divider
  Widget _buildOrDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: borderColor)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.spacing(16)),
          child: Text(
            'or_enter_manually'.tr,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: textSecondary,
              fontSize: context.fontSize(12),
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: borderColor)),
      ],
    );
  }

  /// Card number input field
  Widget _buildCardNumberInput(
    PaymentController controller,
    BuildContext context,
  ) {
    return Obx(
      () => Directionality(
        textDirection: TextDirection.ltr,
        child: TextField(
          onChanged: controller.updateCardNumber,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
          style: TextStyle(
            fontFamily: 'Cairo',
            color: textPrimary,
            fontSize: context.fontSize(16),
            letterSpacing: 2,
          ),
          decoration: InputDecoration(
            labelText: 'card_number'.tr,
            labelStyle: TextStyle(
              fontFamily: 'Cairo',
              color: textSecondary,
              fontSize: context.fontSize(14),
            ),
            hintText: '1234 5678 9012 3456',
            hintStyle: TextStyle(
              fontFamily: 'Cairo',
              color: textSecondary.withValues(alpha: 0.5),
              fontSize: context.fontSize(14),
            ),
            prefixIcon: Icon(
              Icons.credit_card,
              color: primaryColor,
              size: context.fontSize(24),
            ),
            suffixIcon: controller.cardNumber.value.length == 19
                ? Icon(
                    controller.isCardNumberValid
                        ? Icons.check_circle
                        : Icons.error,
                    color: controller.isCardNumberValid
                        ? successColor
                        : errorColor,
                    size: context.fontSize(24),
                  )
                : null,
            filled: true,
            fillColor: surfaceColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.spacing(16),
              vertical: context.spacing(16),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LightTheme.borderRadius),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LightTheme.borderRadius),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LightTheme.borderRadius),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
          controller: TextEditingController(text: controller.cardNumber.value)
            ..selection = TextSelection.collapsed(
              offset: controller.cardNumber.value.length,
            ),
        ),
      ),
    );
  }

  /// Cardholder name input field
  Widget _buildCardHolderNameInput(
    PaymentController controller,
    BuildContext context,
  ) {
    return Obx(
      () => TextField(
        onChanged: controller.updateCardHolderName,
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.words,
        style: TextStyle(
          fontFamily: 'Cairo',
          color: textPrimary,
          fontSize: context.fontSize(16),
        ),
        decoration: InputDecoration(
          labelText: 'cardholder_name'.tr,
          labelStyle: TextStyle(
            fontFamily: 'Cairo',
            color: textSecondary,
            fontSize: context.fontSize(14),
          ),
          hintText: 'enter_full_name'.tr,
          hintStyle: TextStyle(
            fontFamily: 'Cairo',
            color: textSecondary.withValues(alpha: 0.5),
            fontSize: context.fontSize(14),
          ),
          prefixIcon: Icon(
            Icons.person_outline,
            color: primaryColor,
            size: context.fontSize(24),
          ),
          suffixIcon:
              controller.cardHolderName.value.trim().split(' ').length >= 2
              ? Icon(
                  Icons.check_circle,
                  color: successColor,
                  size: context.fontSize(24),
                )
              : null,
          filled: true,
          fillColor: surfaceColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.spacing(16),
            vertical: context.spacing(16),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LightTheme.borderRadius),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LightTheme.borderRadius),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LightTheme.borderRadius),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
        ),
        controller: TextEditingController(text: controller.cardHolderName.value)
          ..selection = TextSelection.collapsed(
            offset: controller.cardHolderName.value.length,
          ),
      ),
    );
  }

  /// Expiration date input
  Widget _buildExpirationInput(
    PaymentController controller,
    BuildContext context,
  ) {
    return Obx(
      () => TextField(
        onChanged: controller.updateExpirationDate,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        style: TextStyle(
          fontFamily: 'Cairo',
          color: textPrimary,
          fontSize: context.fontSize(16),
        ),
        decoration: InputDecoration(
          labelText: 'expiry_date'.tr,
          labelStyle: TextStyle(
            fontFamily: 'Cairo',
            color: textSecondary,
            fontSize: context.fontSize(14),
          ),
          hintText: 'MM/YY',
          hintStyle: TextStyle(
            fontFamily: 'Cairo',
            color: textSecondary.withValues(alpha: 0.5),
            fontSize: context.fontSize(14),
          ),
          prefixIcon: Icon(
            Icons.calendar_today,
            color: primaryColor,
            size: context.fontSize(24),
          ),
          filled: true,
          fillColor: surfaceColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.spacing(16),
            vertical: context.spacing(16),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LightTheme.borderRadius),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LightTheme.borderRadius),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LightTheme.borderRadius),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
        ),
        controller: TextEditingController(text: controller.expirationDate.value)
          ..selection = TextSelection.collapsed(
            offset: controller.expirationDate.value.length,
          ),
      ),
    );
  }

  /// CVV input
  Widget _buildCVVInput(PaymentController controller, BuildContext context) {
    return Obx(
      () => TextField(
        onChanged: (value) => controller.cvv.value = value,
        keyboardType: TextInputType.number,
        obscureText: true,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        style: TextStyle(
          fontFamily: 'Cairo',
          color: textPrimary,
          fontSize: context.fontSize(16),
        ),
        decoration: InputDecoration(
          labelText: 'cvv'.tr,
          labelStyle: TextStyle(
            fontFamily: 'Cairo',
            color: textSecondary,
            fontSize: context.fontSize(14),
          ),
          hintText: '•••',
          hintStyle: TextStyle(
            fontFamily: 'Cairo',
            color: textSecondary.withValues(alpha: 0.5),
            fontSize: context.fontSize(14),
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: primaryColor,
            size: context.fontSize(24),
          ),
          filled: true,
          fillColor: surfaceColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.spacing(16),
            vertical: context.spacing(16),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LightTheme.borderRadius),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LightTheme.borderRadius),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LightTheme.borderRadius),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
        ),
        controller: TextEditingController(text: controller.cvv.value)
          ..selection = TextSelection.collapsed(
            offset: controller.cvv.value.length,
          ),
      ),
    );
  }

  /// Pay now button
  Widget _buildPayButton(PaymentController controller, BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: controller.isProcessing.value ? null : controller.processPayment,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: context.spacing(18)),
          decoration: BoxDecoration(
            color: controller.isFormValid ? primaryColor : surfaceColor,
            borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
            border: Border.all(
              color: controller.isFormValid ? primaryColor : borderColor,
            ),
            boxShadow: controller.isFormValid
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: controller.isProcessing.value
                ? SizedBox(
                    width: context.fontSize(24),
                    height: context.fontSize(24),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: textOnPrimary,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock,
                        color: controller.isFormValid
                            ? textOnPrimary
                            : textSecondary,
                        size: context.fontSize(20),
                      ),
                      SizedBox(width: context.spacing(8)),
                      Text(
                        'pay_now'.tr,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: controller.isFormValid
                              ? textOnPrimary
                              : textSecondary,
                          fontSize: context.fontSize(18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// Invoice summary card displaying reservation details (expandable)
  Widget _buildInvoiceSummaryCard(
    PaymentController controller,
    BuildContext context,
  ) {
    return Obx(
      () => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(LightTheme.borderRadiusLarge),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: isDark ? DarkTheme.shadowLight : LightTheme.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            initiallyExpanded: false,
            tilePadding: EdgeInsets.symmetric(
              horizontal: context.spacing(16),
              vertical: context.spacing(8),
            ),
            childrenPadding: EdgeInsets.only(
              left: context.spacing(16),
              right: context.spacing(16),
              bottom: context.spacing(16),
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                color: primaryColor,
                size: context.fontSize(20),
              ),
            ),
            title: Text(
              'invoice_details'.tr,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: context.fontSize(16),
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            trailing: Icon(Icons.keyboard_arrow_down, color: textSecondary),
            iconColor: textSecondary,
            collapsedIconColor: textSecondary,
            children: [
              // Restaurant Name
              _buildInvoiceRow(
                context,
                icon: Icons.restaurant,
                label: 'restaurant'.tr,
                value: controller.restaurantName.value,
              ),

              _buildInvoiceDivider(),

              // Date
              _buildInvoiceRow(
                context,
                icon: Icons.calendar_today,
                label: 'date'.tr,
                value: controller.dateDisplay.value,
              ),

              _buildInvoiceDivider(),

              // Time
              _buildInvoiceRow(
                context,
                icon: Icons.access_time,
                label: 'time'.tr,
                value: controller.timeDisplay.value,
              ),

              _buildInvoiceDivider(),

              // Guests
              _buildInvoiceRow(
                context,
                icon: Icons.people,
                label: 'guests'.tr,
                value: '${controller.guestCount.value}',
              ),

              SizedBox(height: context.spacing(12)),

              // Total Price
              Container(
                padding: EdgeInsets.all(context.spacing(12)),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(LightTheme.borderRadius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'total_amount'.tr,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: context.fontSize(14),
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      '${controller.totalPrice.value.toStringAsFixed(0)} ${'currency'.tr}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: context.fontSize(18),
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Invoice row item
  Widget _buildInvoiceRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing(10)),
      child: Row(
        children: [
          Icon(icon, size: context.fontSize(18), color: textSecondary),
          SizedBox(width: context.spacing(12)),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: context.fontSize(14),
                color: textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: context.fontSize(14),
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplePaySection(
    PaymentController controller,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'express_checkout'.tr,
          style: TextStyle(
            fontFamily: 'Cairo',
            color: textPrimary,
            fontSize: context.fontSize(18),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.spacing(12)),

        // Apple Pay Button
        ApplePayButtonWidget(
          controller: controller,
          onPressed: () {
            controller.selectPaymentMethod('apple_pay');
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: borderColor)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.spacing(16)),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing(12),
              vertical: context.spacing(6),
            ),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              'or'.tr,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: textSecondary,
                fontSize: context.fontSize(12),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: borderColor)),
      ],
    );
  }

  /// Divider for invoice rows
  Widget _buildInvoiceDivider() {
    return Container(height: 1, color: borderColor.withValues(alpha: 0.5));
  }
}
