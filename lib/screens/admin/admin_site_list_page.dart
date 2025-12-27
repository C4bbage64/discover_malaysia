import 'package:flutter/material.dart';
import '../../models/destination.dart';
import 'package:provider/provider.dart';
import '../../providers/destination_provider.dart';
import 'admin_edit_site_page.dart';

class AdminSiteListPage extends StatefulWidget {
  const AdminSiteListPage({super.key});

  @override
  State<AdminSiteListPage> createState() => _AdminSiteListPageState();
}

class _AdminSiteListPageState extends State<AdminSiteListPage> {
  DestinationCategory? _filterCategory;

  List<Destination> get _filteredDestinations {
    // Watch provider
    final provider = context.watch<DestinationProvider>();
    var destinations = provider.allDestinations;
    
    if (_filterCategory != null) {
      destinations = destinations
          .where((d) => d.category == _filterCategory)
          .toList();
    }
    return destinations
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Widget build(BuildContext context) {
    // Only invoke getter once per build
    final destinations = _filteredDestinations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Sites'),
        actions: [
          PopupMenuButton<DestinationCategory?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterCategory = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Categories'),
              ),
              ...DestinationCategory.values.map(
                (cat) => PopupMenuItem(
                  value: cat,
                  child: Text(_getCategoryName(cat)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: destinations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No sites found',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                return _buildSiteItem(destinations[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminEditSitePage(),
            ),
          );
          // setState not needed as Provider handles listing updates
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Site'),
      ),
    );
  }

  String _getCategoryName(DestinationCategory category) {
    switch (category) {
      case DestinationCategory.sites:
        return 'Cultural Sites';
      case DestinationCategory.events:
        return 'Events';
      case DestinationCategory.packages:
        return 'Packages';
      case DestinationCategory.food:
        return 'Food & Dining';
    }
  }

  Widget _buildSiteItem(Destination destination) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminEditSitePage(destination: destination),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
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
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(destination.category),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getCategoryName(destination.category),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Updated: ${_formatDate(destination.lastUpdatedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdminEditSitePage(destination: destination),
                      ),
                    );
                  } else if (value == 'delete') {
                    _confirmDelete(destination);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(DestinationCategory category) {
    switch (category) {
      case DestinationCategory.sites:
        return Colors.blue;
      case DestinationCategory.events:
        return Colors.purple;
      case DestinationCategory.packages:
        return Colors.green;
      case DestinationCategory.food:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _confirmDelete(Destination destination) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Site'),
        content: Text(
          'Are you sure you want to delete "${destination.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        context.read<DestinationProvider>().deleteDestination(destination.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${destination.name} deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
