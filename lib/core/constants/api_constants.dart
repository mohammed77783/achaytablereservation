/// API configuration constants for the application
/// Includes base URLs, endpoints, timeout settings, and headers
class ApiConstants {
  // Private constructor to prevent instantiation
  ApiConstants._();
  // ==================== Base URLs ====================
  /// Development environment base URL
  /// static const String baseUrl = 'http://10.0.2.2/HrApiProject/public/api/v1';
  // ==================== API Endpoints ====================
  static const String Auth = "/Auth";
  static const String Home = "/Home";
  static const String Restaurant = "/Restaurant";
  static const String Reservation = "/Reservation";
  // Authentication endpoints
  static const String login = '${Auth}/login';
  static const String register = '${Auth}/register';
  static const String logout = '${Auth}/logout';
  static const String refreshToken = '${Auth}/refresh';
  static const String forgotPassword = '${Auth}/forgot-password';
  static const String resetPassword = '${Auth}/reset-password';
  static const String verifyOtp = "${Auth}/{operation}/verify";
  static const String getCurrentUser = '${Auth}/me';
  // Home endpoints
  static const String homeIndex = '${Home}/index';
  static const String branchGellery ='${Home}/restaurant/{restaurantId}/gallery';
  static const String businessHours = '${Restaurant}/business-hours';
  static const String policies = '${Restaurant}/policies';
  // Reservation endpoints
  static const String checkTableAvailability = '${Reservation}/check-availability';
  static const String createReservation = '${Reservation}/create';
  static const String confirmReservation = '${Reservation}/confirm';
  static const String myReservations = '${Reservation}/my-reservations';
  static const String reservationDetail =
      Reservation; // /api/Reservation/{bookingId}
  // User endpoints
  static const String profile = '/Profile';
  static const String profilePassword = '${profile}/password';
  static const String profilePhoneChange = '${profile}/phone/change';
  static const String profilePhoneVerify = '${profile}/phone/verify';
  // ==================== Timeout & Retry Configuration ====================
  /// Connection timeout in milliseconds (30 seconds)
  static const int connectionTimeout = 30000;

  /// Receive timeout in milliseconds (30 seconds)
  static const int receiveTimeout = 30000;

  /// Send timeout in milliseconds (30 seconds)
  static const int sendTimeout = 30000;

  /// Maximum number of retry attempts for failed requests
  static const int maxRetries = 1;

  /// Delay between retry attempts in milliseconds
  static const int retryDelay = 1000;
  // ==================== HTTP Headers ====================

  /// Content-Type header key
  static const String headerContentType = 'Content-Type';

  /// Authorization header key
  static const String headerAuthorization = 'Authorization';

  /// Accept header key
  static const String headerAccept = 'Accept';

  /// Accept-Language header key
  static const String headerAcceptLanguage = 'Accept-Language';

  /// API Key header key (if needed)
  static const String headerApiKey = 'X-API-Key';

  /// User-Agent header key
  static const String headerUserAgent = 'User-Agent';

  // ==================== Header Values ====================

  /// JSON content type value
  static const String contentTypeJson = 'application/json';

  /// Form data content type value
  static const String contentTypeFormData = 'application/x-www-form-urlencoded';

  /// Multipart form data content type value
  static const String contentTypeMultipart = 'multipart/form-data';

  /// Bearer token prefix for authorization
  static const String bearerPrefix = 'Bearer ';

  // ==================== API Versioning ====================

  /// API version
  static const String apiVersion = 'v1';

  /// API version path prefix
  static const String apiVersionPath = '/api/$apiVersion';

  // ==================== Status Codes ====================

  /// Success status code
  static const int statusSuccess = 200;

  /// Created status code
  static const int statusCreated = 201;

  /// Bad request status code
  static const int statusBadRequest = 400;

  /// Unauthorized status code
  static const int statusUnauthorized = 401;

  /// Forbidden status code
  static const int statusForbidden = 403;

  /// Not found status code
  static const int statusNotFound = 404;

  /// Internal server error status code
  static const int statusInternalServerError = 500;
}
