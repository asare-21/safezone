part of 'notification_settings_cubit.dart';

/// Represents the state of notification settings
class NotificationSettingsState extends Equatable {
  const NotificationSettingsState({
    this.pushNotifications = false,
    this.proximityAlerts = true,
    this.soundVibration = false,
    this.anonymousReporting = true,
    this.shareLocationWithContacts = false,
    this.alertRadius = 2.5,
    this.isLoading = false,
  });

  /// Whether push notifications are enabled
  final bool pushNotifications;

  /// Whether proximity alerts are enabled
  final bool proximityAlerts;

  /// Whether sound and vibration are enabled
  final bool soundVibration;

  /// Whether anonymous reporting is enabled
  final bool anonymousReporting;

  /// Whether location sharing with contacts is enabled
  final bool shareLocationWithContacts;

  /// Alert radius in kilometers
  final double alertRadius;

  /// Whether settings are being loaded or saved
  final bool isLoading;

  /// Creates a copy of this state with the given fields replaced
  NotificationSettingsState copyWith({
    bool? pushNotifications,
    bool? proximityAlerts,
    bool? soundVibration,
    bool? anonymousReporting,
    bool? shareLocationWithContacts,
    double? alertRadius,
    bool? isLoading,
  }) {
    return NotificationSettingsState(
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
  List<Object?> get props => [
    pushNotifications,
    proximityAlerts,
    soundVibration,
    anonymousReporting,
    shareLocationWithContacts,
    alertRadius,
    isLoading,
  ];
}
