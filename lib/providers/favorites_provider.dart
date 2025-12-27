import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// Provider for managing user favorites (destinations)
class FavoritesProvider extends ChangeNotifier {
  // Map of userId -> Set of destination IDs
  final Map<String, Set<String>> _userFavorites = {};
  
  // Stream subscription for the current user
  StreamSubscription<QuerySnapshot>? _favoritesSubscription;
  String? _currentUserId;

  /// Initialize favorites for a user (call when user logs in)
  void initForUser(String userId) {
    if (!AppConfig.useFirebase) return;
    if (_currentUserId == userId) return;

    _favoritesSubscription?.cancel();
    _currentUserId = userId;
    _userFavorites[userId] = {}; // Initialize empty set

    _favoritesSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .listen((snapshot) {
      final favoriteIds = snapshot.docs.map((doc) => doc.id).toSet();
      _userFavorites[userId] = favoriteIds;
      notifyListeners();
    });
  }

  /// Get all favorite destination IDs for a user
  Set<String> getFavorites(String userId) {
    return _userFavorites[userId] ?? {};
  }

  /// Check if a destination is favorited by a user
  bool isFavorite(String userId, String destinationId) {
    return _userFavorites[userId]?.contains(destinationId) ?? false;
  }

  /// Toggle favorite status for a destination
  Future<void> toggleFavorite(String userId, String destinationId) async {
    _userFavorites[userId] ??= {};
    
    // Optimistic update for UI responsiveness
    final isCurrentlyFavorite = _userFavorites[userId]!.contains(destinationId);
    if (isCurrentlyFavorite) {
      _userFavorites[userId]!.remove(destinationId);
    } else {
      _userFavorites[userId]!.add(destinationId);
    }
    notifyListeners();

    if (AppConfig.useFirebase) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(destinationId);

      try {
        if (isCurrentlyFavorite) {
          await docRef.delete();
        } else {
          await docRef.set({
            'addedAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        // Revert on error
        if (isCurrentlyFavorite) {
          _userFavorites[userId]!.add(destinationId);
        } else {
          _userFavorites[userId]!.remove(destinationId);
        }
        notifyListeners();
        debugPrint('Error toggling favorite: $e');
        rethrow;
      }
    }
  }

  /// Add a destination to favorites
  Future<void> addFavorite(String userId, String destinationId) async {
    if (isFavorite(userId, destinationId)) return;
    await toggleFavorite(userId, destinationId);
  }

  /// Remove a destination from favorites
  Future<void> removeFavorite(String userId, String destinationId) async {
    if (!isFavorite(userId, destinationId)) return;
    await toggleFavorite(userId, destinationId);
  }

  /// Get count of favorites for a user
  int getFavoritesCount(String userId) {
    return _userFavorites[userId]?.length ?? 0;
  }

  /// Clear user data (call when user logs out)
  void clearUserFavorites(String userId) {
    if (_currentUserId == userId) {
      _favoritesSubscription?.cancel();
      _favoritesSubscription = null;
      _currentUserId = null;
    }
    _userFavorites.remove(userId);
    notifyListeners();
  }
  
  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    super.dispose();
  }
}
