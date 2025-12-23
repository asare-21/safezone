import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_icons/line_icons.dart';
import 'package:safe_zone/map/models/incident_model.dart';
import 'package:safe_zone/profile/cubit/incident_history_cubit.dart';
import 'package:safe_zone/profile/models/user_incident_model.dart';
import 'package:safe_zone/profile/models/user_score_model.dart';
import 'package:safe_zone/utils/device_id_utils.dart';

class IncidentHistoryScreen extends StatefulWidget {
  const IncidentHistoryScreen({super.key});

  @override
  State<IncidentHistoryScreen> createState() => _IncidentHistoryScreenState();
}

class _IncidentHistoryScreenState extends State<IncidentHistoryScreen> {
  IncidentCategory? _selectedCategory;
  IncidentStatus? _selectedStatus;
  final String _sortBy = 'Recent'; // Recent, Oldest, Most Confirmed

  @override
  void initState() {
    super.initState();
    _loadUserIncidents();
  }

  Future<void> _loadUserIncidents() async {
    final deviceId = await DeviceIdUtils.getDeviceId();
    if (!mounted) return;
    context.read<IncidentHistoryCubit>().loadUserIncidents(deviceId);
  }

  List<UserIncident> _convertToUserIncidents(List<ReportedIncident> incidents) {
    return incidents.map((incident) {
      final category = _getCategoryFromString(incident.category);
      final status = _getStatusFromString(incident.status);
      
      return UserIncident(
        id: incident.id.toString(),
        category: category,
        locationName: 'Lat: ${incident.latitude.toStringAsFixed(4)}, '
            'Lng: ${incident.longitude.toStringAsFixed(4)}',
        location: LatLng(incident.latitude, incident.longitude),
        timestamp: incident.timestamp,
        title: incident.title,
        description: incident.description,
        status: status,
        confirmedBy: incident.confirmedBy,
        impactScore: incident.impactScore,
      );
    }).toList();
  }

  IncidentCategory _getCategoryFromString(String category) {
    try {
      return IncidentCategory.values.firstWhere(
        (e) => e.name == category,
      );
    } catch (e) {
      return IncidentCategory.suspicious;
    }
  }

  IncidentStatus _getStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return IncidentStatus.verified;
      case 'resolved':
        return IncidentStatus.resolved;
      case 'disputed':
        return IncidentStatus.disputed;
      default:
        return IncidentStatus.pending;
    }
  }

  List<UserIncident> _filterAndSortIncidents(List<UserIncident> incidents) {
    var filtered = incidents;

    // Filter by category
    if (_selectedCategory != null) {
      filtered = filtered
          .where((incident) => incident.category == _selectedCategory)
          .toList();
    }

    // Filter by status
    if (_selectedStatus != null) {
      filtered = filtered
          .where((incident) => incident.status == _selectedStatus)
          .toList();
    }

    // Sort
    if (_sortBy == 'Recent') {
      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } else if (_sortBy == 'Oldest') {
      filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } else if (_sortBy == 'Most Confirmed') {
      filtered.sort((a, b) => b.confirmedBy.compareTo(a.confirmedBy));
    }

    return filtered;
  }

  Map<String, int> _calculateStatistics(List<UserIncident> incidents) {
    return {
      'total': incidents.length,
      'verified': incidents
          .where((i) => i.status == IncidentStatus.verified)
          .length,
      'pending': incidents
          .where((i) => i.status == IncidentStatus.pending)
          .length,
      'totalImpact': incidents.fold(0, (sum, i) => sum + i.impactScore),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          'My Incident History',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ),
      body: BlocBuilder<IncidentHistoryCubit, IncidentHistoryState>(
        builder: (context, state) {
          if (state is IncidentHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is IncidentHistoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LineIcons.exclamationCircle,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load incidents',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUserIncidents,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is IncidentHistoryLoaded) {
            final userIncidents = _convertToUserIncidents(state.incidents);
            final filteredIncidents = _filterAndSortIncidents(userIncidents);
            final stats = _calculateStatistics(userIncidents);

            if (filteredIncidents.isEmpty) {
              return _buildEmptyState(theme);
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics cards
                    _buildStatisticsSection(theme, stats),
                    const SizedBox(height: 24),

                    // Active filters display
                    if (_selectedCategory != null || _selectedStatus != null)
                      _buildActiveFilters(theme),

                    // Section header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Reports',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          '${filteredIncidents.length} INCIDENTS',
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

                    // Incident list
                    ...filteredIncidents.map(
                      (incident) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildIncidentCard(theme, incident),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }

          // Initial state
          return _buildEmptyState(theme);
        },
      ),
    );
  }

  Widget _buildStatisticsSection(ThemeData theme, Map<String, int> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            'Total Reports',
            stats['total'].toString(),
            LineIcons.fileAlt,
            theme.colorScheme.primary,
            const Color(0xFFEFF6FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme,
            'Verified',
            stats['verified'].toString(),
            LineIcons.checkCircle,
            const Color(0xFF34C759),
            const Color(0xFFE8F5E9),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme,
            'Impact Score',
            stats['totalImpact'].toString(),
            LineIcons.trophy,
            const Color(0xFFFFD60A),
            const Color(0xFFFFFDE7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Filters',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (_selectedCategory != null)
              Chip(
                label: Text(_selectedCategory!.displayName),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
                backgroundColor: _selectedCategory!.color.withValues(
                  alpha: 0.2,
                ),
                side: BorderSide.none,
              ),
            if (_selectedStatus != null)
              Chip(
                label: Text(_selectedStatus!.displayName),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _selectedStatus = null;
                  });
                },
                backgroundColor: _selectedStatus!.color.withValues(alpha: 0.2),
                side: BorderSide.none,
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildIncidentCard(ThemeData theme, UserIncident incident) {
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
                builder: (context) => IncidentDetailScreen(incident: incident),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Category icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: incident.category.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        incident.category.icon,
                        color: incident.category.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title and time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            incident.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            incident.timeAgo,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: incident.status.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            incident.status.icon,
                            size: 14,
                            color: incident.status.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            incident.status.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: incident.status.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        incident.locationName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Stats row
                Row(
                  children: [
                    _buildStatItem(
                      theme,
                      LineIcons.users,
                      '${incident.confirmedBy} confirmed',
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      theme,
                      LineIcons.trophy,
                      '+${incident.impactScore} pts',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LineIcons.fileAlt,
                size: 60,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Incidents Yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "You haven't reported any incidents yet. Start contributing to your community's safety by reporting incidents you encounter.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text(
                'Report an Incident',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IncidentDetailScreen extends StatelessWidget {
  const IncidentDetailScreen({required this.incident, super.key});

  final UserIncident incident;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          'Incident Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card with category and status
              Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: incident.category.color.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            incident.category.icon,
                            color: incident.category.color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                incident.category.displayName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: incident.category.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                incident.title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: incident.status.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            incident.status.icon,
                            size: 16,
                            color: incident.status.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Status: ${incident.status.displayName}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: incident.status.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Information card
              Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      Icons.location_on,
                      'Location',
                      incident.locationName,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.calendar_today,
                      'Date Reported',
                      incident.formattedDate,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.access_time,
                      'Time',
                      incident.timeAgo,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.people,
                      'Confirmed By',
                      '${incident.confirmedBy} users',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.stars,
                      'Impact Score',
                      '+${incident.impactScore} points',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Description card
              if (incident.description != null)
                Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        incident.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 15,
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
