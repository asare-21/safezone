import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum EmergencyServiceType {
  police,
  hospital,
  fireStation,
  ambulance,
}

extension EmergencyServiceTypeExtension on EmergencyServiceType {
  String get displayName {
    switch (this) {
      case EmergencyServiceType.police:
        return 'Police Station';
      case EmergencyServiceType.hospital:
        return 'Hospital';
      case EmergencyServiceType.fireStation:
        return 'Fire Station';
      case EmergencyServiceType.ambulance:
        return 'Ambulance';
    }
  }

  IconData get icon {
    switch (this) {
      case EmergencyServiceType.police:
        return Icons.local_police;
      case EmergencyServiceType.hospital:
        return Icons.local_hospital;
      case EmergencyServiceType.fireStation:
        return Icons.local_fire_department;
      case EmergencyServiceType.ambulance:
        return Icons.emergency;
    }
  }

  Color get color {
    switch (this) {
      case EmergencyServiceType.police:
        return const Color(0xFF007AFF);
      case EmergencyServiceType.hospital:
        return const Color(0xFFFF4C4C);
      case EmergencyServiceType.fireStation:
        return const Color(0xFFFF9500);
      case EmergencyServiceType.ambulance:
        return const Color(0xFF34C759);
    }
  }
}

class EmergencyService {
  EmergencyService({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.phoneNumber,
    this.address,
    this.hours,
    this.distance,
  });

  final String id;
  final String name;
  final EmergencyServiceType type;
  final LatLng location;
  final String phoneNumber;
  final String? address;
  final String? hours;
  final double? distance; // in kilometers

  String get formattedDistance {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toStringAsFixed(0)}m away';
    }
    return '${distance!.toStringAsFixed(1)}km away';
  }
}
