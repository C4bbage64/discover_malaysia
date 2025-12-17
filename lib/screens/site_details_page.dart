import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/destination.dart';
import '../models/review.dart';
import '../providers/auth_provider.dart';
import '../providers/destination_provider.dart';
import '../providers/favorites_provider.dart';
import 'booking_form_page.dart';

class SiteDetailsPage extends StatelessWidget {
  final Destination destination;

  const SiteDetailsPage({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    final destinationProvider = context.watch<DestinationProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();
    final authProvider = context.watch<AuthProvider>();
    final reviews = destinationProvider.getReviewsForDestination(destination.id);
    
    final userId = authProvider.user?.id;
    final isFavorite = userId != null && favoritesProvider.isFavorite(userId, destination.id);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
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
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => _shareDestination(context),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  if (userId != null) {
                    favoritesProvider.toggleFavorite(userId, destination.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavorite 
                            ? 'Removed from favorites'
                            : 'Added to favorites',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please login to add favorites'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          destination.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          destination.displayPrice,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Short description
                  Text(
                    destination.shortDescription,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Distance and Rating
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        destination.displayDistance,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        destination.rating.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' (${destination.reviewCount} reviews)',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // About section
                  const Text(
                    'About this place',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    destination.detailedDescription,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Location & Hours
                  const Text(
                    'Location & Hours',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    destination.address,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  
                  // Maps links
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _openMaps(destination.effectiveGoogleMapsUrl),
                        child: const Row(
                          children: [
                            Icon(Icons.map, size: 18, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              'Open Google Maps',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      GestureDetector(
                        onTap: () => _openMaps(destination.effectiveWazeUrl),
                        child: const Row(
                          children: [
                            Icon(Icons.navigation, size: 18, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              'Open Waze',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Opening hours
                  const Text(
                    'Hours',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildOpeningHoursTable(),
                  const SizedBox(height: 24),
                  
                  // Ticket Prices
                  const Text(
                    'Ticket Prices',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildPricingTable(),
                  const SizedBox(height: 24),
                  
                  // Reviews
                  const Text(
                    'Reviews',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (reviews.isEmpty)
                    Text(
                      'No reviews yet. Be the first to review!',
                      style: TextStyle(color: Colors.grey[600]),
                    )
                  else
                    ...reviews.map((review) => _buildReviewWidget(review)),
                  
                  // Space for bottom button
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Book Now Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingFormPage(destination: destination),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openMaps(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildOpeningHoursTable() {
    final now = DateTime.now();
    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final currentDay = daysOfWeek[now.weekday - 1];

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
      },
      children: destination.openingHours.map((dayHours) {
        final isToday = dayHours.day == currentDay;
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                dayHours.day,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  color: isToday ? Colors.black : Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                dayHours.isClosed ? 'Closed' : dayHours.hours,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPricingTable() {
    final prices = destination.ticketPrice.toMap();
    
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1),
      },
      children: prices.entries.map((entry) {
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                entry.value == 0 ? 'FREE' : 'RM ${entry.value.toStringAsFixed(2)}',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildReviewWidget(Review review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              review.username[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      review.timeAgo,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star,
                      size: 14,
                      color: index < review.rating ? Colors.amber : Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(review.comment),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareDestination(BuildContext context) {
    final text = '''
Check out ${destination.name}!

${destination.shortDescription}

📍 ${destination.address}
⭐ Rating: ${destination.rating}/5.0
💰 ${destination.displayPrice}

Discover more amazing places in Malaysia!
''';

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Share this destination',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(
                    context,
                    icon: Icons.copy,
                    label: 'Copy',
                    onTap: () {
                      // Copy text to clipboard
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Details copied to clipboard'),
                        ),
                      );
                    },
                  ),
                  _buildShareOption(
                    context,
                    icon: Icons.map,
                    label: 'Maps',
                    onTap: () async {
                      Navigator.pop(context);
                      final url = Uri.parse(
                        'https://www.google.com/maps/search/?api=1&query=${destination.latitude},${destination.longitude}',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  _buildShareOption(
                    context,
                    icon: Icons.navigation,
                    label: 'Waze',
                    onTap: () async {
                      Navigator.pop(context);
                      final url = Uri.parse(
                        'https://waze.com/ul?ll=${destination.latitude},${destination.longitude}&navigate=yes',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  text.trim(),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
