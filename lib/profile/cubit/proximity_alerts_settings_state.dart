part of 'proximity_alerts_settings_cubit.dart';

/// Represents the state of proximity alerts settings
class ProximityAlertsSettingsState {
  const ProximityAlertsSettingsState({
    this.pushNotifications = true,
    this.proximityAlerts = true,
    this.soundVibration = false,
    this.anonymousReporting = true,
    this.shareLocationWithContacts = false,
    this.alertRadius = 2.5,
    this.isLoading = true,
  });

  final bool pushNotifications;
  final bool proximityAlerts;
  final bool soundVibration;
  final bool anonymousReporting;
  final bool shareLocationWithContacts;
  final double alertRadius;
  final bool isLoading;

  ProximityAlertsSettingsState copyWith({
    bool? pushNotifications,
    bool? proximityAlerts,
    bool? soundVibration,
    bool? anonymousReporting,
    bool? shareLocationWithContacts,
    double? alertRadius,
    bool? isLoading,
  }) {
    return ProximityAlertsSettingsState(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      proximityAlerts: proximityAlerts ?? this.proximityAlerts,
      soundVibration: soundVibration ?? this.soundVibration,
      anonymousReporting: anonymousReporting ?? this.anonymousReporting,
      shareLocationWithContacts:
          shareLocationWithContacts ?? this.shareLocationWithContacts,
      alertRadius: alertRadius ?? this.alertRadius,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProximityAlertsSettingsState &&
        other.pushNotifications == pushNotifications &&
        other.proximityAlerts == proximityAlerts &&
        other.soundVibration == soundVibration &&
        other.anonymousReporting == anonymousReporting &&
        other.shareLocationWithContacts == shareLocationWithContacts &&
        other.alertRadius == alertRadius &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return Object.hash(
      pushNotifications,
      proximityAlerts,
      soundVibration,
      anonymousReporting,
      shareLocationWithContacts,
      alertRadius,
      isLoading,
    );
  }
}
