import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// Represents a user-defined safe zone (e.g., home, school, work)
class SafeZone extends Equatable {
  const SafeZone({
    required this.id,
    required this.name,
    required this.location,
    required this.radius,
    this.type = SafeZoneType.custom,
    this.isActive = true,
    this.notifyOnEnter = true,
    this.notifyOnExit = true,
  });

  /// Unique identifier for the safe zone
  final String id;

  /// Name of the safe zone (e.g., "Home", "Work", "School")
  final String name;

  /// Center location of the safe zone
  final LatLng location;

  /// Radius in meters
  final double radius;

  /// Type of safe zone
  final SafeZoneType type;

  /// Whether the safe zone is currently active
  final bool isActive;

  /// Whether to notify when entering this zone
  final bool notifyOnEnter;

  /// Whether to notify when exiting this zone
  final bool notifyOnExit;

  /// Creates a copy with updated fields
  SafeZone copyWith({
    String? id,
    String? name,
    LatLng? location,
    double? radius,
    SafeZoneType? type,
    bool? isActive,
    bool? notifyOnEnter,
    bool? notifyOnExit,
  }) {
    return SafeZone(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      radius: radius ?? this.radius,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      notifyOnEnter: notifyOnEnter ?? this.notifyOnEnter,
      notifyOnExit: notifyOnExit ?? this.notifyOnExit,
    );
  }

  /// Converts to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'radius': radius,
      'type': type.name,
      'isActive': isActive,
      'notifyOnEnter': notifyOnEnter,
      'notifyOnExit': notifyOnExit,
    };
  }

  /// Creates from JSON
  factory SafeZone.fromJson(Map<String, dynamic> json) {
    return SafeZone(
      id: json['id'] as String,
      name: json['name'] as String,
      location: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      radius: json['radius'] as double,
      type: SafeZoneType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SafeZoneType.custom,
      ),
      isActive: json['isActive'] as bool? ?? true,
      notifyOnEnter: json['notifyOnEnter'] as bool? ?? true,
      notifyOnExit: json['notifyOnExit'] as bool? ?? true,
    );
  }

  /// Checks if a given location is within this safe zone
  bool contains(LatLng position) {
    const distance = Distance();
    final distanceInMeters = distance.as(
      LengthUnit.Meter,
      location,
      position,
    );
    return distanceInMeters <= radius;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        radius,
        type,
        isActive,
        notifyOnEnter,
        notifyOnExit,
      ];
}

/// Types of safe zones
enum SafeZoneType {
  home,
  work,
  school,
  custom,
}

extension SafeZoneTypeExtension on SafeZoneType {
  String get displayName {
    switch (this) {
      case SafeZoneType.home:
        return 'Home';
      case SafeZoneType.work:
        return 'Work';
      case SafeZoneType.school:
        return 'School';
      case SafeZoneType.custom:
        return 'Custom';
    }
  }
}
