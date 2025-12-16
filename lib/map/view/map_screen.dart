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

  final RiskLevel _currentRiskLevel = RiskLevel.moderate;
  Set<String> _selectedTimeFilterLabel = {'24h'};
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
            setState(() {
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
            });
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
                        _showIncidentDetails(incident);
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

                // Time filter segments
                SegmentedButton(
                  style: SegmentedButton.styleFrom(
                    backgroundColor: Colors.white,
                    selectedBackgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary,
                    selectedForegroundColor: Colors.white,
                  ),
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _selectedTimeFilterLabel = newSelection;
                      if (newSelection.contains('24h')) {
                        _selectedTimeFilter = TimeFilter.twentyFourHours;
                      } else if (newSelection.contains('7d')) {
                        _selectedTimeFilter = TimeFilter.sevenDays;
                      } else if (newSelection.contains('30d')) {
                        _selectedTimeFilter = TimeFilter.thirtyDays;
                      }
                    });
                  },
                  segments: const [
                    ButtonSegment(value: '24h', label: Text('24h')),
                    ButtonSegment(value: '7d', label: Text('7d')),
                    ButtonSegment(value: '30d', label: Text('30d')),
                  ],
                  selected: _selectedTimeFilterLabel,
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
        onPressed: _centerOnUserLocation,
        child: const Icon(
          LineIcons.crosshairs,
          size: 24,
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

class _ReportIncidentDialog extends StatefulWidget {
  const _ReportIncidentDialog({
    required this.onSubmit,
  });

  final void Function(
    IncidentCategory category,
    String title,
    String description,
  ) onSubmit;

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
      title: Row(
        children: [
          const Icon(
            LineIcons.bullhorn,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text(
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
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
