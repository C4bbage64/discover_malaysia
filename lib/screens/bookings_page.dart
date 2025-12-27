import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/booking.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final user = authProvider.user;

    // Ensure bookingProvider streams are initialized for the logged-in user
    if (user != null) {
      bookingProvider.initForUser(user.id);
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Bookings')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Please login to view your bookings',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final upcomingBookings = bookingProvider.getUpcomingBookings(user.id);
    final pastBookings = bookingProvider.getPastBookings(user.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Upcoming (${upcomingBookings.length})'),
            Tab(text: 'Past (${pastBookings.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(upcomingBookings, isUpcoming: true),
          _buildBookingList(pastBookings, isUpcoming: false),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<Booking> bookings, {required bool isUpcoming}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.calendar_today : Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming
                  ? 'No upcoming bookings'
                  : 'No past bookings',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            if (isUpcoming) ...[
              const SizedBox(height: 8),
              Text(
                'Start exploring and book your next adventure!',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(bookings[index], isUpcoming: isUpcoming);
      },
    );
  }

  /// Check if a booking can be cancelled based on policy
  bool _canCancelBooking(Booking booking) {
    if (booking.status == BookingStatus.cancelled ||
        booking.status == BookingStatus.completed) {
      return false;
    }
    
    final now = DateTime.now();
    final daysUntilVisit = booking.visitDate.difference(now).inDays;
    return daysUntilVisit >= AppConfig.minCancellationDays;
  }

  /// Show cancellation confirmation dialog
  Future<void> _showCancelDialog(Booking booking) async {
    final daysUntilVisit = booking.visitDate.difference(DateTime.now()).inDays;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to cancel this booking?'),
            const SizedBox(height: 12),
            Text(
              booking.destinationName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Visit Date: ${booking.formattedVisitDate}'),
            Text('Total: ${booking.formattedTotalPrice}'),
            const SizedBox(height: 12),
            Text(
              'Days until visit: $daysUntilVisit',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final bookingProvider = context.read<BookingProvider>();
      final success = await bookingProvider.cancelBooking(booking.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Booking cancelled successfully'
                  : bookingProvider.error ?? 'Failed to cancel booking',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildBookingCard(Booking booking, {required bool isUpcoming}) {
    Color statusColor;
    switch (booking.status) {
      case BookingStatus.confirmed:
        statusColor = Colors.green;
      case BookingStatus.pending:
        statusColor = Colors.orange;
      case BookingStatus.completed:
        statusColor = Colors.blue;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
    }

    final canCancel = isUpcoming && _canCancelBooking(booking);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and status
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  image: DecorationImage(
                    image: AssetImage(
                      booking.destinationImage.isNotEmpty
                          ? booking.destinationImage
                          : 'assets/images/placeholder.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                  color: Colors.grey[300],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.destinationName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      booking.formattedVisitDate,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.confirmation_number, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '${booking.totalTickets} ${booking.totalTickets == 1 ? 'ticket' : 'tickets'}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking ID: ${booking.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      booking.formattedTotalPrice,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                // Cancel button for upcoming bookings
                if (canCancel) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showCancelDialog(booking),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel Booking'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ] else if (isUpcoming && booking.status == BookingStatus.confirmed) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Cannot cancel - less than ${AppConfig.minCancellationDays} day(s) before visit',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

