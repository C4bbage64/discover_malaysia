/// Category for a destination/cultural site
enum DestinationCategory {
  sites,
  events,
  packages,
  food,
}

/// Represents ticket pricing for different visitor types
class TicketPrice {
  final double adult;
  final double child;
  final double senior;
  final double student;
  final double foreignerAdult;
  final double foreignerChild;

  const TicketPrice({
    required this.adult,
    required this.child,
    required this.senior,
    required this.student,
    required this.foreignerAdult,
    required this.foreignerChild,
  });

  /// Returns a map of ticket type label to price
  Map<String, dynamic> toMap() => {
        'adult': adult,
        'child': child,
        'senior': senior,
        'student': student,
        'foreignerAdult': foreignerAdult,
        'foreignerChild': foreignerChild,
      };

  factory TicketPrice.fromMap(Map<String, dynamic> map) {
    return TicketPrice(
      adult: (map['adult'] as num?)?.toDouble() ?? 0.0,
      child: (map['child'] as num?)?.toDouble() ?? 0.0,
      senior: (map['senior'] as num?)?.toDouble() ?? 0.0,
      student: (map['student'] as num?)?.toDouble() ?? 0.0,
      foreignerAdult: (map['foreignerAdult'] as num?)?.toDouble() ?? 0.0,
      foreignerChild: (map['foreignerChild'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Check if entry is free
  bool get isFree =>
      adult == 0 &&
      child == 0 &&
      senior == 0 &&
      student == 0 &&
      foreignerAdult == 0 &&
      foreignerChild == 0;
}

/// Opening hours for a single day
class DayHours {
  final String day;
  final String hours;
  final bool isClosed;

  const DayHours({
    required this.day,
    required this.hours,
    this.isClosed = false,
  });

  Map<String, dynamic> toMap() => {
        'day': day,
        'hours': hours,
        'isClosed': isClosed,
      };

  factory DayHours.fromMap(Map<String, dynamic> map) {
    return DayHours(
      day: map['day'] ?? '',
      hours: map['hours'] ?? '',
      isClosed: map['isClosed'] ?? false,
    );
  }
}

/// A cultural destination/site
class Destination {
  final String id;
  final String name;
  final String shortDescription;
  final String detailedDescription;
  final DestinationCategory category;
  final String address;
  final double latitude;
  final double longitude;
  final String? googleMapsUrl;
  final String? wazeUrl;
  final List<String> images;
  final List<DayHours> openingHours;
  final TicketPrice ticketPrice;
  final double rating;
  final int reviewCount;
  final double? distanceKm;
  final DateTime? lastUpdatedAt;
  final String? updatedByAdminId;

  const Destination({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.detailedDescription,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.googleMapsUrl,
    this.wazeUrl,
    required this.images,
    required this.openingHours,
    required this.ticketPrice,
    required this.rating,
    required this.reviewCount,
    this.distanceKm,
    this.lastUpdatedAt,
    this.updatedByAdminId,
  });

  /// Returns formatted price string for display (e.g., "RM 5.00" or "FREE")
  String get displayPrice {
    if (ticketPrice.isFree) return 'FREE';
    return 'RM ${ticketPrice.adult.toStringAsFixed(2)}';
  }

  /// Returns formatted distance string
  String get displayDistance {
    if (distanceKm == null) return 'Distance N/A';
    return '${distanceKm!.toStringAsFixed(1)}km away';
  }

  /// Generate Google Maps URL from coordinates if not provided
  String get effectiveGoogleMapsUrl {
    if (googleMapsUrl != null && googleMapsUrl!.isNotEmpty) {
      return googleMapsUrl!;
    }
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  }

  /// Generate Waze URL from coordinates if not provided
  String get effectiveWazeUrl {
    if (wazeUrl != null && wazeUrl!.isNotEmpty) {
      return wazeUrl!;
    }
    return 'https://waze.com/ul?ll=$latitude,$longitude&navigate=yes';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'shortDescription': shortDescription,
      'detailedDescription': detailedDescription,
      'category': category.name, // Save enum as string
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'googleMapsUrl': googleMapsUrl,
      'wazeUrl': wazeUrl,
      'images': images,
      'openingHours': openingHours.map((h) => h.toMap()).toList(),
      'ticketPrice': ticketPrice.toMap(),
      'rating': rating,
      'reviewCount': reviewCount,
      'distanceKm': distanceKm,
      'lastUpdatedAt': lastUpdatedAt?.millisecondsSinceEpoch,
      'updatedByAdminId': updatedByAdminId,
    };
  }

  factory Destination.fromMap(Map<String, dynamic> map, {String? id}) {
    return Destination(
      id: id ?? map['id'] ?? '',
      name: map['name'] ?? '',
      shortDescription: map['shortDescription'] ?? '',
      detailedDescription: map['detailedDescription'] ?? '',
      category: DestinationCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => DestinationCategory.sites,
      ),
      address: map['address'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      googleMapsUrl: map['googleMapsUrl'],
      wazeUrl: map['wazeUrl'],
      images: List<String>.from(map['images'] ?? []),
      openingHours: (map['openingHours'] as List<dynamic>?)
              ?.map((e) => DayHours.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      ticketPrice: TicketPrice.fromMap(
          map['ticketPrice'] as Map<String, dynamic>? ?? {}),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      distanceKm: (map['distanceKm'] as num?)?.toDouble(),
      lastUpdatedAt: map['lastUpdatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastUpdatedAt'])
          : null,
      updatedByAdminId: map['updatedByAdminId'],
    );
  }
}
