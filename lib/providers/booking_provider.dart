import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../models/destination.dart';
import '../services/booking_repository.dart';
import '../services/interfaces/booking_repository_interface.dart';

/// ChangeNotifier wrapper for booking state
/// Allows widgets to rebuild when bookings change
class BookingProvider extends ChangeNotifier {
  final IBookingRepository _repository;
  bool _isLoading = false;
  String? _error;
  Booking? _lastCreatedBooking;

  BookingProvider({IBookingRepository? repository})
      : _repository = repository ?? BookingRepository();

  // ============ Getters ============

  bool get isLoading => _isLoading;
  String? get error => _error;
  Booking? get lastCreatedBooking => _lastCreatedBooking;

  /// Get all bookings for a user
  List<Booking> getBookingsForUser(String userId) {
    return _repository.getBookingsForUser(userId);
  }

  /// Get upcoming bookings for a user
  List<Booking> getUpcomingBookings(String userId) {
    return _repository.getUpcomingBookings(userId);
  }

  /// Get past bookings for a user
  List<Booking> getPastBookings(String userId) {
    return _repository.getPastBookings(userId);
  }

  /// Get a booking by ID
  Booking? getById(String id) {
    return _repository.getById(id);
  }

  /// Calculate price breakdown
  PriceBreakdown calculatePrice({
    required Destination destination,
    required Map<TicketType, int> ticketQuantities,
  }) {
    return _repository.calculatePrice(
      destination: destination,
      ticketQuantities: ticketQuantities,
    );
  }

  // ============ Actions ============

  /// Create a new booking
  Future<Booking?> createBooking({
    required String userId,
    required Destination destination,
    required List<TicketSelection> tickets,
    required List<String> visitorNames,
    required DateTime visitDate,
    required double subtotal,
    required double taxAmount,
    required double totalPrice,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final booking = await _repository.createBooking(
        userId: userId,
        destination: destination,
        tickets: tickets,
        visitorNames: visitorNames,
        visitDate: visitDate,
        subtotal: subtotal,
        taxAmount: taxAmount,
        totalPrice: totalPrice,
      );
      _lastCreatedBooking = booking;
      _setLoading(false);
      notifyListeners();
      return booking;
    } catch (e) {
      _error = 'Failed to create booking: ${e.toString()}';
      _setLoading(false);
      notifyListeners();
      return null;
    }
  }

  /// Cancel a booking
  Future<bool> cancelBooking(String bookingId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _repository.cancelBooking(bookingId);
      _setLoading(false);
      if (!success) {
        _error = 'Failed to cancel booking';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Failed to cancel booking: ${e.toString()}';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // ============ Private Helpers ============

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _clearError() {
    _error = null;
  }
}
