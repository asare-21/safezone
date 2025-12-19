import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_icons/line_icons.dart';
import 'package:safe_zone/incident_report/incident_report.dart';
import 'package:safe_zone/map/cubit/map_filter_cubit.dart';
import 'package:safe_zone/map/models/incident_model.dart';
import 'package:safe_zone/map/utils/debouncer.dart';
import 'package:safe_zone/profile/profile.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MapScreenView();
  }
}

class _MapScreenView extends StatefulWidget {
  const _MapScreenView();

  @override
  State<_MapScreenView> createState() => _MapScreenViewState();
}

class _MapScreenViewState extends State<_MapScreenView> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _searchDebouncer = Debouncer(milliseconds: 300);

  // User's current location (initialized to null, will be fetched)
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  bool _isRequestingLocation = false;
  String? _locationError;

  // Default fallback location (center of world, will prompt for location)
  static const LatLng _fallbackLocation = LatLng(0, 0);

  // Mock incidents for demonstration
  late List<Incident> _allIncidents;

  // Loading state
  late Future<void> _dataLoadingFuture;

  @override
  void initState() {
    super.initState();
    _dataLoadingFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    await _getCurrentLocation();
    await _initializeMockData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapFilterCubit>().initializeIncidents(_allIncidents);
    });
  }

  /// Get the user's current location
  Future<void> _getCurrentLocation() async {
    // Prevent concurrent location requests
    if (_isRequestingLocation) return;

    setState(() {
      _isRequestingLocation = true;
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError =
              'Location services are disabled. Please enable '
              'location services in your device settings.';
          _isLoadingLocation = false;
          _isRequestingLocation = false;
        });
        return;
      }

      // Check location permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError =
                'Location permissions are denied. Please grant '
                'location permissions to use this feature.';
            _isLoadingLocation = false;
            _isRequestingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError =
              'Location permissions are permanently denied. '
              'Please enable location permissions in your device settings.';
          _isLoadingLocation = false;
          _isRequestingLocation = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
        _isRequestingLocation = false;
      });
    } on Exception catch (e) {
      setState(() {
        _locationError = 'Failed to get location: $e';
        _isLoadingLocation = false;
        _isRequestingLocation = false;
      });
    }
  }

  Future<void> _initializeMockData() async {
    // Only create mock incidents if we have a valid location
    if (_currentLocation == null) {
      _allIncidents = [];
      return;
    }

    const distance = Distance();

    // Generate incidents near the user's current location
    _allIncidents = [
      Incident(
        id: '1',
        category: IncidentCategory.accident,
        location: distance.offset(
          _currentLocation!,
          500, // 500 meters away
          45, // 45 degrees bearing (NE)
        ),
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        title: 'Car accident',
        confirmedBy: 3,
      ),
      Incident(
        id: '2',
        category: IncidentCategory.accident,
        location: distance.offset(
          _currentLocation!,
          800, // 800 meters away
          120, // 120 degrees bearing (ESE)
        ),
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        title: 'Bicycle accident',
        confirmedBy: 2,
      ),
      Incident(
        id: '3',
        category: IncidentCategory.accident,
        location: distance.offset(
          _currentLocation!,
          300, // 300 meters away
          350, // 350 degrees bearing (N-NW)
        ),
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        title: 'Pedestrian accident',
        confirmedBy: 1,
      ),
      Incident(
        id: '4',
        category: IncidentCategory.accident,
        location: distance.offset(
          _currentLocation!,
          1200, // 1.2 km away
          200, // 200 degrees bearing (SSW)
        ),
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        title: 'Minor collision',
        confirmedBy: 4,
      ),
      Incident(
        id: '5',
        category: IncidentCategory.accident,
        location: distance.offset(
          _currentLocation!,
          600, // 600 meters away
          90, // 90 degrees bearing (E)
        ),
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        title: 'Traffic accident',
        confirmedBy: 5,
      ),
      Incident(
        id: '6',
        category: IncidentCategory.accident,
        location: distance.offset(
          _currentLocation!,
          1500, // 1.5 km away
          270, // 270 degrees bearing (W)
        ),
        timestamp: DateTime.now().subtract(const Duration(days: 8)),
        title: 'Motorcycle accident',
        confirmedBy: 2,
      ),
    ];
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  void _showIncidentDetails(Incident incident) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: _IncidentDetailsSheet(incident: incident),
        );
      },
    );
  }

  void _showReportIncidentDialog() {
    // Don't allow incident reporting if location is not available
    if (_currentLocation == null) {
      ShadToaster.of(context).show(
        const ShadToast(
          title: Text('Location Required'),
          description: Text(
            'Please enable location services to report an incident.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => ReportIncidentScreen(
          onSubmit: (category, title, description, notifyNearby) {
            final newIncident = Incident(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              category: category,
              location: _currentLocation!,
              timestamp: DateTime.now(),
              title: title,
              description: description,
              confirmedBy: 1,
              notifyNearby: notifyNearby,
            );
            _allIncidents.insert(0, newIncident);
            // Update cubit with new incidents list
            this.context.read<MapFilterCubit>().initializeIncidents(
              _allIncidents,
            );

            Navigator.of(context).pop();

            // Show success message with notification status
            final categoryName = category.displayName;
            final message = notifyNearby
                ? '$categoryName reported and nearby users notified'
                : '$categoryName reported successfully';

            ShadToaster.of(context).show(
              ShadToast(
                title: const Text('Report Submitted'),
                description: Text(message),
              ),
            );
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _centerOnUserLocation(double defaultZoom) async {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, defaultZoom);
    } else if (!_isRequestingLocation) {
      // Try to get location again only if not already requesting
      await _getCurrentLocation();
      if (_currentLocation != null) {
        _mapController.move(_currentLocation!, defaultZoom);
      } else {
        // Show message if location is still not available
        if (mounted) {
          ShadToaster.of(context).show(
            ShadToast(
              title: const Text('Location Unavailable'),
              description: Text(
                _locationError ?? 'Unable to get your current location',
              ),
            ),
          );
        }
      }
    }
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              _isLoadingLocation
                  ? 'Getting your location...'
                  : 'Loading incidents...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (_locationError != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _locationError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _dataLoadingFuture = _initializeData();
                  });
                },
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isRecentIncident(Incident incident) {
    final hoursSinceIncident = DateTime.now()
        .difference(incident.timestamp)
        .inHours;
    return hoursSinceIncident < 1;
  }

  /// Generate circle points for a polygon
  List<LatLng> _generateCirclePoints(LatLng center, double radiusInMeters) {
    const numberOfPoints = 64; // Number of points to approximate the circle
    const distance = Distance();

    final points = <LatLng>[];
    for (var i = 0; i < numberOfPoints; i++) {
      final bearing = i * 360 / numberOfPoints;
      final point = distance.offset(
        center,
        radiusInMeters,
        bearing,
      );
      points.add(point);
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder(
      future: _dataLoadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        return BlocBuilder<SafeZoneCubit, SafeZoneState>(
          builder: (context, safeZoneState) {
            return BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, profileState) {
                return BlocBuilder<MapFilterCubit, MapFilterState>(
                  builder: (context, filterState) {
                    final filteredIncidents = context
                        .read<MapFilterCubit>()
                        .getFilteredIncidents();

                    return Scaffold(
                      body: Stack(
                        children: [
                          // Map
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter:
                                  _currentLocation ?? _fallbackLocation,
                              initialZoom: profileState.defaultZoom,
                              minZoom: 10,
                              maxZoom: 18,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.safezone.app',
                              ),

                              // Safe zone circles
                              PolygonLayer(
                                polygons: safeZoneState.safeZones
                                    .where((zone) => zone.isActive)
                                    .map((zone) {
                                      return Polygon(
                                        points: _generateCirclePoints(
                                          zone.location,
                                          zone.radius,
                                        ),
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        borderColor: theme.colorScheme.primary
                                            .withValues(alpha: 0.5),
                                        borderStrokeWidth: 2,
                                      );
                                    })
                                    .toList(),
                              ),

                              // Incident markers
                              MarkerLayer(
                                markers: filteredIncidents.map((incident) {
                                  final isRecent = _isRecentIncident(incident);
                                  return Marker(
                                    point: incident.location,
                                    width: 40,
                                    height: 40,
                                    child: GestureDetector(
                                      onTap: () {
                                        _showIncidentDetails(incident);
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        decoration: BoxDecoration(
                                          color: incident.category.color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          boxShadow: isRecent
                                              ? [
                                                  BoxShadow(
                                                    color: incident
                                                        .category
                                                        .color
                                                        .withValues(alpha: 0.6),
                                                    blurRadius: 8,
                                                    spreadRadius: 2,
                                                  ),
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                          alpha: 0.2,
                                                        ),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                          alpha: 0.2,
                                                        ),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                        ),
                                        child: Icon(
                                          incident.category.icon,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              if (_currentLocation != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: _currentLocation!,
                                      width: 48,
                                      height: 48,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            right: 0,
                                            bottom: 0,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    theme.colorScheme.primary,
                                                  ),
                                              strokeWidth: 5,
                                              value: 1,
                                            ),
                                          ),
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundColor: Colors.white,
                                            child: Image.asset(
                                              profileState.locationIcon,
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              width: 14,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),

                          // Empty state for filtered results
                          if (filteredIncidents.isEmpty)
                            Positioned.fill(
                              child: Center(
                                child: Container(
                                  margin: const EdgeInsets.all(24),
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_off,
                                        size: 48,
                                        color: theme.colorScheme.onSurface
                                            .withValues(
                                              alpha: 0.4,
                                            ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No incidents found',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Try adjusting your filters',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(
                                                    alpha: 0.6,
                                                  ),
                                            ),
                                      ),
                                      if (filterState
                                              .selectedCategories
                                              .isNotEmpty ||
                                          filterState.searchQuery.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 16,
                                          ),
                                          child: TextButton(
                                            onPressed: () {
                                              _searchController.clear();
                                              context
                                                  .read<MapFilterCubit>()
                                                  .clearFilters();
                                            },
                                            child: const Text('Clear filters'),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // Emergency Services button
                          Positioned(
                            right: 16,
                            bottom: 90,
                            child: FloatingActionButton(
                              heroTag: 'emergency_services',
                              onPressed: () {
                                context.push('/emergency-services');
                              },
                              backgroundColor: const Color(0xFFFF4C4C),
                              tooltip: 'Emergency Services',
                              child: const Icon(
                                Icons.local_hospital,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Location unavailable banner
                          if (_currentLocation == null &&
                              _locationError != null)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                color: theme.colorScheme.error,
                                child: SafeArea(
                                  bottom: false,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_off,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text(
                                          'Location unavailable. Enable location '
                                          'to see nearby incidents.',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _dataLoadingFuture =
                                                _initializeData();
                                          });
                                        },
                                        child: const Text(
                                          'Retry',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // Risk level indicator
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 100,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: filterState.riskLevel.backgroundColor,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: filterState.riskLevel.color,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      filterState.riskLevel.displayName,
                                      style: TextStyle(
                                        color: filterState.riskLevel.color,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Report incident button
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 15,
                            child: Center(
                              child: ElevatedButton.icon(
                                onPressed: _showReportIncidentDialog,
                                icon: const Icon(
                                  LineIcons.bullhorn,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                label: const Text(
                                  'Report Accident',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  elevation: 4,
                                  shadowColor: Colors.black.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      floatingActionButton: FloatingActionButton(
                        onPressed: () =>
                            _centerOnUserLocation(profileState.defaultZoom),
                        tooltip: 'Center on location',
                        child: const Icon(
                          LineIcons.crosshairs,
                          size: 24,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _IncidentDetailsSheet extends StatelessWidget {
  const _IncidentDetailsSheet({
    required this.incident,
  });

  final Incident incident;

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: incident.category.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      incident.category.icon,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      incident.category.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                incident.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // Timestamp
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimestamp(incident.timestamp),
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),

              // Description (if available)
              if (incident.description != null &&
                  incident.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  incident.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Map preview
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5E5E5),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: incident.location,
                    initialZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.safezone.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: incident.location,
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: incident.category.color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              incident.category.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Confirmed by
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Confirmed by ${incident.confirmedBy} ${incident.confirmedBy == 1 ? 'person' : 'people'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Confirm incident functionality
                        ShadToaster.of(context).show(
                          const ShadToast(
                            title: Text('Confirm Incident'),
                            description: Text('Incident confirmed'),
                          ),
                        );

                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Confirm'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Share incident functionality
                        ShadToaster.of(context).show(
                          const ShadToast(
                            title: Text('Share Incident'),
                            description: Text('Sharing incident...'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
