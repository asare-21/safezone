import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_zone/profile/cubit/safe_zone_cubit.dart';
import 'package:safe_zone/profile/cubit/safe_zone_state.dart';
import 'package:safe_zone/profile/models/safe_zone_model.dart';
import 'package:safe_zone/profile/repository/safe_zone_repository.dart';

class MockSafeZoneRepository extends Mock implements SafeZoneRepository {}

void main() {
  group('SafeZoneCubit', () {
    late MockSafeZoneRepository mockRepository;

    setUp(() {
      mockRepository = MockSafeZoneRepository();
    });

    test('initial state is SafeZoneStatus.initial', () {
      when(() => mockRepository.loadSafeZones())
          .thenAnswer((_) async => <SafeZone>[]);

      final cubit = SafeZoneCubit(repository: mockRepository);

      expect(cubit.state.status, SafeZoneStatus.initial);
    });

    blocTest<SafeZoneCubit, SafeZoneState>(
      'emits [loading, success] when loadSafeZones succeeds',
      setUp: () {
        when(() => mockRepository.loadSafeZones())
            .thenAnswer((_) async => <SafeZone>[]);
      },
      build: () => SafeZoneCubit(repository: mockRepository),
      act: (cubit) => cubit.loadSafeZones(),
      expect: () => [
        const SafeZoneState(status: SafeZoneStatus.loading),
        const SafeZoneState(
          status: SafeZoneStatus.success,
        ),
      ],
    );

    blocTest<SafeZoneCubit, SafeZoneState>(
      'emits safe zones when loadSafeZones succeeds with data',
      setUp: () {
        final zones = [
          const SafeZone(
            id: '1',
            name: 'Home',
            location: LatLng(37.7749, -122.4194),
            radius: 500,
          ),
        ];
        when(() => mockRepository.loadSafeZones())
            .thenAnswer((_) async => zones);
      },
      build: () => SafeZoneCubit(repository: mockRepository),
      act: (cubit) => cubit.loadSafeZones(),
      expect: () => [
        const SafeZoneState(status: SafeZoneStatus.loading),
        const SafeZoneState(
          status: SafeZoneStatus.success,
          safeZones: [
            SafeZone(
              id: '1',
              name: 'Home',
              location: LatLng(37.7749, -122.4194),
              radius: 500,
            ),
          ],
        ),
      ],
    );

    blocTest<SafeZoneCubit, SafeZoneState>(
      'emits [loading, error] when loadSafeZones fails',
      setUp: () {
        when(() => mockRepository.loadSafeZones())
            .thenThrow(Exception('Failed to load'));
      },
      build: () => SafeZoneCubit(repository: mockRepository),
      act: (cubit) => cubit.loadSafeZones(),
      expect: () => [
        const SafeZoneState(status: SafeZoneStatus.loading),
        const SafeZoneState(
          status: SafeZoneStatus.error,
          errorMessage: 'Failed to load safe zones: Exception: Failed to load',
        ),
      ],
    );

    blocTest<SafeZoneCubit, SafeZoneState>(
      'addSafeZone calls repository and reloads',
      setUp: () {
        const zone = SafeZone(
          id: '1',
          name: 'Home',
          location: LatLng(37.7749, -122.4194),
          radius: 500,
        );
        when(() => mockRepository.addSafeZone(zone))
            .thenAnswer((_) async => {});
        when(() => mockRepository.loadSafeZones())
            .thenAnswer((_) async => [zone]);
      },
      build: () => SafeZoneCubit(repository: mockRepository),
      act: (cubit) async {
        await cubit.addSafeZone(
          const SafeZone(
            id: '1',
            name: 'Home',
            location: LatLng(37.7749, -122.4194),
            radius: 500,
          ),
        );
      },
      verify: (_) {
        verify(() => mockRepository.addSafeZone(any())).called(1);
        verify(() => mockRepository.loadSafeZones()).called(2);
      },
    );

    blocTest<SafeZoneCubit, SafeZoneState>(
      'updateSafeZone calls repository and reloads',
      setUp: () {
        const zone = SafeZone(
          id: '1',
          name: 'Home',
          location: LatLng(37.7749, -122.4194),
          radius: 500,
        );
        when(() => mockRepository.updateSafeZone(zone))
            .thenAnswer((_) async => {});
        when(() => mockRepository.loadSafeZones())
            .thenAnswer((_) async => [zone]);
      },
      build: () => SafeZoneCubit(repository: mockRepository),
      act: (cubit) async {
        await cubit.updateSafeZone(
          const SafeZone(
            id: '1',
            name: 'Home',
            location: LatLng(37.7749, -122.4194),
            radius: 500,
          ),
        );
      },
      verify: (_) {
        verify(() => mockRepository.updateSafeZone(any())).called(1);
        verify(() => mockRepository.loadSafeZones()).called(2);
      },
    );

    blocTest<SafeZoneCubit, SafeZoneState>(
      'deleteSafeZone calls repository and reloads',
      setUp: () {
        when(() => mockRepository.deleteSafeZone('1'))
            .thenAnswer((_) async => {});
        when(() => mockRepository.loadSafeZones())
            .thenAnswer((_) async => <SafeZone>[]);
      },
      build: () => SafeZoneCubit(repository: mockRepository),
      act: (cubit) async {
        await cubit.deleteSafeZone('1');
      },
      verify: (_) {
        verify(() => mockRepository.deleteSafeZone('1')).called(1);
        verify(() => mockRepository.loadSafeZones()).called(2);
      },
    );

    blocTest<SafeZoneCubit, SafeZoneState>(
      'toggleSafeZone updates zone active status',
      setUp: () {
        const zone = SafeZone(
          id: '1',
          name: 'Home',
          location: LatLng(37.7749, -122.4194),
          radius: 500,
        );
        final updatedZone = zone.copyWith(isActive: false);

        when(() => mockRepository.loadSafeZones())
            .thenAnswer((_) async => [zone]);
        when(() => mockRepository.updateSafeZone(updatedZone))
            .thenAnswer((_) async => {});
      },
      build: () => SafeZoneCubit(repository: mockRepository),
      seed: () => const SafeZoneState(
        status: SafeZoneStatus.success,
        safeZones: [
          SafeZone(
            id: '1',
            name: 'Home',
            location: LatLng(37.7749, -122.4194),
            radius: 500,
          ),
        ],
      ),
      act: (cubit) async {
        await cubit.toggleSafeZone('1');
      },
      verify: (_) {
        verify(() => mockRepository.updateSafeZone(any())).called(1);
      },
    );
  });
}
