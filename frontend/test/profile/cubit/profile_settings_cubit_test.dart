import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_zone/profile/profile.dart';

class MockProfileSettingsRepository extends Mock
    implements ProfileSettingsRepository {}

void main() {
  group('ProfileSettingsCubit', () {
    late ProfileSettingsRepository repository;

    setUp(() {
      repository = MockProfileSettingsRepository();
    });

    test('initial state has anonymousReporting true', () {
      when(() => repository.getAnonymousReporting()).thenReturn(true);
      final cubit = ProfileSettingsCubit(repository);
      expect(cubit.state.anonymousReporting, isTrue);
    });

    test('loads anonymousReporting false from repository', () {
      when(() => repository.getAnonymousReporting()).thenReturn(false);
      final cubit = ProfileSettingsCubit(repository);
      expect(cubit.state.anonymousReporting, isFalse);
    });

    blocTest<ProfileSettingsCubit, ProfileSettingsState>(
      'setAnonymousReporting updates state and calls repository',
      build: () {
        when(() => repository.getAnonymousReporting()).thenReturn(true);
        when(() => repository.setAnonymousReporting(any()))
            .thenAnswer((_) async {});
        return ProfileSettingsCubit(repository);
      },
      act: (cubit) => cubit.setAnonymousReporting(false),
      expect: () => [const ProfileSettingsState(anonymousReporting: false)],
      verify: (_) {
        verify(() => repository.setAnonymousReporting(false)).called(1);
      },
    );

    blocTest<ProfileSettingsCubit, ProfileSettingsState>(
      'setAnonymousReporting to true updates state correctly',
      build: () {
        when(() => repository.getAnonymousReporting()).thenReturn(false);
        when(() => repository.setAnonymousReporting(any()))
            .thenAnswer((_) async {});
        return ProfileSettingsCubit(repository);
      },
      seed: () => const ProfileSettingsState(anonymousReporting: false),
      act: (cubit) => cubit.setAnonymousReporting(true),
      expect: () => [const ProfileSettingsState()],
      verify: (_) {
        verify(() => repository.setAnonymousReporting(true)).called(1);
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

    test('different anonymousReporting values are not equal', () {
      expect(
        const ProfileSettingsState(),
        isNot(equals(const ProfileSettingsState(anonymousReporting: false))),
      );
    });

    test('copyWith creates new instance with updated values', () {
      const state = ProfileSettingsState();
      final newState = state.copyWith(anonymousReporting: false);
      expect(newState.anonymousReporting, isFalse);
    });

    test('copyWith preserves original values when null', () {
      const state = ProfileSettingsState(anonymousReporting: false);
      final newState = state.copyWith();
      expect(newState.anonymousReporting, isFalse);
    });

    test('has correct props', () {
      const state = ProfileSettingsState(anonymousReporting: false);
      expect(state.anonymousReporting, isFalse);
    });
  });
}
