# Data Models

This document summarizes the main domain models used in the **Discover Malaysia** app.

## 1. User & Roles

File: `lib/models/user.dart`

- `UserRole`
  - `user` – standard tourist user
  - `admin` – has access to admin tools and site management
- `User`
  - `id` – unique identifier
  - `name` – display name
  - `email` – login and contact email
  - `role` – `UserRole`
  - `createdAt` – account creation timestamp
  - `avatarUrl` (optional) – URL for user avatar image

Key helpers:

- `isAdmin` – convenience getter to check admin privileges
- `initials` – derived initials for avatar display

## 2. Destinations

File: `lib/models/destination.dart`

- `DestinationCategory`
  - `sites`, `events`, `packages`, `food`

- `TicketPrice`
  - `adult`, `child`, `senior`, `student`
  - `foreignerAdult`, `foreignerChild`
  - `toMap()` – returns a label → price map
  - `isFree` – true when all prices are zero

- `DayHours`
  - `day` – label for the day (e.g. "Monday", "Festival Day")
  - `hours` – opening hours text
  - `isClosed` – whether the destination is closed on that day

- `Destination`
  - Identification: `id`, `name`
  - Content: `shortDescription`, `detailedDescription`, `images`
  - Location: `address`, `latitude`, `longitude`
  - Links: `googleMapsUrl`, `wazeUrl`
  - Business data: `category`, `openingHours`, `ticketPrice`
  - Ratings: `rating`, `reviewCount`
  - UX helpers: `distanceKm`, `lastUpdatedAt`, `updatedByAdminId`

Computed helpers:

- `displayPrice` – e.g. `"RM 5.00"` or `"FREE"`
- `displayDistance` – e.g. `"3.2km away"`
- `effectiveGoogleMapsUrl` – falls back to a URL generated from coordinates
- `effectiveWazeUrl` – falls back to a URL generated from coordinates

## 3. Reviews

File: `lib/models/review.dart`

- `Review`
  - `id`, `destinationId`, `userId`, `username`
  - `comment`, `rating` (1–5)
  - `timestamp`

Helper:

- `timeAgo` – human-readable relative time string (e.g. "3 hours ago")

## 4. Bookings

File: `lib/models/booking.dart`

- `TicketType`
  - `adult`, `child`, `senior`, `student`, `foreignerAdult`, `foreignerChild`

- `TicketSelection`
  - `type` – `TicketType`
  - `quantity`
  - `pricePerTicket`
  - `subtotal` – derived (`quantity * pricePerTicket`)

- `BookingStatus`
  - `pending`, `confirmed`, `completed`, `cancelled`

- `Booking`
  - Identification: `id`
  - Relations: `destinationId`, `destinationName`, `destinationImage`, `userId`
  - Ticketing: `tickets` (`List<TicketSelection>`), `visitorNames`, `visitDate`
  - Pricing: `subtotal`, `taxAmount`, `totalPrice`
  - Status: `status`
  - Metadata: `createdAt`, `paymentMethod`, `paymentReference`

Helpers:

- `totalTickets` – sum of tickets across all selections
- `formattedVisitDate` – `dd/mm/yyyy`
- `formattedTotalPrice` – e.g. `"RM 42.40"`

## 5. Price Breakdown

File: `lib/services/booking_repository.dart`

- `PriceBreakdown`
  - `tickets` – list of `TicketSelection` used in the booking summary
  - `subtotal`
  - `taxRate` – currently `0.06` (6% SST)
  - `taxAmount`
  - `total`

Helpers:

- `totalTickets`
- `formattedSubtotal`, `formattedTax`, `formattedTotal`
- `taxRatePercent` – human-readable percentage string (e.g. `"6%"`)

This document should be kept in sync whenever data models change.
