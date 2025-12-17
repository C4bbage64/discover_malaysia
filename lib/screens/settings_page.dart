import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/settings_provider.dart';
import '../core/utils/ui_helpers.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // ============ Display Section ============
          _buildSectionHeader(context, 'Display'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: settings.isDarkMode,
            onChanged: settings.setDarkMode,
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('Language'),
            subtitle: Text(settings.language),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(context, settings),
          ),
          ListTile(
            leading: const Icon(Icons.attach_money_outlined),
            title: const Text('Currency'),
            subtitle: Text(settings.currency),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCurrencyDialog(context, settings),
          ),
          ListTile(
            leading: const Icon(Icons.straighten_outlined),
            title: const Text('Distance Unit'),
            subtitle: Text(settings.distanceUnit == 'km' ? 'Kilometers' : 'Miles'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDistanceUnitDialog(context, settings),
          ),
          const Divider(),

          // ============ Notifications Section ============
          _buildSectionHeader(context, 'Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive push notifications'),
            value: settings.notificationsEnabled,
            onChanged: settings.setNotificationsEnabled,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.email_outlined),
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive booking confirmations via email'),
            value: settings.emailNotifications,
            onChanged: settings.notificationsEnabled
                ? settings.setEmailNotifications
                : null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.alarm_outlined),
            title: const Text('Booking Reminders'),
            subtitle: const Text('Get reminded before your visits'),
            value: settings.bookingReminders,
            onChanged: settings.notificationsEnabled
                ? settings.setBookingReminders
                : null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.local_offer_outlined),
            title: const Text('Promotions & Deals'),
            subtitle: const Text('Receive special offers and discounts'),
            value: settings.promotionalNotifications,
            onChanged: settings.notificationsEnabled
                ? settings.setPromotionalNotifications
                : null,
          ),
          const Divider(),

          // ============ Privacy Section ============
          _buildSectionHeader(context, 'Privacy'),
          SwitchListTile(
            secondary: const Icon(Icons.location_on_outlined),
            title: const Text('Location Services'),
            subtitle: const Text('Allow app to access your location'),
            value: settings.locationEnabled,
            onChanged: settings.setLocationEnabled,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.analytics_outlined),
            title: const Text('Usage Analytics'),
            subtitle: const Text('Help us improve by sharing anonymous data'),
            value: settings.analyticsEnabled,
            onChanged: settings.setAnalyticsEnabled,
          ),
          const Divider(),

          // ============ About Section ============
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: Text(AppConfig.appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoon(context),
          ),
          const Divider(),

          // ============ Reset Section ============
          Padding(
            padding: const EdgeInsets.all(AppConfig.defaultPadding),
            child: OutlinedButton.icon(
              onPressed: () => _confirmReset(context, settings),
              icon: const Icon(Icons.restore),
              label: const Text('Reset to Defaults'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Language'),
        children: SettingsProvider.supportedLanguages.map((lang) {
          final isSelected = settings.language == lang;
          return ListTile(
            leading: Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
            ),
            title: Text(lang),
            onTap: () {
              settings.setLanguage(lang);
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Currency'),
        children: SettingsProvider.supportedCurrencies.map((curr) {
          final isSelected = settings.currency == curr;
          return ListTile(
            leading: Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
            ),
            title: Text(curr),
            onTap: () {
              settings.setCurrency(curr);
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showDistanceUnitDialog(
      BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isKm = settings.distanceUnit == 'km';
        final isMi = settings.distanceUnit == 'mi';
        final primary = Theme.of(context).colorScheme.primary;
        return SimpleDialog(
          title: const Text('Select Distance Unit'),
          children: [
            ListTile(
              leading: Icon(
                isKm ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isKm ? primary : null,
              ),
              title: const Text('Kilometers (km)'),
              onTap: () {
                settings.setDistanceUnit('km');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(
                isMi ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isMi ? primary : null,
              ),
              title: const Text('Miles (mi)'),
              onTap: () {
                settings.setDistanceUnit('mi');
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      },
    );
  }

  void _showComingSoon(BuildContext context) {
    UIHelpers.showSnackBar(
      context,
      message: 'Coming soon!',
    );
  }

  Future<void> _confirmReset(
      BuildContext context, SettingsProvider settings) async {
    final confirmed = await UIHelpers.showConfirmDialog(
      context,
      title: 'Reset Settings',
      message:
          'Are you sure you want to reset all settings to their default values?',
      confirmLabel: 'Reset',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      settings.resetToDefaults();
      UIHelpers.showSuccessMessage(context, 'Settings reset to defaults');
    }
  }
}
