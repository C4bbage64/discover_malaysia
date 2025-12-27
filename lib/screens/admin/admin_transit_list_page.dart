import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transit_station.dart';
import '../../providers/transit_provider.dart';
import 'admin_edit_transit_page.dart';

class AdminTransitListPage extends StatefulWidget {
  const AdminTransitListPage({super.key});

  @override
  State<AdminTransitListPage> createState() => _AdminTransitListPageState();
}

class _AdminTransitListPageState extends State<AdminTransitListPage> {
  @override
  void initState() {
    super.initState();
    // Ensure we have dat loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransitProvider>().loadStations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransitProvider>();
    final stations = provider.stations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Transit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.loadStations(),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : stations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_subway_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No stations found',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: stations.length,
                  itemBuilder: (context, index) {
                    return _buildStationItem(stations[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminEditTransitPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Station'),
      ),
    );
  }

  Widget _buildStationItem(TransitStation station) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[50],
          child: Icon(_getIconForType(station.type), color: Colors.blue),
        ),
        title: Text(
          station.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(station.lineInfo ?? 'No line info'),
            Text(
              '${station.latitude.toStringAsFixed(4)}, ${station.longitude.toStringAsFixed(4)}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdminEditTransitPage(station: station),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(station),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'bus':
        return Icons.directions_bus;
      case 'train':
      case 'lrt':
      case 'mrt':
      case 'monorail':
      case 'ktm':
        return Icons.train;
      default:
        return Icons.commute;
    }
  }

  Future<void> _confirmDelete(TransitStation station) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Station'),
        content: Text(
          'Are you sure you want to delete "${station.name}"?',
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
        await context.read<TransitProvider>().deleteStation(station.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${station.name} deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
