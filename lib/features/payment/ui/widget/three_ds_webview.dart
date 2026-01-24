// ============================================================================
// STEP 3: 3DS WebView Widget
// ============================================================================
// File: lib/features/payment/ui/widget/three_ds_webview.dart
// ============================================================================

import 'package:achaytablereservation/features/payment/config/moyasar_config.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'package:achaytablereservation/app/themes/dark_theme.dart';
import 'package:achaytablereservation/app/themes/light_theme.dart';

// ============================================================================
// 3DS WEBVIEW CONTROLLER
// ============================================================================

class ThreeDSWebViewController extends GetxController {
  late final WebViewController webViewController;

  final String transactionUrl;
  final String paymentId;
  final String? callbackUrl;

  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();
  final RxDouble loadingProgress = 0.0.obs;

  // Theme helpers
  bool get isDark => Get.isDarkMode;
  Color get backgroundColor =>
      isDark ? DarkTheme.backgroundColor : LightTheme.backgroundColor;
  Color get textPrimary =>
      isDark ? DarkTheme.textPrimary : LightTheme.textPrimary;
  Color get primaryColor =>
      isDark ? DarkTheme.secondaryColor : LightTheme.primaryColor;

  ThreeDSWebViewController({
    required this.transactionUrl,
    required this.paymentId,
    this.callbackUrl,
  });

  @override
  void onInit() {
    super.onInit();
    _initializeWebView();
  }

  void _initializeWebView() {
    final effectiveCallbackUrl = callbackUrl ?? MoyasarConfig.callbackUrl;
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(backgroundColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            loadingProgress.value = progress / 100;
          },
          onPageStarted: (String url) {
            isLoading.value = true;
            error.value = null;
          },
          onPageFinished: (String url) {
            isLoading.value = false;
          },
          onWebResourceError: (WebResourceError err) {
            // Don't show error for callback URL interception
            if (!err.description.contains('callback')) {
              error.value = 'failed_to_load'.tr;
              isLoading.value = false;
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Intercept callback URL
            if (request.url.startsWith(effectiveCallbackUrl) ||
                request.url.contains('callback') ||
                request.url.contains('moyasar')) {
              _handleCallbackUrl(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(transactionUrl));
  }

  /// Parse the callback URL and extract payment result
  void _handleCallbackUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final params = uri.queryParameters;

      final id = params['id'] ?? paymentId;
      final status = params['status'] ?? 'unknown';
      final message = params['message'];

      // Return result to caller
      Get.back<ThreeDSResult>(
        result: ThreeDSResult(
          paymentId: id,
          status: status,
          message: message,
          success: status.toLowerCase() == 'paid',
        ),
      );
    } catch (e) {
      // If parsing fails, return with unknown status
      Get.back<ThreeDSResult>(
        result: ThreeDSResult(
          paymentId: paymentId,
          status: 'unknown',
          message: 'Failed to parse callback',
          success: false,
        ),
      );
    }
  }

  /// Handle back button press
  Future<void> onWillPop() async {
    // Show confirmation dialog before cancelling
    final shouldCancel = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: backgroundColor,
        title: Text(
          'cancel_payment'.tr,
          style: TextStyle(
            fontFamily: 'Cairo',
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'cancel_payment_confirmation'.tr,
          style: TextStyle(fontFamily: 'Cairo', color: textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'no'.tr,
              style: TextStyle(fontFamily: 'Cairo', color: primaryColor),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'yes'.tr,
              style: TextStyle(fontFamily: 'Cairo', color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldCancel == true) {
      Get.back<ThreeDSResult>(
        result: ThreeDSResult(
          paymentId: paymentId,
          status: 'cancelled',
          message: 'User cancelled 3DS authentication',
          success: false,
          cancelled: true,
        ),
      );
    }
  }

  void retryLoading() {
    error.value = null;
    isLoading.value = true;
    webViewController.loadRequest(Uri.parse(transactionUrl));
  }
}

// ============================================================================
// 3DS WEBVIEW WIDGET
// ============================================================================

/// 3DS Authentication WebView
///
/// Displays the bank's 3D Secure authentication page where user enters OTP.
///
/// Flow:
/// 1. Load the transaction_url from Moyasar
/// 2. User sees bank's page and enters OTP
/// 3. Bank redirects to callback_url with payment status
/// 4. Widget intercepts the redirect and returns result
///
/// Usage:
/// ```dart
/// final result = await Get.to<ThreeDSResult>(
///   () => ThreeDSWebView(
///     transactionUrl: paymentResult.transactionUrl!,
///     paymentId: paymentResult.paymentId!,
///   ),
/// );
/// ```
class ThreeDSWebView extends StatelessWidget {
  /// The 3DS authentication URL from Moyasar
  final String transactionUrl;

  /// The payment ID for reference
  final String paymentId;

  /// Optional: Custom callback URL (defaults to MoyasarConfig.callbackUrl)
  final String? callbackUrl;

  const ThreeDSWebView({
    super.key,
    required this.transactionUrl,
    required this.paymentId,
    this.callbackUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(
      ThreeDSWebViewController(
        transactionUrl: transactionUrl,
        paymentId: paymentId,
        callbackUrl: callbackUrl,
      ),
      tag: paymentId, // Use unique tag to allow multiple instances
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await controller.onWillPop();
        }
      },
      child: Scaffold(
        backgroundColor: controller.backgroundColor,
        appBar: AppBar(
          backgroundColor: controller.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: controller.textPrimary),
            onPressed: controller.onWillPop,
          ),
          title: Text(
            'verify_payment'.tr,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: controller.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: Obx(
              () => controller.isLoading.value
                  ? LinearProgressIndicator(
                      value: controller.loadingProgress.value,
                      backgroundColor: controller.backgroundColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        controller.primaryColor,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        body: Obx(() => _buildBody(controller)),
      ),
    );
  }

  Widget _buildBody(ThreeDSWebViewController controller) {
    if (controller.error.value != null) {
      return _buildErrorView(controller);
    }

    return Stack(
      children: [
        // WebView
        WebViewWidget(controller: controller.webViewController),

        // Loading overlay for initial load
        if (controller.isLoading.value &&
            controller.loadingProgress.value < 0.3)
          Container(
            color: controller.backgroundColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: controller.primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'loading_verification'.tr,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: controller.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorView(ThreeDSWebViewController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              controller.error.value!,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: controller.textPrimary,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.retryLoading,
              icon: const Icon(Icons.refresh),
              label: Text(
                'retry'.tr,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 3DS RESULT MODEL
// ============================================================================

/// Result from 3DS authentication
class ThreeDSResult {
  final String paymentId;
  final String status;
  final String? message;
  final bool success;
  final bool cancelled;

  ThreeDSResult({
    required this.paymentId,
    required this.status,
    this.message,
    this.success = false,
    this.cancelled = false,
  });

  @override
  String toString() {
    return 'ThreeDSResult(paymentId: $paymentId, status: $status, success: $success, cancelled: $cancelled)';
  }
}
