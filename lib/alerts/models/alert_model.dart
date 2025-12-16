import 'package:flutter/material.dart';

enum AlertType {
  highRisk,
  theft,
  eventCrowd,
  trafficCleared,
}

enum AlertSeverity {
  high,
  medium,
  low,
  info,
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

  Color get severityColor {
    switch (severity) {
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
