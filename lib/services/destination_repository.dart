import '../models/destination.dart';
import '../models/review.dart';
import 'interfaces/destination_repository_interface.dart';

/// Repository for accessing destination data
/// Currently uses local/dummy data; can be swapped to API later
class DestinationRepository implements IDestinationRepository {
  static final DestinationRepository _instance = DestinationRepository._internal();
  factory DestinationRepository() => _instance;
  DestinationRepository._internal();

  /// Get all destinations
  @override
  List<Destination> getAllDestinations() => _destinations;

  /// Get destinations by category
  @override
  List<Destination> getByCategory(DestinationCategory category) {
    return _destinations.where((d) => d.category == category).toList();
  }

  /// Get featured destinations (top rated)
  @override
  List<Destination> getFeatured({int limit = 3}) {
    final sorted = List<Destination>.from(_destinations)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }

  /// Get nearby destinations (sorted by distance)
  @override
  List<Destination> getNearby({int limit = 5}) {
    final withDistance = _destinations.where((d) => d.distanceKm != null).toList()
      ..sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));
    return withDistance.take(limit).toList();
  }

  /// Search destinations by name or description
  @override
  List<Destination> search(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return _destinations;
    return _destinations.where((d) {
      return d.name.toLowerCase().contains(q) ||
          d.shortDescription.toLowerCase().contains(q) ||
          d.detailedDescription.toLowerCase().contains(q);
    }).toList();
  }

  /// Get a destination by ID
  @override
  Destination? getById(String id) {
    try {
      return _destinations.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get reviews for a destination
  @override
  List<Review> getReviewsForDestination(String destinationId) {
    return _reviews.where((r) => r.destinationId == destinationId).toList();
  }

  // ============ ADMIN METHODS ============

  /// Add a new destination (admin only)
  @override
  void addDestination(Destination destination) {
    _destinations.add(destination);
  }

  /// Update an existing destination (admin only)
  @override
  void updateDestination(Destination destination) {
    final index = _destinations.indexWhere((d) => d.id == destination.id);
    if (index != -1) {
      _destinations[index] = destination;
    }
  }

  /// Delete a destination (admin only)
  @override
  void deleteDestination(String id) {
    _destinations.removeWhere((d) => d.id == id);
  }

  // ============ DUMMY DATA ============

  final List<Destination> _destinations = [
    Destination(
      id: 'national-museum',
      name: 'National Museum',
      shortDescription: 'Malaysia National Museum',
      detailedDescription:
          "The National Museum is Malaysia's premier museum showcasing the country's rich history, culture, and heritage. Explore fascinating exhibits from prehistoric times to modern Malaysia, featuring traditional arts, cultural artifacts, and historical displays that tell the story of this diverse nation.",
      category: DestinationCategory.sites,
      address: 'Jalan Damansara, 50480 Kuala Lumpur, Federal Territory of Kuala Lumpur, Malaysia',
      latitude: 3.1379,
      longitude: 101.6876,
      images: ['assets/images/national_museum.jpg'],
      openingHours: _defaultHours('9:00 AM - 6:00 PM'),
      ticketPrice: const TicketPrice(
        adult: 5.00,
        child: 2.00,
        senior: 3.00,
        student: 3.00,
        foreignerAdult: 10.00,
        foreignerChild: 5.00,
      ),
      rating: 4.0,
      reviewCount: 1234,
      distanceKm: 12.5,
      lastUpdatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Destination(
      id: 'petronas-towers',
      name: 'Petronas Towers',
      shortDescription: 'Iconic twin towers in Kuala Lumpur',
      detailedDescription:
          "The Petronas Twin Towers are an iconic symbol of Kuala Lumpur and Malaysia's rapid modernization. Standing at 451.9 meters tall, they were the world's tallest buildings from 1998 to 2004. Visitors can enjoy panoramic views from the skybridge and observation deck.",
      category: DestinationCategory.sites,
      address: 'Kuala Lumpur City Centre, 50088 Kuala Lumpur, Federal Territory of Kuala Lumpur, Malaysia',
      latitude: 3.1578,
      longitude: 101.7117,
      images: ['assets/images/petronas.jpg'],
      openingHours: _defaultHours('9:00 AM - 9:00 PM'),
      ticketPrice: const TicketPrice(
        adult: 80.00,
        child: 40.00,
        senior: 60.00,
        student: 60.00,
        foreignerAdult: 120.00,
        foreignerChild: 60.00,
      ),
      rating: 4.5,
      reviewCount: 5678,
      distanceKm: 3.2,
      lastUpdatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Destination(
      id: 'batu-caves',
      name: 'Batu Caves',
      shortDescription: 'Ancient Hindu temple site',
      detailedDescription:
          "Batu Caves is a limestone hill that has been converted into a Hindu temple site. The site features a series of caves and cave temples, with the main temple featuring a 140-foot statue of Lord Murugan. It's a place of worship and pilgrimage for Hindus worldwide.",
      category: DestinationCategory.sites,
      address: 'Gombak, 68100 Batu Caves, Selangor, Malaysia',
      latitude: 3.2379,
      longitude: 101.6840,
      images: ['assets/images/batu_caves.jpg'],
      openingHours: _defaultHours('6:00 AM - 9:00 PM'),
      ticketPrice: const TicketPrice(
        adult: 0,
        child: 0,
        senior: 0,
        student: 0,
        foreignerAdult: 0,
        foreignerChild: 0,
      ),
      rating: 4.2,
      reviewCount: 3456,
      distanceKm: 8.1,
      lastUpdatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Destination(
      id: 'kl-bird-park',
      name: 'KL Bird Park',
      shortDescription: "World's largest free-flight aviary",
      detailedDescription:
          "The KL Bird Park is the world's largest free-flight walk-in aviary, spanning 21 acres and housing over 3,000 birds from 200 species. Walk through the park and enjoy close encounters with exotic birds in a natural setting.",
      category: DestinationCategory.sites,
      address:
          'Jalan Cenderawasih, Tasik Perdana, 50480 Kuala Lumpur, Federal Territory of Kuala Lumpur, Malaysia',
      latitude: 3.1426,
      longitude: 101.6876,
      images: ['assets/images/bird_park.jpg'],
      openingHours: _defaultHours('9:00 AM - 6:00 PM'),
      ticketPrice: const TicketPrice(
        adult: 55.00,
        child: 35.00,
        senior: 40.00,
        student: 40.00,
        foreignerAdult: 75.00,
        foreignerChild: 45.00,
      ),
      rating: 4.8,
      reviewCount: 2345,
      distanceKm: 12.5,
      lastUpdatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    // Events category example
    Destination(
      id: 'thaipusam-festival',
      name: 'Thaipusam Festival',
      shortDescription: 'Annual Hindu festival at Batu Caves',
      detailedDescription:
          'Thaipusam is a Hindu festival celebrated mostly by the Tamil community. It is a spectacular event featuring devotees carrying kavadis (elaborate structures) and fulfilling vows. The main celebration takes place at Batu Caves with millions of visitors.',
      category: DestinationCategory.events,
      address: 'Gombak, 68100 Batu Caves, Selangor, Malaysia',
      latitude: 3.2379,
      longitude: 101.6840,
      images: ['assets/images/thaipusam.jpg'],
      openingHours: [
        const DayHours(day: 'Festival Day', hours: 'All Day'),
      ],
      ticketPrice: const TicketPrice(
        adult: 0,
        child: 0,
        senior: 0,
        student: 0,
        foreignerAdult: 0,
        foreignerChild: 0,
      ),
      rating: 4.9,
      reviewCount: 890,
      distanceKm: 8.1,
      lastUpdatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    // Food category example
    Destination(
      id: 'jalan-alor',
      name: 'Jalan Alor Food Street',
      shortDescription: 'Famous hawker street in Bukit Bintang',
      detailedDescription:
          'Jalan Alor is the most famous food street in Kuala Lumpur. Located in the heart of Bukit Bintang, it comes alive every night with hawker stalls selling everything from satay to grilled seafood, char kuey teow, and durian.',
      category: DestinationCategory.food,
      address: 'Jalan Alor, Bukit Bintang, 50200 Kuala Lumpur, Malaysia',
      latitude: 3.1456,
      longitude: 101.7089,
      images: ['assets/images/jalan_alor.jpg'],
      openingHours: _defaultHours('5:00 PM - 4:00 AM'),
      ticketPrice: const TicketPrice(
        adult: 0,
        child: 0,
        senior: 0,
        student: 0,
        foreignerAdult: 0,
        foreignerChild: 0,
      ),
      rating: 4.6,
      reviewCount: 4567,
      distanceKm: 2.5,
      lastUpdatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  final List<Review> _reviews = [
    Review(
      id: 'r1',
      destinationId: 'national-museum',
      userId: 'u1',
      username: 'Alice Wong',
      comment: 'Amazing experience! The history comes alive here.',
      rating: 5,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Review(
      id: 'r2',
      destinationId: 'national-museum',
      userId: 'u2',
      username: 'Bob Tan',
      comment: 'Worth the visit. Great exhibits and friendly staff.',
      rating: 4,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Review(
      id: 'r3',
      destinationId: 'national-museum',
      userId: 'u3',
      username: 'Charlie Lim',
      comment: 'Perfect place for families. Kids loved it!',
      rating: 5,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Review(
      id: 'r4',
      destinationId: 'national-museum',
      userId: 'u4',
      username: 'Diana Chen',
      comment: 'Beautiful architecture and informative displays.',
      rating: 4,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Review(
      id: 'r5',
      destinationId: 'petronas-towers',
      userId: 'u1',
      username: 'Alice Wong',
      comment: 'Breathtaking views from the skybridge! A must-visit.',
      rating: 5,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    Review(
      id: 'r6',
      destinationId: 'petronas-towers',
      userId: 'u5',
      username: 'Emily Tan',
      comment: 'Queue was long but totally worth it. Book online to save time!',
      rating: 4,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Review(
      id: 'r7',
      destinationId: 'batu-caves',
      userId: 'u2',
      username: 'Bob Tan',
      comment: 'The 272 steps are challenging but the temple is beautiful.',
      rating: 5,
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Review(
      id: 'r8',
      destinationId: 'kl-bird-park',
      userId: 'u3',
      username: 'Charlie Lim',
      comment: 'Kids absolutely loved feeding the birds! Great family outing.',
      rating: 5,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}

/// Helper to generate default weekly opening hours
List<DayHours> _defaultHours(String hours) {
  return [
    DayHours(day: 'Monday', hours: hours),
    DayHours(day: 'Tuesday', hours: hours),
    DayHours(day: 'Wednesday', hours: hours),
    DayHours(day: 'Thursday', hours: hours),
    DayHours(day: 'Friday', hours: hours),
    DayHours(day: 'Saturday', hours: hours),
    DayHours(day: 'Sunday', hours: hours),
  ];
}
