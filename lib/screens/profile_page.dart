import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/favorites_provider.dart';
import 'auth/login_page.dart';
import 'admin/admin_dashboard_page.dart';
import 'favorites_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Please login to view your profile',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    final bookings = bookingProvider.getBookingsForUser(user.id);
    final upcomingCount = bookingProvider.getUpcomingBookings(user.id).length;
    final favoritesCount = favoritesProvider.getFavoritesCount(user.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                      child: Text(
                        user.initials,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (user.isAdmin) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'ADMIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.confirmation_number,
                    value: bookings.length.toString(),
                    label: 'Total Bookings',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.calendar_today,
                    value: upcomingCount.toString(),
                    label: 'Upcoming',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.favorite,
                    value: favoritesCount.toString(),
                    label: 'Favorites',
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Menu items
            _buildMenuSection(context),
            const SizedBox(height: 24),

            // Admin section
            if (user.isAdmin) ...[
              _buildAdminSection(context),
              const SizedBox(height: 24),
            ],

            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _logout(context, authProvider),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.favorite_outline,
            title: 'Favorites',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              _showComingSoonDialog(context, 'Notifications');
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              _showComingSoonDialog(context, 'Help & Support');
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminSection(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.orange[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Admin Tools',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.dashboard,
            title: 'Admin Dashboard',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminDashboardPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('This feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Discover Malaysia'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0'),
            SizedBox(height: 12),
            Text(
              'Discover Malaysia is your gateway to exploring the rich cultural heritage, natural wonders, and hidden gems of Malaysia.',
            ),
            SizedBox(height: 12),
            Text(
              '© 2025 Discover Malaysia',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, AuthProvider authProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await authProvider.logout();
    }
  }
}
