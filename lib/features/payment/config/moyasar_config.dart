// ============================================================================
// STEP 2A: Moyasar Configuration
// ============================================================================
// File: lib/core/config/moyasar_config.dart
// ============================================================================

/// Moyasar Payment Gateway Configuration
///
/// IMPORTANT: In production, load these from environment variables or
/// secure storage, not hardcoded!
class MoyasarConfig {
  MoyasarConfig._();

  // ======================== API Keys ========================
  // Use test keys for development, live keys for production

  /// Publishable API Key (safe to use in client-side code)
  /// Used for: Creating payments from Flutter app
  static const String publishableKey =
      'pk_test_8zs4A361QwqbMoRQTTnjap1g7ihNe4L7xxRzV2cE';

  /// Secret API Key (NEVER expose in client code!)
  /// Used for: Backend webhook verification, refunds, captures
  /// This should ONLY be on your ASP.NET server
  static const String secretKey =
      'sk_test_YOUR_SECRET_KEY_HERE'; // DON'T USE IN FLUTTER!

  // ======================== Environment ========================

  /// Set to true when going live
  static const bool isProduction = false;

  /// API Base URL
  static String get apiBaseUrl => 'https://api.moyasar.com/v1';

  // ======================== Payment Settings ========================

  /// Currency code (Saudi Riyal)
  static const String currency = 'SAR';

  /// Callback URL for 3DS redirect
  /// This URL is where Moyasar redirects after 3DS authentication
  /// The Flutter app intercepts this URL to know payment is complete
  static const String callbackUrl =
      'https://your-backend.com/api/payments/callback';

  /// Webhook URL for backend notifications
  static const String webhookUrl =
      'https://your-backend.com/api/webhooks/moyasar';

  // ======================== Apple Pay Settings ========================

  /// Apple Pay Merchant ID (from Apple Developer Portal)
  static const String appleMerchantId = 'merchant.com.mysr.apple';

  /// Display name shown on Apple Pay sheet
  static const String applePayDisplayName = 'Achay Table Reservation';

  // ======================== Supported Payment Methods ========================

  /// Supported card networks
  static const List<String> supportedNetworks = [
    'visa',
    'masterCard',
    'mada', // Saudi debit cards
  ];

  // ======================== Helper Methods ========================

  /// Convert SAR amount to halalas (smallest unit)
  /// Moyasar requires amounts in halalas (1 SAR = 100 halalas)
  static int toHalalas(double sarAmount) {
    return (sarAmount * 100).round();
  }

  /// Convert halalas back to SAR for display
  static double toSAR(int halalas) {
    return halalas / 100;
  }
}
