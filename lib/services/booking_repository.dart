import '../config/app_config.dart';
import '../models/booking.dart';
import '../models/destination.dart';
import 'interfaces/booking_repository_interface.dart';

export 'interfaces/booking_repository_interface.dart' show PriceBreakdown;

/// Repository for managing bookings
/// Currently uses in-memory storage; can be swapped to API/local DB later
class BookingRepository implements IBookingRepository {
  static final BookingRepository _instance = BookingRepository._internal();
  factory BookingRepository() => _instance;
  BookingRepository._internal();

  final List<Booking> _bookings = [];
  int _nextId = 1;

  /// Tax rate from AppConfig
  double get taxRate => AppConfig.taxRate;

  /// Get all bookings for a user
  @override
  List<Booking> getBookingsForUser(String userId) {
    return _bookings
        .where((b) => b.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get upcoming bookings for a user
  @override
  List<Booking> getUpcomingBookings(String userId) {
    final now = DateTime.now();
    return _bookings
        .where((b) =>
            b.userId == userId &&
            b.visitDate.isAfter(now) &&
            b.status != BookingStatus.cancelled)
        .toList()
      ..sort((a, b) => a.visitDate.compareTo(b.visitDate));
  }

  /// Get past bookings for a user
  @override
  List<Booking> getPastBookings(String userId) {
    final now = DateTime.now();
    return _bookings
        .where((b) => b.userId == userId && b.visitDate.isBefore(now))
        .toList()
      ..sort((a, b) => b.visitDate.compareTo(a.visitDate));
  }

  /// Get a booking by ID
  @override
  Booking? getById(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Calculate price breakdown for a booking
  @override
  PriceBreakdown calculatePrice({
    required Destination destination,
    required Map<TicketType, int> ticketQuantities,
  }) {
    double subtotal = 0;
    final tickets = <TicketSelection>[];
    final prices = destination.ticketPrice;

    for (final entry in ticketQuantities.entries) {
      if (entry.value <= 0) continue;

      double pricePerTicket;
      switch (entry.key) {
        case TicketType.adult:
          pricePerTicket = prices.adult;
        case TicketType.child:
          pricePerTicket = prices.child;
        case TicketType.senior:
          pricePerTicket = prices.senior;
        case TicketType.student:
          pricePerTicket = prices.student;
        case TicketType.foreignerAdult:
          pricePerTicket = prices.foreignerAdult;
        case TicketType.foreignerChild:
          pricePerTicket = prices.foreignerChild;
      }

      if (pricePerTicket > 0) {
        tickets.add(TicketSelection(
          type: entry.key,
          quantity: entry.value,
          pricePerTicket: pricePerTicket,
        ));
        subtotal += pricePerTicket * entry.value;
      } else {
        // Free tickets still need to be tracked
        tickets.add(TicketSelection(
          type: entry.key,
          quantity: entry.value,
          pricePerTicket: 0,
        ));
      }
    }

    final taxAmount = subtotal * taxRate;
    final total = subtotal + taxAmount;

    return PriceBreakdown(
      tickets: tickets,
      subtotal: subtotal,
      taxRate: taxRate,
      taxAmount: taxAmount,
      total: total,
    );
  }

  /// Create a new booking
  @override
  Future<Booking> createBooking({
    required String userId,
    required Destination destination,
    required List<TicketSelection> tickets,
    required List<String> visitorNames,
    required DateTime visitDate,
    required double subtotal,
    required double taxAmount,
    required double totalPrice,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final booking = Booking(
      id: 'booking-${_nextId++}',
      destinationId: destination.id,
      destinationName: destination.name,
      destinationImage: destination.images.isNotEmpty ? destination.images.first : '',
      userId: userId,
      tickets: tickets,
      visitorNames: visitorNames,
      visitDate: visitDate,
      subtotal: subtotal,
      taxAmount: taxAmount,
      totalPrice: totalPrice,
      status: BookingStatus.confirmed,
      createdAt: DateTime.now(),
    );

    _bookings.add(booking);
    return booking;
  }

  /// Cancel a booking
  @override
  Future<bool> cancelBooking(String bookingId) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return false;

    final old = _bookings[index];
    _bookings[index] = Booking(
      id: old.id,
      destinationId: old.destinationId,
      destinationName: old.destinationName,
      destinationImage: old.destinationImage,
      userId: old.userId,
      tickets: old.tickets,
      visitorNames: old.visitorNames,
      visitDate: old.visitDate,
      subtotal: old.subtotal,
      taxAmount: old.taxAmount,
      totalPrice: old.totalPrice,
      status: BookingStatus.cancelled,
      createdAt: old.createdAt,
      paymentMethod: old.paymentMethod,
      paymentReference: old.paymentReference,
    );
    return true;
  }
}
