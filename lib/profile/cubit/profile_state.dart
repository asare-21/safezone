part of 'profile_cubit.dart';

/// Represents the state of profile settings
class ProfileState {
  const ProfileState({
    this.alertRadius = 2.5,
    this.isLoading = false,
  });

  /// Alert radius in kilometers
  final double alertRadius;

  /// Whether the state is currently loading
  final bool isLoading;

  ProfileState copyWith({
    double? alertRadius,
    bool? isLoading,
  }) {
    return ProfileState(
      alertRadius: alertRadius ?? this.alertRadius,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileState &&
        other.alertRadius == alertRadius &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => Object.hash(alertRadius, isLoading);
}
