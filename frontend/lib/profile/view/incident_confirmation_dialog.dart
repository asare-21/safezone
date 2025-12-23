import 'package:flutter/material.dart';
import 'package:safe_zone/profile/models/user_score_model.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Dialog to prompt user to confirm if an incident is still present
class IncidentConfirmationDialog extends StatelessWidget {
  const IncidentConfirmationDialog({
    required this.incident,
    required this.onConfirm,
    required this.onDismiss,
    super.key,
  });

  final NearbyIncident incident;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final distanceInMeters = incident.distanceMeters.round();
    final timeAgo = _formatTimeAgo(incident.timestamp);

    return ShadDialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Incident Nearby',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$distanceInMeters m away • $timeAgo',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Incident details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _formatCategory(incident.category),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (incident.confirmedBy > 0) ...[
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${incident.confirmedBy} confirmed',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    incident.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (incident.description != null &&
                      incident.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      incident.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Question
            Text(
              'Is this incident still present?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your confirmation helps keep our community safe and earns you points!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: ShadButton.outline(
                    onPressed: onDismiss,
                    child: const Text('Not Sure'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ShadButton(
                    onPressed: onConfirm,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, size: 18),
                        const SizedBox(width: 8),
                        const Text('Yes, Confirm'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Earn +5 points',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCategory(String category) {
    switch (category) {
      case 'accident':
        return 'Accident';
      case 'fire':
        return 'Fire';
      case 'theft':
        return 'Theft';
      case 'suspicious':
        return 'Suspicious Activity';
      case 'lighting':
        return 'Lighting Issue';
      case 'assault':
        return 'Assault';
      case 'vandalism':
        return 'Vandalism';
      case 'harassment':
        return 'Harassment';
      case 'roadHazard':
        return 'Road Hazard';
      case 'animalDanger':
        return 'Animal Danger';
      case 'medicalEmergency':
        return 'Medical Emergency';
      case 'naturalDisaster':
        return 'Natural Disaster';
      case 'powerOutage':
        return 'Power Outage';
      case 'waterIssue':
        return 'Water Issue';
      case 'noise':
        return 'Noise Complaint';
      case 'trespassing':
        return 'Trespassing';
      case 'drugActivity':
        return 'Drug Activity';
      case 'weaponSighting':
        return 'Weapon Sighting';
      default:
        return category;
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
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

  /// Show the incident confirmation dialog
  static Future<bool?> show(
    BuildContext context,
    NearbyIncident incident,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => IncidentConfirmationDialog(
        incident: incident,
        onConfirm: () => Navigator.of(context).pop(true),
        onDismiss: () => Navigator.of(context).pop(false),
      ),
    );
  }
}
