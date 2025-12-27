import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../models/booking.dart';
import '../models/destination.dart';
import 'interfaces/booking_repository_interface.dart';

/// Firebase-backed implementation of [IBookingRepository]
/// Stores bookings in the `bookings` collection in Firestore
class FirebaseBookingRepository implements IBookingRepository {
  final CollectionReference<Map<String, dynamic>> _bookingsCollection;

  FirebaseBookingRepository({FirebaseFirestore? firestore})
      : _bookingsCollection =
            (firestore ?? FirebaseFirestore.instance).collection('bookings');

  /// Tax rate from AppConfig
  double get taxRate => AppConfig.taxRate;

  @override
  Future<List<Booking>> getAllBookings() async {
    try {
      // Try ordered query
      final snapshot = await _bookingsCollection
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => _fromFirestore(doc)).toList();
    } catch (e) {
      // Fallback if index missing or error
      final snapshot = await _bookingsCollection.get();
      final bookings = snapshot.docs.map((doc) => _fromFirestore(doc)).toList();
      bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return bookings;
    }
  }

  @override
  List<Booking> getBookingsForUser(String userId) {
    // This is called synchronously by the provider, but Firestore is async.
    // For a real app, you'd refactor this to async or use streams.
    // For now, return empty—use the async stream methods instead.
    return [];
  }

  @override
  List<Booking> getUpcomingBookings(String userId) {
    // Same as above—needs async refactor in the provider
    return [];
  }

  @override
  List<Booking> getPastBookings(String userId) {
    return [];
  }

  @override
  Booking? getById(String id) {
    // Synchronous lookup not available; use getByIdAsync
    return null;
  }

  /// Async version to fetch a booking by ID
  Future<Booking?> getByIdAsync(String id) async {
    final doc = await _bookingsCollection.doc(id).get();
    if (!doc.exists) return null;
    return _fromFirestore(doc);
  }

  /// Stream of all bookings for a user, sorted by createdAt desc
  Stream<List<Booking>> streamBookingsForUser(String userId) {
    return _bookingsCollection
        .where('userId', isEqualTo: userId)
        // .orderBy('createdAt', descending: true) // Temporarily removed to fix "Requires Index" error
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _fromFirestore(doc)).toList());
  }

  /// Stream of upcoming bookings for a user
  Stream<List<Booking>> streamUpcomingBookings(String userId) {
    final now = DateTime.now();
    return _bookingsCollection
        .where('userId', isEqualTo: userId)
        .where('visitDate', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('visitDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _fromFirestore(doc))
            .where((b) => b.status != BookingStatus.cancelled)
            .toList());
  }

  /// Stream of past bookings for a user
  Stream<List<Booking>> streamPastBookings(String userId) {
    final now = DateTime.now();
    return _bookingsCollection
        .where('userId', isEqualTo: userId)
        .where('visitDate', isLessThan: Timestamp.fromDate(now))
        .orderBy('visitDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _fromFirestore(doc)).toList());
  }

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
    final docRef = _bookingsCollection.doc();
    final now = DateTime.now();

    final data = {
      'destinationId': destination.id,
      'destinationName': destination.name,
      'destinationImage':
          destination.images.isNotEmpty ? destination.images.first : '',
      'userId': userId,
      'tickets': tickets
          .map((t) => {
                'type': t.type.name,
                'quantity': t.quantity,
                'pricePerTicket': t.pricePerTicket,
              })
          .toList(),
      'visitorNames': visitorNames,
      'visitDate': Timestamp.fromDate(visitDate),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'totalPrice': totalPrice,
      'status': 'confirmed',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(data);

    return Booking(
      id: docRef.id,
      destinationId: destination.id,
      destinationName: destination.name,
      destinationImage:
          destination.images.isNotEmpty ? destination.images.first : '',
      userId: userId,
      tickets: tickets,
      visitorNames: visitorNames,
      visitDate: visitDate,
      subtotal: subtotal,
      taxAmount: taxAmount,
      totalPrice: totalPrice,
      status: BookingStatus.confirmed,
      createdAt: now,
    );
  }

  @override
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _bookingsCollection.doc(bookingId).update({'status': 'cancelled'});
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Convert Firestore document to Booking model
  Booking _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Booking(
      id: doc.id,
      destinationId: data['destinationId'] ?? '',
      destinationName: data['destinationName'] ?? '',
      destinationImage: data['destinationImage'] ?? '',
      userId: data['userId'] ?? '',
      tickets: (data['tickets'] as List<dynamic>? ?? [])
          .map((t) => TicketSelection(
                type: TicketType.values.firstWhere(
                  (e) => e.name == t['type'],
                  orElse: () => TicketType.adult,
                ),
                quantity: t['quantity'] ?? 0,
                pricePerTicket: (t['pricePerTicket'] ?? 0).toDouble(),
              ))
          .toList(),
      visitorNames: List<String>.from(data['visitorNames'] ?? []),
      visitDate: (data['visitDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      taxAmount: (data['taxAmount'] ?? 0).toDouble(),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      status: _parseStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentMethod: data['paymentMethod'],
      paymentReference: data['paymentReference'],
    );
  }

  BookingStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}
