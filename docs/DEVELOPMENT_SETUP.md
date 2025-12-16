# Development Setup

This guide explains how to set up a local development environment for the **Discover Malaysia** Flutter app.

## 1. Prerequisites

- **Flutter SDK** 3.9.2 or later
- **Dart SDK** (bundled with Flutter)
- A supported IDE:
  - Android Studio, VS Code, or IntelliJ with Flutter/Dart plugins
- At least one of the following configured:
  - Android emulator or physical Android device
  - iOS simulator or physical iOS device (macOS only)
  - Chrome or another supported browser (for web)
  - Windows / macOS / Linux desktop target (as supported by Flutter on your OS)

## 2. Clone and Install

```bash
# Clone the repository
git clone https://github.com/C4bbage64/discover_malaysia.git
cd discover_malaysia

# Fetch dependencies
flutter pub get
```

## 3. Running the App

### 3.1 List Available Devices

```bash
flutter devices
```

### 3.2 Run on Your Target

```bash
# Example: run on the first available device
flutter run

# Example: explicitly run on Windows (desktop)
flutter run -d windows

# Example: run on Chrome (web)
flutter run -d chrome
```

If you see build or device errors, ensure that platform-specific setup for Flutter is complete (Android SDK, Xcode, desktop support, etc.).

## 4. Code Quality

### 4.1 Static Analysis

```bash
flutter analyze
```

Resolve any warnings or errors before opening a Pull Request.

### 4.2 Formatting

Follow the standard Dart formatting using:

```bash
flutter format lib
```

or use your IDE’s built-in Dart formatter.

## 5. Configuration Notes

- The app currently uses **in-memory dummy data** for:
  - Authentication (`AuthService`)
  - Destinations and reviews (`DestinationRepository`)
  - Bookings and price calculations (`BookingRepository`)
- No external backend or database configuration is required yet.

## 6. Suggested Workflow

1. Create a feature branch from `main` or your working branch.
2. Implement or update features under `lib/`.
3. Run `flutter analyze` and `flutter test` (once tests are added).
4. Verify UI flows on at least one device target.
5. Open a Pull Request with a clear description and screenshots where relevant.
