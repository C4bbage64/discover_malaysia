import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/booking.dart';
import '../models/destination.dart';
import '../services/booking_repository.dart';
import '../services/firebase_booking_repository.dart';
import '../services/interfaces/booking_repository_interface.dart';

/// ChangeNotifier wrapper for booking state
/// Allows widgets to rebuild when bookings change
class BookingProvider extends ChangeNotifier {
  final IBookingRepository _repository;
  final FirebaseBookingRepository? _firebaseRepository;
  bool _isLoading = false;
  String? _error;
  Booking? _lastCreatedBooking;

  // Cached bookings for Firebase mode (populated via streams)
  List<Booking> _allBookings = [];
  List<Booking> _upcomingBookings = [];
  List<Booking> _pastBookings = [];
  StreamSubscription<List<Booking>>? _allBookingsSubscription;
  StreamSubscription<List<Booking>>? _upcomingSubscription;
  StreamSubscription<List<Booking>>? _pastSubscription;
  String? _currentUserId;

  BookingProvider({IBookingRepository? repository})
      : _repository = repository ??
            (AppConfig.useFirebase
                ? FirebaseBookingRepository()
                : BookingRepository()),
        _firebaseRepository =
            AppConfig.useFirebase ? FirebaseBookingRepository() : null;

  /// Initialize streams for a specific user (call when user logs in)
  void initForUser(String userId) {
    final firebaseRepo = _firebaseRepository;
    if (!AppConfig.useFirebase || firebaseRepo == null) return;
    if (_currentUserId == userId) return; // Already initialized

    debugPrint('[BookingProvider] Initializing for userId: $userId');

    // Cancel previous subscriptions
    _allBookingsSubscription?.cancel();
    _upcomingSubscription?.cancel();
    _pastSubscription?.cancel();

    _currentUserId = userId;

    // Listen to all bookings (Single Source of Truth)
    // We filter upcoming/past client-side to avoid complex Firestore indexes
    _allBookingsSubscription =
        firebaseRepo.streamBookingsForUser(userId).listen((bookings) {
      debugPrint(
          '[BookingProvider] streamBookingsForUser received: ${bookings.length} bookings');
      
      _allBookings = bookings;
      
      final now = DateTime.now();
      _upcomingBookings = bookings.where((b) {
        return b.visitDate.isAfter(now) && b.status != BookingStatus.cancelled;
      }).toList()
        ..sort((a, b) => a.visitDate.compareTo(b.visitDate));

      _pastBookings = bookings.where((b) {
        // Past includes completed, cancelled, or dates in past
        if (b.status == BookingStatus.cancelled) return false; // Usually past doesn't show cancelled? 
        // Wait, original logic for past: visitDate < now
        return b.visitDate.isBefore(now);
      }).toList()
        ..sort((a, b) => b.visitDate.compareTo(a.visitDate));

      notifyListeners();
    }, onError: (e) {
      debugPrint('[BookingProvider] Error in stream: $e');
      _error = 'Failed to load bookings: $e';
      notifyListeners();
    });
  }

  /// Clear user data (call when user logs out)
  void clearUser() {
    _allBookingsSubscription?.cancel();
    _upcomingSubscription?.cancel();
    _pastSubscription?.cancel();
    _allBookings = [];
    _upcomingBookings = [];
    _pastBookings = [];
    _currentUserId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _allBookingsSubscription?.cancel();
    _upcomingSubscription?.cancel();
    _pastSubscription?.cancel();
    super.dispose();
  }

  // ============ Getters ============

  bool get isLoading => _isLoading;
  String? get error => _error;
  Booking? get lastCreatedBooking => _lastCreatedBooking;

  /// Get all bookings for a user
  List<Booking> getBookingsForUser(String userId) {
    if (AppConfig.useFirebase) {
      return _allBookings;
    }
    return _repository.getBookingsForUser(userId);
  }

  /// Get upcoming bookings for a user
  List<Booking> getUpcomingBookings(String userId) {
    if (AppConfig.useFirebase) {
      return _upcomingBookings;
    }
    return _repository.getUpcomingBookings(userId);
  }

  /// Get past bookings for a user
  List<Booking> getPastBookings(String userId) {
    if (AppConfig.useFirebase) {
      return _pastBookings;
    }
    return _repository.getPastBookings(userId);
  }

  /// Get a booking by ID
  Booking? getById(String id) {
    if (AppConfig.useFirebase) {
      return _allBookings.where((b) => b.id == id).firstOrNull;
    }
    return _repository.getById(id);
  }

  /// Get all bookings (Admin only)
  Future<List<Booking>> getAllBookings() async {
    _isLoading = true;
    notifyListeners();
    try {
      // If using Firebase, we might want to use the firebase repo directly if _repository is generic wrapper
      // But _repository is initialized based on config, so it should be fine.
      // However, check constructor:
      // _repository = repository ?? (AppConfig.useFirebase ? FirebaseBookingRepository() : BookingRepository())
      // So _repository IS the correct instance.
      
      final bookings = await _repository.getAllBookings();
      _isLoading = false;
      notifyListeners();
      return bookings;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
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
