import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_zone/alerts/models/alert_model.dart';
import 'package:safe_zone/home/home.dart';

class AlertDetailsScreen extends StatelessWidget {
  const AlertDetailsScreen({required this.alert, super.key});

  final Alert alert;

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
          'Alert Details',
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
              // Alert icon and title card
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
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: alert.iconBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        alert.icon,
                        color: alert.iconColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: alert.severityColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getSeverityText(alert.severity),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: alert.severityColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
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
                      alert.location,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.access_time,
                      'Reported',
                      alert.timeAgo,
                    ),
                    if (alert.confirmedBy != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        Icons.people,
                        'Confirmed By',
                        '${alert.confirmedBy} users',
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.category,
                      'Type',
                      _getTypeText(alert.type),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Description card
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
                      _getDescription(alert),
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
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<BottomNavigationCubit>().navigateToMap();
                        Navigator.of(context).pop();
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
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w100,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getSeverityText(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.high:
        return 'High Severity';
      case AlertSeverity.medium:
        return 'Medium Severity';
      case AlertSeverity.low:
        return 'Low Severity';
      case AlertSeverity.info:
        return 'Informational';
    }
  }

  String _getTypeText(AlertType type) {
    switch (type) {
      case AlertType.highRisk:
        return 'High Risk Area';
      case AlertType.theft:
        return 'Theft';
      case AlertType.eventCrowd:
        return 'Event Crowd';
      case AlertType.trafficCleared:
        return 'Traffic Cleared';
    }
  }

  String _getDescription(Alert alert) {
    switch (alert.type) {
      case AlertType.highRisk:
        return 'You are approaching a high-risk area. This location has been flagged due to recent safety incidents. Please exercise extra caution and consider alternative routes if possible.';
      case AlertType.theft:
        return 'A theft has been reported in this area. Multiple users have confirmed this incident. Stay alert and secure your belongings when in this vicinity.';
      case AlertType.eventCrowd:
        return 'A public event is causing large crowds in this area. Traffic may be congested and parking limited. Plan extra time for travel and consider public transportation.';
      case AlertType.trafficCleared:
        return 'A previously reported traffic accident at this location has been cleared. Normal traffic flow has resumed. Drive safely.';
    }
  }
}
