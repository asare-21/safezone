import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_icons/line_icons.dart';
import 'package:safe_zone/alerts/alerts.dart';
import 'package:safe_zone/home/home.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AlertsScreenView();
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
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => BlocProvider.value(
        value: context.read<AlertFilterCubit>(),
        child: const _FilterBottomSheet(),
      ),
    );
  }

  void _showAlertDetails(BuildContext context, Alert alert) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AlertDetailsScreen(alert: alert),
      ),
    );
  }

  void _showAlertActions(BuildContext context, Alert alert) {
    // Placeholder for future implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Long press actions for ${alert.title}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showSafeZoneDetails(BuildContext context) {
    // Placeholder for future implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Safe Zone details'),
        duration: Duration(seconds: 1),
      ),
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
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFF8F9FA),
                  const Color(0xFFF8F9FA).withOpacity(0.5),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Enhanced header with status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Safety Alerts',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 32,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Stay informed, stay safe',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Badge(
                              backgroundColor: theme.colorScheme.primary,
                              child: IconButton(
                                onPressed: () => _showFilterDialog(context),
                                icon: const Icon(
                                  LineIcons.horizontalSliders,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Live status indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF34C759),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF34C759).withOpacity(0.5),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'System Status: Active',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Enhanced filter chips with counters
                  SizedBox(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _buildEnhancedFilterChip(
                          context,
                          'All Alerts',
                          QuickFilter.all,
                          filterState.selectedQuickFilter == QuickFilter.all,
                          count: _mockAlerts.length,
                        ),
                        const SizedBox(width: 8),
                        _buildEnhancedFilterChip(
                          context,
                          'Critical',
                          QuickFilter.highSeverity,
                          filterState.selectedQuickFilter == QuickFilter.highSeverity,
                          count: _mockAlerts.where((a) => a.severity == AlertSeverity.high).length,
                          color: const Color(0xFFFF4C4C),
                        ),
                        const SizedBox(width: 8),
                        _buildEnhancedFilterChip(
                          context,
                          'Recent',
                          QuickFilter.recent,
                          filterState.selectedQuickFilter == QuickFilter.recent,
                          count: _mockAlerts
                              .where((a) => a.timestamp.isAfter(DateTime.now().subtract(const Duration(hours: 1))))
                              .length,
                        ),
                        const SizedBox(width: 8),
                        _buildEnhancedFilterChip(
                          context,
                          'Nearby',
                          QuickFilter.nearby,
                          filterState.selectedQuickFilter == QuickFilter.nearby,
                          icon: Icons.location_on_outlined,
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

                          // Empty state
                          if (filteredAlerts.isEmpty) ...[
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 32),
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.notifications_off_outlined,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'No alerts match your filters',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try adjusting your filters or check back later',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  OutlinedButton(
                                    onPressed: () => context.read<AlertFilterCubit>().resetFilters(),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      side: BorderSide(color: theme.colorScheme.primary),
                                    ),
                                    child: Text(
                                      'Reset Filters',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Alert list
                          ...filteredAlerts.map(
                            (alert) => _buildAlertCard(context, alert),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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

  // Improved chip widget
  Widget _buildEnhancedFilterChip(
    BuildContext context,
    String label,
    QuickFilter filter,
    bool selected, {
    int? count,
    Color? color,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final backgroundColor = selected
        ? (color ?? theme.colorScheme.primary)
        : Colors.white;

    return GestureDetector(
      onTap: () => context.read<AlertFilterCubit>().setQuickFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? backgroundColor
                : Colors.grey.shade300,
            width: selected ? 0 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: (color ?? theme.colorScheme.primary).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: selected ? Colors.white : Colors.grey.shade800,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(0.2)
                      : (color ?? theme.colorScheme.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : (color ?? theme.colorScheme.primary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSafeZoneCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSafeZoneDetails(context),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E8),
              Color(0xFFF0F9F0),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade100,
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF34C759).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield,
                color: Color(0xFF34C759),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You\'re in a Safe Zone',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: const Color(0xFF1A7F3A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No immediate threats detected in your vicinity.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF1A7F3A).withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF34C759),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Alert alert) {
    final theme = Theme.of(context);
    final isCritical = alert.severity == AlertSeverity.high;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isCritical
                ? alert.severityColor.withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: isCritical ? 1 : 0,
          ),
        ],
        border: isCritical
            ? Border.all(
                color: alert.severityColor.withOpacity(0.3),
                width: 1.5,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showAlertDetails(context, alert),
          onLongPress: () => _showAlertActions(context, alert),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Severity indicator
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: alert.severityColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),

                // Alert icon with badge
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: alert.iconBackgroundColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        alert.icon,
                        color: alert.iconColor,
                        size: 24,
                      ),
                    ),
                    if (isCritical)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: alert.severityColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.warning,
                            size: 8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Alert content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alert.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: isCritical
                                        ? Colors.black
                                        : Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule_outlined,
                                      size: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      alert.timeAgo,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (alert.confirmedBy != null) ...[
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.people_outline,
                                        size: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${alert.confirmedBy} confirmations',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isCritical)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: alert.severityColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'CRITICAL',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: alert.severityColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              alert.location,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
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

// Filter bottom sheet implementation
class _FilterBottomSheet extends StatelessWidget {
  const _FilterBottomSheet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertFilterCubit, AlertFilterState>(
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Alerts',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.read<AlertFilterCubit>().resetFilters(),
                          child: Text(
                            'Reset',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Active filters indicator
                    if (state.selectedSeverities.isNotEmpty ||
                        state.selectedTypes.length != AlertType.values.length)
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_alt,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${state.selectedSeverities.length} severity filters • ${state.selectedTypes.length} types',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),
                    _buildSeverityFilterSection(context, state),
                    const SizedBox(height: 24),
                    _buildAlertTypeFilterSection(context, state),
                    const SizedBox(height: 24),
                    _buildTimeRangeFilterSection(context, state),
                    const SizedBox(height: 24),

                    // Apply button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Builds the severity filter section
  Widget _buildSeverityFilterSection(
    BuildContext context,
    AlertFilterState state,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            final isSelected = state.selectedSeverities.contains(severity);
            return _FilterChip(
              label: severity.displayName,
              isSelected: isSelected,
              color: severity.color,
              onTap: () => context
                  .read<AlertFilterCubit>()
                  .toggleSeverity(severity),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Builds the alert type filter section
  Widget _buildAlertTypeFilterSection(
    BuildContext context,
    AlertFilterState state,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            return _FilterChip(
              label: type.displayName,
              isSelected: isSelected,
              color: Colors.black,
              onTap: () => context.read<AlertFilterCubit>().toggleType(type),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Builds the time range filter section
  Widget _buildTimeRangeFilterSection(
    BuildContext context,
    AlertFilterState state,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            return _FilterChip(
              label: timeFilter.displayName,
              isSelected: isSelected,
              color: Colors.black,
              onTap: () => context
                  .read<AlertFilterCubit>()
                  .setTimeFilter(timeFilter),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Reusable filter chip widget for the filter dialog
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
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
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
