import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_zone/emergency_services/cubit/emergency_services_cubit.dart';
import 'package:safe_zone/emergency_services/cubit/emergency_services_state.dart';
import 'package:safe_zone/emergency_services/models/emergency_service_model.dart';
import 'package:safe_zone/emergency_services/repository/emergency_services_repository.dart';

class MockEmergencyServicesRepository extends Mock
    implements EmergencyServicesRepository {}

void main() {
  late MockEmergencyServicesRepository mockRepository;

  setUp(() {
    mockRepository = MockEmergencyServicesRepository();
  });

  group('EmergencyServicesCubit', () {
    final mockServices = [
      EmergencyService(
        id: 'police_1',
        name: 'Test Police Station',
        type: EmergencyServiceType.police,
        location: const LatLng(40.7128, -74.0060),
        phoneNumber: '+1-212-555-0000',
      ),
      EmergencyService(
        id: 'hospital_1',
        name: 'Test Hospital',
        type: EmergencyServiceType.hospital,
        location: const LatLng(40.7128, -74.0060),
        phoneNumber: '+1-212-555-0001',
      ),
    ];

    test('initial state is EmergencyServicesState with initial status', () {
      final cubit = EmergencyServicesCubit(repository: mockRepository);
      expect(cubit.state.status, EmergencyServicesStatus.initial);
      expect(cubit.state.services, isEmpty);
      expect(cubit.state.filteredServices, isEmpty);
      expect(cubit.state.selectedTypes, isEmpty);
    });

    blocTest<EmergencyServicesCubit, EmergencyServicesState>(
      'emits [loading, success] when loadServices succeeds',
      setUp: () {
        when(() => mockRepository.getServicesNearLocation(
          any(),
          countryCode: any(named: 'countryCode'),
        )).thenReturn(mockServices);
      },
      build: () => EmergencyServicesCubit(repository: mockRepository),
      act: (cubit) => cubit.loadServices(
        userLocation: const LatLng(40.7128, -74.0060),
      ),
      expect: () => [
        const EmergencyServicesState(status: EmergencyServicesStatus.loading),
        EmergencyServicesState(
          status: EmergencyServicesStatus.success,
          services: mockServices,
          filteredServices: mockServices,
        ),
      ],
    );

    blocTest<EmergencyServicesCubit, EmergencyServicesState>(
      'toggleServiceType adds type to selectedTypes',
      seed: () => EmergencyServicesState(
        status: EmergencyServicesStatus.success,
        services: mockServices,
        filteredServices: mockServices,
      ),
      build: () => EmergencyServicesCubit(repository: mockRepository),
      act: (cubit) => cubit.toggleServiceType(EmergencyServiceType.police),
      expect: () => [
        EmergencyServicesState(
          status: EmergencyServicesStatus.success,
          services: mockServices,
          filteredServices: [mockServices[0]],
          selectedTypes: const {EmergencyServiceType.police},
        ),
      ],
    );

    blocTest<EmergencyServicesCubit, EmergencyServicesState>(
      'toggleServiceType removes type from selectedTypes when already selected',
      seed: () => EmergencyServicesState(
        status: EmergencyServicesStatus.success,
        services: mockServices,
        filteredServices: [mockServices[0]],
        selectedTypes: const {EmergencyServiceType.police},
      ),
      build: () => EmergencyServicesCubit(repository: mockRepository),
      act: (cubit) => cubit.toggleServiceType(EmergencyServiceType.police),
      expect: () => [
        EmergencyServicesState(
          status: EmergencyServicesStatus.success,
          services: mockServices,
          filteredServices: mockServices,
        ),
      ],
    );

    blocTest<EmergencyServicesCubit, EmergencyServicesState>(
      'clearFilters resets selectedTypes and shows all services',
      seed: () => EmergencyServicesState(
        status: EmergencyServicesStatus.success,
        services: mockServices,
        filteredServices: [mockServices[0]],
        selectedTypes: const {EmergencyServiceType.police},
      ),
      build: () => EmergencyServicesCubit(repository: mockRepository),
      act: (cubit) => cubit.clearFilters(),
      expect: () => [
        EmergencyServicesState(
          status: EmergencyServicesStatus.success,
          services: mockServices,
          filteredServices: mockServices,
        ),
      ],
    );

    blocTest<EmergencyServicesCubit, EmergencyServicesState>(
      'filters services by multiple types',
      seed: () => EmergencyServicesState(
        status: EmergencyServicesStatus.success,
        services: mockServices,
        filteredServices: mockServices,
      ),
      build: () => EmergencyServicesCubit(repository: mockRepository),
      act: (cubit) {
        cubit.toggleServiceType(EmergencyServiceType.police);
        cubit.toggleServiceType(EmergencyServiceType.hospital);
      },
      expect: () => [
        EmergencyServicesState(
          status: EmergencyServicesStatus.success,
          services: mockServices,
          filteredServices: [mockServices[0]],
          selectedTypes: const {EmergencyServiceType.police},
        ),
        EmergencyServicesState(
          status: EmergencyServicesStatus.success,
          services: mockServices,
          filteredServices: mockServices,
          selectedTypes: const {
            EmergencyServiceType.police,
            EmergencyServiceType.hospital,
          },
        ),
      ],
    );
  });
}
