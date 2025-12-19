import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing proximity alerts settings persistence
class ProximityAlertsSettingsRepository {
  ProximityAlertsSettingsRepository({
    SharedPreferences? sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  final SharedPreferences? _sharedPreferences;
  SharedPreferences? _cachedPrefs;

  // Keys for stored values
  static const String _pushNotificationsKey = 'push_notifications';
  static const String _proximityAlertsKey = 'proximity_alerts';
  static const String _soundVibrationKey = 'sound_vibration';
  static const String _anonymousReportingKey = 'anonymous_reporting';
  static const String _shareLocationKey = 'share_location_with_contacts';
  static const String _alertRadiusKey = 'alert_radius';

  /// Get shared preferences instance
  Future<SharedPreferences> get _prefs async {
    if (_sharedPreferences != null) {
      return _sharedPreferences;
    }
    _cachedPrefs ??= await SharedPreferences.getInstance();
    return _cachedPrefs!;
  }

  /// Load push notifications setting
  Future<bool> getPushNotifications() async {
    final prefs = await _prefs;
    return prefs.getBool(_pushNotificationsKey) ?? true;
  }

  /// Save push notifications setting
  Future<void> setPushNotifications(any, {required bool value}) async {
    final prefs = await _prefs;
    await prefs.setBool(_pushNotificationsKey, value);
  }

  /// Load proximity alerts setting
  Future<bool> getProximityAlerts() async {
    final prefs = await _prefs;
    return prefs.getBool(_proximityAlertsKey) ?? true;
  }

  /// Save proximity alerts setting
  Future<void> setProximityAlerts(any, {required bool value}) async {
    final prefs = await _prefs;
    await prefs.setBool(_proximityAlertsKey, value);
  }

  /// Load sound and vibration setting
  Future<bool> getSoundVibration() async {
    final prefs = await _prefs;
    return prefs.getBool(_soundVibrationKey) ?? false;
  }

  /// Save sound and vibration setting
  Future<void> setSoundVibration(any, {required bool value}) async {
    final prefs = await _prefs;
    await prefs.setBool(_soundVibrationKey, value);
  }

  /// Load anonymous reporting setting
  Future<bool> getAnonymousReporting() async {
    final prefs = await _prefs;
    return prefs.getBool(_anonymousReportingKey) ?? true;
  }

  /// Save anonymous reporting setting
  Future<void> setAnonymousReporting(any, {required bool value}) async {
    final prefs = await _prefs;
    await prefs.setBool(_anonymousReportingKey, value);
  }

  /// Load share location with contacts setting
  Future<bool> getShareLocationWithContacts() async {
    final prefs = await _prefs;
    return prefs.getBool(_shareLocationKey) ?? false;
  }

  /// Save share location with contacts setting
  Future<void> setShareLocationWithContacts(any, {required bool value}) async {
    final prefs = await _prefs;
    await prefs.setBool(_shareLocationKey, value);
  }

  /// Load alert radius setting
  Future<double> getAlertRadius() async {
    final prefs = await _prefs;
    return prefs.getDouble(_alertRadiusKey) ?? 2.5;
  }

  /// Save alert radius setting
  Future<void> setAlertRadius(double value) async {
    final prefs = await _prefs;
    await prefs.setDouble(_alertRadiusKey, value);
  }

  /// Load all settings at once
  Future<Map<String, dynamic>> loadAllSettings() async {
    final prefs = await _prefs;
    return {
      'pushNotifications': prefs.getBool(_pushNotificationsKey) ?? true,
      'proximityAlerts': prefs.getBool(_proximityAlertsKey) ?? true,
      'soundVibration': prefs.getBool(_soundVibrationKey) ?? false,
      'anonymousReporting': prefs.getBool(_anonymousReportingKey) ?? true,
      'shareLocationWithContacts': prefs.getBool(_shareLocationKey) ?? false,
      'alertRadius': prefs.getDouble(_alertRadiusKey) ?? 2.5,
    };
  }
}
