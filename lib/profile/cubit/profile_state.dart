part of 'profile_cubit.dart';

/// Represents the state of profile settings
class ProfileState {
  const ProfileState({
    this.alertRadius = 2.5,
    this.defaultZoom = 13.0,
    this.locationIcon = 'assets/icons/courier.png',
    this.isLoading = false,
  });

  /// Alert radius in kilometers
  final double alertRadius;

  /// Default zoom level for the map
  final double defaultZoom;

  /// Path to the location icon asset
  final String locationIcon;

  /// Whether the state is currently loading
  final bool isLoading;

  ProfileState copyWith({
    double? alertRadius,
    double? defaultZoom,
    String? locationIcon,
    bool? isLoading,
  }) {
    return ProfileState(
      alertRadius: alertRadius ?? this.alertRadius,
      defaultZoom: defaultZoom ?? this.defaultZoom,
      locationIcon: locationIcon ?? this.locationIcon,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileState &&
        other.alertRadius == alertRadius &&
        other.defaultZoom == defaultZoom &&
        other.locationIcon == locationIcon &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => Object.hash(alertRadius, defaultZoom, locationIcon, isLoading);
}
