import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/transit_station.dart';
import '../services/transit_repository.dart';

class TransitProvider extends ChangeNotifier {
  final TransitRepository _repository = TransitRepository();
  List<TransitStation> _stations = [];
  bool _isLoading = false;

  List<TransitStation> get stations => _stations;
  bool get isLoading => _isLoading;

  Future<void> loadStations() async {
    _isLoading = true;
    notifyListeners();
    
    _stations = await _repository.getAll();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> seed() async {
    _isLoading = true;
    notifyListeners();
    await _repository.seedDefaults();
    await loadStations();
  }

  /// Get nearby stations
  List<TransitStation> getNearby(double lat, double lng, {int limit = 3}) {
    if (_stations.isEmpty) return [];

    final distance = const Distance();
    final center = LatLng(lat, lng);

    final sortable = _stations.map((s) {
      final d = distance.as(LengthUnit.Kilometer, center, LatLng(s.latitude, s.longitude));
      return MapEntry(s, d);
    }).toList();

    sortable.sort((a, b) => a.value.compareTo(b.value));

    return sortable.take(limit).map((e) => e.key).toList();
  }
}
