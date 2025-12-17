/// Centralized app configuration and constants
/// Use this to avoid magic numbers and enable easy environment switching
library;

class AppConfig {
  AppConfig._();

  // ============ Environment ============
  static const bool isDemoMode = true;
  static const String appName = 'Discover Malaysia';
  static const String appVersion = '1.0.0';

  // ============ Pricing ============
  /// Sales and Service Tax (SST) rate in Malaysia
  static const double taxRate = 0.06;
  static const String taxLabel = 'SST (6%)';
  static const String currencySymbol = 'RM';

  // ============ Demo Credentials ============
  static const String demoUserEmail = 'john@example.com';
  static const String demoUserPassword = 'password123';
  static const String demoAdminEmail = 'admin@discovermalaysia.com';
  static const String demoAdminPassword = 'admin123';

  // ============ Validation ============
  static const int minPasswordLength = 6;
  static const int maxVisitorNameLength = 50;

  // ============ UI Constants ============
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;

  // ============ Date/Time ============
  /// How many days in advance can users book
  static const int maxBookingDaysAhead = 90;
  /// Minimum days before visit for cancellation
  static const int minCancellationDays = 1;

  // ============ Formatting Helpers ============
  /// Format a price with currency symbol
  static String formatPrice(double price) {
    if (price == 0) return 'FREE';
    return '$currencySymbol ${price.toStringAsFixed(2)}';
  }

  /// Format a distance in km
  static String formatDistance(double? distanceKm) {
    if (distanceKm == null) return 'Distance N/A';
    return '${distanceKm.toStringAsFixed(1)}km away';
  }
}
