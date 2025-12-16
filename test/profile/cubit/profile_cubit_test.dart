import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_zone/profile/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('ProfileCubit', () {
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
    });

    test('initial state has default alert radius of 2.5', () {
      final cubit = ProfileCubit(sharedPreferences: mockSharedPreferences);
      expect(cubit.state.alertRadius, 2.5);
      expect(cubit.state.isLoading, false);
    });

    group('loadSettings', () {
      blocTest<ProfileCubit, ProfileState>(
        'loads saved alert radius from shared preferences',
        setUp: () {
          when(() => mockSharedPreferences.getDouble('alert_radius'))
              .thenReturn(5.0);
        },
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.loadSettings(),
        expect: () => [
          const ProfileState(isLoading: true),
          const ProfileState(alertRadius: 5.0, isLoading: false),
        ],
      );

      blocTest<ProfileCubit, ProfileState>(
        'uses default value when no saved setting exists',
        setUp: () {
          when(() => mockSharedPreferences.getDouble('alert_radius'))
              .thenReturn(null);
        },
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.loadSettings(),
        expect: () => [
          const ProfileState(isLoading: true),
          const ProfileState(alertRadius: 2.5, isLoading: false),
        ],
      );

      blocTest<ProfileCubit, ProfileState>(
        'handles errors gracefully when loading fails',
        setUp: () {
          when(() => mockSharedPreferences.getDouble('alert_radius'))
              .thenThrow(Exception('Storage error'));
        },
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.loadSettings(),
        expect: () => [
          const ProfileState(isLoading: true),
          const ProfileState(isLoading: false),
        ],
      );
    });

    group('updateAlertRadius', () {
      blocTest<ProfileCubit, ProfileState>(
        'updates alert radius and saves to preferences',
        setUp: () {
          when(() => mockSharedPreferences.setDouble('alert_radius', 7.5))
              .thenAnswer((_) async => true);
        },
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.updateAlertRadius(7.5),
        expect: () => [
          const ProfileState(alertRadius: 7.5),
        ],
        verify: (_) {
          verify(() => mockSharedPreferences.setDouble('alert_radius', 7.5))
              .called(1);
        },
      );

      blocTest<ProfileCubit, ProfileState>(
        'does not update when radius is below minimum',
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.updateAlertRadius(0.3),
        expect: () => <dynamic>[],
        verify: (_) {
          verifyNever(
            () => mockSharedPreferences.setDouble(any(), any()),
          );
        },
      );

      blocTest<ProfileCubit, ProfileState>(
        'does not update when radius is above maximum',
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.updateAlertRadius(15.0),
        expect: () => <dynamic>[],
        verify: (_) {
          verifyNever(
            () => mockSharedPreferences.setDouble(any(), any()),
          );
        },
      );

      blocTest<ProfileCubit, ProfileState>(
        'updates state even when persistence fails',
        setUp: () {
          when(() => mockSharedPreferences.setDouble('alert_radius', 3.5))
              .thenThrow(Exception('Storage error'));
        },
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.updateAlertRadius(3.5),
        expect: () => [
          const ProfileState(alertRadius: 3.5),
        ],
      );

      blocTest<ProfileCubit, ProfileState>(
        'accepts minimum valid radius (0.5)',
        setUp: () {
          when(() => mockSharedPreferences.setDouble('alert_radius', 0.5))
              .thenAnswer((_) async => true);
        },
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.updateAlertRadius(0.5),
        expect: () => [
          const ProfileState(alertRadius: 0.5),
        ],
      );

      blocTest<ProfileCubit, ProfileState>(
        'accepts maximum valid radius (10.0)',
        setUp: () {
          when(() => mockSharedPreferences.setDouble('alert_radius', 10.0))
              .thenAnswer((_) async => true);
        },
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.updateAlertRadius(10.0),
        expect: () => [
          const ProfileState(alertRadius: 10.0),
        ],
      );
    });
  });

  group('ProfileState', () {
    test('supports value equality', () {
      expect(
        const ProfileState(),
        equals(const ProfileState()),
      );
    });

    test('different alert radii are not equal', () {
      expect(
        const ProfileState(alertRadius: 2.5),
        isNot(equals(const ProfileState(alertRadius: 5.0))),
      );
    });

    test('different loading states are not equal', () {
      expect(
        const ProfileState(isLoading: true),
        isNot(equals(const ProfileState(isLoading: false))),
      );
    });

    test('copyWith returns new instance with updated values', () {
      const state = ProfileState(alertRadius: 3.0, isLoading: false);
      final newState = state.copyWith(alertRadius: 5.0);

      expect(newState.alertRadius, 5.0);
      expect(newState.isLoading, false);
    });

    test('copyWith preserves values when not specified', () {
      const state = ProfileState(alertRadius: 3.0, isLoading: true);
      final newState = state.copyWith(alertRadius: 5.0);

      expect(newState.isLoading, true);
    });

    test('has correct default values', () {
      const state = ProfileState();
      expect(state.alertRadius, 2.5);
      expect(state.isLoading, false);
    });
  });
}
