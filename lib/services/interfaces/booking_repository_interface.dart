import '../../models/booking.dart';
import '../../models/destination.dart';

/// Price breakdown for booking summary
class PriceBreakdown {
  final List<TicketSelection> tickets;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double total;

  const PriceBreakdown({
    required this.tickets,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
  });

  int get totalTickets => tickets.fold(0, (sum, t) => sum + t.quantity);

  String get formattedSubtotal => 'RM ${subtotal.toStringAsFixed(2)}';
  String get formattedTax => 'RM ${taxAmount.toStringAsFixed(2)}';
  String get formattedTotal => 'RM ${total.toStringAsFixed(2)}';
  String get taxRatePercent => '${(taxRate * 100).toStringAsFixed(0)}%';
}

/// Abstract interface for booking operations
/// Allows for easy swapping between mock and real implementations
abstract class IBookingRepository {
  /// Get all bookings for a user
  List<Booking> getBookingsForUser(String userId);

  /// Get upcoming bookings for a user
  List<Booking> getUpcomingBookings(String userId);

  /// Get past bookings for a user
  List<Booking> getPastBookings(String userId);

  /// Get a booking by ID
  Booking? getById(String id);

  /// Calculate price breakdown for a booking
  PriceBreakdown calculatePrice({
    required Destination destination,
    required Map<TicketType, int> ticketQuantities,
  });

  /// Create a new booking
  Future<Booking> createBooking({
    required String userId,
    required Destination destination,
    required List<TicketSelection> tickets,
    required List<String> visitorNames,
    required DateTime visitDate,
    required double subtotal,
    required double taxAmount,
    required double totalPrice,
  });

  /// Cancel a booking
  Future<bool> cancelBooking(String bookingId);
}
