import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_zone/user_settings/services/user_preferences_api_service.dart';

/// Repository for managing profile settings persistence
class ProfileSettingsRepository {
  ProfileSettingsRepository(
    this._prefs, {
    UserPreferencesApiService? apiService,
  }) : _apiService = apiService;

  final SharedPreferences _prefs;
  final UserPreferencesApiService? _apiService;

  static const String _anonymousReportingKey = 'anonymous_reporting';
  static const String _deviceIdKey = 'device_id';

  /// Gets the device ID from shared preferences
  String? _getDeviceId() {
    return _prefs.getString(_deviceIdKey);
  }

  /// Gets the anonymous reporting setting
  /// Returns true by default if not set
  bool getAnonymousReporting() {
    return _prefs.getBool(_anonymousReportingKey) ?? true;
  }

  /// Sets the anonymous reporting setting
  /// Syncs with backend if API service is available
  Future<void> setAnonymousReporting(bool value) async {
    await _prefs.setBool(_anonymousReportingKey, value);
    
    // Sync with backend if API service is available
    final deviceId = _getDeviceId();
    if (_apiService != null && deviceId != null) {
      try {
        await _apiService.updatePreferences(
          deviceId: deviceId,
          anonymousReporting: value,
        );
      } catch (e) {
        // Continue if backend sync fails, local setting is already saved
      }
    }
  }

  /// Load preferences from backend
  /// Returns the UserPreferencesModel or null if failed
  Future<UserPreferencesModel?> loadPreferencesFromBackend() async {
    final deviceId = _getDeviceId();
    if (_apiService == null || deviceId == null) {
      return null;
    }

    try {
      final preferences = await _apiService.getPreferences(deviceId);
      
      // Update local cache with backend values
      await _prefs.setBool(
        _anonymousReportingKey,
        preferences.anonymousReporting,
      );
      
      return preferences;
    } catch (e) {
      // Return null if backend load fails
      return null;
    }
  }
}
