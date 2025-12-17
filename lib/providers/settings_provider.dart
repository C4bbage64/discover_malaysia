import 'package:flutter/foundation.dart';

/// App settings and preferences
/// Currently uses in-memory storage; can be swapped to SharedPreferences later
class SettingsProvider extends ChangeNotifier {
  // ============ Theme Settings ============
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  // ============ Notification Settings ============
  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  bool _emailNotifications = true;
  bool get emailNotifications => _emailNotifications;

  void setEmailNotifications(bool value) {
    _emailNotifications = value;
    notifyListeners();
  }

  bool _bookingReminders = true;
  bool get bookingReminders => _bookingReminders;

  void setBookingReminders(bool value) {
    _bookingReminders = value;
    notifyListeners();
  }

  bool _promotionalNotifications = false;
  bool get promotionalNotifications => _promotionalNotifications;

  void setPromotionalNotifications(bool value) {
    _promotionalNotifications = value;
    notifyListeners();
  }

  // ============ Privacy Settings ============
  bool _locationEnabled = true;
  bool get locationEnabled => _locationEnabled;

  void setLocationEnabled(bool value) {
    _locationEnabled = value;
    notifyListeners();
  }

  bool _analyticsEnabled = true;
  bool get analyticsEnabled => _analyticsEnabled;

  void setAnalyticsEnabled(bool value) {
    _analyticsEnabled = value;
    notifyListeners();
  }

  // ============ Display Settings ============
  String _language = 'English';
  String get language => _language;

  static const List<String> supportedLanguages = [
    'English',
    'Bahasa Malaysia',
    'Chinese',
    'Tamil',
  ];

  void setLanguage(String value) {
    _language = value;
    notifyListeners();
  }

  String _currency = 'MYR';
  String get currency => _currency;

  static const List<String> supportedCurrencies = [
    'MYR',
    'USD',
    'SGD',
  ];

  void setCurrency(String value) {
    _currency = value;
    notifyListeners();
  }

  String _distanceUnit = 'km';
  String get distanceUnit => _distanceUnit;

  void setDistanceUnit(String value) {
    _distanceUnit = value;
    notifyListeners();
  }

  // ============ Reset ============
  void resetToDefaults() {
    _isDarkMode = false;
    _notificationsEnabled = true;
    _emailNotifications = true;
    _bookingReminders = true;
    _promotionalNotifications = false;
    _locationEnabled = true;
    _analyticsEnabled = true;
    _language = 'English';
    _currency = 'MYR';
    _distanceUnit = 'km';
    notifyListeners();
  }
}
