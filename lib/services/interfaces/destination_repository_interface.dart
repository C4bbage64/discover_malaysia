import '../../models/destination.dart';
import '../../models/review.dart';

/// Abstract interface for destination operations
/// Allows for easy swapping between mock and real implementations
abstract class IDestinationRepository {
  /// Get all destinations
  List<Destination> getAllDestinations();

  /// Get destinations by category
  List<Destination> getByCategory(DestinationCategory category);

  /// Get featured destinations (top rated)
  List<Destination> getFeatured({int limit = 3});

  /// Get nearby destinations (sorted by distance)
  List<Destination> getNearby({int limit = 5});

  /// Search destinations by name or description
  List<Destination> search(String query);

  /// Get a destination by ID
  Destination? getById(String id);

  /// Get reviews for a destination
  List<Review> getReviewsForDestination(String destinationId);

  // ============ ADMIN METHODS ============

  /// Add a new destination (admin only)
  void addDestination(Destination destination);

  /// Update an existing destination (admin only)
  void updateDestination(Destination destination);

  /// Delete a destination (admin only)
  void deleteDestination(String id);
}
