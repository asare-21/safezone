import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_icons/line_icons.dart';
import 'package:safe_zone/alerts/alerts.dart';
import 'package:safe_zone/home/home.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AlertFilterCubit(),
      child: const _AlertsScreenView(),
    );
  }
}

class _AlertsScreenView extends StatelessWidget {
  const _AlertsScreenView();

  // Mock data for demonstration
  static List<Alert> get _mockAlerts => [
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

  List<Alert> _getFilteredAlerts(AlertFilterState filterState) {
    return _mockAlerts.where((alert) {
      return filterState.selectedSeverities.contains(alert.severity) &&
          filterState.selectedTypes.contains(alert.type) &&
          alert.isWithinTimeFilter(filterState.selectedTimeFilter);
    }).toList();
  }

  void _showFilterDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: context.read<AlertFilterCubit>(),
          child: const _FilterDialog(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AlertFilterCubit, AlertFilterState>(
      builder: (context, filterState) {
        final filteredAlerts = _getFilteredAlerts(filterState);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                        onPressed: () => _showFilterDialog(context),
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
                      _buildFilterChip(
                        context,
                        'All Alerts',
                        QuickFilter.all,
                        filterState.selectedQuickFilter == QuickFilter.all,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        context,
                        'High Severity',
                        QuickFilter.highSeverity,
                        filterState.selectedQuickFilter ==
                            QuickFilter.highSeverity,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        context,
                        'Recent',
                        QuickFilter.recent,
                        filterState.selectedQuickFilter == QuickFilter.recent,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        context,
                        'Nearby',
                        QuickFilter.nearby,
                        filterState.selectedQuickFilter == QuickFilter.nearby,
                      ),
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
                        ...filteredAlerts.map(
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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  // For filter chips with selection, use InputChip:
  Widget _buildFilterChip(
    BuildContext context,
    String label,
    QuickFilter filter,
    bool selected,
  ) {
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
      onPressed: () => context.read<AlertFilterCubit>().setQuickFilter(filter),
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

class _FilterDialog extends StatelessWidget {
  const _FilterDialog();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertFilterCubit, AlertFilterState>(
      builder: (context, state) {
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
                onPressed: () =>
                    context.read<AlertFilterCubit>().resetFilters(),
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
                      final isSelected =
                          state.selectedSeverities.contains(severity);
                      final color = severity.color;

                      return GestureDetector(
                        onTap: () => context
                            .read<AlertFilterCubit>()
                            .toggleSeverity(severity),
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
                      final isSelected = state.selectedTypes.contains(type);

                      return GestureDetector(
                        onTap: () =>
                            context.read<AlertFilterCubit>().toggleType(type),
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
                      final isSelected = state.selectedTimeFilter == timeFilter;

                      return GestureDetector(
                        onTap: () => context
                            .read<AlertFilterCubit>()
                            .setTimeFilter(timeFilter),
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
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      },
    );
  }
}
