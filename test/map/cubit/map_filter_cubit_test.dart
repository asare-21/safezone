import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_zone/map/cubit/map_filter_cubit.dart';
import 'package:safe_zone/map/models/incident_model.dart';

void main() {
  group('MapFilterCubit', () {
    late MapFilterCubit cubit;

    setUp(() {
      cubit = MapFilterCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has default values', () {
      expect(cubit.state.timeFilter, TimeFilter.twentyFourHours);
      expect(
        cubit.state.selectedCategories,
        {
          IncidentCategory.theft,
          IncidentCategory.assault,
          IncidentCategory.suspicious,
          IncidentCategory.lighting,
        },
      );
      expect(cubit.state.riskLevel, RiskLevel.moderate);
    });

    blocTest<MapFilterCubit, MapFilterState>(
      'updateTimeFilter changes time filter',
      build: () => cubit,
      act: (cubit) => cubit.updateTimeFilter(TimeFilter.sevenDays),
      expect: () => [
        MapFilterState(
          timeFilter: TimeFilter.sevenDays,
          selectedCategories: {
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
      'toggleCategory removes category when present',
      build: () => cubit,
      act: (cubit) => cubit.toggleCategory(IncidentCategory.theft),
      expect: () => [
        MapFilterState(
          timeFilter: TimeFilter.twentyFourHours,
          selectedCategories: {
            IncidentCategory.assault,
            IncidentCategory.suspicious,
            IncidentCategory.lighting,
          },
          riskLevel: RiskLevel.moderate,
        ),
      ],
    );

    blocTest<MapFilterCubit, MapFilterState>(
      'toggleCategory adds category when not present',
      build: () => MapFilterCubit(),
      seed: () => MapFilterState(
        timeFilter: TimeFilter.twentyFourHours,
        selectedCategories: {
          IncidentCategory.assault,
          IncidentCategory.suspicious,
        },
        riskLevel: RiskLevel.moderate,
      ),
      act: (cubit) => cubit.toggleCategory(IncidentCategory.theft),
      expect: () => [
        MapFilterState(
          timeFilter: TimeFilter.twentyFourHours,
          selectedCategories: {
            IncidentCategory.assault,
            IncidentCategory.suspicious,
            IncidentCategory.theft,
          },
          riskLevel: RiskLevel.moderate,
        ),
      ],
    );

    group('updateRiskLevel', () {
      blocTest<MapFilterCubit, MapFilterState>(
        'sets risk level to safe when no incidents',
        build: () => cubit,
        act: (cubit) => cubit.updateRiskLevel([]),
        expect: () => [
          MapFilterState(
            timeFilter: TimeFilter.twentyFourHours,
            selectedCategories: {
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
        act: (cubit) => cubit.updateRiskLevel([
          Incident(
            id: '1',
            category: IncidentCategory.lighting,
            location: const LatLng(40.7128, -74.0060),
            timestamp: DateTime.now(),
            title: 'Test',
          ),
        ]),
        expect: () => [
          MapFilterState(
            timeFilter: TimeFilter.twentyFourHours,
            selectedCategories: {
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
        act: (cubit) => cubit.updateRiskLevel([
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
          MapFilterState(
            timeFilter: TimeFilter.twentyFourHours,
            selectedCategories: {
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
        act: (cubit) => cubit.updateRiskLevel([
          Incident(
            id: '1',
            category: IncidentCategory.theft,
            location: const LatLng(40.7128, -74.0060),
            timestamp: DateTime.now(),
            title: 'Test',
          ),
        ]),
        expect: () => [
          MapFilterState(
            timeFilter: TimeFilter.twentyFourHours,
            selectedCategories: {
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
        act: (cubit) => cubit.updateRiskLevel([
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
          MapFilterState(
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

      blocTest<MapFilterCubit, MapFilterState>(
        'sets risk level to high with 3+ high severity incidents',
        build: () => cubit,
        act: (cubit) => cubit.updateRiskLevel([
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
          MapFilterState(
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
      );

      expect(updated.timeFilter, TimeFilter.sevenDays);
      expect(updated.selectedCategories, {IncidentCategory.theft});
      expect(updated.riskLevel, RiskLevel.safe);
    });

    test('copyWith preserves original values when no parameters provided', () {
      const original = MapFilterState(
        timeFilter: TimeFilter.thirtyDays,
        selectedCategories: {
          IncidentCategory.assault,
          IncidentCategory.suspicious,
        },
        riskLevel: RiskLevel.moderate,
      );

      final updated = original.copyWith();

      expect(updated.timeFilter, TimeFilter.thirtyDays);
      expect(
        updated.selectedCategories,
        {IncidentCategory.assault, IncidentCategory.suspicious},
      );
      expect(updated.riskLevel, RiskLevel.moderate);
    });
  });
}
