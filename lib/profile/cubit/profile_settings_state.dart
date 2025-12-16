part of 'profile_settings_cubit.dart';

/// Represents the state of profile settings
class ProfileSettingsState extends Equatable {
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
  List<Object?> get props => [soundVibrationEnabled];
}
