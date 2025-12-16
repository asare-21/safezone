import 'package:flutter_test/flutter_test.dart';
import 'package:safe_zone/profile/repository/proximity_alerts_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ProximityAlertsSettingsRepository', () {
    late ProximityAlertsSettingsRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = ProximityAlertsSettingsRepository(
        sharedPreferences: prefs,
      );
    });

    group('getPushNotifications', () {
      test('returns default value true when no value stored', () async {
        final result = await repository.getPushNotifications();
        expect(result, true);
      });

      test('returns stored value when available', () async {
        await repository.setPushNotifications(false);
        final result = await repository.getPushNotifications();
        expect(result, false);
      });
    });

    group('getProximityAlerts', () {
      test('returns default value true when no value stored', () async {
        final result = await repository.getProximityAlerts();
        expect(result, true);
      });

      test('returns stored value when available', () async {
        await repository.setProximityAlerts(false);
        final result = await repository.getProximityAlerts();
        expect(result, false);
      });
    });

    group('getSoundVibration', () {
      test('returns default value false when no value stored', () async {
        final result = await repository.getSoundVibration();
        expect(result, false);
      });

      test('returns stored value when available', () async {
        await repository.setSoundVibration(true);
        final result = await repository.getSoundVibration();
        expect(result, true);
      });
    });

    group('getAnonymousReporting', () {
      test('returns default value true when no value stored', () async {
        final result = await repository.getAnonymousReporting();
        expect(result, true);
      });

      test('returns stored value when available', () async {
        await repository.setAnonymousReporting(false);
        final result = await repository.getAnonymousReporting();
        expect(result, false);
      });
    });

    group('getShareLocationWithContacts', () {
      test('returns default value false when no value stored', () async {
        final result = await repository.getShareLocationWithContacts();
        expect(result, false);
      });

      test('returns stored value when available', () async {
        await repository.setShareLocationWithContacts(true);
        final result = await repository.getShareLocationWithContacts();
        expect(result, true);
      });
    });

    group('getAlertRadius', () {
      test('returns default value 2.5 when no value stored', () async {
        final result = await repository.getAlertRadius();
        expect(result, 2.5);
      });

      test('returns stored value when available', () async {
        await repository.setAlertRadius(5.0);
        final result = await repository.getAlertRadius();
        expect(result, 5.0);
      });
    });

    group('loadAllSettings', () {
      test('returns all default values when no values stored', () async {
        final result = await repository.loadAllSettings();
        expect(result['pushNotifications'], true);
        expect(result['proximityAlerts'], true);
        expect(result['soundVibration'], false);
        expect(result['anonymousReporting'], true);
        expect(result['shareLocationWithContacts'], false);
        expect(result['alertRadius'], 2.5);
      });

      test('returns all stored values when available', () async {
        await repository.setPushNotifications(false);
        await repository.setProximityAlerts(false);
        await repository.setSoundVibration(true);
        await repository.setAnonymousReporting(false);
        await repository.setShareLocationWithContacts(true);
        await repository.setAlertRadius(7.5);

        final result = await repository.loadAllSettings();
        expect(result['pushNotifications'], false);
        expect(result['proximityAlerts'], false);
        expect(result['soundVibration'], true);
        expect(result['anonymousReporting'], false);
        expect(result['shareLocationWithContacts'], true);
        expect(result['alertRadius'], 7.5);
      });
    });
  });
}
