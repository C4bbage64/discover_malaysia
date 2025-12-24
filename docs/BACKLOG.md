# Backlog

## Payment (Deferred)
- [ ] **Payment Gateway Integration**
    - Integrate with a payment provider (e.g., Stripe, ToyyibPay).
    - Support Credit Card and FPX Online Banking.
- [ ] **Payment Flow**
    - UI for selecting payment methods.
    - Handle success, failure, and pending states.
    - Generate receipts/invoices.

## Backend Migration
- [ ] **Authentication**
    - Replace dummy `AuthService` with Firebase Auth.
    - Implement Registration and Login validation.
    - Secure Firestore rules based on User IDs.
- [ ] **Bookings**
    - Migrate in-memory `BookingRepository` to Firestore `bookings` collection.
    - Implement booking history persistence.
    - specific security rules for booking access.

## Map Features
- [ ] **General Address Search (Geocoding)**
    - *Idea:* Allow users to search for any address in Malaysia.
    - *Implementation:* Use OpenStreetMap Nominatim or Google Places API.

## User Profile
- [ ] **Profile Management**
    - Allow users to edit name and email.
    - Implement Avatar upload (requires Firebase Storage).
