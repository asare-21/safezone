import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_zone/alerts/alerts.dart';

void main() {
  group('AlertFilterCubit', () {
    test('initial state has all default filters selected', () {
      final cubit = AlertFilterCubit();
      expect(
        cubit.state.selectedSeverities,
        equals(AlertFilterDefaults.severities),
      );
      expect(cubit.state.selectedTypes, equals(AlertFilterDefaults.types));
      expect(
        cubit.state.selectedTimeFilter,
        equals(AlertFilterDefaults.timeFilter),
      );
      expect(
        cubit.state.selectedQuickFilter,
        equals(AlertFilterDefaults.quickFilter),
      );
    });

    group('toggleSeverity', () {
      blocTest<AlertFilterCubit, AlertFilterState>(
        'removes severity when already selected',
        build: AlertFilterCubit.new,
        act: (cubit) => cubit.toggleSeverity(AlertSeverity.high),
        expect: () => [
          const AlertFilterState(
            selectedSeverities: {
              AlertSeverity.medium,
              AlertSeverity.low,
              AlertSeverity.info,
            },
          ),
        ],
      );

      blocTest<AlertFilterCubit, AlertFilterState>(
        'adds severity when not selected',
        build: AlertFilterCubit.new,
        seed: () => const AlertFilterState(
          selectedSeverities: {
            AlertSeverity.medium,
            AlertSeverity.low,
          },
        ),
        act: (cubit) => cubit.toggleSeverity(AlertSeverity.high),
        expect: () => [
          const AlertFilterState(
            selectedSeverities: {
              AlertSeverity.medium,
              AlertSeverity.low,
              AlertSeverity.high,
            },
          ),
        ],
      );
    });

    group('toggleType', () {
      blocTest<AlertFilterCubit, AlertFilterState>(
        'removes type when already selected',
        build: AlertFilterCubit.new,
        act: (cubit) => cubit.toggleType(AlertType.highRisk),
        expect: () => [
          const AlertFilterState(
            selectedTypes: {
              AlertType.theft,
              AlertType.eventCrowd,
              AlertType.trafficCleared,
            },
          ),
        ],
      );

      blocTest<AlertFilterCubit, AlertFilterState>(
        'adds type when not selected',
        build: AlertFilterCubit.new,
        seed: () => const AlertFilterState(
          selectedTypes: {AlertType.theft},
        ),
        act: (cubit) => cubit.toggleType(AlertType.highRisk),
        expect: () => [
          const AlertFilterState(
            selectedTypes: {AlertType.theft, AlertType.highRisk},
          ),
        ],
      );
    });

    group('setTimeFilter', () {
      blocTest<AlertFilterCubit, AlertFilterState>(
        'sets time filter to last hour',
        build: AlertFilterCubit.new,
        act: (cubit) => cubit.setTimeFilter(AlertTimeFilter.lastHour),
        expect: () => [
          const AlertFilterState(
            selectedTimeFilter: AlertTimeFilter.lastHour,
          ),
        ],
      );

      blocTest<AlertFilterCubit, AlertFilterState>(
        'sets time filter to last day',
        build: AlertFilterCubit.new,
        act: (cubit) => cubit.setTimeFilter(AlertTimeFilter.lastDay),
        expect: () => [
          const AlertFilterState(
            selectedTimeFilter: AlertTimeFilter.lastDay,
          ),
        ],
      );
    });

    group('setQuickFilter', () {
      blocTest<AlertFilterCubit, AlertFilterState>(
        'sets quick filter to high severity',
        build: AlertFilterCubit.new,
        act: (cubit) => cubit.setQuickFilter(QuickFilter.highSeverity),
        expect: () => [
          const AlertFilterState(
            selectedQuickFilter: QuickFilter.highSeverity,
          ),
        ],
      );

      blocTest<AlertFilterCubit, AlertFilterState>(
        'sets quick filter to recent',
        build: AlertFilterCubit.new,
        act: (cubit) => cubit.setQuickFilter(QuickFilter.recent),
        expect: () => [
          const AlertFilterState(
            selectedQuickFilter: QuickFilter.recent,
          ),
        ],
      );
    });

    group('resetFilters', () {
      blocTest<AlertFilterCubit, AlertFilterState>(
        'resets all filters to defaults',
        build: AlertFilterCubit.new,
        seed: () => const AlertFilterState(
          selectedSeverities: {AlertSeverity.high},
          selectedTypes: {AlertType.theft},
          selectedTimeFilter: AlertTimeFilter.lastHour,
          selectedQuickFilter: QuickFilter.highSeverity,
        ),
        act: (cubit) => cubit.resetFilters(),
        expect: () => [const AlertFilterState()],
      );
    });
  });

  group('AlertFilterState', () {
    test('supports value equality', () {
      expect(
        const AlertFilterState(),
        equals(const AlertFilterState()),
      );
    });

    test('different severities are not equal', () {
      expect(
        const AlertFilterState(
          selectedSeverities: {AlertSeverity.high},
        ),
        isNot(
          equals(
            const AlertFilterState(
              selectedSeverities: {AlertSeverity.medium},
            ),
          ),
        ),
      );
    });

    test('different types are not equal', () {
      expect(
        const AlertFilterState(selectedTypes: {AlertType.theft}),
        isNot(
          equals(
            const AlertFilterState(selectedTypes: {AlertType.highRisk}),
          ),
        ),
      );
    });

    test('different time filters are not equal', () {
      expect(
        const AlertFilterState(
          selectedTimeFilter: AlertTimeFilter.lastHour,
        ),
        isNot(
          equals(
            const AlertFilterState(
              selectedTimeFilter: AlertTimeFilter.lastDay,
            ),
          ),
        ),
      );
    });

    test('different quick filters are not equal', () {
      expect(
        const AlertFilterState(selectedQuickFilter: QuickFilter.highSeverity),
        isNot(
          equals(
            const AlertFilterState(selectedQuickFilter: QuickFilter.recent),
          ),
        ),
      );
    });

    test('copyWith creates new state with updated values', () {
      const original = AlertFilterState();
      final updated = original.copyWith(
        selectedTimeFilter: AlertTimeFilter.lastHour,
      );

      expect(updated.selectedTimeFilter, AlertTimeFilter.lastHour);
      expect(updated.selectedSeverities, original.selectedSeverities);
      expect(updated.selectedTypes, original.selectedTypes);
      expect(updated.selectedQuickFilter, original.selectedQuickFilter);
    });

    test('copyWith with null values keeps original values', () {
      const original = AlertFilterState(
        selectedTimeFilter: AlertTimeFilter.lastHour,
      );
      final updated = original.copyWith();

      expect(updated, equals(original));
    });
  });
}
