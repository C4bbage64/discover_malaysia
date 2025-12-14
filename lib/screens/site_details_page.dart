import 'package:flutter/material.dart';

class SiteDetailsPage extends StatelessWidget {
  final Map<String, dynamic> site;

  const SiteDetailsPage({super.key, required this.site});

  List<Map<String, dynamic>> get reviews => [
    {
      'username': 'Alice Wong',
      'comment': 'Amazing experience! The history comes alive here.',
      'rating': 5,
      'timestamp': DateTime.now().subtract(Duration(hours: 3)),
    },
    {
      'username': 'Bob Tan',
      'comment': 'Worth the visit. Great exhibits and friendly staff.',
      'rating': 4,
      'timestamp': DateTime.now().subtract(Duration(days: 1)),
    },
    {
      'username': 'Charlie Lim',
      'comment': 'Perfect place for families. Kids loved it!',
      'rating': 5,
      'timestamp': DateTime.now().subtract(Duration(days: 2)),
    },
    {
      'username': 'Diana Chen',
      'comment': 'Beautiful architecture and informative displays.',
      'rating': 4,
      'timestamp': DateTime.now().subtract(Duration(hours: 5)),
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                    image: AssetImage(site['image'] ?? 'assets/images/placeholder.jpg'),
                    fit: BoxFit.cover,
                  ),
                  color: Colors.grey[300], // Fallback
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: const [],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          site['title'] ?? 'Site Title',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          site['price'] ?? 'FREE',
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
                  Text(
                    site['description'] ?? 'Site description',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        site['distance'] ?? 'Distance not available',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        site['rating']?.toString() ?? 'N/A',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(' (1,234 reviews)', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'About this place',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getDetailedDescription(site['title'] ?? ''),
                    style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Location & Hours',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getAddress(site['title'] ?? ''),
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // TODO: Open Google Maps with the address
                        },
                        child: Text(
                          'Open Google Maps',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          // TODO: Open Waze with the address
                        },
                        child: Text(
                          'Open Waze',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Hours',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(3),
                    },
                    children: _getOpeningHoursTable(site['title'] ?? ''),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ticket Prices',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildPricingTable(site['title'] ?? ''),
                  const SizedBox(height: 24),
                  const Text(
                    'Reviews',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...reviews.map((review) => _buildReviewWidget(review)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDetailedDescription(String title) {
    switch (title) {
      case 'National Museum':
        return 'The National Museum is Malaysia\'s premier museum showcasing the country\'s rich history, culture, and heritage. Explore fascinating exhibits from prehistoric times to modern Malaysia, featuring traditional arts, cultural artifacts, and historical displays that tell the story of this diverse nation.';
      case 'Petronas Towers':
        return 'The Petronas Twin Towers are an iconic symbol of Kuala Lumpur and Malaysia\'s rapid modernization. Standing at 451.9 meters tall, they were the world\'s tallest buildings from 1998 to 2004. Visitors can enjoy panoramic views from the skybridge and observation deck.';
      case 'Batu Caves':
        return 'Batu Caves is a limestone hill that has been converted into a Hindu temple site. The site features a series of caves and cave temples, with the main temple featuring a 140-foot statue of Lord Murugan. It\'s a place of worship and pilgrimage for Hindus worldwide.';
      case 'KL Bird Park':
        return 'The KL Bird Park is the world\'s largest free-flight walk-in aviary, spanning 21 acres and housing over 3,000 birds from 200 species. Walk through the park and enjoy close encounters with exotic birds in a natural setting.';
      default:
        return 'This is a beautiful cultural site in Malaysia offering visitors a unique glimpse into the country\'s rich heritage and natural wonders. Perfect for tourists looking to explore Malaysia\'s diverse attractions.';
    }
  }

  String _getAddress(String title) {
    switch (title) {
      case 'National Museum':
        return 'Jalan Damansara, 50480 Kuala Lumpur, Federal Territory of Kuala Lumpur, Malaysia';
      case 'Petronas Towers':
        return 'Kuala Lumpur City Centre, 50088 Kuala Lumpur, Federal Territory of Kuala Lumpur, Malaysia';
      case 'Batu Caves':
        return 'Gombak, 68100 Batu Caves, Selangor, Malaysia';
      case 'KL Bird Park':
        return 'Jalan Cenderawasih, Tasik Perdana, 50480 Kuala Lumpur, Federal Territory of Kuala Lumpur, Malaysia';
      default:
        return 'Address not available';
    }
  }

  List<TableRow> _getOpeningHoursTable(String title) {
    List<Map<String, String>> hours;

    switch (title) {
      case 'National Museum':
        hours = [
          {'day': 'Monday', 'hours': '9:00 AM - 6:00 PM'},
          {'day': 'Tuesday', 'hours': '9:00 AM - 6:00 PM'},
          {'day': 'Wednesday', 'hours': '9:00 AM - 6:00 PM'},
          {'day': 'Thursday', 'hours': '9:00 AM - 6:00 PM'},
          {'day': 'Friday', 'hours': '9:00 AM - 6:00 PM'},
          {'day': 'Saturday', 'hours': '9:00 AM - 6:00 PM'},
          {'day': 'Sunday', 'hours': '9:00 AM - 6:00 PM'},
        ];
        break;
      case 'Petronas Towers':
        hours = [
          {'day': 'Monday', 'hours': '9:00 AM - 9:00 PM'},
          {'day': 'Tuesday', 'hours': '9:00 AM - 9:00 PM'},
          {'day': 'Wednesday', 'hours': '9:00 AM - 9:00 PM'},
          {'day': 'Thursday', 'hours': '9:00 AM - 9:00 PM'},
          {'day': 'Friday', 'hours': '9:00 AM - 9:00 PM'},
          {'day': 'Saturday', 'hours': '9:00 AM - 9:00 PM'},
          {'day': 'Sunday', 'hours': '9:00 AM - 9:00 PM'},
        ];
        break;
      case 'Batu Caves':
        hours = [
          {'day': 'Monday', 'hours': '6:00 AM - 9:00 PM'},
          {'day': 'Tuesday', 'hours': '6:00 AM - 9:00 PM'},
          {'day': 'Wednesday', 'hours': '6:00 AM - 9:00 PM'},
          {'day': 'Thursday', 'hours': '6:00 AM - 9:00 PM'},
          {'day': 'Friday', 'hours': '6:00 AM - 9:00 PM'},
          {'day': 'Saturday', 'hours': '6:00 AM - 9:00 PM'},
          {'day': 'Sunday', 'hours': '6:00 AM - 9:00 PM'},
        ];
        break;
      case 'KL Bird Park':
        hours = [
          {'day': 'Monday', 'hours': '9:00 AM - 6:00 PM'},
          {'day': 'Tuesday', 'hours': '9:00 AM - 6:00 PM'},
          {'day': 'Wednesday', 'hours': '9:00 AM - 6:00 PM'},
          {'day': 'Thursday', 'hours': '9:00 AM - 6:00 PM'},
          {'day': 'Friday', 'hours': '9:00 AM - 6:00 PM'},
          {'day': 'Saturday', 'hours': '9:00 AM - 6:00 PM'},
          {'day': 'Sunday', 'hours': '9:00 AM - 6:00 PM'},
        ];
        break;
      default:
        return [
          const TableRow(
            children: [
              Text('Hours not available', style: TextStyle(fontSize: 14)),
              Text(''),
            ],
          ),
        ];
    }

    // Get current day of the week
    final now = DateTime.now();
    String currentDay = '';
    switch (now.weekday) {
      case DateTime.monday:
        currentDay = 'Monday';
        break;
      case DateTime.tuesday:
        currentDay = 'Tuesday';
        break;
      case DateTime.wednesday:
        currentDay = 'Wednesday';
        break;
      case DateTime.thursday:
        currentDay = 'Thursday';
        break;
      case DateTime.friday:
        currentDay = 'Friday';
        break;
      case DateTime.saturday:
        currentDay = 'Saturday';
        break;
      case DateTime.sunday:
        currentDay = 'Sunday';
        break;
    }

    return hours.map((hour) {
      final isToday = hour['day'] == currentDay;
      return TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              hour['day']!,
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
              hour['hours']!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildPricingTable(String title) {
    Map<String, String> pricing;

    switch (title) {
      case 'National Museum':
        pricing = {
          'Adult': 'RM 5.00',
          'Child': 'RM 2.00',
          'Senior': 'RM 3.00',
          'Student': 'RM 3.00',
          'Foreigner Adult': 'RM 10.00',
          'Foreigner Child': 'RM 5.00',
        };
        break;
      case 'Petronas Towers':
        pricing = {
          'Adult': 'RM 80.00',
          'Child': 'RM 40.00',
          'Senior': 'RM 60.00',
          'Student': 'RM 60.00',
          'Foreigner Adult': 'RM 120.00',
          'Foreigner Child': 'RM 60.00',
        };
        break;
      case 'Batu Caves':
        pricing = {
          'Adult': 'FREE',
          'Child': 'FREE',
          'Senior': 'FREE',
          'Student': 'FREE',
          'Foreigner Adult': 'FREE',
          'Foreigner Child': 'FREE',
        };
        break;
      case 'KL Bird Park':
        pricing = {
          'Adult': 'RM 55.00',
          'Child': 'RM 35.00',
          'Senior': 'RM 40.00',
          'Student': 'RM 40.00',
          'Foreigner Adult': 'RM 75.00',
          'Foreigner Child': 'RM 45.00',
        };
        break;
      default:
        pricing = {
          'Adult': 'RM 5.00',
          'Child': 'RM 2.00',
          'Senior': 'RM 3.00',
          'Student': 'RM 3.00',
          'Foreigner': 'RM 10.00',
        };
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1),
      },
      children: pricing.entries.map((entry) {
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
                entry.value,
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

  Widget _buildReviewWidget(Map<String, dynamic> review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(review['username'][0].toUpperCase()),
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
                      review['username'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatTimeAgo(review['timestamp']),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: List.generate(5, (index) => Icon(
                    Icons.star,
                    size: 14,
                    color: index < review['rating'] ? Colors.amber : Colors.grey[300],
                  )),
                ),
                const SizedBox(height: 4),
                Text(review['comment']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
