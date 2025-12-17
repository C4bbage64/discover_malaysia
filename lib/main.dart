import 'package:discover_malaysia/providers/auth_provider.dart';
import 'package:discover_malaysia/providers/booking_provider.dart';
import 'package:discover_malaysia/providers/destination_provider.dart';
import 'package:discover_malaysia/providers/settings_provider.dart';
import 'package:discover_malaysia/screens/auth/login_page.dart';
import 'package:discover_malaysia/screens/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => DestinationProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Discover Malaysia',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

/// Wrapper that shows LoginPage or MainNavigation based on auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch auth provider for changes
    final authProvider = context.watch<AuthProvider>();

    // Check if user is logged in via provider
    if (authProvider.isLoggedIn) {
      return const MainNavigation();
    }
    return const LoginPage();
  }
}
