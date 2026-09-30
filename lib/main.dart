import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'favorite_location.dart';

void main() {
  runApp(const FavoriteLocationsApp());
}

class FavoriteLocationsApp extends StatelessWidget {
  const FavoriteLocationsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Favorite Locations',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087F78),
          surface: const Color(0xFFF7F8F5),
        ),
        useMaterial3: true,
      ),
      home: const FavoriteLocationsPage(),
    );
  }
}

class FavoriteLocationsPage extends StatefulWidget {
  const FavoriteLocationsPage({super.key});

  @override
  State<FavoriteLocationsPage> createState() => _FavoriteLocationsPageState();
}

class _FavoriteLocationsPageState extends State<FavoriteLocationsPage> {
  GoogleMapController? _mapController;
  bool _hasLocationPermission = false;
  bool _isGettingLocation = false;
  FavoriteLocation? _selectedLocation;

  Set<Marker> get _markers => FavoriteLocation.samples.map((location) {
    return Marker(
      markerId: MarkerId(location.id.toString()),
      position: LatLng(location.latitude, location.longitude),
      infoWindow: InfoWindow(title: location.name),
      onTap: () => _showLocationDetails(location),
    );
  }).toSet();

  Future<void> _moveToLocation(FavoriteLocation location) async {
    setState(() => _selectedLocation = location);
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(location.latitude, location.longitude),
          zoom: 15.5,
        ),
      ),
    );
  }

  Future<void> _zoomBy(double amount) async {
    await _mapController?.animateCamera(CameraUpdate.zoomBy(amount));
  }

  Future<void> _goToCurrentLocation() async {
    if (_isGettingLocation) return;

    setState(() => _isGettingLocation = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const _LocationMessage('Turn on location services to continue.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw const _LocationMessage('Location permission was denied.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw const _LocationMessage(
          'Location permission is disabled. Allow it in Settings to continue.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;

      setState(() => _hasLocationPermission = true);
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16,
          ),
        ),
      );
    } on _LocationMessage catch (message) {
      _showMessage(message.text);
    } catch (_) {
      _showMessage('Could not get your location. Please try again.');
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  void _showLocationDetails(FavoriteLocation location) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Favorite Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailLine(label: 'ID', value: location.id.toString()),
            _DetailLine(label: 'Name', value: location.name),
            _DetailLine(
              label: 'Latitude',
              value: location.latitude.toStringAsFixed(4),
            ),
            _DetailLine(
              label: 'Longitude',
              value: location.longitude.toStringAsFixed(4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showFavoritesSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.55,
          child: _FavoritesPanel(
            selectedLocation: _selectedLocation,
            onSelected: (location) {
              Navigator.pop(context);
              _moveToLocation(location);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorite Locations',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 820;
          final map = _buildMap();
          if (isWide) {
            return Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(child: map),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: _MapControls(
                          isLoading: _isGettingLocation,
                          onMyLocation: _goToCurrentLocation,
                          onZoomIn: () => _zoomBy(1),
                          onZoomOut: () => _zoomBy(-1),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 340,
                  child: _FavoritesPanel(
                    selectedLocation: _selectedLocation,
                    onSelected: _moveToLocation,
                  ),
                ),
              ],
            );
          }
          return Stack(
            children: [
              Positioned.fill(child: map),
              Positioned(
                top: 16,
                right: 16,
                child: _MapControls(
                  isLoading: _isGettingLocation,
                  onMyLocation: _goToCurrentLocation,
                  onZoomIn: () => _zoomBy(1),
                  onZoomOut: () => _zoomBy(-1),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Center(
                  child: FilledButton.icon(
                    onPressed: _showFavoritesSheet,
                    icon: const Icon(Icons.star_rounded),
                    label: const Text('Favorite Locations'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF087F78),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(22.8026, 89.3709),
        zoom: 13.2,
      ),
      markers: _markers,
      zoomControlsEnabled: false,
      myLocationEnabled: _hasLocationPermission,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      onMapCreated: (controller) => _mapController = controller,
    );
  }
}

class _FavoritesPanel extends StatelessWidget {
  const _FavoritesPanel({
    required this.selectedLocation,
    required this.onSelected,
  });

  final FavoriteLocation? selectedLocation;
  final ValueChanged<FavoriteLocation> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Text(
              'Saved places',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              itemCount: FavoriteLocation.samples.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final location = FavoriteLocation.samples[index];
                final isSelected = selectedLocation?.id == location.id;
                return ListTile(
                  selected: isSelected,
                  selectedTileColor: const Color(0xFFE0F1ED),
                  leading: const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFE7A923),
                  ),
                  title: Text(
                    location.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${location.latitude.toStringAsFixed(4)}, '
                    '${location.longitude.toStringAsFixed(4)}',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => onSelected(location),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControls extends StatelessWidget {
  const _MapControls({
    required this.isLoading,
    required this.onMyLocation,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final bool isLoading;
  final VoidCallback onMyLocation;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filledTonal(
          tooltip: 'Zoom in',
          onPressed: onZoomIn,
          icon: const Icon(Icons.add_rounded),
          style: IconButton.styleFrom(backgroundColor: Colors.white),
        ),
        IconButton.filledTonal(
          tooltip: 'Zoom out',
          onPressed: onZoomOut,
          icon: const Icon(Icons.remove_rounded),
          style: IconButton.styleFrom(backgroundColor: Colors.white),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'my-location',
          tooltip: 'My Location',
          onPressed: isLoading ? null : onMyLocation,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF087F78),
          child: isLoading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location_rounded),
        ),
      ],
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('$label: $value'),
    );
  }
}

class _LocationMessage implements Exception {
  const _LocationMessage(this.text);

  final String text;
}
