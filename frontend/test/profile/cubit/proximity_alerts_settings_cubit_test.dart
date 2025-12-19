import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_zone/profile/cubit/proximity_alerts_settings_cubit.dart';
import 'package:safe_zone/profile/repository/proximity_alerts_settings_repository.dart';

class MockProximityAlertsSettingsRepository extends Mock
    implements ProximityAlertsSettingsRepository {}

void main() {
  group('ProximityAlertsSettingsCubit', () {
    late ProximityAlertsSettingsRepository repository;

    setUp(() {
      repository = MockProximityAlertsSettingsRepository();
    });

    group('constructor', () {
      test('initial state has default values and isLoading true', () {
        when(() => repository.loadAllSettings()).thenAnswer(
          (_) async => {
            'pushNotifications': true,
            'proximityAlerts': true,
            'soundVibration': false,
            'anonymousReporting': true,
            'shareLocationWithContacts': false,
            'alertRadius': 2.5,
          },
        );

        final cubit = ProximityAlertsSettingsCubit(repository: repository);
        expect(cubit.state.isLoading, true);
        expect(cubit.state.pushNotifications, true);
        expect(cubit.state.proximityAlerts, true);
        expect(cubit.state.soundVibration, false);
        expect(cubit.state.anonymousReporting, true);
        expect(cubit.state.shareLocationWithContacts, false);
        expect(cubit.state.alertRadius, 2.5);
      });
    });

    group('loadSettings', () {
      blocTest<ProximityAlertsSettingsCubit, ProximityAlertsSettingsState>(
        'loads settings from repository and sets isLoading to false',
        setUp: () {
          when(() => repository.loadAllSettings()).thenAnswer(
            (_) async => {
              'pushNotifications': false,
              'proximityAlerts': false,
              'soundVibration': true,
              'anonymousReporting': false,
              'shareLocationWithContacts': true,
              'alertRadius': 5.0,
            },
          );
        },
        build: () => ProximityAlertsSettingsCubit(repository: repository),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          const ProximityAlertsSettingsState(
            pushNotifications: false,
            proximityAlerts: false,
            soundVibration: true,
            anonymousReporting: false,
            shareLocationWithContacts: true,
            alertRadius: 5,
            isLoading: false,
          ),
        ],
        verify: (_) {
          verify(() => repository.loadAllSettings()).called(1);
        },
      );

      blocTest<ProximityAlertsSettingsCubit, ProximityAlertsSettingsState>(
        'sets isLoading to false on error',
        setUp: () {
          when(() => repository.loadAllSettings()).thenThrow(Exception());
        },
        build: () => ProximityAlertsSettingsCubit(repository: repository),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          const ProximityAlertsSettingsState(isLoading: false),
        ],
      );
    });

    group('updatePushNotifications', () {
      blocTest<ProximityAlertsSettingsCubit, ProximityAlertsSettingsState>(
        'updates push notifications setting',
        setUp: () {
          when(() => repository.loadAllSettings()).thenAnswer(
            (_) async => {
              'pushNotifications': true,
              'proximityAlerts': true,
              'soundVibration': false,
              'anonymousReporting': true,
              'shareLocationWithContacts': false,
              'alertRadius': 2.5,
            },
          );
          when(
            () => repository.setPushNotifications(any(), value: false),
          ).thenAnswer((_) async {});
        },
        build: () => ProximityAlertsSettingsCubit(repository: repository),
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await cubit.updatePushNotifications(false, value: false);
        },
        skip: 1,
        expect: () => [
          const ProximityAlertsSettingsState(
            pushNotifications: false,
            isLoading: false,
          ),
        ],
        verify: (_) {
          verify(
            () => repository.setPushNotifications(any(), value: false),
          ).called(1);
        },
      );
    });

    group('updateProximityAlerts', () {
      blocTest<ProximityAlertsSettingsCubit, ProximityAlertsSettingsState>(
        'updates proximity alerts setting',
        setUp: () {
          when(() => repository.loadAllSettings()).thenAnswer(
            (_) async => {
              'pushNotifications': true,
              'proximityAlerts': true,
              'soundVibration': false,
              'anonymousReporting': true,
              'shareLocationWithContacts': false,
              'alertRadius': 2.5,
            },
          );
          when(
            () => repository.setProximityAlerts(any(), value: false),
          ).thenAnswer((_) async {});
        },
        build: () => ProximityAlertsSettingsCubit(repository: repository),
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await cubit.updateProximityAlerts(false, value: false);
        },
        skip: 1,
        expect: () => [
          const ProximityAlertsSettingsState(
            proximityAlerts: false,
            isLoading: false,
          ),
        ],
        verify: (_) {
          verify(
            () => repository.setProximityAlerts(false, value: false),
          ).called(1);
        },
      );
    });

    group('updateSoundVibration', () {
      blocTest<ProximityAlertsSettingsCubit, ProximityAlertsSettingsState>(
        'updates sound and vibration setting',
        setUp: () {
          when(() => repository.loadAllSettings()).thenAnswer(
            (_) async => {
              'pushNotifications': true,
              'proximityAlerts': true,
              'soundVibration': false,
              'anonymousReporting': true,
              'shareLocationWithContacts': false,
              'alertRadius': 2.5,
            },
          );
          when(
            () => repository.setSoundVibration(any(), value: true),
          ).thenAnswer((_) async {});
        },
        build: () => ProximityAlertsSettingsCubit(repository: repository),
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await cubit.updateSoundVibration(true, value: true);
        },
        skip: 1,
        expect: () => [
          const ProximityAlertsSettingsState(
            soundVibration: true,
            isLoading: false,
          ),
        ],
        verify: (_) {
          verify(
            () => repository.setSoundVibration(true, value: true),
          ).called(1);
        },
      );
    });

    group('updateAnonymousReporting', () {
      blocTest<ProximityAlertsSettingsCubit, ProximityAlertsSettingsState>(
        'updates anonymous reporting setting',
        setUp: () {
          when(() => repository.loadAllSettings()).thenAnswer(
            (_) async => {
              'pushNotifications': true,
              'proximityAlerts': true,
              'soundVibration': false,
              'anonymousReporting': true,
              'shareLocationWithContacts': false,
              'alertRadius': 2.5,
            },
          );
          when(
            () => repository.setAnonymousReporting(any(), value: false),
          ).thenAnswer((_) async {});
        },
        build: () => ProximityAlertsSettingsCubit(repository: repository),
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await cubit.updateAnonymousReporting(false, value: false);
        },
        skip: 1,
        expect: () => [
          const ProximityAlertsSettingsState(
            anonymousReporting: false,
            isLoading: false,
          ),
        ],
        verify: (_) {
          verify(
            () => repository.setAnonymousReporting(false, value: false),
          ).called(1);
        },
      );
    });

    group('updateShareLocationWithContacts', () {
      blocTest<ProximityAlertsSettingsCubit, ProximityAlertsSettingsState>(
        'updates share location with contacts setting',
        setUp: () {
          when(() => repository.loadAllSettings()).thenAnswer(
            (_) async => {
              'pushNotifications': true,
              'proximityAlerts': true,
              'soundVibration': false,
              'anonymousReporting': true,
              'shareLocationWithContacts': false,
              'alertRadius': 2.5,
            },
          );
          when(
            () => repository.setShareLocationWithContacts(any(), value: true),
          ).thenAnswer((_) async {});
        },
        build: () => ProximityAlertsSettingsCubit(repository: repository),
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await cubit.updateShareLocationWithContacts(true, value: true);
        },
        skip: 1,
        expect: () => [
          const ProximityAlertsSettingsState(
            shareLocationWithContacts: true,
            isLoading: false,
          ),
        ],
        verify: (_) {
          verify(
            () => repository.setShareLocationWithContacts(true, value: true),
          ).called(1);
        },
      );
    });

    group('updateAlertRadius', () {
      blocTest<ProximityAlertsSettingsCubit, ProximityAlertsSettingsState>(
        'updates alert radius setting',
        setUp: () {
          when(() => repository.loadAllSettings()).thenAnswer(
            (_) async => {
              'pushNotifications': true,
              'proximityAlerts': true,
              'soundVibration': false,
              'anonymousReporting': true,
              'shareLocationWithContacts': false,
              'alertRadius': 2.5,
            },
          );
          when(() => repository.setAlertRadius(any())).thenAnswer((_) async {});
        },
        build: () => ProximityAlertsSettingsCubit(repository: repository),
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await cubit.updateAlertRadius(7.5);
        },
        skip: 1,
        expect: () => [
          const ProximityAlertsSettingsState(
            alertRadius: 7.5,
            isLoading: false,
          ),
        ],
        verify: (_) {
          verify(() => repository.setAlertRadius(7.5)).called(1);
        },
      );
    });
  });

  group('ProximityAlertsSettingsState', () {
    test('supports value equality', () {
      expect(
        const ProximityAlertsSettingsState(),
        equals(const ProximityAlertsSettingsState()),
      );
    });

    test('different values are not equal', () {
      expect(
        const ProximityAlertsSettingsState(),
        isNot(
          equals(
            const ProximityAlertsSettingsState(pushNotifications: false),
          ),
        ),
      );
    });

    test('copyWith returns new instance with updated values', () {
      const state = ProximityAlertsSettingsState();
      final newState = state.copyWith(pushNotifications: false);
      expect(newState.pushNotifications, false);
      expect(newState.proximityAlerts, true);
    });

    test('copyWith with no parameters returns same values', () {
      const state = ProximityAlertsSettingsState(pushNotifications: false);
      final newState = state.copyWith();
      expect(newState.pushNotifications, false);
    });
  });
}
