import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import '../components/country_selector.dart';

/// Lightweight service that:
///  1. Requests location permission
///  2. Gets a single GPS fix
///  3. Reverse-geocodes coords → country name
///  4. Matches it against the app's supported country list
class LocationService {
  static final Location _location = Location();

  /// Attempts to detect the user's country from their GPS position.
  ///
  /// Returns the matched country name (key from [countryFlags]) or `null`
  /// if permission is denied, location unavailable, or no match is found.
  static Future<String?> detectCountry() async {
    try {
      // ── 1. Ensure location service is enabled ──
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return null;
      }

      // ── 2. Request permission ──
      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted &&
            permission != PermissionStatus.grantedLimited) {
          return null;
        }
      }

      // ── 3. Get a single position fix ──
      final LocationData pos = await _location.getLocation();
      if (pos.latitude == null || pos.longitude == null) return null;

      // ── 4. Reverse-geocode ──
      final List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(
        pos.latitude!,
        pos.longitude!,
      );

      if (placemarks.isEmpty) return null;

      final String? geocodedCountry = placemarks.first.country;
      if (geocodedCountry == null || geocodedCountry.isEmpty) return null;

      // ── 5. Match against supported countries ──
      return _matchCountry(geocodedCountry);
    } catch (e) {
      // Gracefully degrade — user can always pick manually
      print('LocationService.detectCountry error: $e');
      return null;
    }
  }

  /// Tries to match the geocoded country name to one of the app's
  /// supported countries. Falls back to substring matching for edge cases
  /// (e.g. "St. Vincent and the Grenadines" vs "Saint Vincent and the Grenadines").
  static String? _matchCountry(String geocodedName) {
    final supportedCountries = countryFlags.keys.toList();
    final lower = geocodedName.toLowerCase().trim();

    // Exact match first
    for (final c in supportedCountries) {
      if (c.toLowerCase() == lower) return c;
    }

    // Fuzzy: geocoded name contains a supported name or vice-versa
    for (final c in supportedCountries) {
      final cl = c.toLowerCase();
      if (lower.contains(cl) || cl.contains(lower)) return c;
    }

    // Common abbreviation substitutions (e.g. "St." ↔ "Saint")
    final normalised = lower
        .replaceAll('st.', 'saint')
        .replaceAll('st ', 'saint ');
    for (final c in supportedCountries) {
      final cl = c.toLowerCase();
      if (normalised.contains(cl) || cl.contains(normalised)) return c;
    }

    return null;
  }
}
