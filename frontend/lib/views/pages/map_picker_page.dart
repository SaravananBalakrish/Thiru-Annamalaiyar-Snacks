import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../../controllers/address_controller.dart';
import '../../models/address.dart';

class MapPickerPage extends StatefulWidget {
  final Address? address;
  const MapPickerPage({super.key, this.address});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng _currentCenter = const LatLng(13.0827, 80.2707);
  LatLng? _deviceLocation;
  String _currentAddress = "Loading...";
  bool _isLoading = true;
  bool _isFetchingAddress = false;
  bool _isMapReady = false;
  bool _isDeterminingPosition = false;
  bool _isSatelliteView = false;
  Timer? _debounceTimer;
  final MapController _mapController = MapController();

  String _selectedLabel = "Home";

  // Address Form Controllers
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _stateController = TextEditingController(text: "Tamil Nadu");
  XFile? _doorImage;

  // DraggableScrollableSheet controller for programmatic snap
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  static const double _snapMin = 0.18;
  static const double _snapMid = 0.52;
  static const double _snapMax = 0.92;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _sheetController.dispose();
    _searchController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _landmarkController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _initializeWithAddress(widget.address!);
    } else {
      _determinePosition();
    }
  }

  void _initializeWithAddress(Address address) {
    _currentCenter = LatLng(
      (address.latitude ?? 13.0827).toDouble(),
      (address.longitude ?? 80.2707).toDouble(),
    );
    _fullNameController.text = address.fullName;
    _phoneController.text = address.phoneNumber;
    _streetController.text = address.street;
    _cityController.text = address.city;
    _zipController.text = address.zipCode;
    _stateController.text = address.state;
    _landmarkController.text = address.landmark ?? "";

    final label = address.label.toLowerCase();
    if (label == 'home') {
      _selectedLabel = "Home";
    } else if (label == 'work' || label == 'office') {
      _selectedLabel = "Work";
    } else {
      _selectedLabel = "Other";
    }

    _isLoading = false;
    _currentAddress = address.fullAddress;
  }

  Future<void> _determinePosition() async {
    if (_isDeterminingPosition) return;
    setState(() => _isDeterminingPosition = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are permanently denied.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;

      final newCenter = LatLng(position.latitude, position.longitude);
      setState(() {
        _deviceLocation = newCenter;
        _currentCenter = newCenter;
        _isLoading = false;
      });

      if (_isMapReady) {
        try {
          _mapController.move(newCenter, 16.0);
        } catch (e) {
          debugPrint("Error moving map: $e");
        }
      }

      _getAddressFromLatLng(newCenter);
    } finally {
      if (mounted) setState(() => _isDeterminingPosition = false);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    if (_isFetchingAddress) return;
    setState(() {
      _isFetchingAddress = true;
      _currentAddress = "Fetching address...";
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${latLng.latitude}&lon=${latLng.longitude}&zoom=18&addressdetails=1',
        ),
        headers: {
          'User-Agent': 'ThiruAnnamalaiyarSnacksApp/1.0 (com.thiruannamalaiyarsnacks.app)',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] ?? {};
        setState(() {
          _currentAddress = data['display_name'] ?? "Unknown Location";
          _streetController.text = address['road'] ?? address['pedestrian'] ?? "";
          _cityController.text = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['county'] ??
              "";
          _zipController.text = address['postcode'] ?? "";
          _stateController.text = address['state'] ?? "Tamil Nadu";
        });
      } else {
        setState(() => _currentAddress = "Address not found");
      }
    } catch (e) {
      if (mounted) setState(() => _currentAddress = "Address not found");
    } finally {
      if (mounted) setState(() => _isFetchingAddress = false);
    }
  }

  void _onMapPositionChanged(LatLng center) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) _getAddressFromLatLng(center);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) setState(() => _doorImage = image);
  }

  /// Opens the location search as a modal bottom-sheet overlay.
  void _showLocationSearchSheet() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final sheetSearchController = TextEditingController(text: _searchController.text);
    final isLoadingNotifier = ValueNotifier<bool>(false);
    final resultsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);

    Future<void> fetchResults(String query) async {
      if (query.length < 3) {
        resultsNotifier.value = [];
        return;
      }
      isLoadingNotifier.value = true;
      try {
        final response = await http.get(
          Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=6&addressdetails=1',
          ),
          headers: {
            'User-Agent': 'ThiruAnnamalaiyarSnacksApp/1.0 (com.thiruannamalaiyarsnacks.app)',
          },
        );
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          resultsNotifier.value = data.cast<Map<String, dynamic>>();
        }
      } catch (e) {
        debugPrint('Search error: $e');
      } finally {
        isLoadingNotifier.value = false;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (sheetCtx) {
        final sheetHeight = MediaQuery.of(sheetCtx).size.height * 0.85;
        Timer? debounce;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              height: sheetHeight,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 4),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.location_on_outlined, color: kRed, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: sheetSearchController,
                                    autofocus: true,
                                    style: theme.textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      hintText: "Search for area, street name...",
                                      hintStyle: TextStyle(
                                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onChanged: (val) {
                                      debounce?.cancel();
                                      debounce = Timer(const Duration(milliseconds: 500), () {
                                        fetchResults(val);
                                      });
                                    },
                                    onSubmitted: (val) {
                                      debounce?.cancel();
                                      fetchResults(val);
                                    },
                                  ),
                                ),
                                ValueListenableBuilder<bool>(
                                  valueListenable: isLoadingNotifier,
                                  builder: (c, loading, ch) => loading
                                      ? const Padding(
                                          padding: EdgeInsets.all(10),
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: kRed),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => Navigator.pop(sheetCtx),
                          child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: resultsNotifier,
                      builder: (c, results, ch) {
                        if (results.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_searching_rounded,
                                  size: 64,
                                  color: colorScheme.primary.withValues(alpha: 0.12),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Type to search for a location",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: results.length,
                          separatorBuilder: (c, i) => const Divider(height: 1, indent: 56),
                          itemBuilder: (c, i) {
                            final item = results[i];
                            final displayName = item['display_name'] as String? ?? '';
                            final parts = displayName.split(',');
                            final title = parts.first.trim();
                            final subtitle = parts.length > 1 ? parts.skip(1).join(',').trim() : '';
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: kRed.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.location_on, color: kRed, size: 18),
                              ),
                              title: Text(
                                title,
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                              ),
                              onTap: () {
                                final lat = double.tryParse(item['lat'] as String? ?? '');
                                final lon = double.tryParse(item['lon'] as String? ?? '');
                                if (lat != null && lon != null) {
                                  final newCenter = LatLng(lat, lon);
                                  _searchController.text = title;
                                  _mapController.move(newCenter, 16.0);
                                  setState(() => _currentCenter = newCenter);
                                  _getAddressFromLatLng(newCenter);
                                }
                                Navigator.pop(sheetCtx);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      sheetSearchController.dispose();
      isLoadingNotifier.dispose();
      resultsNotifier.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    double distance = 0;
    if (_deviceLocation != null) {
      distance = Geolocator.distanceBetween(
            _deviceLocation!.latitude,
            _deviceLocation!.longitude,
            _currentCenter.latitude,
            _currentCenter.longitude,
          ) /
          1000;
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // ── AppBar: back button + read-only search bar ──────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kPaddingM, vertical: kPaddingS),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(kRadiusM),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                  // Tapping opens the location search overlay bottom sheet
                  Expanded(
                    child: GestureDetector(
                      onTap: _showLocationSearchSheet,
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _searchController,
                          readOnly: true,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: _searchController.text.isNotEmpty
                                ? _searchController.text
                                : "Search for area, street name...",
                            hintStyle: TextStyle(
                              color: _searchController.text.isNotEmpty
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant,
                            ),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(Icons.search, color: colorScheme.onSurfaceVariant, size: 20),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ── Body: full-screen map + draggable form sheet ────────────────────
      body: Stack(
        children: [
          // ── Layer 1: Full-screen map ────────────────────────────────────
          Positioned.fill(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: colorScheme.primary),
                  )
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentCenter,
                      initialZoom: 16.0,
                      onTap: (tapPosition, point) {
                        setState(() => _currentCenter = point);
                        _mapController.move(point, _mapController.camera.zoom);
                        _onMapPositionChanged(point);
                      },
                      onMapReady: () => setState(() => _isMapReady = true),
                      onPositionChanged: (position, hasGesture) {
                        if (hasGesture) {
                          setState(() => _currentCenter = position.center);
                          _onMapPositionChanged(_currentCenter);
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: _isSatelliteView
                            ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                            : 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.thiruannamalaiyarsnacks.app',
                      ),
                    ],
                  ),
          ),

          // ── Layer 2: Map centre pin ─────────────────────────────────────
          if (!_isLoading)
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    // Shift the pin up so its tip is at the exact centre
                    padding: const EdgeInsets.only(bottom: 54),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Address tooltip bubble
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: kPaddingM,
                            vertical: kPaddingS,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(kRadiusS),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withValues(alpha: 0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            "Delivery location",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        // Tooltip arrow
                        CustomPaint(
                          size: const Size(10, 5),
                          painter: _TrianglePainter(color: colorScheme.primary),
                        ),
                        Icon(Icons.location_on, color: colorScheme.primary, size: 54),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ── Layer 3: Map action buttons ─────────────────────────────────
          if (!_isLoading) ...[
            // Satellite / Standard toggle (top-right)
            Positioned(
              top: kPaddingS,
              right: kPaddingM,
              child: FloatingActionButton.small(
                heroTag: 'satellite',
                onPressed: () => setState(() => _isSatelliteView = !_isSatelliteView),
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.primary,
                elevation: 4,
                child: Icon(
                  _isSatelliteView ? Icons.map_outlined : Icons.satellite_alt_outlined,
                ),
              ),
            ),

            // Sheet expand/collapse toggle (top-left)
            Positioned(
              top: kPaddingS,
              left: kPaddingM,
              child: FloatingActionButton.small(
                heroTag: 'sheet_toggle',
                onPressed: () {
                  final current = _sheetController.size;
                  if (current >= _snapMax - 0.05) {
                    // Collapse to peek
                    _sheetController.animateTo(
                      _snapMin,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );
                  } else if (current >= _snapMid - 0.05) {
                    // Expand to max
                    _sheetController.animateTo(
                      _snapMax,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    // From peek → mid
                    _sheetController.animateTo(
                      _snapMid,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.primary,
                elevation: 4,
                child: AnimatedBuilder(
                  animation: _sheetController,
                  builder: (ctx, ch) {
                    final size = _sheetController.isAttached ? _sheetController.size : _snapMid;
                    return Icon(size >= _snapMax - 0.05
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded);
                  },
                ),
              ),
            ),

            // Use current location button (just above the sheet peek area)
            AnimatedBuilder(
              animation: _sheetController,
              builder: (ctx, ch) {
                final sheetFraction =
                    _sheetController.isAttached ? _sheetController.size : _snapMid;
                final screenH = MediaQuery.of(context).size.height;
                // Position button just above the sheet's top edge
                final bottomOffset = screenH * sheetFraction + 12;
                return Positioned(
                  bottom: bottomOffset,
                  left: 0,
                  right: 0,
                  child: ch!,
                );
              },
              child: Center(
                child: InkWell(
                  onTap: _determinePosition,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kPaddingM,
                      vertical: kPaddingS,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isDeterminingPosition
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              )
                            : Icon(Icons.my_location, color: colorScheme.primary, size: 18),
                        const SizedBox(width: kPaddingS),
                        Text(
                          "Use current location",
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          // ── Layer 4: DraggableScrollableSheet with the address form ──────
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: _snapMid,
            minChildSize: _snapMin,
            maxChildSize: _snapMax,
            snap: true,
            snapSizes: const [_snapMin, _snapMid, _snapMax],
            builder: (ctx, scrollController) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // ── Sticky sheet header (drag handle + address preview) ──
                    SliverAppBar(
                      pinned: true,
                      automaticallyImplyLeading: false,
                      backgroundColor: colorScheme.surface,
                      surfaceTintColor: Colors.transparent,
                      expandedHeight: 0,
                      collapsedHeight: _buildSheetHeaderHeight(),
                      flexibleSpace: _buildSheetHeader(colorScheme, theme, distance),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                    ),

                    // ── Form body ───────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: _buildForm(colorScheme, theme),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  double _buildSheetHeaderHeight() => 90;

  Widget _buildSheetHeader(ColorScheme colorScheme, ThemeData theme, double distance) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Address preview row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kPaddingM),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kRed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: _isFetchingAddress
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: kRed),
                        )
                      : const Icon(Icons.location_on, color: kRed, size: 18),
                ),
                const SizedBox(width: kPaddingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentAddress.split(',').first.trim(),
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_currentAddress.contains(','))
                        Text(
                          _currentAddress.substring(_currentAddress.indexOf(',') + 1).trim(),
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Indicate distance from GPS location
                if (distance > 0.1)
                  Tooltip(
                    message: "${distance.toStringAsFixed(1)} km from your location",
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(kRadiusS),
                      ),
                      child: Text(
                        "${distance.toStringAsFixed(1)} km",
                        style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ],
      ),
    );
  }

  Widget _buildForm(ColorScheme colorScheme, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPaddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: kPaddingL),

          // ── Landmark / Address detail ─────────────────────────────────
          _sectionLabel("Address details*", colorScheme),
          TextField(
            controller: _landmarkController,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "Flat no., Floor, nearby landmark",
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "E.g. Floor, House no., Apartment name",
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10),
          ),

          const SizedBox(height: kPaddingL),

          // ── Receiver details ──────────────────────────────────────────
          _sectionLabel("Receiver details*", colorScheme),
          const SizedBox(height: kPaddingS),

          _outlinedField(
            controller: _fullNameController,
            label: "Full Name",
            hint: "Full Name",
            icon: Icons.person_outline,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: kPaddingM),
          _outlinedField(
            controller: _phoneController,
            label: "Phone Number",
            hint: "Phone Number",
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            colorScheme: colorScheme,
            bold: true,
          ),

          const SizedBox(height: kPaddingL),

          // ── Label chips ───────────────────────────────────────────────
          _sectionLabel("Save address as", colorScheme),
          const SizedBox(height: kPaddingS),
          Row(
            children: [
              _LabelChip(
                label: "Home",
                icon: Icons.home_outlined,
                isSelected: _selectedLabel == "Home",
                onTap: () => setState(() => _selectedLabel = "Home"),
              ),
              const SizedBox(width: kPaddingS),
              _LabelChip(
                label: "Work",
                icon: Icons.work_outline,
                isSelected: _selectedLabel == "Work",
                onTap: () => setState(() => _selectedLabel = "Work"),
              ),
              const SizedBox(width: kPaddingS),
              _LabelChip(
                label: "Other",
                icon: Icons.location_on_outlined,
                isSelected: _selectedLabel == "Other",
                onTap: () => setState(() => _selectedLabel = "Other"),
              ),
            ],
          ),

          const SizedBox(height: kPaddingL),

          // ── Door / building image ─────────────────────────────────────
          _sectionLabel("Door/building image (optional)", colorScheme),
          const SizedBox(height: kPaddingS),
          InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(kRadiusM),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(kRadiusM),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: _doorImage == null
                  ? Padding(
                      padding: const EdgeInsets.all(kPaddingM),
                      child: Column(
                        children: [
                          const Icon(Icons.add_a_photo_outlined, color: kRed, size: 24),
                          const SizedBox(height: kPaddingS),
                          const Text(
                            "Add an image",
                            style: TextStyle(color: kRed, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Helps delivery partners find your location faster",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusM)),
                          child: Image.file(
                            File(_doorImage!.path),
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: kPaddingM,
                            vertical: kPaddingS,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 18),
                              const SizedBox(width: kPaddingS),
                              Expanded(
                                child: Text(
                                  "Image added successfully",
                                  style: TextStyle(color: colorScheme.onSurface, fontSize: 12),
                                ),
                              ),
                              TextButton(
                                onPressed: _pickImage,
                                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                child: const Text("Change", style: TextStyle(color: kRed, fontSize: 12)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                onPressed: () => setState(() => _doorImage = null),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: kPaddingXL),

          // ── Save / Update button ──────────────────────────────────────
          Consumer<AddressController>(
            builder: (context, controller, child) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kRed,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kRadiusM),
                  ),
                  elevation: 0,
                ),
                onPressed: (controller.isLoading || _isFetchingAddress)
                    ? null
                    : () async {
                        final fullName = _fullNameController.text.trim();
                        final phone = _phoneController.text.trim();
                        final street = _streetController.text.trim();
                        final landmark = _landmarkController.text.trim();

                        if (fullName.isEmpty || phone.isEmpty || street.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please fill all required fields")),
                          );
                          return;
                        }

                        if (widget.address != null) {
                          final updated = widget.address!.copyWith(
                            label: _selectedLabel,
                            fullName: fullName,
                            phoneNumber: phone,
                            street: street,
                            landmark: landmark,
                            city: _cityController.text,
                            state: _stateController.text,
                            zipCode: _zipController.text,
                            latitude: _currentCenter.latitude,
                            longitude: _currentCenter.longitude,
                          );
                          await controller.updateAddress(updated);
                        } else {
                          await controller.addAddress(
                            _selectedLabel,
                            street,
                            _cityController.text,
                            fullName: fullName,
                            phoneNumber: phone,
                            landmark: landmark,
                            state: _stateController.text,
                            zipCode: _zipController.text,
                            latitude: _currentCenter.latitude,
                            longitude: _currentCenter.longitude,
                          );
                        }

                        if (controller.error == null && context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                child: controller.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        widget.address != null ? "Update address" : "Save address",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              );
            },
          ),

          // Bottom safe-area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + kPaddingXL),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, ColorScheme colorScheme) {
    return Text(
      text,
      style: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _outlinedField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ColorScheme colorScheme,
    TextInputType keyboardType = TextInputType.text,
    bool bold = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadiusM)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusM),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusM),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _LabelChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _LabelChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kRadiusS),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: kPaddingM, vertical: kPaddingS),
        decoration: BoxDecoration(
          color: isSelected ? kRed.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(kRadiusS),
          border: Border.all(color: isSelected ? kRed : colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? kRed : colorScheme.onSurfaceVariant),
            const SizedBox(width: kPaddingS),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
