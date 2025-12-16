import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'profile_settings_state.dart';

/// Cubit that manages profile settings state with persistence
class ProfileSettingsCubit extends Cubit<ProfileSettingsState> {
  ProfileSettingsCubit({
    required SharedPreferences sharedPreferences,
  })  : _sharedPreferences = sharedPreferences,
        super(const ProfileSettingsState()) {
    _loadSettings();
  }

  final SharedPreferences _sharedPreferences;

  static const String _soundVibrationKey = 'sound_vibration_enabled';

  /// Load settings from shared preferences
  Future<void> _loadSettings() async {
    final soundVibrationEnabled =
        _sharedPreferences.getBool(_soundVibrationKey) ?? false;

    emit(
      state.copyWith(
        soundVibrationEnabled: soundVibrationEnabled,
      ),
    );
  }

  /// Toggle sound and vibration setting
  Future<void> toggleSoundVibration(bool enabled) async {
    await _sharedPreferences.setBool(_soundVibrationKey, enabled);
    emit(state.copyWith(soundVibrationEnabled: enabled));
  }
}
