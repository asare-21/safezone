import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing profile settings persistence
class ProfileSettingsRepository {
  ProfileSettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _anonymousReportingKey = 'anonymous_reporting';

  /// Gets the anonymous reporting setting
  /// Returns true by default if not set
  bool getAnonymousReporting() {
    return _prefs.getBool(_anonymousReportingKey) ?? true;
  }

  /// Sets the anonymous reporting setting
  Future<void> setAnonymousReporting(bool value) async {
    await _prefs.setBool(_anonymousReportingKey, value);
  }
}
