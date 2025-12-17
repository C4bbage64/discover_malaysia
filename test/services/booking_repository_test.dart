import 'package:discover_malaysia/models/booking.dart';
import 'package:discover_malaysia/models/destination.dart';
import 'package:discover_malaysia/services/booking_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookingRepository', () {
    late BookingRepository repository;
    late Destination testDestination;

    setUp(() {
      repository = BookingRepository();
      testDestination = const Destination(
        id: 'test-dest',
        name: 'Test Destination',
        shortDescription: 'A test destination',
        detailedDescription: 'Detailed description for testing',
        category: DestinationCategory.sites,
        address: '123 Test Street',
        latitude: 3.1390,
        longitude: 101.6869,
        images: [],
        openingHours: [],
        ticketPrice: TicketPrice(
          adult: 50.00,
          child: 25.00,
          senior: 35.00,
          student: 30.00,
          foreignerAdult: 100.00,
          foreignerChild: 50.00,
        ),
        rating: 4.5,
        reviewCount: 100,
      );
    });

    group('calculatePrice', () {
      test('should calculate correct subtotal for single ticket type', () {
        final breakdown = repository.calculatePrice(
          destination: testDestination,
          ticketQuantities: {TicketType.adult: 2},
        );

        expect(breakdown.subtotal, equals(100.00)); // 50 * 2
        expect(breakdown.totalTickets, equals(2));
      });

      test('should calculate correct subtotal for multiple ticket types', () {
        final breakdown = repository.calculatePrice(
          destination: testDestination,
          ticketQuantities: {
            TicketType.adult: 2, // 50 * 2 = 100
            TicketType.child: 3, // 25 * 3 = 75
          },
        );

        expect(breakdown.subtotal, equals(175.00));
        expect(breakdown.totalTickets, equals(5));
      });

      test('should calculate correct tax amount (6% SST)', () {
        final breakdown = repository.calculatePrice(
          destination: testDestination,
          ticketQuantities: {TicketType.adult: 2}, // subtotal = 100
        );

        expect(breakdown.taxRate, equals(0.06));
        expect(breakdown.taxAmount, equals(6.00)); // 100 * 0.06
      });

      test('should calculate correct total price', () {
        final breakdown = repository.calculatePrice(
          destination: testDestination,
          ticketQuantities: {TicketType.adult: 2}, // subtotal = 100, tax = 6
        );

        expect(breakdown.total, equals(106.00)); // 100 + 6
      });

      test('should handle zero quantity gracefully', () {
        final breakdown = repository.calculatePrice(
          destination: testDestination,
          ticketQuantities: {TicketType.adult: 0},
        );

        expect(breakdown.subtotal, equals(0.00));
        expect(breakdown.taxAmount, equals(0.00));
        expect(breakdown.total, equals(0.00));
      });

      test('should handle foreigner pricing correctly', () {
        final breakdown = repository.calculatePrice(
          destination: testDestination,
          ticketQuantities: {
            TicketType.foreignerAdult: 1, // 100
            TicketType.foreignerChild: 2, // 50 * 2 = 100
          },
        );

        expect(breakdown.subtotal, equals(200.00));
        expect(breakdown.taxAmount, closeTo(12.00, 0.01));
        expect(breakdown.total, closeTo(212.00, 0.01));
      });

      test('should track free tickets without adding to price', () {
        final freeDestination = const Destination(
          id: 'free-dest',
          name: 'Free Destination',
          shortDescription: 'A free destination',
          detailedDescription: 'Free entry',
          category: DestinationCategory.sites,
          address: '123 Free Street',
          latitude: 3.1390,
          longitude: 101.6869,
          images: [],
          openingHours: [],
          ticketPrice: TicketPrice(
            adult: 0,
            child: 0,
            senior: 0,
            student: 0,
            foreignerAdult: 0,
            foreignerChild: 0,
          ),
          rating: 4.0,
          reviewCount: 50,
        );

        final breakdown = repository.calculatePrice(
          destination: freeDestination,
          ticketQuantities: {
            TicketType.adult: 2,
            TicketType.child: 2,
          },
        );

        expect(breakdown.subtotal, equals(0.00));
        expect(breakdown.total, equals(0.00));
        expect(breakdown.totalTickets, equals(4));
      });
    });

    group('createBooking', () {
      test('should create booking with correct data', () async {
        final tickets = [
          const TicketSelection(
            type: TicketType.adult,
            quantity: 2,
            pricePerTicket: 50.00,
          ),
        ];

        final booking = await repository.createBooking(
          userId: 'user1',
          destination: testDestination,
          tickets: tickets,
          visitorNames: ['John Doe', 'Jane Doe'],
          visitDate: DateTime.now().add(const Duration(days: 7)),
          subtotal: 100.00,
          taxAmount: 6.00,
          totalPrice: 106.00,
        );

        expect(booking.destinationId, equals('test-dest'));
        expect(booking.userId, equals('user1'));
        expect(booking.totalTickets, equals(2));
        expect(booking.status, equals(BookingStatus.confirmed));
      });

      test('should assign unique booking IDs', () async {
        final tickets = [
          const TicketSelection(
            type: TicketType.adult,
            quantity: 1,
            pricePerTicket: 50.00,
          ),
        ];

        final booking1 = await repository.createBooking(
          userId: 'user1',
          destination: testDestination,
          tickets: tickets,
          visitorNames: ['John'],
          visitDate: DateTime.now().add(const Duration(days: 7)),
          subtotal: 50.00,
          taxAmount: 3.00,
          totalPrice: 53.00,
        );

        final booking2 = await repository.createBooking(
          userId: 'user1',
          destination: testDestination,
          tickets: tickets,
          visitorNames: ['Jane'],
          visitDate: DateTime.now().add(const Duration(days: 14)),
          subtotal: 50.00,
          taxAmount: 3.00,
          totalPrice: 53.00,
        );

        expect(booking1.id, isNot(equals(booking2.id)));
      });
    });

    group('cancelBooking', () {
      test('should cancel existing booking', () async {
        final tickets = [
          const TicketSelection(
            type: TicketType.adult,
            quantity: 1,
            pricePerTicket: 50.00,
          ),
        ];

        final booking = await repository.createBooking(
          userId: 'user1',
          destination: testDestination,
          tickets: tickets,
          visitorNames: ['John'],
          visitDate: DateTime.now().add(const Duration(days: 7)),
          subtotal: 50.00,
          taxAmount: 3.00,
          totalPrice: 53.00,
        );

        final success = await repository.cancelBooking(booking.id);
        expect(success, isTrue);

        final cancelledBooking = repository.getById(booking.id);
        expect(cancelledBooking?.status, equals(BookingStatus.cancelled));
      });

      test('should return false for non-existent booking', () async {
        final success = await repository.cancelBooking('non-existent-id');
        expect(success, isFalse);
      });
    });
  });

  group('PriceBreakdown', () {
    test('should format subtotal correctly', () {
      const breakdown = PriceBreakdown(
        tickets: [],
        subtotal: 100.50,
        taxRate: 0.06,
        taxAmount: 6.03,
        total: 106.53,
      );

      expect(breakdown.formattedSubtotal, equals('RM 100.50'));
    });

    test('should format tax correctly', () {
      const breakdown = PriceBreakdown(
        tickets: [],
        subtotal: 100.00,
        taxRate: 0.06,
        taxAmount: 6.00,
        total: 106.00,
      );

      expect(breakdown.formattedTax, equals('RM 6.00'));
      expect(breakdown.taxRatePercent, equals('6%'));
    });

    test('should format total correctly', () {
      const breakdown = PriceBreakdown(
        tickets: [],
        subtotal: 100.00,
        taxRate: 0.06,
        taxAmount: 6.00,
        total: 106.00,
      );

      expect(breakdown.formattedTotal, equals('RM 106.00'));
    });
  });
}
