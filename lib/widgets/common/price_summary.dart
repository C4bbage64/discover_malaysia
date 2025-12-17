import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/booking.dart';
import '../../services/booking_repository.dart';

/// Reusable price summary widget for booking checkout
class PriceSummary extends StatelessWidget {
  final PriceBreakdown breakdown;
  final bool showTicketDetails;

  const PriceSummary({
    super.key,
    required this.breakdown,
    this.showTicketDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Price Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Ticket details
            if (showTicketDetails)
              ...breakdown.tickets
                  .where((t) => t.quantity > 0)
                  .map((ticket) => _buildTicketRow(theme, ticket)),
            if (showTicketDetails && breakdown.tickets.isNotEmpty)
              const Divider(height: 24),
            // Subtotal
            _buildPriceRow(
              theme,
              label: 'Subtotal',
              value: breakdown.formattedSubtotal,
            ),
            const SizedBox(height: 8),
            // Tax
            _buildPriceRow(
              theme,
              label: AppConfig.taxLabel,
              value: breakdown.formattedTax,
              isSecondary: true,
            ),
            const Divider(height: 24),
            // Total
            _buildPriceRow(
              theme,
              label: 'Total',
              value: breakdown.formattedTotal,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketRow(ThemeData theme, TicketSelection ticket) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${ticket.type.displayName} × ${ticket.quantity}',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            AppConfig.formatPrice(ticket.subtotal),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    ThemeData theme, {
    required String label,
    required String value,
    bool isSecondary = false,
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: isTotal
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  color: isSecondary
                      ? theme.colorScheme.onSurfaceVariant
                      : null,
                ),
        ),
        const Spacer(),
        Text(
          value,
          style: isTotal
              ? theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  color: isSecondary
                      ? theme.colorScheme.onSurfaceVariant
                      : null,
                ),
        ),
      ],
    );
  }
}
