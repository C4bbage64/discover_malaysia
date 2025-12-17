import 'package:flutter/material.dart';
import '../../config/app_config.dart';

/// Reusable empty state widget for when lists have no items
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  /// Factory for no search results
  factory EmptyState.noSearchResults({VoidCallback? onClear}) {
    return EmptyState(
      icon: Icons.search_off_outlined,
      title: 'No Results Found',
      subtitle: 'Try adjusting your search terms',
      actionLabel: onClear != null ? 'Clear Search' : null,
      onAction: onClear,
    );
  }

  /// Factory for no bookings
  factory EmptyState.noBookings({VoidCallback? onExplore}) {
    return EmptyState(
      icon: Icons.confirmation_number_outlined,
      title: 'No Bookings Yet',
      subtitle: 'Start exploring destinations and book your first adventure!',
      actionLabel: onExplore != null ? 'Explore' : null,
      onAction: onExplore,
    );
  }

  /// Factory for no destinations
  factory EmptyState.noDestinations({VoidCallback? onRefresh}) {
    return EmptyState(
      icon: Icons.place_outlined,
      title: 'No Destinations',
      subtitle: 'Check back later for new destinations',
      actionLabel: onRefresh != null ? 'Refresh' : null,
      onAction: onRefresh,
    );
  }

  /// Factory for error state
  factory EmptyState.error({
    String? message,
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Something Went Wrong',
      subtitle: message ?? 'An unexpected error occurred',
      actionLabel: onRetry != null ? 'Try Again' : null,
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.largePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
