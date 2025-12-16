# User Flows

This document summarizes the main user flows for tourists and admins in the **Discover Malaysia** app. For full product requirements, see `PRD.md`.

## 1. Tourist – Booking Flow

1. **Authentication**
   - Open the app and land on the login screen.
   - Login with email and password, or go to registration.
   - On success, user is redirected to the main discovery experience.

2. **Discover Destinations**
   - Browse featured and nearby destinations from the home screen.
   - Filter or browse by category (Sites, Events, Packages, Food).
   - Use search to find destinations by name or description.

3. **View Destination Details**
   - Open a destination card to see details:
     - Images, descriptions, cultural significance
     - Opening hours and address
     - Ticket prices for different visitor types
     - Rating and reviews
     - Buttons to open location in Google Maps or Waze

4. **Configure Booking**
   - Tap **Book Now** from the destination details page.
   - Select ticket quantities by type (Adult, Child, Foreigner, etc.).
   - Enter visitor names.
   - Choose visit date from a date picker.

5. **Review Price & Confirm**
   - The app calculates:
     - Ticket subtotals
     - Tax (6% SST)
     - Final total price
   - User reviews booking summary and confirms.

6. **(Future) Payment**
   - In a future version, user will select a payment method
     (card or online banking) and complete payment.

7. **View Bookings**
   - User can view upcoming and past bookings from the bookings page.
   - Users may cancel eligible bookings (depending on policy).

## 2. Admin – Site Management Flow

1. **Admin Login**
   - Admin logs in using admin credentials.
   - The app checks the `UserRole` for admin access.

2. **Dashboard Overview**
   - Admin sees a dashboard with quick stats or recent updates.
   - Shortcuts to manage destinations.

3. **Browse Sites**
   - View the full list of cultural sites with key fields
     (name, category, last updated timestamp).

4. **Add New Site**
   - Open "Add Site" form.
   - Fill in:
     - Name, descriptions
     - Address and coordinates
     - Images (currently from bundled assets; later from uploads)
     - Opening schedule per day
     - Ticket prices for each visitor type
   - Save to persist the new site in the repository (currently in-memory).

5. **Update Existing Site**
   - Select an existing site from the list.
   - Edit content, schedule, or pricing.
   - Save changes; `lastUpdatedAt` is updated.

6. **Delete Site**
   - Remove outdated or incorrect listings.

## 3. Error & Edge Cases (Conceptual)

- **Invalid login/registration** – User is shown validation or auth error messages.
- **No available destinations** – A friendly empty state should guide the user.
- **Network/backend errors (future)** – Once a backend is integrated, error handling and retry patterns will be added.

This document should evolve alongside actual screen and navigation changes.
