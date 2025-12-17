import 'package:flutter/foundation.dart';

/// Provider for managing user favorites (destinations)
/// Currently uses in-memory storage; can be swapped to Firebase/local storage later
class FavoritesProvider extends ChangeNotifier {
  // Map of userId -> Set of destination IDs
  final Map<String, Set<String>> _userFavorites = {};

  /// Get all favorite destination IDs for a user
  Set<String> getFavorites(String userId) {
    return _userFavorites[userId] ?? {};
  }

  /// Check if a destination is favorited by a user
  bool isFavorite(String userId, String destinationId) {
    return _userFavorites[userId]?.contains(destinationId) ?? false;
  }

  /// Toggle favorite status for a destination
  void toggleFavorite(String userId, String destinationId) {
    _userFavorites[userId] ??= {};
    
    if (_userFavorites[userId]!.contains(destinationId)) {
      _userFavorites[userId]!.remove(destinationId);
    } else {
      _userFavorites[userId]!.add(destinationId);
    }
    notifyListeners();
  }

  /// Add a destination to favorites
  void addFavorite(String userId, String destinationId) {
    _userFavorites[userId] ??= {};
    _userFavorites[userId]!.add(destinationId);
    notifyListeners();
  }

  /// Remove a destination from favorites
  void removeFavorite(String userId, String destinationId) {
    _userFavorites[userId]?.remove(destinationId);
    notifyListeners();
  }

  /// Get count of favorites for a user
  int getFavoritesCount(String userId) {
    return _userFavorites[userId]?.length ?? 0;
  }

  /// Clear all favorites for a user (e.g., on logout)
  void clearUserFavorites(String userId) {
    _userFavorites.remove(userId);
    notifyListeners();
  }
}
