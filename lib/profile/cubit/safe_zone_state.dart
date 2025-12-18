import 'package:equatable/equatable.dart';
import 'package:safe_zone/profile/models/safe_zone_model.dart';

enum SafeZoneStatus {
  initial,
  loading,
  success,
  error,
}

class SafeZoneState extends Equatable {
  const SafeZoneState({
    this.status = SafeZoneStatus.initial,
    this.safeZones = const [],
    this.errorMessage,
  });

  final SafeZoneStatus status;
  final List<SafeZone> safeZones;
  final String? errorMessage;

  SafeZoneState copyWith({
    SafeZoneStatus? status,
    List<SafeZone>? safeZones,
    String? errorMessage,
  }) {
    return SafeZoneState(
      status: status ?? this.status,
      safeZones: safeZones ?? this.safeZones,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, safeZones, errorMessage];
}
