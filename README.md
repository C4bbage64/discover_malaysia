# Discover Malaysia

Discover Malaysia is a cross-platform Flutter app for discovering and booking Malaysian cultural tourism destinations. It supports Android, iOS, and Web, and uses Firebase for authentication and data storage.

## Features

- 🔍 **Browse & Search:** Explore curated sites, events, food spots, and travel packages
- 📍 **Destination Details:** Images, descriptions, opening hours, ticket prices, and reviews
- 🗺️ **Maps Integration:** Open locations in Google Maps or Waze
- 🎫 **Ticket Booking:** Select ticket types, quantities, visitor names, and visit dates
- 💰 **Price Calculation:** Automatic subtotal, tax (6% SST), and total computation
- 📋 **Booking History:** View upcoming and past bookings
- 👤 **Authentication:** Sign up, log in, and manage your account (Firebase Auth)
- 🛠️ **Admin Dashboard:** Manage sites, categories, and updates
- 🏷️ **Categories:** Sites, Events, Packages, Food
- 🧪 **Demo Mode:** Switch between in-memory and Firebase-backed repositories for testing

## Tech Stack

- **Flutter 3.9.2**
- **Dart**
- **Firebase Auth & Cloud Firestore**
- **Provider/ChangeNotifier** for state management
- **Navigator 1.0** (MaterialPageRoute)
- **url_launcher** (Maps/Waze links)
- **intl** (Date formatting)

## Project Structure

```
lib/
  main.dart                 # App entry point with auth wrapper
  config/                   # App-wide configuration and constants
  core/                     # Core utilities and base classes
  models/                   # User, Booking, Destination, Review, etc.
  providers/                # Provider classes for state management
  screens/                  # UI screens (admin, auth, booking, home, etc.)
  services/                 # Auth, booking, and destination repositories
  widgets/                  # Reusable UI widgets
  firebase_options.dart     # Platform-specific Firebase config (auto-generated)
```

## Firebase Setup

The app uses Firebase for authentication and data storage. Supported platforms:

- **Android:** `google-services.json` in `android/app/`
- **iOS:** `GoogleService-Info.plist` in `ios/Runner/`
- **Web:** `lib/firebase_options.dart` (auto-generated)

To update Firebase config:
1. Use the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) to regenerate `firebase_options.dart` after making changes in the Firebase Console.
2. Ensure platform-specific config files are present in the correct directories.

## Getting Started

### Prerequisites
- Flutter SDK 3.9.2+
- Dart SDK
- Firebase project (see above)

### Installation & Running

```bash
# Clone the repository
git clone https://github.com/C4bbage64/discover_malaysia.git
cd discover_malaysia
flutter pub get
```

#### Android
```
flutter emulators --launch <emulator_id>
flutter run -d <emulator_id>
```

#### iOS
```
open ios/Runner.xcworkspace
flutter run -d <device_id>
```

#### Web
```
flutter run -d chrome
```

## Development Workflow

1. Configure Firebase for all platforms (see above).
2. Use the `main.dart` entry point to launch the app.
3. Use providers and repositories for all data access and state management.
4. To switch between demo (in-memory) and Firebase mode, update the repository provider in `lib/providers/`.

## Troubleshooting

- **Blank screen or auth errors on Web:** Double-check API keys in `firebase_options.dart` and Google Cloud Console.
- **Emulator issues:** Ensure Android/iOS emulators are running and recognized by Flutter.
- **Firebase errors:** Use `debugPrint` for error logging in services.

## Roadmap

- [ ] Payment gateway integration (Stripe / local Malaysian options)
- [ ] Backend API & database persistence
- [ ] Real GPS-based distance & recommendations
- [ ] Image upload for admin site management
- [ ] Multi-language support
- [ ] Push notifications

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
6. For upstream sync, add the main repo as `upstream` and merge as needed.

## References

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase for Flutter](https://firebase.flutter.dev/)

---
For more details, see the `docs/` directory for architecture, data models, and user flows.

## License

This project is for educational purposes.
