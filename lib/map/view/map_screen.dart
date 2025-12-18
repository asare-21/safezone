import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_icons/line_icons.dart';
import 'package:safe_zone/map/cubit/map_filter_cubit.dart';
import 'package:safe_zone/map/models/incident_model.dart';
import 'package:safe_zone/map/utils/debouncer.dart';
import 'package:safe_zone/profile/profile.dart';

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

  // New York City center coordinates (example location)
  final LatLng _center = const LatLng(40.7128, -74.0060);

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
    await _initializeMockData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapFilterCubit>().initializeIncidents(_allIncidents);
    });
  }

  Future<void> _initializeMockData() async {
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
      builder: (BuildContext context) {
        return _IncidentDetailsSheet(incident: incident);
      },
    );
  }

  void _showReportIncidentDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _ReportIncidentDialog(
          onSubmit: (category, title, description) {
            final newIncident = Incident(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              category: category,
              location: _center,
              timestamp: DateTime.now(),
              title: title,
              description: description,
              confirmedBy: 1,
            );
            _allIncidents.insert(0, newIncident);
            // Update cubit with new incidents list
            context.read<MapFilterCubit>().initializeIncidents(_allIncidents);

            Navigator.of(dialogContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Incident reported successfully'),
                backgroundColor: Color(0xFF34C759),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  void _centerOnUserLocation(double defaultZoom) {
    _mapController.move(_center, defaultZoom);
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
              'Loading incidents...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _zoomIn() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom + 1,
    );
  }

  void _zoomOut() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom - 1,
    );
  }

  bool _isRecentIncident(Incident incident) {
    final hoursSinceIncident = DateTime.now()
        .difference(incident.timestamp)
        .inHours;
    return hoursSinceIncident < 1;
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
                          initialCenter: _center,
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
                                    duration: const Duration(milliseconds: 300),
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
                                                color: incident.category.color
                                                    .withValues(alpha: 0.6),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.2,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : [
                                              BoxShadow(
                                                color: Colors.black.withValues(
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
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _center,
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
                                            color: theme.colorScheme.primary,
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

                      // Top overlay with search and filters
                      SafeArea(
                        child: Column(
                          children: [
                            // Avatar and search bar
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 5,
                              ),
                              child: Row(
                                children: [
                                  // Search bar
                                  Expanded(
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
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
                                      child: TextField(
                                        controller: _searchController,
                                        onChanged: (value) {
                                          _searchDebouncer.run(() {
                                            context
                                                .read<MapFilterCubit>()
                                                .updateSearchQuery(value);
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Search location or zone',
                                          hintStyle: TextStyle(
                                            color: theme.colorScheme.onSurface
                                                .withValues(
                                                  alpha: 0.4,
                                                ),
                                            fontSize: 15,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.search,
                                            color: theme.colorScheme.onSurface
                                                .withValues(
                                                  alpha: 0.4,
                                                ),
                                          ),
                                          suffixIcon:
                                              filterState.searchQuery.isNotEmpty
                                              ? IconButton(
                                                  icon: const Icon(Icons.clear),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    context
                                                        .read<MapFilterCubit>()
                                                        .clearSearch();
                                                  },
                                                )
                                              : null,
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
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

                            // Time filter segments
                            SegmentedButton<TimeFilter>(
                              style: SegmentedButton.styleFrom(
                                backgroundColor: Colors.white,
                                selectedBackgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                selectedForegroundColor: Colors.white,
                              ),
                              onSelectionChanged: (newSelection) {
                                final selectedFilter = newSelection.first;
                                context.read<MapFilterCubit>().updateTimeFilter(
                                  selectedFilter,
                                );
                              },
                              segments: const [
                                ButtonSegment(
                                  value: TimeFilter.twentyFourHours,
                                  label: Text('24h'),
                                ),
                                ButtonSegment(
                                  value: TimeFilter.sevenDays,
                                  label: Text('7d'),
                                ),
                                ButtonSegment(
                                  value: TimeFilter.thirtyDays,
                                  label: Text('30d'),
                                ),
                              ],
                              selected: {filterState.timeFilter},
                            ),

                            const SizedBox(height: 12),

                            // Category filter chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                children: IncidentCategory.values.map((
                                  category,
                                ) {
                                  final isSelected = filterState
                                      .selectedCategories
                                      .contains(category);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: _buildCategoryFilterChip(
                                      category,
                                      isSelected: isSelected,
                                      onTap: () {
                                        context
                                            .read<MapFilterCubit>()
                                            .toggleCategory(
                                              category,
                                            );
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
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
                                    color: Colors.black.withValues(alpha: 0.1),
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
                                    style: theme.textTheme.bodyMedium?.copyWith(
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
                                      padding: const EdgeInsets.only(top: 16),
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

                      // Zoom controls
                      Positioned(
                        right: 16,
                        bottom: 180,
                        child: Column(
                          children: [
                            FloatingActionButton.small(
                              heroTag: 'zoom_in',
                              onPressed: _zoomIn,
                              backgroundColor: Colors.white,
                              tooltip: 'Zoom in',
                              child: Icon(
                                Icons.add,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: 'zoom_out',
                              onPressed: _zoomOut,
                              backgroundColor: Colors.white,
                              tooltip: 'Zoom out',
                              child: Icon(
                                Icons.remove,
                                color: theme.colorScheme.primary,
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
                              color: filterState.riskLevel.backgroundColor,
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

class _ReportIncidentDialog extends StatefulWidget {
  const _ReportIncidentDialog({
    required this.onSubmit,
  });

  final void Function(
    IncidentCategory category,
    String title,
    String description,
  )
  onSubmit;

  @override
  State<_ReportIncidentDialog> createState() => _ReportIncidentDialogState();
}

class _ReportIncidentDialogState extends State<_ReportIncidentDialog> {
  final _formKey = GlobalKey<FormState>();
  IncidentCategory _selectedCategory = IncidentCategory.theft;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _selectedCategory,
        _titleController.text,
        _descriptionController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Row(
        children: [
          Icon(
            LineIcons.bullhorn,
            size: 24,
          ),
          SizedBox(width: 12),
          Text(
            'Report Incident',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category selection
              Text(
                'Category',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: IncidentCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? category.color : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? category.color
                              : const Color(0xFFE5E5E5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.icon,
                            color: isSelected ? Colors.white : category.color,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category.displayName,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Title field
              Text(
                'Title',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Brief description of the incident',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              Text(
                'Description (Optional)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Additional details...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Submit',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Incident confirmed'),
                            backgroundColor: Color(0xFF34C759),
                            behavior: SnackBarBehavior.floating,
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sharing incident...'),
                            backgroundColor: Color(0xFF007AFF),
                            behavior: SnackBarBehavior.floating,
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
