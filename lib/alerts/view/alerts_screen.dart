import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_icons/line_icons.dart';
import 'package:safe_zone/alerts/models/alert_model.dart';
import 'package:safe_zone/alerts/view/alert_details_screen.dart';
import 'package:safe_zone/home/home.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  // Filter state
  Set<AlertSeverity> _selectedSeverities = {
    AlertSeverity.high,
    AlertSeverity.medium,
    AlertSeverity.low,
    AlertSeverity.info,
  };
  Set<AlertType> _selectedTypes = {
    AlertType.highRisk,
    AlertType.theft,
    AlertType.eventCrowd,
    AlertType.trafficCleared,
  };
  AlertTimeFilter _selectedTimeFilter = AlertTimeFilter.all;

  // Mock data for demonstration
  final List<Alert> _mockAlerts = [
    Alert(
      id: '1',
      type: AlertType.highRisk,
      severity: AlertSeverity.high,
      title: 'Entering High-Risk Area',
      location: 'Market St & 5th Ave',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      icon: Icons.warning,
      iconColor: const Color(0xFFFF4C4C),
      iconBackgroundColor: const Color(0xFFFFF0F0),
    ),
    Alert(
      id: '2',
      type: AlertType.theft,
      severity: AlertSeverity.medium,
      title: 'Recent Theft Reported',
      location: 'Central Park Entrance',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      confirmedBy: 3,
      icon: Icons.star,
      iconColor: const Color(0xFFFF9500),
      iconBackgroundColor: const Color(0xFFFFF4E5),
    ),
    Alert(
      id: '3',
      type: AlertType.eventCrowd,
      severity: AlertSeverity.low,
      title: 'Public Event Crowd',
      location: 'Downtown Plaza',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      icon: Icons.people,
      iconColor: const Color(0xFF5856D6),
      iconBackgroundColor: const Color(0xFFF0F0FF),
    ),
    Alert(
      id: '4',
      type: AlertType.trafficCleared,
      severity: AlertSeverity.info,
      title: 'Traffic Accident Cleared',
      location: 'I-95 Exit 42',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      icon: Icons.check_circle,
      iconColor: const Color(0xFF8E8E93),
      iconBackgroundColor: const Color(0xFFF5F5F5),
    ),
  ];

  List<Alert> get _filteredAlerts {
    return _mockAlerts.where((alert) {
      return _selectedSeverities.contains(alert.severity) &&
          _selectedTypes.contains(alert.type) &&
          alert.isWithinTimeFilter(_selectedTimeFilter);
    }).toList();
  }

  void _showFilterDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _FilterDialog(
          selectedSeverities: _selectedSeverities,
          selectedTypes: _selectedTypes,
          selectedTimeFilter: _selectedTimeFilter,
          onApply: (severities, types, timeFilter) {
            setState(() {
              _selectedSeverities = severities;
              _selectedTypes = types;
              _selectedTimeFilter = timeFilter;
            });
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Safety Alerts',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
                  ),
                  IconButton(
                    onPressed: _showFilterDialog,
                    icon: const Icon(
                      LineIcons.horizontalSliders,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            // Filter chips
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildFilterChip('All Alerts', selected: true),
                  const SizedBox(width: 12),
                  _buildFilterChip('High Severity'),
                  const SizedBox(width: 12),
                  _buildFilterChip('Recent'),
                  const SizedBox(width: 12),
                  _buildFilterChip('Nearby'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Safe zone status card
                    _buildSafeZoneCard(context),

                    const SizedBox(height: 32),

                    // Real-time alerts section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Real-time Alerts',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          'SORTED BY TIME',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Alert list
                    ..._filteredAlerts.map(
                      (alert) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildAlertCard(context, alert),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Map View FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.read<BottomNavigationCubit>().navigateToMap();
        },
        backgroundColor: theme.colorScheme.primary,
        icon: const Icon(Icons.map, color: Colors.white),
        label: const Text(
          'Map View',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFilterChip(String label, {bool selected = false}) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected ? Colors.black : const Color(0xFFE5E5E5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSafeZoneCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFF34C759),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'You are in a Safe Zone',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'No immediate threats detected in your current vicinity.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Alert alert) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => AlertDetailsScreen(alert: alert),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Alert icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: alert.iconBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    alert.icon,
                    color: alert.iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Alert content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alert.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // Severity indicator
                          if (alert.severity == AlertSeverity.high)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: alert.severityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Reported ${alert.timeAgo}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 13,
                        ),
                      ),
                      if (alert.confirmedBy != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Confirmed by ${alert.confirmedBy} users',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            alert.location,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Chevron
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  const _FilterDialog({
    required this.selectedSeverities,
    required this.selectedTypes,
    required this.selectedTimeFilter,
    required this.onApply,
  });

  final Set<AlertSeverity> selectedSeverities;
  final Set<AlertType> selectedTypes;
  final AlertTimeFilter selectedTimeFilter;
  final void Function(
    Set<AlertSeverity> severities,
    Set<AlertType> types,
    AlertTimeFilter timeFilter,
  ) onApply;

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late Set<AlertSeverity> _tempSeverities;
  late Set<AlertType> _tempTypes;
  late AlertTimeFilter _tempTimeFilter;

  @override
  void initState() {
    super.initState();
    _tempSeverities = Set.from(widget.selectedSeverities);
    _tempTypes = Set.from(widget.selectedTypes);
    _tempTimeFilter = widget.selectedTimeFilter;
  }

  void _toggleSeverity(AlertSeverity severity) {
    setState(() {
      if (_tempSeverities.contains(severity)) {
        _tempSeverities.remove(severity);
      } else {
        _tempSeverities.add(severity);
      }
    });
  }

  void _toggleType(AlertType type) {
    setState(() {
      if (_tempTypes.contains(type)) {
        _tempTypes.remove(type);
      } else {
        _tempTypes.add(type);
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _tempSeverities = {
        AlertSeverity.high,
        AlertSeverity.medium,
        AlertSeverity.low,
        AlertSeverity.info,
      };
      _tempTypes = {
        AlertType.highRisk,
        AlertType.theft,
        AlertType.eventCrowd,
        AlertType.trafficCleared,
      };
      _tempTimeFilter = AlertTimeFilter.all;
    });
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filter Alerts',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          TextButton(
            onPressed: _clearFilters,
            child: Text(
              'Clear All',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Severity filter
              Text(
                'Severity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AlertSeverity.values.map((severity) {
                  final isSelected = _tempSeverities.contains(severity);
                  final color = Alert(
                    id: '',
                    type: AlertType.highRisk,
                    severity: severity,
                    title: '',
                    location: '',
                    timestamp: DateTime.now(),
                  ).severityColor;

                  return GestureDetector(
                    onTap: () => _toggleSeverity(severity),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? color : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? color : const Color(0xFFE5E5E5),
                        ),
                      ),
                      child: Text(
                        severity.displayName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Type filter
              Text(
                'Alert Type',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AlertType.values.map((type) {
                  final isSelected = _tempTypes.contains(type);

                  return GestureDetector(
                    onTap: () => _toggleType(type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.black
                              : const Color(0xFFE5E5E5),
                        ),
                      ),
                      child: Text(
                        type.displayName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Time filter
              Text(
                'Time Range',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AlertTimeFilter.values.map((timeFilter) {
                  final isSelected = _tempTimeFilter == timeFilter;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _tempTimeFilter = timeFilter;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.black
                              : const Color(0xFFE5E5E5),
                        ),
                      ),
                      child: Text(
                        timeFilter.displayName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
          onPressed: () {
            widget.onApply(
              _tempSeverities,
              _tempTypes,
              _tempTimeFilter,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Apply Filters',
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
