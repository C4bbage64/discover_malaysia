import 'package:flutter/foundation.dart';
import '../models/destination.dart';
import '../models/review.dart';
import '../services/destination_repository.dart';
import '../services/interfaces/destination_repository_interface.dart';

/// ChangeNotifier wrapper for destination state
/// Allows widgets to rebuild when destinations change
class DestinationProvider extends ChangeNotifier {
  final IDestinationRepository _repository;
  // ignore: prefer_final_fields
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  DestinationProvider({IDestinationRepository? repository})
      : _repository = repository ?? DestinationRepository();

  // ============ Getters ============

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  /// Get all destinations
  List<Destination> get allDestinations => _repository.getAllDestinations();

  /// Get destinations by category
  List<Destination> getByCategory(DestinationCategory category) {
    return _repository.getByCategory(category);
  }

  /// Get featured destinations (top rated)
  List<Destination> getFeatured({int limit = 3}) {
    return _repository.getFeatured(limit: limit);
  }

  /// Get nearby destinations (sorted by distance)
  List<Destination> getNearby({int limit = 5}) {
    return _repository.getNearby(limit: limit);
  }

  /// Search destinations by name or description
  List<Destination> search(String query) {
    _searchQuery = query;
    return _repository.search(query);
  }

  /// Get current search results
  List<Destination> get searchResults {
    if (_searchQuery.isEmpty) return allDestinations;
    return _repository.search(_searchQuery);
  }

  /// Get a destination by ID
  Destination? getById(String id) {
    return _repository.getById(id);
  }

  /// Get reviews for a destination
  List<Review> getReviewsForDestination(String destinationId) {
    return _repository.getReviewsForDestination(destinationId);
  }

  // ============ Admin Actions ============

  /// Add a new destination (admin only)
  void addDestination(Destination destination) {
    _repository.addDestination(destination);
    notifyListeners();
  }

  /// Update an existing destination (admin only)
  void updateDestination(Destination destination) {
    _repository.updateDestination(destination);
    notifyListeners();
  }

  /// Delete a destination (admin only)
  void deleteDestination(String id) {
    _repository.deleteDestination(id);
    notifyListeners();
  }

  // ============ Search & Filter ============

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
