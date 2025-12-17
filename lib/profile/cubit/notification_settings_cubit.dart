import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'notification_settings_state.dart';

/// Cubit that manages notification settings state
class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  NotificationSettingsCubit({
    SharedPreferences? sharedPreferences,
    FirebaseMessaging? firebaseMessaging,
  }) : _sharedPreferences = sharedPreferences,
       _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance,
       super(const NotificationSettingsState()) {
    _loadSettings();
  }

  final SharedPreferences? _sharedPreferences;
  final FirebaseMessaging _firebaseMessaging;
  SharedPreferences? _cachedPreferences;

  // Storage keys
  static const String _pushNotificationsKey = 'push_notifications';
  static const String _proximityAlertsKey = 'proximity_alerts';
  static const String _soundVibrationKey = 'sound_vibration';
  static const String _anonymousReportingKey = 'anonymous_reporting';
  static const String _shareLocationKey = 'share_location_with_contacts';
  static const String _alertRadiusKey = 'alert_radius';

  /// Get SharedPreferences instance (cached)
  Future<SharedPreferences> _getPreferences() async {
    if (_sharedPreferences != null) return _sharedPreferences;
    _cachedPreferences ??= await SharedPreferences.getInstance();
    return _cachedPreferences!;
  }

  /// Load settings from persistent storage
  Future<void> _loadSettings() async {
    emit(state.copyWith(isLoading: true));

    try {
      final prefs = await _getPreferences();

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
