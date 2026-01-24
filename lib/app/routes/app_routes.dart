/// Route name constants for the application
///
/// This class defines all route paths used throughout the application.
/// Using constants ensures type-safety and prevents typos in route names.
class AppRoutes {
  // Prevent instantiation
  AppRoutes._();

  /// Splash screen route - the initial loading screen
  static const String SPLASH = '/splash';

  /// Login page route - for user authentication
  static const String LOGIN = '/login';

  /// Registration page route - for new user sign up
  static const String REGISTER = '/register';

  /// OTP verification page route - for phone number verification
  static const String OTP = '/otp';

  /// Forgot password page route - for password reset
  static const String FORGOT_PASSWORD = '/forgot-password';

  /// Reset password page route - for setting new password
  static const String RESET_PASSWORD = '/reset-password';

  //========================   NAVIGATION      ====================================
  /// Main navigation route - the bottom navigation scaffold
  static const String MAIN_NAVIGATION = '/main';

  //========================   HOME PAGE      ====================================
  /// Home page route - the main landing page
  static const String HOME = '/home';
  static const String branchinfor = '/branchinfor';
  static const String reservationpage = '/reservationpage';
  static const String reservationpageconfirmation =
      '/reservationpageconfirmation';

  //========================   BOOKINGS PAGE      ====================================
  /// Booking details page route
  static const String bookingDetails = '/booking-details';

  //========================   PayMent PAGE      ====================================
  static const String paymentpage = '/paymentpage';

  /// Settings page route - for app configuration
  static const String SETTINGS = '/settings';

  /// Initial route when app starts
  static const String INITIAL = SPLASH;

  /// Settings page route - for app configuration
  static const String Dashbordpage = '/Dashbordpage';

  /// Edit profile page route - for editing user profile information
  static const String EDIT_PROFILE = '/edit-profile';
  static const String PROFILE = '/profile';

  static const String UpdateProfile = "/updateProfile";

  static const String UpdatePassword = "/updatePassword";
  static const String ChangePhone = "/changePhone";

  /// Terms and Conditions page route
  static const String TERMS_CONDITIONS = '/terms-conditions';
}
