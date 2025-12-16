import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_zone/profile/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ProfileSettingsCubit', () {
    late SharedPreferences sharedPreferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
    });

    test('initial state has sound & vibration disabled', () async {
      final cubit = ProfileSettingsCubit(
        sharedPreferences: sharedPreferences,
      );
      // Wait for the initial load
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.soundVibrationEnabled, false);
    });

    test('loads saved sound & vibration setting from preferences', () async {
      await sharedPreferences.setBool('sound_vibration_enabled', true);
      final cubit = ProfileSettingsCubit(
        sharedPreferences: sharedPreferences,
      );
      // Wait for the initial load
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.soundVibrationEnabled, true);
    });

    blocTest<ProfileSettingsCubit, ProfileSettingsState>(
      'toggleSoundVibration enables sound & vibration and persists it',
      build: () => ProfileSettingsCubit(
        sharedPreferences: sharedPreferences,
      ),
      act: (cubit) => cubit.toggleSoundVibration(true),
      expect: () => [
        const ProfileSettingsState(soundVibrationEnabled: true),
      ],
      verify: (_) {
        expect(
          sharedPreferences.getBool('sound_vibration_enabled'),
          true,
        );
      },
    );

    blocTest<ProfileSettingsCubit, ProfileSettingsState>(
      'toggleSoundVibration disables sound & vibration and persists it',
      build: () => ProfileSettingsCubit(
        sharedPreferences: sharedPreferences,
      ),
      seed: () => const ProfileSettingsState(soundVibrationEnabled: true),
      act: (cubit) => cubit.toggleSoundVibration(false),
      expect: () => [
        const ProfileSettingsState(soundVibrationEnabled: false),
      ],
      verify: (_) {
        expect(
          sharedPreferences.getBool('sound_vibration_enabled'),
          false,
        );
      },
    );
  });

  group('ProfileSettingsState', () {
    test('supports value equality', () {
      expect(
        const ProfileSettingsState(),
        equals(const ProfileSettingsState()),
      );
    });

    test('different soundVibrationEnabled values are not equal', () {
      expect(
        const ProfileSettingsState(),
        isNot(
          equals(const ProfileSettingsState(soundVibrationEnabled: true)),
        ),
      );
    });

    test('copyWith returns new instance with updated values', () {
      const original = ProfileSettingsState();
      final updated = original.copyWith(soundVibrationEnabled: true);

      expect(updated.soundVibrationEnabled, true);
      expect(original.soundVibrationEnabled, false);
    });

    test('copyWith with no parameters returns same values', () {
      const original = ProfileSettingsState(soundVibrationEnabled: true);
      final updated = original.copyWith();

      expect(updated.soundVibrationEnabled, true);
    });
  });
}
