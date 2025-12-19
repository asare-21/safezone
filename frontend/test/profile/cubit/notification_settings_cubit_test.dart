import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_zone/profile/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  group('NotificationSettingsCubit', () {
    late MockSharedPreferences mockSharedPreferences;
    late MockFirebaseMessaging mockFirebaseMessaging;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      mockFirebaseMessaging = MockFirebaseMessaging();

      // Set up default mock behaviors
      when(() => mockSharedPreferences.getBool(any())).thenReturn(null);
      when(() => mockSharedPreferences.getDouble(any())).thenReturn(null);
      when(
        () => mockSharedPreferences.setBool(any(), any()),
      ).thenAnswer((_) async => true);
      when(
        () => mockSharedPreferences.setDouble(any(), any()),
      ).thenAnswer((_) async => true);
      when(
        () => mockFirebaseMessaging.requestPermission(
          alert: any(named: 'alert'),
          badge: any(named: 'badge'),
          sound: any(named: 'sound'),
        ),
      ).thenAnswer(
        (_) async => const NotificationSettings(
          authorizationStatus: AuthorizationStatus.authorized,
          alert: AppleNotificationSetting.enabled,
          badge: AppleNotificationSetting.enabled,
          sound: AppleNotificationSetting.enabled,
          announcement: AppleNotificationSetting.notSupported,
          carPlay: AppleNotificationSetting.notSupported,
          criticalAlert: AppleNotificationSetting.notSupported,
          lockScreen: AppleNotificationSetting.enabled,
          notificationCenter: AppleNotificationSetting.enabled,
          showPreviews: AppleShowPreviewSetting.always,
          timeSensitive: AppleNotificationSetting.notSupported,
          providesAppNotificationSettings:
              AppleNotificationSetting.notSupported,
        ),
      );
      when(
        () => mockFirebaseMessaging.subscribeToTopic(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockFirebaseMessaging.unsubscribeFromTopic(any()),
      ).thenAnswer((_) async {});
    });

    test('initial state has default values', () {
      final cubit = NotificationSettingsCubit(
        sharedPreferences: mockSharedPreferences,
        firebaseMessaging: mockFirebaseMessaging,
      );
      expect(cubit.state.pushNotifications, true);
      expect(cubit.state.proximityAlerts, true);
      expect(cubit.state.soundVibration, false);
      expect(cubit.state.anonymousReporting, true);
      expect(cubit.state.shareLocationWithContacts, false);
      expect(cubit.state.alertRadius, 2.5);
      expect(cubit.state.isLoading, false);
    });

    blocTest<NotificationSettingsCubit, NotificationSettingsState>(
      'togglePushNotifications updates state and saves to preferences',
      build: () => NotificationSettingsCubit(
        sharedPreferences: mockSharedPreferences,
        firebaseMessaging: mockFirebaseMessaging,
      ),
      act: (cubit) => cubit.togglePushNotifications(false, value: false),
      expect: () => [
        const NotificationSettingsState(),
      ],
      verify: (_) {
        verify(
          () => mockSharedPreferences.setBool('push_notifications', false),
        ).called(1);
        verify(
          () => mockFirebaseMessaging.unsubscribeFromTopic('all_users'),
        ).called(1);
      },
    );

    blocTest<NotificationSettingsCubit, NotificationSettingsState>(
      'togglePushNotifications to true subscribes to notifications',
      build: () => NotificationSettingsCubit(
        sharedPreferences: mockSharedPreferences,
        firebaseMessaging: mockFirebaseMessaging,
      ),
      seed: () => const NotificationSettingsState(),
      act: (cubit) => cubit.togglePushNotifications(true, value: true),
      expect: () => [
        const NotificationSettingsState(),
      ],
      verify: (_) {
        verify(
          () => mockSharedPreferences.setBool('push_notifications', true),
        ).called(1);
        verify(
          () => mockFirebaseMessaging.requestPermission(),
        ).called(1);
        verify(
          () => mockFirebaseMessaging.subscribeToTopic('all_users'),
        ).called(1);
      },
    );

    blocTest<NotificationSettingsCubit, NotificationSettingsState>(
      'toggleProximityAlerts updates state and subscribes to topic',
      build: () => NotificationSettingsCubit(
        sharedPreferences: mockSharedPreferences,
        firebaseMessaging: mockFirebaseMessaging,
      ),
      act: (cubit) => cubit.toggleProximityAlerts(false, value: false),
      expect: () => [
        const NotificationSettingsState(proximityAlerts: false),
      ],
      verify: (_) {
        verify(
          () => mockSharedPreferences.setBool('proximity_alerts', false),
        ).called(1);
        verify(
          () => mockFirebaseMessaging.unsubscribeFromTopic('proximity_alerts'),
        ).called(1);
      },
    );

    blocTest<NotificationSettingsCubit, NotificationSettingsState>(
      'toggleSoundVibration updates state and saves to preferences',
      build: () => NotificationSettingsCubit(
        sharedPreferences: mockSharedPreferences,
        firebaseMessaging: mockFirebaseMessaging,
      ),
      act: (cubit) => cubit.toggleSoundVibration(true, value: true),
      expect: () => [
        const NotificationSettingsState(soundVibration: true),
      ],
      verify: (_) {
        verify(
          () => mockSharedPreferences.setBool('sound_vibration', true),
        ).called(1);
      },
    );

    blocTest<NotificationSettingsCubit, NotificationSettingsState>(
      'toggleAnonymousReporting updates state and saves to preferences',
      build: () => NotificationSettingsCubit(
        sharedPreferences: mockSharedPreferences,
        firebaseMessaging: mockFirebaseMessaging,
      ),
      act: (cubit) => cubit.toggleAnonymousReporting(false, value: false),
      expect: () => [
        const NotificationSettingsState(anonymousReporting: false),
      ],
      verify: (_) {
        verify(
          () => mockSharedPreferences.setBool('anonymous_reporting', false),
        ).called(1);
      },
    );

    blocTest<NotificationSettingsCubit, NotificationSettingsState>(
      'toggleShareLocationWithContacts updates state and saves to preferences',
      build: () => NotificationSettingsCubit(
        sharedPreferences: mockSharedPreferences,
        firebaseMessaging: mockFirebaseMessaging,
      ),
      act: (cubit) => cubit.toggleShareLocationWithContacts(true, value: true),
      expect: () => [
        const NotificationSettingsState(shareLocationWithContacts: true),
      ],
      verify: (_) {
        verify(
          () => mockSharedPreferences.setBool(
            'share_location_with_contacts',
            true,
          ),
        ).called(1);
      },
    );

    blocTest<NotificationSettingsCubit, NotificationSettingsState>(
      'updateAlertRadius updates state and saves to preferences',
      build: () => NotificationSettingsCubit(
        sharedPreferences: mockSharedPreferences,
        firebaseMessaging: mockFirebaseMessaging,
      ),
      act: (cubit) => cubit.updateAlertRadius(5.5),
      expect: () => [
        const NotificationSettingsState(alertRadius: 5.5),
      ],
      verify: (_) {
        verify(
          () => mockSharedPreferences.setDouble('alert_radius', 5.5),
        ).called(1);
      },
    );

    blocTest<NotificationSettingsCubit, NotificationSettingsState>(
      'loads settings from shared preferences on initialization',
      setUp: () {
        when(
          () => mockSharedPreferences.getBool('push_notifications'),
        ).thenReturn(false);
        when(
          () => mockSharedPreferences.getBool('proximity_alerts'),
        ).thenReturn(false);
        when(
          () => mockSharedPreferences.getBool('sound_vibration'),
        ).thenReturn(true);
        when(
          () => mockSharedPreferences.getBool('anonymous_reporting'),
        ).thenReturn(false);
        when(
          () => mockSharedPreferences.getBool('share_location_with_contacts'),
        ).thenReturn(true);
        when(
          () => mockSharedPreferences.getDouble('alert_radius'),
        ).thenReturn(7.5);
      },
      build: () => NotificationSettingsCubit(
        sharedPreferences: mockSharedPreferences,
        firebaseMessaging: mockFirebaseMessaging,
      ),
      expect: () => [
        const NotificationSettingsState(isLoading: true),
        const NotificationSettingsState(
          proximityAlerts: false,
          soundVibration: true,
          anonymousReporting: false,
          shareLocationWithContacts: true,
          alertRadius: 7.5,
        ),
      ],
    );
  });

  group('NotificationSettingsState', () {
    test('supports value equality', () {
      expect(
        const NotificationSettingsState(),
        equals(const NotificationSettingsState()),
      );
    });

    test('different values are not equal', () {
      expect(
        const NotificationSettingsState(),
        isNot(
          equals(
            const NotificationSettingsState(),
          ),
        ),
      );
    });

    test('copyWith creates new instance with updated values', () {
      const state = NotificationSettingsState();
      final newState = state.copyWith(pushNotifications: false);

      expect(newState.pushNotifications, false);
      expect(newState.proximityAlerts, state.proximityAlerts);
      expect(newState.soundVibration, state.soundVibration);
    });

    test('has correct props', () {
      const state = NotificationSettingsState(
        alertRadius: 5,
      );
      expect(state.pushNotifications, false);
      expect(state.alertRadius, 5.0);
    });
  });
}
