import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_icons/line_icons.dart';
import 'package:safe_zone/alerts/models/alert_model.dart';
import 'package:safe_zone/alerts/view/alert_details_screen.dart';
import 'package:safe_zone/home/home.dart';

/// Default filter values for alerts screen
class AlertFilterDefaults {
  const AlertFilterDefaults._();

  static const Set<AlertSeverity> severities = {
    AlertSeverity.high,
    AlertSeverity.medium,
    AlertSeverity.low,
    AlertSeverity.info,
  };
  static const Set<AlertType> types = {
    AlertType.highRisk,
    AlertType.theft,
    AlertType.eventCrowd,
    AlertType.trafficCleared,
  };
  static const AlertTimeFilter timeFilter = AlertTimeFilter.all;
}

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  // Filter state
  Set<AlertSeverity> _selectedSeverities = Set.from(
    AlertFilterDefaults.severities,
  );
  Set<AlertType> _selectedTypes = Set.from(AlertFilterDefaults.types);
  AlertTimeFilter _selectedTimeFilter = AlertFilterDefaults.timeFilter;

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

  // For filter chips with selection, use InputChip:
  Widget _buildFilterChip(
    String label, {
    bool selected = false,
    VoidCallback? onPressed,
  }) {
    return InputChip(
      label: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: selected
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface,
          fontSize: 14,
        ),
      ),
      selected: selected,
      onPressed: onPressed,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      selectedColor: Theme.of(context).colorScheme.primary,
      side: const BorderSide(
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      visualDensity: VisualDensity.compact,
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
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
  )
  onApply;

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
      _tempSeverities = Set.from(AlertFilterDefaults.severities);
      _tempTypes = Set.from(AlertFilterDefaults.types);
      _tempTimeFilter = AlertFilterDefaults.timeFilter;
    });
  }

  // Get icon for each alert type
  IconData _getTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.highRisk:
        return Icons.warning_rounded;
      case AlertType.theft:
        return Icons.shopping_bag_outlined;
      case AlertType.eventCrowd:
        return Icons.people_outline;
      case AlertType.trafficCleared:
        return Icons.traffic;
    }
  }

  // Get icon for each severity level
  IconData _getSeverityIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.high:
        return Icons.error_outline;
      case AlertSeverity.medium:
        return Icons.warning_amber_rounded;
      case AlertSeverity.low:
        return Icons.info_outline;
      case AlertSeverity.info:
        return Icons.notifications_none;
    }
  }

  // Count active filters
  int get _activeFilterCount {
    var count = 0;
    if (_tempSeverities.length != AlertSeverity.values.length) {
      count++;
    }
    if (_tempTypes.length != AlertType.values.length) {
      count++;
    }
    if (_tempTimeFilter != AlertTimeFilter.all) {
      count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeCount = _activeFilterCount;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Enhanced Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          LineIcons.filter,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filter Alerts',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                            ),
                          ),
                          if (activeCount > 0)
                            Text(
                              '$activeCount active filter${activeCount > 1 ? 's' : ''}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Severity Filter Section
                    _buildFilterSection(
                      theme: theme,
                      title: 'Severity',
                      icon: Icons.speed_rounded,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: AlertSeverity.values.map((severity) {
                          final isSelected = _tempSeverities.contains(severity);
                          final color = severity.color;

                          return _buildEnhancedChip(
                            label: severity.displayName,
                            icon: _getSeverityIcon(severity),
                            isSelected: isSelected,
                            selectedColor: color,
                            onTap: () => _toggleSeverity(severity),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 24),

                    // Type Filter Section
                    _buildFilterSection(
                      theme: theme,
                      title: 'Alert Type',
                      icon: Icons.category_outlined,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: AlertType.values.map((type) {
                          final isSelected = _tempTypes.contains(type);

                          return _buildEnhancedChip(
                            label: type.displayName,
                            icon: _getTypeIcon(type),
                            isSelected: isSelected,
                            selectedColor: theme.colorScheme.primary,
                            onTap: () => _toggleType(type),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 24),

                    // Time Filter Section
                    _buildFilterSection(
                      theme: theme,
                      title: 'Time Range',
                      icon: Icons.access_time_rounded,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: AlertTimeFilter.values.map((timeFilter) {
                          final isSelected = _tempTimeFilter == timeFilter;

                          return _buildEnhancedChip(
                            label: timeFilter.displayName,
                            icon: Icons.schedule,
                            isSelected: isSelected,
                            selectedColor: theme.colorScheme.primary,
                            onTap: () {
                              setState(() {
                                _tempTimeFilter = timeFilter;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Enhanced Footer with Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Clear All Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('Clear All'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Apply Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.onApply(
                          _tempSeverities,
                          _tempTypes,
                          _tempTimeFilter,
                        );
                      },
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Apply Filters'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildEnhancedChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? selectedColor : const Color(0xFFE5E5E5),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: selectedColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF8E8E93),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
