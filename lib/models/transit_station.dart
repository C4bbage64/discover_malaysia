class TransitStation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String type; // 'bus', 'train', 'lrt', 'mrt'
  final String? lineInfo;
  
  const TransitStation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.lineInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'lineInfo': lineInfo,
    };
  }

  factory TransitStation.fromMap(Map<String, dynamic> map, {String? id}) {
    return TransitStation(
      id: id ?? '',
      name: map['name'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      type: map['type'] ?? 'bus',
      lineInfo: map['lineInfo'],
    );
  }
}
