# Architecture Overview

This document describes the high-level architecture of the **Discover Malaysia** app.

## 1. App Layers

The app is currently a **Flutter client-only application** with in-memory data.
It is structured into the following layers:

- **UI (Screens)** – Widgets under `lib/screens/` for tourist and admin flows
- **Domain Models** – Plain Dart models under `lib/models/` (e.g. `Destination`, `Booking`, `User`)
- **Services / Repositories** – Classes under `lib/services/` that encapsulate business logic and in-memory data

Planned future work (see `README.md` Roadmap) includes integrating a real backend API and database.

## 2. Navigation

- **Entry Point:** `main.dart` boots `MainApp`.
- `MainApp` wraps the app in `MaterialApp` and sets `AuthWrapper` as `home`.
- `AuthWrapper` decides between:
  - `LoginPage` (unauthenticated users)
  - `MainNavigation` (authenticated users – bottom navigation shell).

Navigation inside the app uses **Navigator 1.0** with `MaterialPageRoute`.

## 3. Core Components

### 3.1 Models (`lib/models`)

- `destination.dart` – `Destination`, `TicketPrice`, `DayHours`, `DestinationCategory`
- `booking.dart` – `Booking`, `TicketSelection`, `TicketType`, `BookingStatus`
- `user.dart` – `User`, `UserRole`
- `review.dart` – `Review`

These models are **framework-agnostic** and do not depend on Flutter widgets.

### 3.2 Services & Repositories (`lib/services`)

- `auth_service.dart`
  - Singleton service managing authentication state
  - Exposes `authStateChanges` stream, `currentUser`, `login`, `register`, `logout`
  - Currently uses **dummy in-memory users**, but can be swapped to Firebase/API later

- `destination_repository.dart`
  - Provides access to a dummy list of `Destination` objects and their `Review`s
  - Supports operations such as `getAllDestinations`, `getByCategory`, `getFeatured`, `getNearby`, `search`, and basic admin CRUD

- `booking_repository.dart`
  - Manages in-memory list of `Booking` objects
  - Provides helper `calculatePrice` for SST tax and total computation
  - Exposes methods for creating and canceling bookings, and querying user bookings

## 4. Data Flow

1. **Auth:**
   - `AuthService` logs in or registers a user and updates `_currentUser`.
   - UI listens to auth state (via wrapper or direct access) to decide what to render.

2. **Destinations:**
   - Screens request data from `DestinationRepository` (e.g. featured, nearby, by category).
   - A selected `Destination` is passed into the details page for display and booking.

3. **Booking:**
   - Booking form collects ticket quantities, visitor names, and visit date.
   - `BookingRepository.calculatePrice()` computes `PriceBreakdown` (subtotal, tax, total).
   - On confirmation, `BookingRepository.createBooking()` stores a `Booking` in memory.

## 5. Future Backend Integration

When a backend is introduced, the following changes are expected:

- Replace in-memory lists in `AuthService`, `BookingRepository`, and `DestinationRepository` with API calls.
- Introduce DTOs and mapping between network models and domain models.
- Add error handling, caching, and pagination in repositories.
- Introduce persistence for bookings, users, reviews, and destinations.

This document should be updated once a real backend is implemented.
