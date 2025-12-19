import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:safe_zone/user_settings/services/user_preferences_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'profile_state.dart';

/// Cubit that manages profile settings
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    SharedPreferences? sharedPreferences,
    UserPreferencesApiService? apiService,
  })  : _sharedPreferences = sharedPreferences,
        _apiService = apiService,
        super(const ProfileState());

  final SharedPreferences? _sharedPreferences;
  final UserPreferencesApiService? _apiService;

  static const String _alertRadiusKey = 'alert_radius';
  static const String _defaultZoomKey = 'default_zoom';
  static const String _locationIconKey = 'location_icon';
  static const String _deviceIdKey = 'device_id';

  /// Get device ID from shared preferences
  Future<String?> _getDeviceId() async {
    final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
    return prefs.getString(_deviceIdKey);
  }

  /// Load saved settings from persistent storage and backend
  Future<void> loadSettings() async {
    emit(state.copyWith(isLoading: true));

    try {
      final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
      
      // Try to load from backend first
      final deviceId = await _getDeviceId();
      if (_apiService != null && deviceId != null) {
        try {
          final backendPrefs = await _apiService.getPreferences(deviceId);
          
          // Update local cache with backend values
          await prefs.setDouble(_alertRadiusKey, backendPrefs.alertRadius);
          await prefs.setDouble(_defaultZoomKey, backendPrefs.defaultZoom);
          await prefs.setString(_locationIconKey, backendPrefs.locationIcon);
          
          emit(
            state.copyWith(
              alertRadius: backendPrefs.alertRadius,
              defaultZoom: backendPrefs.defaultZoom,
              locationIcon: backendPrefs.locationIcon,
              isLoading: false,
            ),
          );
          return;
        } catch (e) {
          // Fall back to local storage if backend fails
          if (kDebugMode) {
            print('Failed to load from backend, using local storage: $e');
          }
        }
      }
      
      // Load from local storage
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
      
      // Sync with backend
      final deviceId = await _getDeviceId();
      if (_apiService != null && deviceId != null) {
        try {
          await _apiService.updatePreferences(
            deviceId: deviceId,
            alertRadius: radius,
          );
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync alert radius to backend: $e');
          }
        }
      }
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
      
      // Sync with backend
      final deviceId = await _getDeviceId();
      if (_apiService != null && deviceId != null) {
        try {
          await _apiService.updatePreferences(
            deviceId: deviceId,
            defaultZoom: zoom,
          );
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync default zoom to backend: $e');
          }
        }
      }
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
      
      // Sync with backend
      final deviceId = await _getDeviceId();
      if (_apiService != null && deviceId != null) {
        try {
          await _apiService.updatePreferences(
            deviceId: deviceId,
            locationIcon: iconPath,
          );
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync location icon to backend: $e');
          }
        }
      }
    } on Exception catch (e) {
      // Persistence failed, but state is already updated
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
