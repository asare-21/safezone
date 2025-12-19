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

    test('initial state has default values', () {
      final cubit = ProfileCubit(sharedPreferences: mockSharedPreferences);
      expect(cubit.state.alertRadius, 2.5);
      expect(cubit.state.defaultZoom, 13.0);
      expect(cubit.state.locationIcon, 'assets/icons/courier.png');
      expect(cubit.state.isLoading, false);
    });

    group('loadSettings', () {
      blocTest<ProfileCubit, ProfileState>(
        'loads all saved settings from shared preferences',
        setUp: () {
          when(() => mockSharedPreferences.getDouble('alert_radius'))
              .thenReturn(5);
          when(() => mockSharedPreferences.getDouble('default_zoom'))
              .thenReturn(15);
          when(() => mockSharedPreferences.getString('location_icon'))
              .thenReturn('assets/icons/penguin.png');
        },
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.loadSettings(),
        expect: () => [
          const ProfileState(isLoading: true),
          const ProfileState(
            alertRadius: 5,
            defaultZoom: 15,
            locationIcon: 'assets/icons/penguin.png',
          ),
        ],
      );

      blocTest<ProfileCubit, ProfileState>(
        'uses default values when no saved settings exist',
        setUp: () {
          when(() => mockSharedPreferences.getDouble('alert_radius'))
              .thenReturn(null);
          when(() => mockSharedPreferences.getDouble('default_zoom'))
              .thenReturn(null);
          when(() => mockSharedPreferences.getString('location_icon'))
              .thenReturn(null);
        },
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.loadSettings(),
        expect: () => [
          const ProfileState(isLoading: true),
          const ProfileState(),
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
          const ProfileState(),
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
        act: (cubit) => cubit.updateAlertRadius(15),
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
          when(() => mockSharedPreferences.setDouble('alert_radius', 10))
              .thenAnswer((_) async => true);
        },
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.updateAlertRadius(10),
        expect: () => [
          const ProfileState(alertRadius: 10),
        ],
      );
    });

    group('updateDefaultZoom', () {
      blocTest<ProfileCubit, ProfileState>(
        'updates default zoom and saves to preferences',
        setUp: () {
          when(() => mockSharedPreferences.setDouble('default_zoom', 15))
              .thenAnswer((_) async => true);
        },
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.updateDefaultZoom(15),
        expect: () => [
          const ProfileState(defaultZoom: 15),
        ],
        verify: (_) {
          verify(() => mockSharedPreferences.setDouble('default_zoom', 15))
              .called(1);
        },
      );

      blocTest<ProfileCubit, ProfileState>(
        'does not update when zoom is below minimum',
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.updateDefaultZoom(5),
        expect: () => <dynamic>[],
        verify: (_) {
          verifyNever(
            () => mockSharedPreferences.setDouble(any(), any()),
          );
        },
      );

      blocTest<ProfileCubit, ProfileState>(
        'does not update when zoom is above maximum',
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.updateDefaultZoom(20),
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
          when(() => mockSharedPreferences.setDouble('default_zoom', 14))
              .thenThrow(Exception('Storage error'));
        },
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.updateDefaultZoom(14),
        expect: () => [
          const ProfileState(defaultZoom: 14),
        ],
      );

      blocTest<ProfileCubit, ProfileState>(
        'accepts minimum valid zoom (10.0)',
        setUp: () {
          when(() => mockSharedPreferences.setDouble('default_zoom', 10))
              .thenAnswer((_) async => true);
        },
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.updateDefaultZoom(10),
        expect: () => [
          const ProfileState(defaultZoom: 10),
        ],
      );

      blocTest<ProfileCubit, ProfileState>(
        'accepts maximum valid zoom (18.0)',
        setUp: () {
          when(() => mockSharedPreferences.setDouble('default_zoom', 18))
              .thenAnswer((_) async => true);
        },
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.updateDefaultZoom(18),
        expect: () => [
          const ProfileState(defaultZoom: 18),
        ],
      );
    });

    group('updateLocationIcon', () {
      blocTest<ProfileCubit, ProfileState>(
        'updates location icon and saves to preferences',
        setUp: () {
          when(() => mockSharedPreferences.setString('location_icon', 'assets/icons/penguin.png'))
              .thenAnswer((_) async => true);
        },
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.updateLocationIcon('assets/icons/penguin.png'),
        expect: () => [
          const ProfileState(locationIcon: 'assets/icons/penguin.png'),
        ],
        verify: (_) {
          verify(() => mockSharedPreferences.setString('location_icon', 'assets/icons/penguin.png'))
              .called(1);
        },
      );

      blocTest<ProfileCubit, ProfileState>(
        'does not update when icon path is empty',
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.updateLocationIcon(''),
        expect: () => <dynamic>[],
        verify: (_) {
          verifyNever(
            () => mockSharedPreferences.setString(any(), any()),
          );
        },
      );

      blocTest<ProfileCubit, ProfileState>(
        'updates state even when persistence fails',
        setUp: () {
          when(() => mockSharedPreferences.setString('location_icon', 'assets/icons/animal.png'))
              .thenThrow(Exception('Storage error'));
        },
        build: () => ProfileCubit(sharedPreferences: mockSharedPreferences),
        act: (cubit) => cubit.updateLocationIcon('assets/icons/animal.png'),
        expect: () => [
          const ProfileState(locationIcon: 'assets/icons/animal.png'),
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
        const ProfileState(),
        isNot(equals(const ProfileState(alertRadius: 5))),
      );
    });

    test('different zoom levels are not equal', () {
      expect(
        const ProfileState(),
        isNot(equals(const ProfileState(defaultZoom: 15))),
      );
    });

    test('different location icons are not equal', () {
      expect(
        const ProfileState(),
        isNot(equals(const ProfileState(locationIcon: 'assets/icons/penguin.png'))),
      );
    });

    test('different loading states are not equal', () {
      expect(
        const ProfileState(isLoading: true),
        isNot(equals(const ProfileState())),
      );
    });

    test('copyWith returns new instance with updated values', () {
      const state = ProfileState(alertRadius: 3);
      final newState = state.copyWith(
        alertRadius: 5,
        defaultZoom: 16,
        locationIcon: 'assets/icons/food.png',
      );

      expect(newState.alertRadius, 5.0);
      expect(newState.defaultZoom, 16.0);
      expect(newState.locationIcon, 'assets/icons/food.png');
      expect(newState.isLoading, false);
    });

    test('copyWith preserves values when not specified', () {
      const state = ProfileState(
        alertRadius: 3,
        defaultZoom: 14,
        locationIcon: 'assets/icons/animal.png',
        isLoading: true,
      );
      final newState = state.copyWith(alertRadius: 5);

      expect(newState.alertRadius, 5.0);
      expect(newState.defaultZoom, 14.0);
      expect(newState.locationIcon, 'assets/icons/animal.png');
      expect(newState.isLoading, true);
    });

    test('has correct default values', () {
      const state = ProfileState();
      expect(state.alertRadius, 2.5);
      expect(state.defaultZoom, 13.0);
      expect(state.locationIcon, 'assets/icons/courier.png');
      expect(state.isLoading, false);
    });
  });
}
