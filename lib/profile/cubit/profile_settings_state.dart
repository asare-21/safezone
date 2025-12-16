part of 'profile_settings_cubit.dart';

/// Represents the state of profile settings
class ProfileSettingsState {
  const ProfileSettingsState({
    this.anonymousReporting = true,
  });

  /// Whether anonymous reporting is enabled
  final bool anonymousReporting;

  /// Creates a copy of this state with the given fields replaced
  ProfileSettingsState copyWith({
    bool? anonymousReporting,
  }) {
    return ProfileSettingsState(
      anonymousReporting: anonymousReporting ?? this.anonymousReporting,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileSettingsState &&
        other.anonymousReporting == anonymousReporting;
  }

  @override
  int get hashCode => anonymousReporting.hashCode;
}
