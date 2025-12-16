import 'package:bloc/bloc.dart';
import 'package:safe_zone/profile/repository/proximity_alerts_settings_repository.dart';

part 'proximity_alerts_settings_state.dart';

/// Cubit that manages proximity alerts settings
class ProximityAlertsSettingsCubit extends Cubit<ProximityAlertsSettingsState> {
  ProximityAlertsSettingsCubit({
    required ProximityAlertsSettingsRepository repository,
  })  : _repository = repository,
        super(const ProximityAlertsSettingsState()) {
    loadSettings();
  }

  final ProximityAlertsSettingsRepository _repository;

  /// Load all settings from repository
  Future<void> loadSettings() async {
    try {
      final settings = await _repository.loadAllSettings();
      emit(
        ProximityAlertsSettingsState(
          pushNotifications: settings['pushNotifications'] as bool,
          proximityAlerts: settings['proximityAlerts'] as bool,
          soundVibration: settings['soundVibration'] as bool,
          anonymousReporting: settings['anonymousReporting'] as bool,
          shareLocationWithContacts:
              settings['shareLocationWithContacts'] as bool,
          alertRadius: settings['alertRadius'] as double,
          isLoading: false,
        ),
      );
    } catch (e) {
      // If loading fails, keep defaults and mark as loaded
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Update push notifications setting
  Future<void> updatePushNotifications(bool value) async {
    await _repository.setPushNotifications(value);
    emit(state.copyWith(pushNotifications: value));
  }

  /// Update proximity alerts setting
  Future<void> updateProximityAlerts(bool value) async {
    await _repository.setProximityAlerts(value);
    emit(state.copyWith(proximityAlerts: value));
  }

  /// Update sound and vibration setting
  Future<void> updateSoundVibration(bool value) async {
    await _repository.setSoundVibration(value);
    emit(state.copyWith(soundVibration: value));
  }

  /// Update anonymous reporting setting
  Future<void> updateAnonymousReporting(bool value) async {
    await _repository.setAnonymousReporting(value);
    emit(state.copyWith(anonymousReporting: value));
  }

  /// Update share location with contacts setting
  Future<void> updateShareLocationWithContacts(bool value) async {
    await _repository.setShareLocationWithContacts(value);
    emit(state.copyWith(shareLocationWithContacts: value));
  }

  /// Update alert radius setting
  Future<void> updateAlertRadius(double value) async {
    await _repository.setAlertRadius(value);
    emit(state.copyWith(alertRadius: value));
  }
}
