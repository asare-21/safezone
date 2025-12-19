import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'profile_state.dart';

/// Cubit that manages profile settings
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({SharedPreferences? sharedPreferences})
    : _sharedPreferences = sharedPreferences,
      super(const ProfileState());

  final SharedPreferences? _sharedPreferences;

  static const String _alertRadiusKey = 'alert_radius';
  static const String _defaultZoomKey = 'default_zoom';
  static const String _locationIconKey = 'location_icon';

  /// Load saved settings from persistent storage
  Future<void> loadSettings() async {
    emit(state.copyWith(isLoading: true));

    try {
      final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
      final savedRadius = prefs.getDouble(_alertRadiusKey) ?? 2.5;
      final savedZoom = prefs.getDouble(_defaultZoomKey) ?? 13.0;
      final savedIcon = prefs.getString(_locationIconKey) ?? 'assets/icons/courier.png';

      emit(
        state.copyWith(
          alertRadius: savedRadius,
          defaultZoom: savedZoom,
          locationIcon: savedIcon,
          isLoading: false,
        ),
      );
    } on Exception catch (e) {
      // If loading fails, keep default value
      emit(state.copyWith(isLoading: false));
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// Update the alert radius setting
  Future<void> updateAlertRadius(double radius) async {
    if (radius < 0.5 || radius > 10) {
      return; // Invalid radius
    }

    emit(state.copyWith(alertRadius: radius));

    try {
      final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
      await prefs.setDouble(_alertRadiusKey, radius);
    } on Exception catch (e) {
      // Persistence failed, but state is already updated
      // Could emit an error state here if needed
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// Update the default zoom level setting
  Future<void> updateDefaultZoom(double zoom) async {
    if (zoom < 10 || zoom > 18) {
      return; // Invalid zoom level
    }

    emit(state.copyWith(defaultZoom: zoom));

    try {
      final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
      await prefs.setDouble(_defaultZoomKey, zoom);
    } on Exception catch (e) {
      // Persistence failed, but state is already updated
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// Update the location icon setting
  Future<void> updateLocationIcon(String iconPath) async {
    if (iconPath.isEmpty) {
      return; // Invalid icon path
    }

    emit(state.copyWith(locationIcon: iconPath));

    try {
      final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
      await prefs.setString(_locationIconKey, iconPath);
    } on Exception catch (e) {
      // Persistence failed, but state is already updated
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
