import 'package:achaytablereservation/app/bindings/auth_binding.dart';
import 'package:achaytablereservation/app/bindings/initial_binding.dart';
import 'package:achaytablereservation/features/homepage/bindings/home_page_binding.dart';
import 'package:achaytablereservation/app/routes/app_routes.dart';
import 'package:achaytablereservation/core/middleware/auth_middleware.dart';
import 'package:achaytablereservation/features/authentication/ui/screens/loginpage.dart';
import 'package:achaytablereservation/features/authentication/ui/screens/otppage.dart';
import 'package:achaytablereservation/features/authentication/ui/screens/reset_password_page.dart';
import 'package:achaytablereservation/features/authentication/ui/screens/sign_in_page.dart';
import 'package:achaytablereservation/features/authentication/ui/screens/forgetpassword.dart';
import 'package:achaytablereservation/features/homepage/ui/screen/branch_info_page.dart';
import 'package:achaytablereservation/features/navigation/bindings/main_navigation_binding.dart';
import 'package:achaytablereservation/features/navigation/ui/main_navigation_scaffold.dart';
import 'package:achaytablereservation/features/payment/ui/screen/payment_page.dart';
import 'package:achaytablereservation/features/profile/di/profile_bindings.dart';
import 'package:achaytablereservation/features/profile/ui/screen/change_phone_screen.dart';
import 'package:achaytablereservation/features/profile/ui/screen/profile_screen.dart';
import 'package:achaytablereservation/features/profile/ui/screen/update_password_screen.dart';
import 'package:achaytablereservation/features/profile/ui/screen/update_profile_screen.dart';
import 'package:achaytablereservation/features/reservation/bindging/reservationbinding.dart';
import 'package:achaytablereservation/features/reservation/bindging/reservation_confirmation_binding.dart';
import 'package:achaytablereservation/features/reservation/bindging/bookings_binding.dart';
import 'package:achaytablereservation/features/reservation/ui/screen/reservation_confirmation_page.dart';
import 'package:achaytablereservation/features/reservation/ui/screen/reservation_page.dart';
import 'package:achaytablereservation/features/reservation/ui/screen/booking_details.dart';
import 'package:achaytablereservation/features/setupfeature/ui/splash_screen.dart';
import 'package:achaytablereservation/features/homepage/ui/screen/homepage.dart';
import 'package:achaytablereservation/features/more/ui/screen/terms_conditions_page.dart';
import 'package:achaytablereservation/app/Setting/settings_page.dart';
import 'package:achaytablereservation/app/Setting/settings_binding.dart';
import 'package:get/get.dart';

class AppPages {
  // Prevent instantiation
  AppPages._();

  /// List of all application pages with their configurations
  /// Enhanced for authentication persistence with proper splash screen configuration
  static final routes = [
    // ==================== App Initialization ====================
    // Splash screen - handles app startup and authentication flow
    // Uses InitialBinding which includes all necessary dependencies
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
      // binding:
      //     InitialBinding(), // Contains all core dependencies including auth
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ==================== Authentication Routes ====================
    // Login page - for user authentication
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginPage(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [Authmiddeleware()], // Redirects authenticated users to home
    ),

    // Registration page - for new user sign up
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => SignUpPage(),
      binding: SignUpBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [Authmiddeleware()], // Redirects authenticated users to home
    ),

    // OTP verification page - for phone number verification
    GetPage(
      name: AppRoutes.OTP,
      page: () => OtpPage(),
      binding: OtpBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      // No middleware - OTP can be accessed during auth flow
    ),

    // Forgot password page - for password reset
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD,
      page: () => ForgotPasswordPage(),
      binding: ForgotPasswordBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [Authmiddeleware()], // Redirects authenticated users to home
    ),

    // Reset password page - for setting new password
    GetPage(
      name: AppRoutes.RESET_PASSWORD,
      page: () => ResetPasswordPage(),
      binding: ResetPasswordBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [Authmiddeleware()], // Redirects authenticated users to home
    ),

    // ==================== Main Navigation ====================
    // Main navigation scaffold - bottom navigation bar (protected)
    GetPage(
      name: AppRoutes.MAIN_NAVIGATION,
      page: () => const MainNavigationScaffold(),
      binding: MainNavigationBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [
        Authmiddeleware(),
      ], // Redirects unauthenticated users to login
    ),

    // ==================== Protected Routes ====================
    // Home page - the main landing page (protected)
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      binding: HomePageBinding(),
      middlewares: [Authmiddeleware()],
      // Redirects unauthenticated users to login
    ),

    // ==================== Protected Routes ====================
    // Profile page - the main landing page (protected)
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => ProfileScreen(),
      binding: ProfileBindings(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.UpdateProfile,
      page: () => UpdateProfileScreen(),
      binding: UpdateProfileBindings(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.UpdatePassword,
      page: () => UpdatePasswordScreen(),
      binding: UpdatePasswordBindings(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.ChangePhone,
      page: () => ChangePhoneScreen(),
      binding: ChangePhoneBindings(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.branchinfor,
      page: () => const BranchInfoPage(),
      transition: Transition.rightToLeft, // Optional: slide animation
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.reservationpage,
      page: () => const ReservationPage(),
      transition: Transition.rightToLeft, // Optional: slide animation
      transitionDuration: const Duration(milliseconds: 300),
      binding: ReservationBinding(),
    ),
    GetPage(
      name: AppRoutes.reservationpageconfirmation,
      page: () => ReservationConfirmationpage(),
      transition: Transition.leftToRight, // Optional: slide animation
      transitionDuration: const Duration(milliseconds: 300),
      binding: ReservationConfirmationBinding(),
    ),
    GetPage(
      name: AppRoutes.paymentpage,
      // page: () => PaymentPage(totalPrice: Get.arguments,),
      page: () => PaymentPage(),
      transition: Transition.rightToLeft, // Optional: slide animation
      transitionDuration: const Duration(milliseconds: 300),
      binding: ReservationConfirmationBinding(),
    ),

    // ==================== Booking Details ====================
    GetPage(
      name: AppRoutes.bookingDetails,
      page: () => const BookingDetails(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      binding: BookingDetailBinding(),
    ),

    // ==================== Settings ====================
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      binding: SettingsBinding(),
    ),

    // ==================== Terms & Conditions ====================
    GetPage(
      name: AppRoutes.TERMS_CONDITIONS,
      page: () => const TermsConditionsPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
