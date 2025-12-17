/// Base exception class for app-specific errors
/// Provides consistent error handling across the application
library;

/// Base class for all app exceptions
sealed class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message';
}

/// Authentication-related errors
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.originalError});

  factory AuthException.invalidCredentials() =>
      const AuthException('Invalid email or password', code: 'invalid_credentials');

  factory AuthException.userNotFound() =>
      const AuthException('User not found. Please register first.', code: 'user_not_found');

  factory AuthException.emailAlreadyExists() =>
      const AuthException('Email already registered. Please login.', code: 'email_exists');

  factory AuthException.weakPassword() =>
      const AuthException('Password must be at least 6 characters', code: 'weak_password');

  factory AuthException.invalidEmail() =>
      const AuthException('Please enter a valid email address', code: 'invalid_email');

  factory AuthException.emptyName() =>
      const AuthException('Name is required', code: 'empty_name');
}

/// Booking-related errors
class BookingException extends AppException {
  const BookingException(super.message, {super.code, super.originalError});

  factory BookingException.notFound() =>
      const BookingException('Booking not found', code: 'booking_not_found');

  factory BookingException.cannotCancel() =>
      const BookingException('This booking cannot be cancelled', code: 'cannot_cancel');

  factory BookingException.invalidDate() =>
      const BookingException('Please select a valid visit date', code: 'invalid_date');

  factory BookingException.noTicketsSelected() =>
      const BookingException('Please select at least one ticket', code: 'no_tickets');

  factory BookingException.missingVisitorNames() =>
      const BookingException('Please enter names for all visitors', code: 'missing_names');
}

/// Destination-related errors
class DestinationException extends AppException {
  const DestinationException(super.message, {super.code, super.originalError});

  factory DestinationException.notFound() =>
      const DestinationException('Destination not found', code: 'destination_not_found');

  factory DestinationException.invalidData() =>
      const DestinationException('Invalid destination data', code: 'invalid_data');
}

/// Network and external service errors
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.originalError});

  factory NetworkException.noConnection() =>
      const NetworkException('No internet connection', code: 'no_connection');

  factory NetworkException.timeout() =>
      const NetworkException('Request timed out. Please try again.', code: 'timeout');

  factory NetworkException.serverError() =>
      const NetworkException('Server error. Please try again later.', code: 'server_error');

  factory NetworkException.launchFailed(String url) =>
      NetworkException('Could not open $url', code: 'launch_failed');
}
