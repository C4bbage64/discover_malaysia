import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/transit_station.dart';

class TransitRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'transits';

  /// Get all transit stations
  Future<List<TransitStation>> getAll() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => TransitStation.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting transits: $e');
      return [];
    }
  }

  /// Add a new station (Admin/Seed)
  Future<void> addStation(TransitStation station) async {
    await _firestore.collection(_collection).add(station.toMap());
  }

  /// Seed initial data
  Future<void> seedDefaults() async {
    try {
      final defaults = [
        const TransitStation(
          id: '', name: 'KL Sentral', 
          latitude: 3.134, longitude: 101.686, 
          type: 'hub', lineInfo: 'LRT, MRT, Monorail, KTM',
        ),
        const TransitStation(
          id: '', name: 'Pasar Seni', 
          latitude: 3.142, longitude: 101.696, 
          type: 'lrt', lineInfo: 'LRT Kelana Jaya, MRT Kajang',
        ),
        const TransitStation(
          id: '', name: 'Bukit Bintang', 
          latitude: 3.147, longitude: 101.710, 
          type: 'mrt', lineInfo: 'MRT Kajang, Monorail',
        ),
        const TransitStation(
          id: '', name: 'KLCC', 
          latitude: 3.158, longitude: 101.712, 
          type: 'lrt', lineInfo: 'LRT Kelana Jaya',
        ),
        const TransitStation(
          id: '', name: 'Masjid Jamek', 
          latitude: 3.149, longitude: 101.696, 
          type: 'lrt', lineInfo: 'LRT Kelana Jaya, LRT Ampang',
        ),
        const TransitStation(
          id: '', name: 'Muzium Negara', 
          latitude: 3.138, longitude: 101.688, 
          type: 'mrt', lineInfo: 'MRT Kajang',
        ),
         const TransitStation(
          id: '', name: 'Batu Caves', 
          latitude: 3.237, longitude: 101.684, 
          type: 'ktm', lineInfo: 'KTM Seremban Line',
        ),
      ];

      final batch = _firestore.batch();
      
      // Get existing to prevent duplicates
      final existingSnapshot = await _firestore.collection(_collection).get();
      final existingNames = existingSnapshot.docs.map((d) => d.data()['name']).toSet();

      for (var s in defaults) {
        if (!existingNames.contains(s.name)) {
          final doc = _firestore.collection(_collection).doc();
          batch.set(doc, s.toMap());
        }
      }
      
      await batch.commit();
      debugPrint('Transit defaults seeded (new entries only)');
    } catch (e) {
      debugPrint('Error seeding transits: $e');
    }
  }
}
