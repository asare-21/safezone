part of 'profile_settings_cubit.dart';

/// Represents the state of profile settings
class ProfileSettingsState {
  const ProfileSettingsState({
    this.soundVibrationEnabled = false,
  });

  /// Whether sound and vibration are enabled for alerts
  final bool soundVibrationEnabled;

  /// Create a copy of this state with updated values
  ProfileSettingsState copyWith({
    bool? soundVibrationEnabled,
  }) {
    return ProfileSettingsState(
      soundVibrationEnabled:
          soundVibrationEnabled ?? this.soundVibrationEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileSettingsState &&
        other.soundVibrationEnabled == soundVibrationEnabled;
  }

  @override
  int get hashCode => soundVibrationEnabled.hashCode;
}
