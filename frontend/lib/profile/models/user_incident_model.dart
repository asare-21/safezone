import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_zone/map/models/incident_model.dart';

enum IncidentStatus {
  pending,
  verified,
  resolved,
  disputed,
}

extension IncidentStatusExtension on IncidentStatus {
  String get displayName {
    switch (this) {
      case IncidentStatus.pending:
        return 'Pending';
      case IncidentStatus.verified:
        return 'Verified';
      case IncidentStatus.resolved:
        return 'Resolved';
      case IncidentStatus.disputed:
        return 'Disputed';
    }
  }

  Color get color {
    switch (this) {
      case IncidentStatus.pending:
        return const Color(0xFFFF9500);
      case IncidentStatus.verified:
        return const Color(0xFF34C759);
      case IncidentStatus.resolved:
        return const Color(0xFF8E8E93);
      case IncidentStatus.disputed:
        return const Color(0xFFFF4C4C);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case IncidentStatus.pending:
        return const Color(0xFFFFF4E5);
      case IncidentStatus.verified:
        return const Color(0xFFE8F5E9);
      case IncidentStatus.resolved:
        return const Color(0xFFF5F5F5);
      case IncidentStatus.disputed:
        return const Color(0xFFFFEBEE);
    }
  }

  IconData get icon {
    switch (this) {
      case IncidentStatus.pending:
        return Icons.schedule;
      case IncidentStatus.verified:
        return Icons.verified;
      case IncidentStatus.resolved:
        return Icons.check_circle;
      case IncidentStatus.disputed:
        return Icons.report_problem;
    }
  }
}

class UserIncident {
  UserIncident({
    required this.id,
    required this.category,
    required this.locationName,
    required this.timestamp,
    required this.title,
    required this.status,
    this.location,
    this.description,
    this.confirmedBy = 0,
    this.impactScore = 0,
  });

  final String id;
  final IncidentCategory category;
  final String locationName;
  final LatLng? location;
  final DateTime timestamp;
  final String title;
  final String? description;
  final IncidentStatus status;
  final int confirmedBy;
  final int impactScore; // Points earned from this incident

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }

  String get formattedDate {
    final month = timestamp.month.toString().padLeft(2, '0');
    final day = timestamp.day.toString().padLeft(2, '0');
    final year = timestamp.year;
    return '$month/$day/$year';
  }
}
