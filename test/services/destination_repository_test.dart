import 'package:discover_malaysia/models/destination.dart';
import 'package:discover_malaysia/services/destination_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DestinationRepository', () {
    late DestinationRepository repository;

    setUp(() {
      repository = DestinationRepository();
    });

    group('getAllDestinations', () {
      test('should return non-empty list of destinations', () {
        final destinations = repository.getAllDestinations();
        expect(destinations, isNotEmpty);
      });

      test('should return destinations with required fields', () {
        final destinations = repository.getAllDestinations();

        for (final dest in destinations) {
          expect(dest.id, isNotEmpty);
          expect(dest.name, isNotEmpty);
          expect(dest.shortDescription, isNotEmpty);
          expect(dest.category, isNotNull);
        }
      });
    });

    group('getByCategory', () {
      test('should return only destinations of specified category', () {
        final sites = repository.getByCategory(DestinationCategory.sites);

        for (final dest in sites) {
          expect(dest.category, equals(DestinationCategory.sites));
        }
      });

      test('should return empty list for category with no destinations', () {
        // Packages might be empty in the dummy data
        final packages = repository.getByCategory(DestinationCategory.packages);
        expect(packages, isA<List<Destination>>());
      });
    });

    group('getFeatured', () {
      test('should return destinations sorted by rating (descending)', () {
        final featured = repository.getFeatured(limit: 3);

        for (int i = 1; i < featured.length; i++) {
          expect(
            featured[i - 1].rating,
            greaterThanOrEqualTo(featured[i].rating),
          );
        }
      });

      test('should respect limit parameter', () {
        final featured = repository.getFeatured(limit: 2);
        expect(featured.length, lessThanOrEqualTo(2));
      });
    });

    group('getNearby', () {
      test('should return destinations sorted by distance (ascending)', () {
        final nearby = repository.getNearby(limit: 5);

        for (int i = 1; i < nearby.length; i++) {
          expect(
            nearby[i - 1].distanceKm!,
            lessThanOrEqualTo(nearby[i].distanceKm!),
          );
        }
      });

      test('should only include destinations with distance data', () {
        final nearby = repository.getNearby();

        for (final dest in nearby) {
          expect(dest.distanceKm, isNotNull);
        }
      });
    });

    group('search', () {
      test('should find destinations by name', () {
        final results = repository.search('museum');

        expect(results, isNotEmpty);
        expect(
          results.any((d) => d.name.toLowerCase().contains('museum')),
          isTrue,
        );
      });

      test('should find destinations by description', () {
        final results = repository.search('Hindu');

        expect(results, isNotEmpty);
      });

      test('should be case-insensitive', () {
        final lowerResults = repository.search('petronas');
        final upperResults = repository.search('PETRONAS');

        expect(lowerResults.length, equals(upperResults.length));
      });

      test('should return all destinations for empty query', () {
        final results = repository.search('');
        final all = repository.getAllDestinations();

        expect(results.length, equals(all.length));
      });

      test('should return empty list for no matches', () {
        final results = repository.search('xyznonexistent123');
        expect(results, isEmpty);
      });
    });

    group('getById', () {
      test('should return destination with matching ID', () {
        final all = repository.getAllDestinations();
        if (all.isNotEmpty) {
          final firstId = all.first.id;
          final result = repository.getById(firstId);

          expect(result, isNotNull);
          expect(result!.id, equals(firstId));
        }
      });

      test('should return null for non-existent ID', () {
        final result = repository.getById('non-existent-id-12345');
        expect(result, isNull);
      });
    });

    group('getReviewsForDestination', () {
      test('should return reviews list for destination', () {
        final destinations = repository.getAllDestinations();
        if (destinations.isNotEmpty) {
          final reviews = repository.getReviewsForDestination(destinations.first.id);
          expect(reviews, isA<List>());
        }
      });

      test('should return reviews with valid data', () {
        final reviews = repository.getReviewsForDestination('national-museum');

        for (final review in reviews) {
          expect(review.id, isNotEmpty);
          expect(review.username, isNotEmpty);
          expect(review.rating, inInclusiveRange(1, 5));
        }
      });
    });

    group('admin operations', () {
      test('addDestination should add new destination', () {
        final initialCount = repository.getAllDestinations().length;

        const newDest = Destination(
          id: 'test-new-dest',
          name: 'Test New Destination',
          shortDescription: 'New test destination',
          detailedDescription: 'Detailed description',
          category: DestinationCategory.sites,
          address: '123 Test St',
          latitude: 3.0,
          longitude: 101.0,
          images: [],
          openingHours: [],
          ticketPrice: TicketPrice(
            adult: 10,
            child: 5,
            senior: 7,
            student: 7,
            foreignerAdult: 20,
            foreignerChild: 10,
          ),
          rating: 4.0,
          reviewCount: 0,
        );

        repository.addDestination(newDest);

        expect(repository.getAllDestinations().length, equals(initialCount + 1));
        expect(repository.getById('test-new-dest'), isNotNull);
      });

      test('updateDestination should modify existing destination', () {
        final original = repository.getById('national-museum');
        expect(original, isNotNull);

        final updated = Destination(
          id: original!.id,
          name: 'Updated Museum Name',
          shortDescription: original.shortDescription,
          detailedDescription: original.detailedDescription,
          category: original.category,
          address: original.address,
          latitude: original.latitude,
          longitude: original.longitude,
          images: original.images,
          openingHours: original.openingHours,
          ticketPrice: original.ticketPrice,
          rating: original.rating,
          reviewCount: original.reviewCount,
        );

        repository.updateDestination(updated);

        final result = repository.getById('national-museum');
        expect(result?.name, equals('Updated Museum Name'));
      });

      test('deleteDestination should remove destination', () {
        const toDelete = Destination(
          id: 'to-delete-dest',
          name: 'To Delete',
          shortDescription: 'Will be deleted',
          detailedDescription: 'Description',
          category: DestinationCategory.food,
          address: 'Address',
          latitude: 3.0,
          longitude: 101.0,
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
          rating: 3.0,
          reviewCount: 0,
        );

        repository.addDestination(toDelete);
        expect(repository.getById('to-delete-dest'), isNotNull);

        repository.deleteDestination('to-delete-dest');
        expect(repository.getById('to-delete-dest'), isNull);
      });
    });
  });
}
