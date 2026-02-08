import 'package:achaytablereservation/features/setupfeature/logic/splash_screen_controller.dart';
import 'package:achaytablereservation/core/assets/assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the controller
    final controller = Get.find<SplashScreenController>();

    // Get theme colors dynamically
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final surfaceColor = theme.colorScheme.surface;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background subtle decoration
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Container
                Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: AssetHelper.loadImage(
                        AppImages.LOGO,
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                        errorWidget: const Text('Failed to load image'),
                      ),
                    )
                    .animate()
                    .scale(duration: 800.ms, curve: Curves.easeOutBack)
                    .fade(duration: 600.ms),

                const SizedBox(height: 32),

                // // Title
                // Text(
                //       "TeaBake".tr,
                //       style: GoogleFonts.playfairDisplay(
                //         fontSize: 36,
                //         fontWeight: FontWeight.bold,
                //         color: textPrimary,
                //         height: 1.2,
                //       ),
                //     )
                //     .animate()
                //     .fadeIn(delay: 400.ms, duration: 600.ms)
                //     .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
                const SizedBox(height: 12),

                // // Subtitle
                // Text(
                //       "distancedont".tr,
                //       style: GoogleFonts.lato(
                //         fontSize: 16,
                //         color: textSecondary,
                //         letterSpacing: 1.2,
                //       ),
                //     )
                //     .animate()
                //     .fadeIn(delay: 600.ms, duration: 600.ms)
                //     .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                const SizedBox(height: 40),

                // // Status message
                // Obx(
                //   () => Text(
                //     controller.currentStatus,
                //     style: GoogleFonts.lato(fontSize: 14, color: textSecondary),
                //   ).animate().fadeIn(delay: 800.ms),
                // ),
              ],
            ),
          ),

          // Loading Indicator or Error
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Obx(() {
                if (controller.hasInitializationError) {
                  return Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error.withValues(alpha: 0.7),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: controller.retryInitialization,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  );
                } else {
                  return SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: textColor.withValues(alpha: 0.5),
                      strokeWidth: 2,
                    ),
                  );
                }
              }),
            ).animate().fadeIn(delay: 1000.ms),
          ),
        ],
      ),
    );
  }
}
