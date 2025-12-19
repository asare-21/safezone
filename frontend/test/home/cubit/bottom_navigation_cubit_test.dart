import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_zone/home/home.dart';

void main() {
  group('BottomNavigationCubit', () {
    test('initial state has index 0', () {
      final cubit = BottomNavigationCubit();
      expect(cubit.state.index, 0);
    });

    blocTest<BottomNavigationCubit, BottomNavigationState>(
      'navigateToTab emits new state with correct index',
      build: BottomNavigationCubit.new,
      act: (cubit) => cubit.navigateToTab(2),
      expect: () => [const BottomNavigationState(index: 2)],
    );

    blocTest<BottomNavigationCubit, BottomNavigationState>(
      'navigateToMap navigates to index 0',
      build: BottomNavigationCubit.new,
      seed: () => const BottomNavigationState(index: 2),
      act: (cubit) => cubit.navigateToMap(),
      expect: () => [const BottomNavigationState()],
    );

    blocTest<BottomNavigationCubit, BottomNavigationState>(
      'navigateToAlerts navigates to index 1',
      build: BottomNavigationCubit.new,
      act: (cubit) => cubit.navigateToAlerts(),
      expect: () => [const BottomNavigationState(index: 1)],
    );

    blocTest<BottomNavigationCubit, BottomNavigationState>(
      'navigateToGuide navigates to index 2',
      build: BottomNavigationCubit.new,
      act: (cubit) => cubit.navigateToGuide(),
      expect: () => [const BottomNavigationState(index: 2)],
    );

    blocTest<BottomNavigationCubit, BottomNavigationState>(
      'navigateToSettings navigates to index 3',
      build: BottomNavigationCubit.new,
      act: (cubit) => cubit.navigateToSettings(),
      expect: () => [const BottomNavigationState(index: 3)],
    );

    blocTest<BottomNavigationCubit, BottomNavigationState>(
      'navigateToTab does not emit when index is negative',
      build: BottomNavigationCubit.new,
      act: (cubit) => cubit.navigateToTab(-1),
      expect: () => <dynamic>[],
    );

    blocTest<BottomNavigationCubit, BottomNavigationState>(
      'navigateToTab does not emit when index is greater than 3',
      build: BottomNavigationCubit.new,
      act: (cubit) => cubit.navigateToTab(4),
      expect: () => <dynamic>[],
    );
  });

  group('BottomNavigationState', () {
    test('supports value equality', () {
      expect(
        const BottomNavigationState(),
        equals(const BottomNavigationState()),
      );
    });

    test('different indices are not equal', () {
      expect(
        const BottomNavigationState(),
        isNot(equals(const BottomNavigationState(index: 1))),
      );
    });

    test('has correct props', () {
      const state = BottomNavigationState(index: 2);
      expect(state.index, 2);
    });
  });
}
