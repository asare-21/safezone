import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'profile_settings_state.dart';

/// Cubit that manages profile settings state with persistence
class ProfileSettingsCubit extends Cubit<ProfileSettingsState> {
  ProfileSettingsCubit({
    required SharedPreferences sharedPreferences,
  })  : _sharedPreferences = sharedPreferences,
        super(
          ProfileSettingsState(
            soundVibrationEnabled:
                sharedPreferences.getBool(_soundVibrationKey) ?? false,
          ),
        );

  final SharedPreferences _sharedPreferences;

  static const String _soundVibrationKey = 'sound_vibration_enabled';

  /// Toggle sound and vibration setting
  Future<void> toggleSoundVibration(bool enabled) async {
    await _sharedPreferences.setBool(_soundVibrationKey, enabled);
    emit(state.copyWith(soundVibrationEnabled: enabled));
  }
}
