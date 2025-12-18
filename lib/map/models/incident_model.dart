import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum IncidentCategory {
  accident,
}

extension IncidentCategoryExtension on IncidentCategory {
  String get displayName {
    switch (this) {
      case IncidentCategory.accident:
        return 'Accident';
    }
  }

  IconData get icon {
    switch (this) {
      case IncidentCategory.accident:
        return Icons.car_crash;
    }
  }

  Color get color {
    switch (this) {
      case IncidentCategory.accident:
        return const Color(0xFFFF3B30);
    }
  }
}

enum TimeFilter {
  twentyFourHours,
  sevenDays,
  thirtyDays,
}

extension TimeFilterExtension on TimeFilter {
  String get displayName {
    switch (this) {
      case TimeFilter.twentyFourHours:
        return '24h';
      case TimeFilter.sevenDays:
        return '7d';
      case TimeFilter.thirtyDays:
        return '30d';
    }
  }

  Duration get duration {
    switch (this) {
      case TimeFilter.twentyFourHours:
        return const Duration(hours: 24);
      case TimeFilter.sevenDays:
        return const Duration(days: 7);
      case TimeFilter.thirtyDays:
        return const Duration(days: 30);
    }
  }
}

class Incident {
  Incident({
    required this.id,
    required this.category,
    required this.location,
    required this.timestamp,
    required this.title,
    this.description,
    this.confirmedBy = 0,
    this.notifyNearby = false,
  });

  final String id;
  final IncidentCategory category;
  final LatLng location;
  final DateTime timestamp;
  final String title;
  final String? description;
  final int confirmedBy;
  final bool notifyNearby;

  bool isWithinTimeFilter(TimeFilter filter) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference <= filter.duration;
  }
}

enum RiskLevel {
  safe,
  moderate,
  high,
}

extension RiskLevelExtension on RiskLevel {
  String get displayName {
    switch (this) {
      case RiskLevel.safe:
        return 'Safe Zone';
      case RiskLevel.moderate:
        return 'Moderate Risk Zone';
      case RiskLevel.high:
        return 'High Risk Zone';
    }
  }

  Color get color {
    switch (this) {
      case RiskLevel.safe:
        return const Color(0xFF34C759);
      case RiskLevel.moderate:
        return const Color(0xFFFFD60A);
      case RiskLevel.high:
        return const Color(0xFFFF4C4C);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case RiskLevel.safe:
        return const Color(0xFFE8F5E9);
      case RiskLevel.moderate:
        return const Color(0xFFFFFDE7);
      case RiskLevel.high:
        return const Color(0xFFFFEBEE);
    }
  }
}
