import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../config/app_config.dart';

/// Page shown after a booking is successfully created
class BookingConfirmationPage extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationPage({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              
              // Success message
              Text(
                'Booking Confirmed!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your booking has been successfully placed',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Booking details card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Booking ID
                      Row(
                        children: [
                          Icon(
                            Icons.confirmation_number,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Booking ID',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.id,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Divider(height: 24),
                      
                      // Destination
                      _buildDetailRow(
                        context,
                        icon: Icons.location_on,
                        label: 'Destination',
                        value: booking.destinationName,
                      ),
                      const SizedBox(height: 16),
                      
                      // Visit date
                      _buildDetailRow(
                        context,
                        icon: Icons.calendar_today,
                        label: 'Visit Date',
                        value: booking.formattedVisitDate,
                      ),
                      const SizedBox(height: 16),
                      
                      // Tickets
                      _buildDetailRow(
                        context,
                        icon: Icons.people,
                        label: 'Tickets',
                        value: '${booking.totalTickets} ${booking.totalTickets == 1 ? 'ticket' : 'tickets'}',
                      ),
                      const SizedBox(height: 16),
                      
                      // Visitors
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.badge,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Visitors',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...booking.visitorNames.map((name) => Text(
                                  name,
                                  style: theme.textTheme.bodyMedium,
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      
                      // Price breakdown
                      _buildPriceRow(context, 'Subtotal', AppConfig.formatPrice(booking.subtotal)),
                      const SizedBox(height: 8),
                      _buildPriceRow(context, 'Tax (6% SST)', AppConfig.formatPrice(booking.taxAmount)),
                      const Divider(height: 16),
                      _buildPriceRow(
                        context,
                        'Total',
                        booking.formattedTotalPrice,
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Info note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please show this confirmation or your booking ID at the entrance on your visit date.',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Action buttons
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    // Pop to home
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to bookings page
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    // TODO: Navigate to bookings tab
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View My Bookings',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
              : theme.textTheme.bodyMedium,
        ),
        Text(
          value,
          style: isTotal
              ? theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                )
              : theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
