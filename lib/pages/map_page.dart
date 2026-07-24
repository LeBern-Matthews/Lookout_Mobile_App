import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/country_provider.dart';
import '../services/emergency_centers.dart';
import '../components/country_selector.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final Location _locationController = Location();
  LatLng? _currentPosition;
  GoogleMapController? _mapController;
  String? _lastLoadedCountry;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _startLocationUpdates() async {
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permission = await _locationController.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _locationController.requestPermission();
      if (permission != PermissionStatus.granted) return;
    }

    _locationController.onLocationChanged.listen((LocationData data) {
      if (!mounted) return;
      if (data.latitude == null || data.longitude == null) return;

      final pos = LatLng(data.latitude!, data.longitude!);
      setState(() => _currentPosition = pos);

      // Update distances in provider whenever GPS refreshes
      context.read<EmergencyLocationsProvider>().updateDistances(
            data.latitude!,
            data.longitude!,
          );

      // Pan camera to user on first fix
      _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
    });
  }

  Set<Marker> _buildMarkers(
    List<EmergencyLocation> locations,
    BuildContext context,
  ) {
    final markers = <Marker>{};

    // User location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('_user'),
          position: _currentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );
    }

    // Emergency location markers
    for (int i = 0; i < locations.length; i++) {
      final loc = locations[i];
      final hue = _hueForType(loc.type);
      markers.add(
        Marker(
          markerId: MarkerId('loc_$i'),
          position: LatLng(loc.lat, loc.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(
            title: loc.name,
            snippet: loc.type.label,
          ),
          onTap: () => _showLocationSheet(context, loc, i == 0),
        ),
      );
    }

    return markers;
  }

  double _hueForType(LocationType type) {
    switch (type) {
      case LocationType.hospital:
        return BitmapDescriptor.hueRed;
      case LocationType.clinic:
        return BitmapDescriptor.hueRose;
      case LocationType.policeStation:
        return BitmapDescriptor.hueBlue;
      case LocationType.emergencyCenter:
        return BitmapDescriptor.hueOrange;
    }
  }

  void _showLocationSheet(
      BuildContext context, EmergencyLocation loc, bool isNearest) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final sheetBg =
        isLight ? Colors.white : const Color(0xFF1C1C1E);

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Type badge + nearest badge
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: loc.type.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(loc.type.icon, color: loc.type.color, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          loc.type.label,
                          style: TextStyle(
                            color: loc.type.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isNearest) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              color: Colors.amber, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Nearest',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Name
              Text(
                loc.name,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),

              // Distance
              if (loc.distanceKm != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${loc.distanceKm!.toStringAsFixed(1)} km away',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],

              // Phone
              if (loc.phone.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.phone_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5)),
                    const SizedBox(width: 6),
                    Text(
                      loc.phone,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  if (loc.phone.isNotEmpty)
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.phone_rounded,
                        label: 'Call',
                        color: Colors.green,
                        onTap: () => _launch('tel:${loc.phone}'),
                      ),
                    ),
                  if (loc.phone.isNotEmpty) const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.directions_rounded,
                      label: 'Directions',
                      color: theme.colorScheme.primary,
                      onTap: () => _launch(
                        'https://www.google.com/maps/dir/?api=1&destination=${loc.lat},${loc.lng}',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final countryP = context.watch<CountryProvider>();
    final locP = context.watch<EmergencyLocationsProvider>();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final isLight = theme.brightness == Brightness.light;

    // Trigger load when country changes
    final country = countryP.country;
    if (country != 'Country' && country != _lastLoadedCountry) {
      _lastLoadedCountry = country;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) locP.loadForCountry(country);
      });
    }

    final bool noCountry = country == 'Country';
    final bool loading = locP.isLoading;
    final bool noData = !loading && !locP.hasData && !noCountry;

    return Scaffold(
      backgroundColor: surface,
      body: Stack(
        children: [
          // ── Google Map ────────────────────────────────────────────────
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: const CameraPosition(
              target: LatLng(13.158670985689088, -61.230774818593694),
              zoom: 12,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: _buildMarkers(locP.locations, context),
            onMapCreated: (ctrl) => _mapController = ctrl,
          ),

          // ── Top bar ───────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Title card
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isLight
                          ? Colors.white
                          : const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(countryFlags[countryP.country] ?? '🌍'),
                        const SizedBox(width: 8),
                        Text(
                          noCountry
                              ? 'Emergency Map'
                              : country,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Recenter button
                  if (_currentPosition != null)
                    _MapButton(
                      icon: Icons.my_location_rounded,
                      onTap: () {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(_currentPosition!, 13),
                        );
                      },
                      isLight: isLight,
                    ),
                ],
              ),
            ),
          ),

          // ── Overlay states ────────────────────────────────────────────
          if (noCountry || loading || noData)
            Positioned(
              left: 16,
              right: 16,
              bottom: 40,
              child: _StatusCard(
                isLight: isLight,
                icon: noCountry
                    ? Icons.public_rounded
                    : loading
                        ? null
                        : Icons.location_off_rounded,
                color: primary,
                title: noCountry
                    ? 'No country selected'
                    : loading
                        ? 'Loading locations…'
                        : 'No data available',
                subtitle: noCountry
                    ? 'Set your country in Settings to see nearby emergency centers.'
                    : loading
                        ? null
                        : 'No emergency center data is available for $country yet.',
                showSpinner: loading,
              ),
            ),

          // ── Location list chip strip ──────────────────────────────────
          if (!noCountry && !loading && locP.hasData)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _LocationStrip(
                locations: locP.locations,
                onTap: (loc, isNearest) =>
                    _showLocationSheet(context, loc, isNearest),
                mapController: _mapController,
                isLight: isLight,
                onSurface: onSurface,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Supporting widgets ───────────────────────────────────────────────────────

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isLight;
  const _MapButton(
      {required this.icon, required this.onTap, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20,
            color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool isLight;
  final IconData? icon;
  final Color color;
  final String title;
  final String? subtitle;
  final bool showSpinner;

  const _StatusCard({
    required this.isLight,
    this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.showSpinner = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          showSpinner
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: color,
                  ),
                )
              : Icon(icon, color: color, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationStrip extends StatelessWidget {
  final List<EmergencyLocation> locations;
  final void Function(EmergencyLocation, bool isNearest) onTap;
  final GoogleMapController? mapController;
  final bool isLight;
  final Color onSurface;

  const _LocationStrip({
    required this.locations,
    required this.onTap,
    required this.mapController,
    required this.isLight,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: SizedBox(
        height: 90,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: locations.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final loc = locations[i];
            final isNearest = i == 0;
            return GestureDetector(
              onTap: () {
                mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(LatLng(loc.lat, loc.lng), 14),
                );
                onTap(loc, isNearest);
              },
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(loc.type.icon, color: loc.type.color, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            loc.type.label,
                            style: TextStyle(
                              color: loc.type.color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isNearest)
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 14),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (loc.distanceKm != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${loc.distanceKm!.toStringAsFixed(1)} km away',
                        style: TextStyle(
                          fontSize: 11,
                          color: onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}