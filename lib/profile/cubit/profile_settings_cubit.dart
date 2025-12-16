import 'package:bloc/bloc.dart';
import 'package:safe_zone/profile/repository/profile_settings_repository.dart';

part 'profile_settings_state.dart';

/// Cubit that manages profile settings state and persistence
class ProfileSettingsCubit extends Cubit<ProfileSettingsState> {
  ProfileSettingsCubit(this._repository)
      : super(const ProfileSettingsState()) {
    _loadSettings();
  }

  final ProfileSettingsRepository _repository;

  /// Loads settings from the repository
  void _loadSettings() {
    final anonymousReporting = _repository.getAnonymousReporting();
    emit(ProfileSettingsState(anonymousReporting: anonymousReporting));
  }

  /// Toggles anonymous reporting setting
  Future<void> setAnonymousReporting(bool value) async {
    await _repository.setAnonymousReporting(value);
    emit(state.copyWith(anonymousReporting: value));
  }
}
