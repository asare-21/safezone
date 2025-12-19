import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum IncidentCategory {
  accident,
  fire,
  theft,
  suspicious,
  lighting,
  assault,
  vandalism,
  harassment,
  roadHazard,
  animalDanger,
  medicalEmergency,
  naturalDisaster,
  powerOutage,
  waterIssue,
  noise,
  trespassing,
  drugActivity,
  weaponSighting,
}

extension IncidentCategoryExtension on IncidentCategory {
  String get displayName {
    switch (this) {
      case IncidentCategory.accident:
        return 'Accident';
      case IncidentCategory.fire:
        return 'Fire';
      case IncidentCategory.theft:
        return 'Theft';
      case IncidentCategory.suspicious:
        return 'Suspicious Activity';
      case IncidentCategory.lighting:
        return 'Lighting Issue';
      case IncidentCategory.assault:
        return 'Assault';
      case IncidentCategory.vandalism:
        return 'Vandalism';
      case IncidentCategory.harassment:
        return 'Harassment';
      case IncidentCategory.roadHazard:
        return 'Road Hazard';
      case IncidentCategory.animalDanger:
        return 'Animal Danger';
      case IncidentCategory.medicalEmergency:
        return 'Medical Emergency';
      case IncidentCategory.naturalDisaster:
        return 'Natural Disaster';
      case IncidentCategory.powerOutage:
        return 'Power Outage';
      case IncidentCategory.waterIssue:
        return 'Water Issue';
      case IncidentCategory.noise:
        return 'Noise Complaint';
      case IncidentCategory.trespassing:
        return 'Trespassing';
      case IncidentCategory.drugActivity:
        return 'Drug Activity';
      case IncidentCategory.weaponSighting:
        return 'Weapon Sighting';
    }
  }

  IconData get icon {
    switch (this) {
      case IncidentCategory.accident:
        return Icons.car_crash;
      case IncidentCategory.fire:
        return Icons.local_fire_department;
      case IncidentCategory.theft:
        return Icons.security;
      case IncidentCategory.suspicious:
        return Icons.visibility;
      case IncidentCategory.lighting:
        return Icons.lightbulb;
      case IncidentCategory.assault:
        return Icons.warning;
      case IncidentCategory.vandalism:
        return Icons.broken_image;
      case IncidentCategory.harassment:
        return Icons.person_off;
      case IncidentCategory.roadHazard:
        return Icons.warning_amber;
      case IncidentCategory.animalDanger:
        return Icons.pets;
      case IncidentCategory.medicalEmergency:
        return Icons.medical_services;
      case IncidentCategory.naturalDisaster:
        return Icons.storm;
      case IncidentCategory.powerOutage:
        return Icons.power_off;
      case IncidentCategory.waterIssue:
        return Icons.water_damage;
      case IncidentCategory.noise:
        return Icons.volume_up;
      case IncidentCategory.trespassing:
        return Icons.no_accounts;
      case IncidentCategory.drugActivity:
        return Icons.medication;
      case IncidentCategory.weaponSighting:
        return Icons.dangerous;
    }
  }

  Color get color {
    switch (this) {
      case IncidentCategory.accident:
        return const Color(0xFFFF3B30);
      case IncidentCategory.fire:
        return const Color(0xFFFF9500);
      case IncidentCategory.theft:
        return const Color(0xFF5856D6);
      case IncidentCategory.suspicious:
        return const Color(0xFF5AC8FA);
      case IncidentCategory.lighting:
        return const Color(0xFFFFCC00);
      case IncidentCategory.assault:
        return const Color(0xFFAF52DE);
      case IncidentCategory.vandalism:
        return const Color(0xFF8E8E93);
      case IncidentCategory.harassment:
        return const Color(0xFFFF2D55);
      case IncidentCategory.roadHazard:
        return const Color(0xFFFF9500);
      case IncidentCategory.animalDanger:
        return const Color(0xFF32ADE6);
      case IncidentCategory.medicalEmergency:
        return const Color(0xFFFF3B30);
      case IncidentCategory.naturalDisaster:
        return const Color(0xFF5856D6);
      case IncidentCategory.powerOutage:
        return const Color(0xFF000000);
      case IncidentCategory.waterIssue:
        return const Color(0xFF007AFF);
      case IncidentCategory.noise:
        return const Color(0xFFFFCC00);
      case IncidentCategory.trespassing:
        return const Color(0xFF8E8E93);
      case IncidentCategory.drugActivity:
        return const Color(0xFFAF52DE);
      case IncidentCategory.weaponSighting:
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
