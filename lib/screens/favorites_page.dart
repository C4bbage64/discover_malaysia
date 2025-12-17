import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/destination.dart';
import '../providers/auth_provider.dart';
import '../providers/destination_provider.dart';
import '../providers/favorites_provider.dart';
import 'site_details_page.dart';

/// Page showing user's favorite destinations
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();
    final destinationProvider = context.watch<DestinationProvider>();
    
    final userId = authProvider.user?.id;
    
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favorites')),
        body: const Center(
          child: Text('Please login to view favorites'),
        ),
      );
    }

    final favoriteIds = favoritesProvider.getFavorites(userId);
    final favorites = favoriteIds
        .map((id) => destinationProvider.getById(id))
        .whereType<Destination>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start exploring and add destinations\nto your favorites!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final destination = favorites[index];
                return _buildFavoriteCard(
                  context,
                  destination,
                  favoritesProvider,
                  userId,
                );
              },
            ),
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    Destination destination,
    FavoritesProvider favoritesProvider,
    String userId,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SiteDetailsPage(destination: destination),
            ),
          );
        },
        child: Row(
          children: [
            // Image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    destination.images.isNotEmpty
                        ? destination.images.first
                        : 'assets/images/placeholder.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
                color: Colors.grey[300],
              ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          destination.rating.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            destination.address,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      destination.displayPrice,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Remove button
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                favoritesProvider.removeFavorite(userId, destination.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${destination.name} removed from favorites'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        favoritesProvider.addFavorite(userId, destination.id);
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
