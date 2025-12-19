import 'package:flutter/material.dart';

enum AlertType {
  highRisk,
  theft,
  eventCrowd,
  trafficCleared,
}

extension AlertTypeExtension on AlertType {
  String get displayName {
    switch (this) {
      case AlertType.highRisk:
        return 'High Risk';
      case AlertType.theft:
        return 'Theft';
      case AlertType.eventCrowd:
        return 'Event Crowd';
      case AlertType.trafficCleared:
        return 'Traffic Cleared';
    }
  }
}

enum AlertSeverity {
  high,
  medium,
  low,
  info,
}

extension AlertSeverityExtension on AlertSeverity {
  String get displayName {
    switch (this) {
      case AlertSeverity.high:
        return 'High';
      case AlertSeverity.medium:
        return 'Medium';
      case AlertSeverity.low:
        return 'Low';
      case AlertSeverity.info:
        return 'Info';
    }
  }

  Color get color {
    switch (this) {
      case AlertSeverity.high:
        return const Color(0xFFFF4C4C);
      case AlertSeverity.medium:
        return const Color(0xFFFF9500);
      case AlertSeverity.low:
        return const Color(0xFF5856D6);
      case AlertSeverity.info:
        return const Color(0xFF8E8E93);
    }
  }
}

enum AlertTimeFilter {
  lastHour,
  lastDay,
  lastWeek,
  all,
}

extension AlertTimeFilterExtension on AlertTimeFilter {
  String get displayName {
    switch (this) {
      case AlertTimeFilter.lastHour:
        return 'Last Hour';
      case AlertTimeFilter.lastDay:
        return 'Last 24 Hours';
      case AlertTimeFilter.lastWeek:
        return 'Last Week';
      case AlertTimeFilter.all:
        return 'All Time';
    }
  }

  Duration? get duration {
    switch (this) {
      case AlertTimeFilter.lastHour:
        return const Duration(hours: 1);
      case AlertTimeFilter.lastDay:
        return const Duration(hours: 24);
      case AlertTimeFilter.lastWeek:
        return const Duration(days: 7);
      case AlertTimeFilter.all:
        return null;
    }
  }
}

class Alert {
  Alert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.location,
    required this.timestamp,
    this.confirmedBy,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
  });

  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String location;
  final DateTime timestamp;
  final int? confirmedBy;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }

  Color get severityColor => severity.color;

  bool isWithinTimeFilter(AlertTimeFilter filter) {
    if (filter.duration == null) return true;
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference <= filter.duration!;
  }
}
