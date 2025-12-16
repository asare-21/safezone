import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_icons/line_icons.dart';
import 'package:safe_zone/map/models/incident_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  TimeFilter _selectedTimeFilter = TimeFilter.twentyFourHours;
  final Set<IncidentCategory> _selectedCategories = {
    IncidentCategory.theft,
    IncidentCategory.assault,
    IncidentCategory.suspicious,
    IncidentCategory.lighting,
  };

  // New York City center coordinates (example location)
  final LatLng _center = const LatLng(40.7128, -74.0060);
  RiskLevel _currentRiskLevel = RiskLevel.moderate;

  // Mock incidents for demonstration
  late List<Incident> _allIncidents;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    _allIncidents = [
      Incident(
        id: '1',
        category: IncidentCategory.theft,
        location: const LatLng(40.7580, -73.9855), // Times Square area
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        title: 'Theft reported',
        confirmedBy: 3,
      ),
      Incident(
        id: '2',
        category: IncidentCategory.assault,
        location: const LatLng(40.7489, -73.9680), // East side
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        title: 'Assault reported',
        confirmedBy: 2,
      ),
      Incident(
        id: '3',
        category: IncidentCategory.suspicious,
        location: const LatLng(40.7614, -73.9776), // Central Park South
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        title: 'Suspicious activity',
        confirmedBy: 1,
      ),
      Incident(
        id: '4',
        category: IncidentCategory.lighting,
        location: const LatLng(40.7282, -74.0776), // West Village
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        title: 'Poor lighting',
        confirmedBy: 4,
      ),
      Incident(
        id: '5',
        category: IncidentCategory.theft,
        location: const LatLng(40.7589, -73.9851), // Near Times Square
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        title: 'Pickpocketing',
        confirmedBy: 5,
      ),
      Incident(
        id: '6',
        category: IncidentCategory.assault,
        location: const LatLng(40.7128, -74.0134), // Downtown
        timestamp: DateTime.now().subtract(const Duration(days: 8)),
        title: 'Physical altercation',
        confirmedBy: 2,
      ),
    ];
  }

  List<Incident> get _filteredIncidents {
    return _allIncidents.where((incident) {
      return incident.isWithinTimeFilter(_selectedTimeFilter) &&
          _selectedCategories.contains(incident.category);
    }).toList();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _toggleCategory(IncidentCategory category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _showReportIncidentDialog() {
    // TODO(joasare019): Implement report incident functionality.
  }

  void _centerOnUserLocation() {
    _mapController.move(_center, 13);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 13,
              minZoom: 10,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.safezone.app',
              ),
              // Incident markers
              MarkerLayer(
                markers: _filteredIncidents.map((incident) {
                  return Marker(
                    point: incident.location,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        // TODO(joasare019): Show incident details
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: incident.category.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
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
            ],
          ),

          // Top overlay with search and filters
          SafeArea(
            child: Column(
              children: [
                // Avatar and search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // User avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4CC),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          LineIcons.user,
                          color: Color(0xFF8B7355),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Search bar
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search location or zone',
                              hintStyle: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                                fontSize: 15,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Time filter chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: TimeFilter.values.map((filter) {
                      final isSelected = _selectedTimeFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildTimeFilterChip(
                          filter.displayName,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedTimeFilter = filter;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 12),

                // Category filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: IncidentCategory.values.map((category) {
                      final isSelected = _selectedCategories.contains(category);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildCategoryFilterChip(
                          category,
                          isSelected: isSelected,
                          onTap: () => _toggleCategory(category),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Map controls (right side)
          Positioned(
            right: 16,
            bottom: 200,
            child: Column(
              children: [
                // Layers button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(LineIcons.layerGroup, size: 24),
                    onPressed: () {
                      // TODO(joasare019): Implement layer selection
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Current location button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      LineIcons.crosshairs,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: _centerOnUserLocation,
                  ),
                ),
              ],
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
                  color: _currentRiskLevel.backgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
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
                      color: _currentRiskLevel.color,
                      size: 12,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _currentRiskLevel.displayName,
                      style: TextStyle(
                        color: _currentRiskLevel.color,
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
            bottom: 24,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _showReportIncidentDialog,
                icon: const Icon(
                  LineIcons.bullhorn,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  'Report Incident',
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
                  shadowColor: Colors.black.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilterChip(
    String label, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black : const Color(0xFFE5E5E5),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterChip(
    IncidentCategory category, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? category.color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? category.color : const Color(0xFFE5E5E5),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              color: isSelected ? Colors.white : category.color,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              category.displayName,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
