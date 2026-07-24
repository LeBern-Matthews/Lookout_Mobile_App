import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// ─── Model ───────────────────────────────────────────────────────────────────

enum LocationType { hospital, clinic, policeStation, emergencyCenter }

extension LocationTypeX on LocationType {
  String get label {
    switch (this) {
      case LocationType.hospital:
        return 'Hospital';
      case LocationType.clinic:
        return 'Clinic';
      case LocationType.policeStation:
        return 'Police Station';
      case LocationType.emergencyCenter:
        return 'Emergency Center';
    }
  }

  IconData get icon {
    switch (this) {
      case LocationType.hospital:
        return Icons.local_hospital_rounded;
      case LocationType.clinic:
        return Icons.medical_services_rounded;
      case LocationType.policeStation:
        return Icons.local_police_rounded;
      case LocationType.emergencyCenter:
        return Icons.emergency_rounded;
    }
  }

  Color get color {
    switch (this) {
      case LocationType.hospital:
        return const Color(0xFFE53935); // red
      case LocationType.clinic:
        return const Color(0xFFE91E8C); // pink
      case LocationType.policeStation:
        return const Color(0xFF1565C0); // blue
      case LocationType.emergencyCenter:
        return const Color(0xFFE65100); // deep orange
    }
  }
}

class EmergencyLocation {
  final String name;
  final LocationType type;
  final double lat;
  final double lng;
  final String phone;
  double? distanceKm;

  EmergencyLocation({
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
    required this.phone,
  });
}

// ─── Provider ────────────────────────────────────────────────────────────────

class EmergencyLocationsProvider extends ChangeNotifier {
  List<EmergencyLocation> _locations = [];
  bool _isLoading = false;  String _loadedCountry = '';

  List<EmergencyLocation> get locations => List.unmodifiable(_locations);
  bool get isLoading => _isLoading;
  bool get hasData => _locations.isNotEmpty;
  String get loadedCountry => _loadedCountry;

  /// Parses a single facility object from the JSON array.
  EmergencyLocation? _parse(Map<String, dynamic> obj, LocationType type) {
    final lat = (obj['lat'] as num?)?.toDouble();
    final lng = (obj['lng'] as num?)?.toDouble();
    if (lat == null || lng == null || (lat == 0.0 && lng == 0.0)) return null;
    return EmergencyLocation(
      name: obj['name'] as String? ?? 'Unknown',
      type: type,
      lat: lat,
      lng: lng,
      phone: obj['phone'] as String? ?? '',
    );
  }

  Future<void> loadForCountry(String country) async {
    if (country.isEmpty || country == 'Country') {
      _locations = [];
      _loadedCountry = '';
      notifyListeners();
      return;
    }

    if (_loadedCountry == country) return; // already loaded

    _isLoading = true;
    notifyListeners();

    try {
      final raw = await rootBundle
          .loadString('lib/assets/emergency_locations.json');
      final Map<String, dynamic> all =
          jsonDecode(raw) as Map<String, dynamic>;

      final countryData = all[country] as Map<String, dynamic>?;

      if (countryData == null) {
        _locations = [];
        _loadedCountry = country;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final List<EmergencyLocation> parsed = [];

      void addAll(String key, LocationType type) {
        final list = countryData[key] as List<dynamic>? ?? [];
        for (final item in list) {
          final loc = _parse(item as Map<String, dynamic>, type);
          if (loc != null) parsed.add(loc);
        }
      }

      addAll('hospitals', LocationType.hospital);
      addAll('clinics', LocationType.clinic);
      addAll('police_stations', LocationType.policeStation);
      addAll('emergency_centers', LocationType.emergencyCenter);

      _locations = parsed;
      _loadedCountry = country;
    } catch (e) {
      debugPrint('EmergencyLocationsProvider error: $e');
      _locations = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Re-sorts locations by distance from [userLat, userLng].
  void updateDistances(double userLat, double userLng) {
    for (final loc in _locations) {
      loc.distanceKm = _haversineKm(userLat, userLng, loc.lat, loc.lng);
    }
    _locations.sort((a, b) =>
        (a.distanceKm ?? double.infinity)
            .compareTo(b.distanceKm ?? double.infinity));
    notifyListeners();
  }

  /// Haversine distance in kilometres.
  double _haversineKm(
      double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _rad(double deg) => deg * pi / 180;
}
