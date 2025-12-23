import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_zone/profile/cubit/scoring_cubit.dart';
import 'package:safe_zone/profile/models/user_score_model.dart';
import 'package:safe_zone/profile/repository/scoring_repository.dart';

class MockScoringRepository extends Mock implements ScoringRepository {}

void main() {
  group('ScoringCubit', () {
    late ScoringRepository repository;
    const testDeviceId = 'test_device_123';

    setUp(() {
      repository = MockScoringRepository();
    });

    test('initial state is ScoringInitial', () {
      final cubit = ScoringCubit(repository);
      expect(cubit.state, equals(ScoringInitial()));
    });

    group('loadUserProfile', () {
      final testUserScore = UserScore(
        id: 1,
        totalPoints: 125,
        reportsCount: 10,
        confirmationsCount: 15,
        currentTier: 2,
        tierName: 'Neighborhood Watch',
        tierIcon: '🛡️',
        tierReward: 'Bronze shield',
        verifiedReports: 9,
        accuracyPercentage: 90.0,
        badges: [],
      );

      blocTest<ScoringCubit, ScoringState>(
        'emits [ScoringLoading, ScoringLoaded] when loadUserProfile succeeds',
        build: () {
          when(() => repository.getUserProfile(testDeviceId))
              .thenAnswer((_) async => testUserScore);
          return ScoringCubit(repository);
        },
        act: (cubit) => cubit.loadUserProfile(testDeviceId),
        expect: () => [
          ScoringLoading(),
          ScoringLoaded(testUserScore),
        ],
        verify: (_) {
          verify(() => repository.getUserProfile(testDeviceId)).called(1);
        },
      );

      blocTest<ScoringCubit, ScoringState>(
        'emits [ScoringLoading, ScoringError] when loadUserProfile fails',
        build: () {
          when(() => repository.getUserProfile(testDeviceId))
              .thenThrow(Exception('Network error'));
          return ScoringCubit(repository);
        },
        act: (cubit) => cubit.loadUserProfile(testDeviceId),
        expect: () => [
          ScoringLoading(),
          const ScoringError('Exception: Network error'),
        ],
        verify: (_) {
          verify(() => repository.getUserProfile(testDeviceId)).called(1);
        },
      );
    });

    group('confirmIncident', () {
      const testIncidentId = 1;
      final testUserScore = UserScore(
        id: 1,
        totalPoints: 130,
        reportsCount: 10,
        confirmationsCount: 16,
        currentTier: 2,
        tierName: 'Neighborhood Watch',
        tierIcon: '🛡️',
        tierReward: 'Bronze shield',
        verifiedReports: 9,
        accuracyPercentage: 90.0,
        badges: [],
      );

      final testConfirmationResponse = ConfirmationResponse(
        pointsEarned: 5,
        totalPoints: 130,
        tierChanged: false,
        message: 'Incident confirmed successfully!',
        confirmationCount: 3,
      );

      blocTest<ScoringCubit, ScoringState>(
        'confirms incident and reloads profile successfully',
        build: () {
          when(
            () => repository.confirmIncident(testIncidentId, testDeviceId),
          ).thenAnswer((_) async => testConfirmationResponse);
          when(() => repository.getUserProfile(testDeviceId))
              .thenAnswer((_) async => testUserScore);
          return ScoringCubit(repository);
        },
        act: (cubit) => cubit.confirmIncident(testIncidentId, testDeviceId),
        expect: () => [
          ScoringLoading(),
          ScoringLoaded(testUserScore),
        ],
        verify: (_) {
          verify(
            () => repository.confirmIncident(testIncidentId, testDeviceId),
          ).called(1);
          verify(() => repository.getUserProfile(testDeviceId)).called(1);
        },
      );

      blocTest<ScoringCubit, ScoringState>(
        'emits error when confirmIncident fails',
        build: () {
          when(
            () => repository.confirmIncident(testIncidentId, testDeviceId),
          ).thenThrow(Exception('Confirmation failed'));
          return ScoringCubit(repository);
        },
        act: (cubit) => cubit.confirmIncident(testIncidentId, testDeviceId),
        expect: () => [
          const ScoringError('Exception: Confirmation failed'),
        ],
        verify: (_) {
          verify(
            () => repository.confirmIncident(testIncidentId, testDeviceId),
          ).called(1);
        },
      );

      test('returns ConfirmationResponse on success', () async {
        when(
          () => repository.confirmIncident(testIncidentId, testDeviceId),
        ).thenAnswer((_) async => testConfirmationResponse);
        when(() => repository.getUserProfile(testDeviceId))
            .thenAnswer((_) async => testUserScore);

        final cubit = ScoringCubit(repository);
        final result = await cubit.confirmIncident(
          testIncidentId,
          testDeviceId,
        );

        expect(result, equals(testConfirmationResponse));
      });

      test('returns null when confirmIncident fails', () async {
        when(
          () => repository.confirmIncident(testIncidentId, testDeviceId),
        ).thenThrow(Exception('Confirmation failed'));

        final cubit = ScoringCubit(repository);
        final result = await cubit.confirmIncident(
          testIncidentId,
          testDeviceId,
        );

        expect(result, isNull);
      });
    });

    group('refresh', () {
      final testUserScore = UserScore(
        id: 1,
        totalPoints: 125,
        reportsCount: 10,
        confirmationsCount: 15,
        currentTier: 2,
        tierName: 'Neighborhood Watch',
        tierIcon: '🛡️',
        tierReward: 'Bronze shield',
        verifiedReports: 9,
        accuracyPercentage: 90.0,
        badges: [],
      );

      blocTest<ScoringCubit, ScoringState>(
        'refresh calls loadUserProfile',
        build: () {
          when(() => repository.getUserProfile(testDeviceId))
              .thenAnswer((_) async => testUserScore);
          return ScoringCubit(repository);
        },
        act: (cubit) => cubit.refresh(testDeviceId),
        expect: () => [
          ScoringLoading(),
          ScoringLoaded(testUserScore),
        ],
        verify: (_) {
          verify(() => repository.getUserProfile(testDeviceId)).called(1);
        },
      );
    });
  });

  group('ScoringState', () {
    test('ScoringInitial supports value equality', () {
      expect(ScoringInitial(), equals(ScoringInitial()));
    });

    test('ScoringLoading supports value equality', () {
      expect(ScoringLoading(), equals(ScoringLoading()));
    });

    test('ScoringLoaded supports value equality', () {
      final userScore1 = UserScore(
        id: 1,
        totalPoints: 100,
        reportsCount: 5,
        confirmationsCount: 10,
        currentTier: 1,
        tierName: 'Fresh Eye Scout',
        tierIcon: '👁️',
        tierReward: 'New Watcher badge',
        verifiedReports: 5,
        accuracyPercentage: 100.0,
        badges: [],
      );

      final userScore2 = UserScore(
        id: 1,
        totalPoints: 100,
        reportsCount: 5,
        confirmationsCount: 10,
        currentTier: 1,
        tierName: 'Fresh Eye Scout',
        tierIcon: '👁️',
        tierReward: 'New Watcher badge',
        verifiedReports: 5,
        accuracyPercentage: 100.0,
        badges: [],
      );

      expect(ScoringLoaded(userScore1), equals(ScoringLoaded(userScore2)));
    });

    test('ScoringError supports value equality', () {
      expect(
        const ScoringError('error message'),
        equals(const ScoringError('error message')),
      );
    });

    test('different ScoringError messages are not equal', () {
      expect(
        const ScoringError('error 1'),
        isNot(equals(const ScoringError('error 2'))),
      );
    });

    test('different states are not equal', () {
      expect(ScoringInitial(), isNot(equals(ScoringLoading())));
      expect(ScoringLoading(), isNot(equals(const ScoringError('error'))));
    });
  });
}
