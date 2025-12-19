import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_zone/user_settings/services/user_preferences_api_service.dart';

part 'notification_settings_state.dart';

/// Cubit that manages notification settings state
class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  NotificationSettingsCubit({
    SharedPreferences? sharedPreferences,
    FirebaseMessaging? firebaseMessaging,
    UserPreferencesApiService? apiService,
  }) : _sharedPreferences = sharedPreferences,
       _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance,
       _apiService = apiService,
       super(const NotificationSettingsState()) {
    _loadSettings();
  }

  final SharedPreferences? _sharedPreferences;
  final FirebaseMessaging _firebaseMessaging;
  final UserPreferencesApiService? _apiService;
  SharedPreferences? _cachedPreferences;

  // Storage keys
  static const String _pushNotificationsKey = 'push_notifications';
  static const String _proximityAlertsKey = 'proximity_alerts';
  static const String _soundVibrationKey = 'sound_vibration';
  static const String _anonymousReportingKey = 'anonymous_reporting';
  static const String _shareLocationKey = 'share_location_with_contacts';
  static const String _alertRadiusKey = 'alert_radius';
  static const String _deviceIdKey = 'device_id';

  /// Get device ID from shared preferences
  String? _getDeviceId() {
    if (_sharedPreferences != null) {
      return _sharedPreferences.getString(_deviceIdKey);
    }
    return _cachedPreferences?.getString(_deviceIdKey);
  }

  /// Get SharedPreferences instance (cached)
  Future<SharedPreferences> _getPreferences() async {
    if (_sharedPreferences != null) return _sharedPreferences;
    _cachedPreferences ??= await SharedPreferences.getInstance();
    return _cachedPreferences!;
  }

  /// Load settings from persistent storage and backend
  Future<void> _loadSettings() async {
    emit(state.copyWith(isLoading: true));

    try {
      final prefs = await _getPreferences();

      // Try to load from backend first
      final deviceId = prefs.getString(_deviceIdKey);
      if (_apiService != null && deviceId != null) {
        try {
          final backendPrefs = await _apiService.getPreferences(deviceId);
          
          // Update local cache with backend values
          await prefs.setBool(_pushNotificationsKey, backendPrefs.pushNotifications);
          await prefs.setBool(_proximityAlertsKey, backendPrefs.proximityAlerts);
          await prefs.setBool(_soundVibrationKey, backendPrefs.soundVibration);
          
          emit(
            NotificationSettingsState(
              pushNotifications: backendPrefs.pushNotifications,
              proximityAlerts: backendPrefs.proximityAlerts,
              soundVibration: backendPrefs.soundVibration,
              anonymousReporting: backendPrefs.anonymousReporting,
              shareLocationWithContacts: state.shareLocationWithContacts,
              alertRadius: state.alertRadius,
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
      final pushNotifications =
          prefs.getBool(_pushNotificationsKey) ?? state.pushNotifications;
      final proximityAlerts =
          prefs.getBool(_proximityAlertsKey) ?? state.proximityAlerts;
      final soundVibration =
          prefs.getBool(_soundVibrationKey) ?? state.soundVibration;
      final anonymousReporting =
          prefs.getBool(_anonymousReportingKey) ?? state.anonymousReporting;
      final shareLocationWithContacts =
          prefs.getBool(_shareLocationKey) ?? state.shareLocationWithContacts;
      final alertRadius = prefs.getDouble(_alertRadiusKey) ?? state.alertRadius;

      emit(
        NotificationSettingsState(
          pushNotifications: pushNotifications,
          proximityAlerts: proximityAlerts,
          soundVibration: soundVibration,
          anonymousReporting: anonymousReporting,
          shareLocationWithContacts: shareLocationWithContacts,
          alertRadius: alertRadius,
        ),
      );
    } on Exception catch (e) {
      // If loading fails, keep default state
      emit(state.copyWith(isLoading: false));
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// Toggle push notifications setting
  Future<void> togglePushNotifications({required bool value}) async {
    emit(state.copyWith(pushNotifications: value));
    await _saveSetting(_pushNotificationsKey, value);
    
    // Sync with backend
    await _syncBooleanToBackend('pushNotifications', value);

    // Update Firebase Messaging subscription
    if (value) {
      await _subscribeToNotifications();
    } else {
      await _unsubscribeFromNotifications();
    }
  }

  /// Toggle proximity alerts setting
  Future<void> toggleProximityAlerts({required bool value}) async {
    emit(state.copyWith(proximityAlerts: value));
    await _saveSetting(_proximityAlertsKey, value);
    
    // Sync with backend
    await _syncBooleanToBackend('proximityAlerts', value);

    // Subscribe/unsubscribe from proximity alerts topic
    if (value) {
      await _firebaseMessaging.subscribeToTopic('proximity_alerts');
    } else {
      await _firebaseMessaging.unsubscribeFromTopic('proximity_alerts');
    }
  }

  /// Toggle sound and vibration setting
  Future<void> toggleSoundVibration({required bool value}) async {
    emit(state.copyWith(soundVibration: value));
    await _saveSetting(_soundVibrationKey, value);
    
    // Sync with backend
    await _syncBooleanToBackend('soundVibration', value);
  }

  /// Toggle anonymous reporting setting
  Future<void> toggleAnonymousReporting({required bool value}) async {
    emit(state.copyWith(anonymousReporting: value));
    await _saveSetting(_anonymousReportingKey, value);
  }

  /// Toggle share location with contacts setting
  Future<void> toggleShareLocationWithContacts({required bool value}) async {
    emit(state.copyWith(shareLocationWithContacts: value));
    await _saveSetting(_shareLocationKey, value);
  }

  /// Update alert radius setting
  Future<void> updateAlertRadius(double value) async {
    emit(state.copyWith(alertRadius: value));
    await _saveDoubleSetting(_alertRadiusKey, value);
  }

  /// Sync boolean setting to backend
  Future<void> _syncBooleanToBackend(String settingName, bool value) async {
    final deviceId = _getDeviceId();
    if (_apiService == null || deviceId == null) return;

    try {
      switch (settingName) {
        case 'pushNotifications':
          await _apiService.updatePreferences(
            deviceId: deviceId,
            pushNotifications: value,
          );
          break;
        case 'proximityAlerts':
          await _apiService.updatePreferences(
            deviceId: deviceId,
            proximityAlerts: value,
          );
          break;
        case 'soundVibration':
          await _apiService.updatePreferences(
            deviceId: deviceId,
            soundVibration: value,
          );
          break;
      }
    } catch (e) {
      // Continue if backend sync fails
      if (kDebugMode) {
        print('Failed to sync $settingName to backend: $e');
      }
    }
  }

  /// Save a boolean setting to persistent storage
  Future<void> _saveSetting(String key, bool value) async {
    try {
      final prefs = await _getPreferences();
      await prefs.setBool(key, value);
    } on Exception catch (e) {
      // Fail silently - setting is still updated in state
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// Save a double setting to persistent storage
  Future<void> _saveDoubleSetting(String key, double value) async {
    try {
      final prefs = await _getPreferences();
      await prefs.setDouble(key, value);
    } on Exception catch (e) {
      // Fail silently - setting is still updated in state
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// Subscribe to Firebase notifications
  Future<void> _subscribeToNotifications() async {
    try {
      await _firebaseMessaging.requestPermission();
      await _firebaseMessaging.subscribeToTopic('all_users');
    } on Exception catch (e) {
      // Fail silently - notifications may not be available
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// Unsubscribe from Firebase notifications
  Future<void> _unsubscribeFromNotifications() async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic('all_users');
    } on Exception catch (e) {
      // Fail silently
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
