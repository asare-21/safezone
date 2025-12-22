import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:safe_zone/profile/repository/proximity_alerts_settings_repository.dart';

part 'proximity_alerts_settings_state.dart';

/// Cubit that manages proximity alerts settings
class ProximityAlertsSettingsCubit extends Cubit<ProximityAlertsSettingsState> {
  ProximityAlertsSettingsCubit({
    required ProximityAlertsSettingsRepository repository,
  }) : _repository = repository,
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
          pushNotifications: settings['pushNotifications'] as bool? ?? true,
          proximityAlerts: settings['proximityAlerts'] as bool? ?? true,
          soundVibration: settings['soundVibration'] as bool? ?? true,
          anonymousReporting: settings['anonymousReporting'] as bool? ?? false,
          shareLocationWithContacts:
              settings['shareLocationWithContacts'] as bool? ?? false,
          alertRadius: (settings['alertRadius'] as num?)?.toDouble() ?? 5.0,
          isLoading: false,
        ),
      );
    } on Exception catch (e) {
      // If loading fails, keep defaults and mark as loaded
      emit(state.copyWith(isLoading: false));
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// Update push notifications setting
  Future<void> updatePushNotifications(bool bool, {required bool value}) async {
    try {
      await _repository.setPushNotifications(value, value: value);
      emit(state.copyWith(pushNotifications: value));
    } on Exception catch (e) {
      // If save fails, reload settings to ensure UI is in sync
      await loadSettings();
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// Update proximity alerts setting
  Future<void> updateProximityAlerts(bool bool, {required bool value}) async {
    try {
      await _repository.setProximityAlerts(value, value: value);
      emit(state.copyWith(proximityAlerts: value));
    } on Exception catch (e) {
      // If save fails, reload settings to ensure UI is in sync
      await loadSettings();
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// Update sound and vibration setting
  Future<void> updateSoundVibration(bool bool, {required bool value}) async {
    try {
      await _repository.setSoundVibration(value, value: value);
      emit(state.copyWith(soundVibration: value));
    } on Exception catch (e) {
      // If save fails, reload settings to ensure UI is in sync
      await loadSettings();
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// Update anonymous reporting setting
  Future<void> updateAnonymousReporting(
    bool bool, {
    required bool value,
  }) async {
    try {
      await _repository.setAnonymousReporting(value, value: value);
      emit(state.copyWith(anonymousReporting: value));
    } on Exception catch (e) {
      // If save fails, reload settings to ensure UI is in sync
      await loadSettings();
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// Update share location with contacts setting
  Future<void> updateShareLocationWithContacts(
    bool bool, {
    required bool value,
  }) async {
    try {
      await _repository.setShareLocationWithContacts(value, value: value);
      emit(state.copyWith(shareLocationWithContacts: value));
    } on Exception catch (e) {
      // If save fails, reload settings to ensure UI is in sync
      await loadSettings();
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// Update alert radius setting
  Future<void> updateAlertRadius(double value) async {
    try {
      await _repository.setAlertRadius(value);
      emit(state.copyWith(alertRadius: value));
    } on Exception catch (e) {
      // If save fails, reload settings to ensure UI is in sync
      await loadSettings();
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
