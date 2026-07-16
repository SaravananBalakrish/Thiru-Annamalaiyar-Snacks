import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../constants.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng _currentCenter = const LatLng(13.0827, 80.2707);
  String _currentAddress = "Loading...";
  bool _isLoading = true;
  bool _isFetchingAddress = false;
  bool _isMapReady = false;
  bool _isDeterminingPosition = false;
  Timer? _debounceTimer;
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    if (_isDeterminingPosition) return;
    setState(() => _isDeterminingPosition = true);

    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location services are disabled.')));
        }
        setState(() => _isLoading = false);
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Location permissions are denied')));
          }
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Location permissions are permanently denied.')));
        }
        setState(() => _isLoading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;

      final newCenter = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentCenter = newCenter;
        _isLoading = false;
      });

      // If the map is ready, we use the controller to move the camera.
      // If it's not ready yet (first load), initialCenter handles it.
      if (_isMapReady) {
        try {
          _mapController.move(newCenter, 15.0);
        } catch (e) {
          debugPrint("Error moving map: $e");
        }
      }

      _getAddressFromLatLng(newCenter);
    } finally {
      if (mounted) {
        setState(() => _isDeterminingPosition = false);
      }
    }
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    if (_isFetchingAddress) return;

    setState(() {
      _isFetchingAddress = true;
      _currentAddress = "Fetching address...";
    });

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress =
              "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}";
        });
      } else {
        setState(() => _currentAddress = "Address not found");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _currentAddress = "Address not found");
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingAddress = false);
      }
    }
  }

  void _onMapMoved(LatLng center) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        _getAddressFromLatLng(center);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: _isDeterminingPosition
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location),
              onPressed: _isDeterminingPosition ? null : () => _determinePosition(),
            )
        ],
      ),
      body: Stack(
        children: [
          if (!_isLoading)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCenter,
                initialZoom: 15.0,
                onMapReady: () {
                  setState(() {
                    _isMapReady = true;
                  });
                },
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    setState(() {
                      _currentCenter = position.center;
                    });
                    _onMapMoved(_currentCenter);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.thiruannamalaiyarsnacks.app',
                ),
              ],
            ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          
          // Center Marker
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Icon(Icons.location_on, color: colorScheme.primary, size: 40),
            ),
          ),

          // Address Bottom Card
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusM)),
              child: Padding(
                padding: const EdgeInsets.all(kPaddingM),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: colorScheme.primary),
                        const SizedBox(width: kPaddingS),
                        Expanded(
                          child: Text(
                            _currentAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: kPaddingM),
                    ElevatedButton(
                      onPressed: (_isFetchingAddress || _currentAddress == "Address not found" || _currentAddress == "Loading...")
                        ? null
                        : () {
                        Navigator.pop(context, {
                          'address': _currentAddress,
                          'lat': _currentCenter.latitude,
                          'lng': _currentCenter.longitude,
                        });
                      },
                      child: _isFetchingAddress
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary)
                          )
                        : const Text("Confirm Location"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
