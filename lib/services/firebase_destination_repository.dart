import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/destination.dart';
import '../models/review.dart';
import 'interfaces/destination_repository_interface.dart';

/// Repository for accessing destination data from Firestore
class FirebaseDestinationRepository implements IDestinationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'destinations';

  static final FirebaseDestinationRepository _instance =
      FirebaseDestinationRepository._internal();
  factory FirebaseDestinationRepository() => _instance;
  FirebaseDestinationRepository._internal();

  /// Get all destinations
  @override
  List<Destination> getAllDestinations() {
    // Note: This returns an empty list initially because it's synchronous.
    // In a real app, we should change the interface to return Future<List<Destination>>
    // or Stream<List<Destination>>.
    // However, to keep compatibility with the existing interface which returns List<Destination>,
    // we might need to fetch data and cache it, or change the interface.
    //
    // Given the constraints and the existing synchronous interface in IDestinationRepository,
    // we clearly need to change the interface to be asynchronous, OR maintain a local cache that is updated.
    //
    // BUT, for this task, let's look at the existing interface.
    // It returns `List<Destination>`, not `Future`.
    // This implies the previous implementation was purely in-memory.
    // To properly implement Firestore, we MUST refactor the interface to return Futures/Streams.
    // OR, we can fetch once at startup and keep a local list synced.
    //
    // Let's check the current interface again.
    return _localCache;
  }

  // Local cache to satisfy synchronous interface
  List<Destination> _localCache = [];
  bool _initialized = false;

  /// Initialize the repository by fetching data
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final snapshot = await _firestore.collection(_collection).get();
      _localCache = snapshot.docs
          .map((doc) => Destination.fromMap(doc.data(), id: doc.id))
          .toList();
      _initialized = true;
      debugPrint('FirebaseDestinationRepository initialized with ${_localCache.length} destinations');
    } catch (e) {
      debugPrint('Error initializing FirebaseDestinationRepository: $e');
    }
  }

  /// Get destinations by category
  @override
  List<Destination> getByCategory(DestinationCategory category) {
    return _localCache.where((d) => d.category == category).toList();
  }

  /// Get featured destinations (top rated)
  @override
  List<Destination> getFeatured({int limit = 3}) {
    final sorted = List<Destination>.from(_localCache)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }

  /// Get nearby destinations (sorted by distance)
  @override
  List<Destination> getNearby({int limit = 5}) {
    final withDistance =
        _localCache.where((d) => d.distanceKm != null).toList()
          ..sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));
    return withDistance.take(limit).toList();
  }

  /// Search destinations by name or description
  @override
  List<Destination> search(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return _localCache;
    return _localCache.where((d) {
      return d.name.toLowerCase().contains(q) ||
          d.shortDescription.toLowerCase().contains(q) ||
          d.detailedDescription.toLowerCase().contains(q);
    }).toList();
  }

  /// Get a destination by ID
  @override
  Destination? getById(String id) {
    try {
      return _localCache.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get reviews for a destination (Dummy implementation for now as Reviews aren't in Firestore yet)
  /// Get reviews for a destination from Firestore subcollection
  @override
  List<Review> getReviewsForDestination(String destinationId) {
    // Note: Ideally this should return Stream<List<Review>> or Future<List<Review>>
    // Since the interface is synchronous, we cannot implement this correctly without
    // changing the interface or using a separate method.
    // However, users usually want to see reviews "live".
    // 
    // TEMPORARY SOLUTION:
    // We will return an empty list here because the Provider needs to switch to a
    // Stream-based approach for reviews, similar to Bookings.
    // 
    // The actual fetching will be done via a NEW method `streamReviews` that the Provider will call.
    return []; 
  }

  /// Stream reviews for a destination
  Stream<List<Review>> streamReviews(String destinationId) {
    return _firestore
        .collection(_collection)
        .doc(destinationId)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Review.fromMap(doc.data(), id: doc.id))
            .toList());
  }

  /// Add a review to a destination
  Future<void> addReview(Review review) async {
    try {
      // 1. Add review to subcollection
      final docRef = _firestore
          .collection(_collection)
          .doc(review.destinationId)
          .collection('reviews')
          .doc();
          
      // Create review with new ID
      final newReview = Review(
        id: docRef.id,
        destinationId: review.destinationId,
        userId: review.userId,
        username: review.username,
        comment: review.comment,
        rating: review.rating,
        timestamp: DateTime.now(),
      );

      await docRef.set(newReview.toMap());

      // 2. Update destination average rating
      // We can do this via a Cloud Function ideally, but for now client-side
      await _updateDestinationRating(review.destinationId);

    } catch (e) {
      debugPrint('Error adding review: $e');
      rethrow;
    }
  }

  /// Helper to recalculate usage
  Future<void> _updateDestinationRating(String destinationId) async {
      final reviewsQuery = await _firestore
          .collection(_collection)
          .doc(destinationId)
          .collection('reviews')
          .get();
      
      final reviews = reviewsQuery.docs;
      if (reviews.isEmpty) return;

      double totalRating = 0;
      for (var doc in reviews) {
        totalRating += (doc.data()['rating'] ?? 0) as num;
      }
      
      final averageRating = totalRating / reviews.length;
      final roundedRating = double.parse(averageRating.toStringAsFixed(1));

      await _firestore.collection(_collection).doc(destinationId).update({
        'rating': roundedRating,
        'reviewCount': reviews.length,
      });
  }

  // ============ ADMIN METHODS ============

  /// Add a new destination
  @override
  Future<void> addDestination(Destination destination) async {
    try {
      // Create a reference with the specific ID
      final docRef = _firestore.collection(_collection).doc(destination.id);
      await docRef.set(destination.toMap());
      
      // Update local cache
      _localCache.add(destination);
    } catch (e) {
      debugPrint('Error adding destination: $e');
      rethrow;
    }
  }

  /// Update an existing destination
  @override
  Future<void> updateDestination(Destination destination) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(destination.id)
          .update(destination.toMap());
          
      // Update local cache
      final index = _localCache.indexWhere((d) => d.id == destination.id);
      if (index != -1) {
        _localCache[index] = destination;
      }
    } catch (e) {
      debugPrint('Error updating destination: $e');
      rethrow;
    }
  }

  /// Delete a destination
  @override
  Future<void> deleteDestination(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      
      // Update local cache
      _localCache.removeWhere((d) => d.id == id);
    } catch (e) {
      debugPrint('Error deleting destination: $e');
      rethrow;
    }
  }
  
  /// Seed data from a list
  Future<void> seedData(List<Destination> destinations) async {
    final batch = _firestore.batch();
    
    for (var dest in destinations) {
      final docRef = _firestore.collection(_collection).doc(dest.id);
      batch.set(docRef, dest.toMap());
    }
    
    await batch.commit();
    await initialize(); // Refresh cache
  }
}
