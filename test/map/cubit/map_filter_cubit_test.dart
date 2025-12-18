import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_zone/map/cubit/map_filter_cubit.dart';
import 'package:safe_zone/map/models/incident_model.dart';

void main() {
  group('MapFilterCubit', () {
    late MapFilterCubit cubit;
    late List<Incident> mockIncidents;

    setUp(() {
      cubit = MapFilterCubit();
      mockIncidents = [
        Incident(
          id: '1',
          category: IncidentCategory.theft,
          location: const LatLng(40.7128, -74.0060),
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          title: 'Theft 1',
        ),
        Incident(
          id: '2',
          category: IncidentCategory.assault,
          location: const LatLng(40.7128, -74.0060),
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          title: 'Assault 1',
        ),
        Incident(
          id: '3',
          category: IncidentCategory.suspicious,
          location: const LatLng(40.7128, -74.0060),
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
          title: 'Suspicious 1',
        ),
        Incident(
          id: '4',
          category: IncidentCategory.lighting,
          location: const LatLng(40.7128, -74.0060),
          timestamp: DateTime.now().subtract(const Duration(hours: 12)),
          title: 'Lighting 1',
        ),
      ];
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has default values', () {
      expect(cubit.state.timeFilter, TimeFilter.twentyFourHours);
      expect(
        cubit.state.selectedCategories,
        {
          IncidentCategory.accident,
          IncidentCategory.fire,
          IncidentCategory.theft,
          IncidentCategory.assault,
          IncidentCategory.suspicious,
          IncidentCategory.lighting,
        },
      );
      expect(cubit.state.riskLevel, RiskLevel.moderate);
      expect(cubit.state.searchQuery, '');
    });

    blocTest<MapFilterCubit, MapFilterState>(
      'initializeIncidents calculates risk level based on incidents',
      build: () => cubit,
      act: (cubit) => cubit.initializeIncidents(mockIncidents),
      expect: () => [
        const MapFilterState(
          timeFilter: TimeFilter.twentyFourHours,
          selectedCategories: {
            IncidentCategory.accident,
            IncidentCategory.fire,
            IncidentCategory.theft,
            IncidentCategory.assault,
            IncidentCategory.suspicious,
            IncidentCategory.lighting,
          },
          riskLevel: RiskLevel.high,
        ),
      ],
    );

    blocTest<MapFilterCubit, MapFilterState>(
      'updateTimeFilter changes time filter and recalculates risk',
      build: () {
        final cubit = MapFilterCubit()..initializeIncidents(mockIncidents);
        return cubit;
      },
      act: (cubit) => cubit.updateTimeFilter(TimeFilter.sevenDays),
      skip: 1, // Skip the initialization emission
      expect: () => [
        const MapFilterState(
          timeFilter: TimeFilter.sevenDays,
          selectedCategories: {
            IncidentCategory.accident,
            IncidentCategory.fire,
            IncidentCategory.theft,
            IncidentCategory.assault,
            IncidentCategory.suspicious,
            IncidentCategory.lighting,
          },
          riskLevel: RiskLevel.high,
        ),
      ],
    );

    blocTest<MapFilterCubit, MapFilterState>(
      'toggleCategory removes category when present and recalculates risk',
      build: () {
        final cubit = MapFilterCubit()..initializeIncidents(mockIncidents);
        return cubit;
      },
      act: (cubit) => cubit.toggleCategory(IncidentCategory.theft),
      skip: 1, // Skip the initialization emission
      expect: () => [
        const MapFilterState(
          timeFilter: TimeFilter.twentyFourHours,
          selectedCategories: {
            IncidentCategory.accident,
            IncidentCategory.fire,
            IncidentCategory.assault,
            IncidentCategory.suspicious,
            IncidentCategory.lighting,
          },
          riskLevel: RiskLevel.moderate,
        ),
      ],
    );

    blocTest<MapFilterCubit, MapFilterState>(
      'toggleCategory adds category when not present and recalculates risk',
      build: () {
        final cubit = MapFilterCubit()
          ..initializeIncidents(mockIncidents)
          ..toggleCategory(IncidentCategory.theft);
        return cubit;
      },
      act: (cubit) => cubit.toggleCategory(IncidentCategory.theft),
      skip: 2, // Skip initialization and first toggle
      expect: () => [
        const MapFilterState(
          timeFilter: TimeFilter.twentyFourHours,
          selectedCategories: {
            IncidentCategory.accident,
            IncidentCategory.fire,
            IncidentCategory.assault,
            IncidentCategory.suspicious,
            IncidentCategory.lighting,
            IncidentCategory.theft,
          },
          riskLevel: RiskLevel.high,
        ),
      ],
    );

    test('getFilteredIncidents filters by time and category', () {
      cubit.initializeIncidents(mockIncidents);

      // All incidents within 24h
      var filtered = cubit.getFilteredIncidents();
      expect(filtered.length, 4);

      // Toggle off theft category
      cubit.toggleCategory(IncidentCategory.theft);
      filtered = cubit.getFilteredIncidents();
      expect(filtered.length, 3);
      expect(filtered.any((i) => i.category == IncidentCategory.theft), false);
    });

    blocTest<MapFilterCubit, MapFilterState>(
      'updateSearchQuery updates search query and recalculates risk',
      build: () {
        final cubit = MapFilterCubit()..initializeIncidents(mockIncidents);
        return cubit;
      },
      act: (cubit) => cubit.updateSearchQuery('Theft'),
      skip: 1,
      expect: () => [
        const MapFilterState(
          timeFilter: TimeFilter.twentyFourHours,
          selectedCategories: {
            IncidentCategory.accident,
            IncidentCategory.fire,
            IncidentCategory.theft,
            IncidentCategory.assault,
            IncidentCategory.suspicious,
            IncidentCategory.lighting,
          },
          riskLevel: RiskLevel.moderate,
          searchQuery: 'Theft',
        ),
      ],
    );

    blocTest<MapFilterCubit, MapFilterState>(
      'clearSearch clears search query',
      build: () {
        final cubit = MapFilterCubit()
          ..initializeIncidents(mockIncidents)
          ..updateSearchQuery('test');
        return cubit;
      },
      act: (cubit) => cubit.clearSearch(),
      skip: 2,
      expect: () => [
        const MapFilterState(
          timeFilter: TimeFilter.twentyFourHours,
          selectedCategories: {
            IncidentCategory.theft,
            IncidentCategory.assault,
            IncidentCategory.suspicious,
            IncidentCategory.lighting,
          },
          riskLevel: RiskLevel.high,
        ),
      ],
    );

    test('getFilteredIncidents filters by search query', () {
      cubit.initializeIncidents(mockIncidents);

      // Search for "Theft"
      cubit.updateSearchQuery('Theft');
      var filtered = cubit.getFilteredIncidents();
      expect(filtered.length, 1);
      expect(filtered.first.title, 'Theft 1');

      // Clear search
      cubit.clearSearch();
      filtered = cubit.getFilteredIncidents();
      expect(filtered.length, 4);
    });

    blocTest<MapFilterCubit, MapFilterState>(
      'clearFilters resets categories and search',
      build: () {
        final cubit = MapFilterCubit()
          ..initializeIncidents(mockIncidents)
          ..toggleCategory(IncidentCategory.theft)
          ..updateSearchQuery('test');
        return cubit;
      },
      act: (cubit) => cubit.clearFilters(),
      skip: 3,
      expect: () => [
        const MapFilterState(
          timeFilter: TimeFilter.twentyFourHours,
          selectedCategories: {
            IncidentCategory.accident,
            IncidentCategory.fire,
            IncidentCategory.theft,
            IncidentCategory.assault,
            IncidentCategory.suspicious,
            IncidentCategory.lighting,
          },
          riskLevel: RiskLevel.high,
        ),
      ],
    );

    group('risk level calculation', () {
      blocTest<MapFilterCubit, MapFilterState>(
        'sets risk level to safe when no incidents',
        build: () => cubit,
        act: (cubit) => cubit.initializeIncidents([]),
        expect: () => [
          const MapFilterState(
            timeFilter: TimeFilter.twentyFourHours,
            selectedCategories: {
              IncidentCategory.accident,
              IncidentCategory.fire,
              IncidentCategory.theft,
              IncidentCategory.assault,
              IncidentCategory.suspicious,
              IncidentCategory.lighting,
            },
            riskLevel: RiskLevel.safe,
          ),
        ],
      );

      blocTest<MapFilterCubit, MapFilterState>(
        'sets risk level to safe with 1 low severity incident',
        build: () => cubit,
        act: (cubit) => cubit.initializeIncidents([
          Incident(
            id: '1',
            category: IncidentCategory.lighting,
            location: const LatLng(40.7128, -74.0060),
            timestamp: DateTime.now(),
            title: 'Test',
          ),
        ]),
        expect: () => [
          const MapFilterState(
            timeFilter: TimeFilter.twentyFourHours,
            selectedCategories: {
              IncidentCategory.accident,
              IncidentCategory.fire,
              IncidentCategory.theft,
              IncidentCategory.assault,
              IncidentCategory.suspicious,
              IncidentCategory.lighting,
            },
            riskLevel: RiskLevel.safe,
          ),
        ],
      );

      blocTest<MapFilterCubit, MapFilterState>(
        'sets risk level to moderate with 2 incidents',
        build: () => cubit,
        act: (cubit) => cubit.initializeIncidents([
          Incident(
            id: '1',
            category: IncidentCategory.lighting,
            location: const LatLng(40.7128, -74.0060),
            timestamp: DateTime.now(),
            title: 'Test 1',
          ),
          Incident(
            id: '2',
            category: IncidentCategory.suspicious,
            location: const LatLng(40.7128, -74.0060),
            timestamp: DateTime.now(),
            title: 'Test 2',
          ),
        ]),
        expect: () => [
          const MapFilterState(
            timeFilter: TimeFilter.twentyFourHours,
            selectedCategories: {
              IncidentCategory.accident,
              IncidentCategory.fire,
              IncidentCategory.theft,
              IncidentCategory.assault,
              IncidentCategory.suspicious,
              IncidentCategory.lighting,
            },
            riskLevel: RiskLevel.moderate,
          ),
        ],
      );

      blocTest<MapFilterCubit, MapFilterState>(
        'sets risk level to moderate with 1 high severity incident',
        build: () => cubit,
        act: (cubit) => cubit.initializeIncidents([
          Incident(
            id: '1',
            category: IncidentCategory.theft,
            location: const LatLng(40.7128, -74.0060),
            timestamp: DateTime.now(),
            title: 'Test',
          ),
        ]),
        expect: () => [
          const MapFilterState(
            timeFilter: TimeFilter.twentyFourHours,
            selectedCategories: {
              IncidentCategory.accident,
              IncidentCategory.fire,
              IncidentCategory.theft,
              IncidentCategory.assault,
              IncidentCategory.suspicious,
              IncidentCategory.lighting,
            },
            riskLevel: RiskLevel.moderate,
          ),
        ],
      );

      blocTest<MapFilterCubit, MapFilterState>(
        'sets risk level to high with 5+ incidents',
        build: () => cubit,
        act: (cubit) => cubit.initializeIncidents([
          Incident(
            id: '1',
            category: IncidentCategory.lighting,
            location: const LatLng(40.7128, -74.0060),
            timestamp: DateTime.now(),
            title: 'Test 1',
          ),
          Incident(
            id: '2',
            category: IncidentCategory.lighting,
            location: const LatLng(40.7128, -74.0060),
            timestamp: DateTime.now(),
            title: 'Test 2',
          ),
          Incident(
            id: '3',
            category: IncidentCategory.suspicious,
            location: const LatLng(40.7128, -74.0060),
            timestamp: DateTime.now(),
            title: 'Test 3',
          ),
          Incident(
            id: '4',
            category: IncidentCategory.suspicious,
            location: const LatLng(40.7128, -74.0060),
            timestamp: DateTime.now(),
            title: 'Test 4',
          ),
          Incident(
            id: '5',
            category: IncidentCategory.suspicious,
            location: const LatLng(40.7128, -74.0060),
            timestamp: DateTime.now(),
            title: 'Test 5',
          ),
        ]),
        expect: () => [
          const MapFilterState(
            timeFilter: TimeFilter.twentyFourHours,
            selectedCategories: {
              IncidentCategory.accident,
              IncidentCategory.fire,
              IncidentCategory.theft,
              IncidentCategory.assault,
              IncidentCategory.suspicious,
              IncidentCategory.lighting,
            },
            riskLevel: RiskLevel.high,
          ),
        ],
      );

      blocTest<MapFilterCubit, MapFilterState>(
        'sets risk level to high with 3+ high severity incidents',
        build: () => cubit,
        act: (cubit) => cubit.initializeIncidents([
          Incident(
            id: '1',
            category: IncidentCategory.theft,
            location: const LatLng(40.7128, -74.0060),
            timestamp: DateTime.now(),
            title: 'Test 1',
          ),
          Incident(
            id: '2',
            category: IncidentCategory.assault,
            location: const LatLng(40.7128, -74.0060),
            timestamp: DateTime.now(),
            title: 'Test 2',
          ),
          Incident(
            id: '3',
            category: IncidentCategory.theft,
            location: const LatLng(40.7128, -74.0060),
            timestamp: DateTime.now(),
            title: 'Test 3',
          ),
        ]),
        expect: () => [
          const MapFilterState(
            timeFilter: TimeFilter.twentyFourHours,
            selectedCategories: {
              IncidentCategory.accident,
              IncidentCategory.fire,
              IncidentCategory.theft,
              IncidentCategory.assault,
              IncidentCategory.suspicious,
              IncidentCategory.lighting,
            },
            riskLevel: RiskLevel.high,
          ),
        ],
      );
    });
  });

  group('MapFilterState', () {
    test('copyWith creates new instance with updated values', () {
      const original = MapFilterState(
        timeFilter: TimeFilter.twentyFourHours,
        selectedCategories: {IncidentCategory.theft},
        riskLevel: RiskLevel.safe,
      );

      final updated = original.copyWith(
        timeFilter: TimeFilter.sevenDays,
        searchQuery: 'test',
      );

      expect(updated.timeFilter, TimeFilter.sevenDays);
      expect(updated.selectedCategories, {IncidentCategory.theft});
      expect(updated.riskLevel, RiskLevel.safe);
      expect(updated.searchQuery, 'test');
    });

    test('copyWith preserves original values when no parameters provided', () {
      const original = MapFilterState(
        timeFilter: TimeFilter.thirtyDays,
        selectedCategories: {
          IncidentCategory.assault,
          IncidentCategory.suspicious,
        },
        riskLevel: RiskLevel.moderate,
        searchQuery: 'search term',
      );

      final updated = original.copyWith();

      expect(updated.timeFilter, TimeFilter.thirtyDays);
      expect(
        updated.selectedCategories,
        {IncidentCategory.assault, IncidentCategory.suspicious},
      );
      expect(updated.riskLevel, RiskLevel.moderate);
      expect(updated.searchQuery, 'search term');
    });
  });
}
