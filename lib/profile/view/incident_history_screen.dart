import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:safe_zone/map/models/incident_model.dart';
import 'package:safe_zone/profile/models/user_incident_model.dart';

class IncidentHistoryScreen extends StatefulWidget {
  const IncidentHistoryScreen({super.key});

  @override
  State<IncidentHistoryScreen> createState() => _IncidentHistoryScreenState();
}

class _IncidentHistoryScreenState extends State<IncidentHistoryScreen> {
  IncidentCategory? _selectedCategory;
  IncidentStatus? _selectedStatus;
  String _sortBy = 'Recent'; // Recent, Oldest, Most Confirmed

  // Mock data for demonstration
  late List<UserIncident> _mockIncidents;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    _mockIncidents = [
      UserIncident(
        id: '1',
        category: IncidentCategory.theft,
        locationName: 'Market St & 5th Ave, Downtown',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        title: 'Bike theft at shopping district',
        description:
            'Witnessed a bike being stolen from the rack outside the mall. Suspect fled on foot towards the subway station.',
        status: IncidentStatus.verified,
        confirmedBy: 8,
        impactScore: 25,
      ),
      UserIncident(
        id: '2',
        category: IncidentCategory.suspicious,
        locationName: 'Central Park, North Entrance',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        title: 'Suspicious activity near parking lot',
        description:
            'Group of individuals acting suspiciously around parked vehicles. Appeared to be checking car doors.',
        status: IncidentStatus.pending,
        confirmedBy: 2,
        impactScore: 10,
      ),
      UserIncident(
        id: '3',
        category: IncidentCategory.lighting,
        locationName: 'Oak Street Underpass',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        title: 'Broken street lights in tunnel',
        description:
            'Multiple street lights are out in the tunnel creating very dark conditions at night.',
        status: IncidentStatus.resolved,
        confirmedBy: 15,
        impactScore: 40,
      ),
      UserIncident(
        id: '4',
        category: IncidentCategory.assault,
        locationName: 'University Campus, Building C',
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        title: 'Harassment incident reported',
        description:
            'Verbal harassment incident near the campus library. Campus security was notified.',
        status: IncidentStatus.verified,
        confirmedBy: 5,
        impactScore: 20,
      ),
      UserIncident(
        id: '5',
        category: IncidentCategory.theft,
        locationName: 'Transit Station, Platform 3',
        timestamp: DateTime.now().subtract(const Duration(days: 14)),
        title: 'Pickpocketing at subway station',
        description:
            'Wallet was stolen from bag on crowded platform during rush hour.',
        status: IncidentStatus.verified,
        confirmedBy: 12,
        impactScore: 35,
      ),
      UserIncident(
        id: '6',
        category: IncidentCategory.suspicious,
        locationName: 'West End Shopping Mall',
        timestamp: DateTime.now().subtract(const Duration(days: 21)),
        title: 'Suspicious vehicle in parking lot',
        description: 'Vehicle with no plates circling the parking lot repeatedly.',
        status: IncidentStatus.disputed,
        confirmedBy: 1,
        impactScore: 5,
      ),
    ];
  }

  List<UserIncident> get _filteredIncidents {
    var filtered = _mockIncidents;

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

  Map<String, int> get _statistics {
    return {
      'total': _mockIncidents.length,
      'verified':
          _mockIncidents.where((i) => i.status == IncidentStatus.verified).length,
      'pending':
          _mockIncidents.where((i) => i.status == IncidentStatus.pending).length,
      'totalImpact': _mockIncidents.fold(0, (sum, i) => sum + i.impactScore),
    };
  }

  void _showFilterDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
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
                    'Filter & Sort',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setStateDialog(() {
                        _selectedCategory = null;
                        _selectedStatus = null;
                        _sortBy = 'Recent';
                      });
                      setState(() {
                        _selectedCategory = null;
                        _selectedStatus = null;
                        _sortBy = 'Recent';
                      });
                    },
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
                      // Category filter
                      Text(
                        'Category',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFilterChip(
                            'All',
                            _selectedCategory == null,
                            Colors.black,
                            () {
                              setStateDialog(() {
                                _selectedCategory = null;
                              });
                              setState(() {
                                _selectedCategory = null;
                              });
                            },
                          ),
                          ...IncidentCategory.values.map((category) {
                            final isSelected = _selectedCategory == category;
                            return _buildFilterChip(
                              category.displayName,
                              isSelected,
                              category.color,
                              () {
                                setStateDialog(() {
                                  _selectedCategory = category;
                                });
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Status filter
                      Text(
                        'Status',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFilterChip(
                            'All',
                            _selectedStatus == null,
                            Colors.black,
                            () {
                              setStateDialog(() {
                                _selectedStatus = null;
                              });
                              setState(() {
                                _selectedStatus = null;
                              });
                            },
                          ),
                          ...IncidentStatus.values.map((status) {
                            final isSelected = _selectedStatus == status;
                            return _buildFilterChip(
                              status.displayName,
                              isSelected,
                              status.color,
                              () {
                                setStateDialog(() {
                                  _selectedStatus = status;
                                });
                                setState(() {
                                  _selectedStatus = status;
                                });
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Sort options
                      Text(
                        'Sort By',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['Recent', 'Oldest', 'Most Confirmed'].map((sort) {
                          final isSelected = _sortBy == sort;
                          return _buildFilterChip(
                            sort,
                            isSelected,
                            Colors.black,
                            () {
                              setStateDialog(() {
                                _sortBy = sort;
                              });
                              setState(() {
                                _sortBy = sort;
                              });
                            },
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
                    'Close',
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply',
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
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredIncidents = _filteredIncidents;
    final stats = _statistics;

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
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(
              LineIcons.horizontalSliders,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: filteredIncidents.isEmpty
            ? _buildEmptyState(theme)
            : SingleChildScrollView(
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
                backgroundColor: _selectedCategory!.color.withValues(alpha: 0.2),
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
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
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
              'You haven\'t reported any incidents yet. Start contributing to your community\'s safety by reporting incidents you encounter.',
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
                            color: incident.category.color.withValues(alpha: 0.1),
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

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Share incident
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.share),
                      label: const Text(
                        'Share',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // View on map
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.map),
                      label: const Text(
                        'View on Map',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
