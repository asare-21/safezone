import 'package:flutter_test/flutter_test.dart';
import 'package:safe_zone/profile/models/user_score_model.dart';

void main() {
  group('UserScore', () {
    group('progressToNextTier', () {
      test('returns 0.0 for tier 1 with 0 points', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 0,
          reportsCount: 0,
          confirmationsCount: 0,
          currentTier: 1,
          tierName: 'Fresh Eye Scout',
          tierIcon: '👁️',
          tierReward: 'New Watcher badge',
          verifiedReports: 0,
          accuracyPercentage: 0,
        );

        expect(userScore.progressToNextTier, equals(0.0));
      });

      test('returns ~0.49 for tier 1 with 25 points', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 25,
          reportsCount: 2,
          confirmationsCount: 1,
          currentTier: 1,
          tierName: 'Fresh Eye Scout',
          tierIcon: '👁️',
          tierReward: 'New Watcher badge',
          verifiedReports: 2,
          accuracyPercentage: 100,
        );

        // 25 / 51 ≈ 0.49
        expect(userScore.progressToNextTier, closeTo(0.49, 0.01));
      });

      test('returns ~0.98 for tier 1 with 50 points', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 50,
          reportsCount: 5,
          confirmationsCount: 0,
          currentTier: 1,
          tierName: 'Fresh Eye Scout',
          tierIcon: '👁️',
          tierReward: 'New Watcher badge',
          verifiedReports: 5,
          accuracyPercentage: 100,
        );

        // 50 / 51 ≈ 0.98
        expect(userScore.progressToNextTier, closeTo(0.98, 0.01));
      });

      test('returns 0.0 for tier 2 with 51 points', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 51,
          reportsCount: 5,
          confirmationsCount: 1,
          currentTier: 2,
          tierName: 'Neighborhood Watch',
          tierIcon: '🛡️',
          tierReward: 'Bronze shield',
          verifiedReports: 5,
          accuracyPercentage: 100,
        );

        // (51 - 51) / (151 - 51) = 0 / 100 = 0.0
        expect(userScore.progressToNextTier, equals(0.0));
      });

      test('returns 0.74 for tier 2 with 125 points', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 125,
          reportsCount: 10,
          confirmationsCount: 15,
          currentTier: 2,
          tierName: 'Neighborhood Watch',
          tierIcon: '🛡️',
          tierReward: 'Bronze shield',
          verifiedReports: 9,
          accuracyPercentage: 90,
        );

        // (125 - 51) / (151 - 51) = 74 / 100 = 0.74
        expect(userScore.progressToNextTier, equals(0.74));
      });

      test('returns ~0.99 for tier 2 with 150 points', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 150,
          reportsCount: 12,
          confirmationsCount: 16,
          currentTier: 2,
          tierName: 'Neighborhood Watch',
          tierIcon: '🛡️',
          tierReward: 'Bronze shield',
          verifiedReports: 11,
          accuracyPercentage: 91.7,
        );

        // (150 - 51) / (151 - 51) = 99 / 100 = 0.99
        expect(userScore.progressToNextTier, equals(0.99));
      });

      test('returns 0.0 for tier 6 with 801 points', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 801,
          reportsCount: 65,
          confirmationsCount: 80,
          currentTier: 6,
          tierName: 'Safety Sentinel',
          tierIcon: '👑',
          tierReward: 'Crown with sparkles',
          verifiedReports: 60,
          accuracyPercentage: 92.3,
        );

        // (801 - 801) / (1200 - 801) = 0 / 399 = 0.0
        expect(userScore.progressToNextTier, equals(0.0));
      });

      test('returns ~0.50 for tier 6 with 1000 points', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 1000,
          reportsCount: 80,
          confirmationsCount: 100,
          currentTier: 6,
          tierName: 'Safety Sentinel',
          tierIcon: '👑',
          tierReward: 'Crown with sparkles',
          verifiedReports: 75,
          accuracyPercentage: 93.8,
        );

        // (1000 - 801) / (1200 - 801) = 199 / 399 ≈ 0.499
        expect(userScore.progressToNextTier, closeTo(0.499, 0.001));
      });

      test('returns 1.0 for tier 7 (max tier)', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 1200,
          reportsCount: 100,
          confirmationsCount: 120,
          currentTier: 7,
          tierName: 'Legendary Watchmaster',
          tierIcon: '🌟',
          tierReward: 'Legendary frame',
          verifiedReports: 95,
          accuracyPercentage: 95,
        );

        expect(userScore.progressToNextTier, equals(1.0));
      });

      test('returns 1.0 for tier 7 with 2000 points', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 2000,
          reportsCount: 150,
          confirmationsCount: 200,
          currentTier: 7,
          tierName: 'Legendary Watchmaster',
          tierIcon: '🌟',
          tierReward: 'Legendary frame',
          verifiedReports: 145,
          accuracyPercentage: 96.7,
        );

        expect(userScore.progressToNextTier, equals(1.0));
      });

      test('handles division by zero safely', () {
        // This shouldn't happen with valid data, but test defensive programming
        const userScore = UserScore(
          id: 1,
          totalPoints: 100,
          reportsCount: 10,
          confirmationsCount: 10,
          currentTier: 7, // Max tier - should return early
          tierName: 'Legendary Watchmaster',
          tierIcon: '🌟',
          tierReward: 'Legendary frame',
          verifiedReports: 9,
          accuracyPercentage: 90,
        );

        expect(userScore.progressToNextTier, equals(1.0));
      });

      test('clamps negative progress to 0.0 (data inconsistency)', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 40,
          reportsCount: 4,
          confirmationsCount: 0,
          currentTier: 2, // Inconsistent: should be tier 1 with 40 points
          tierName: 'Neighborhood Watch',
          tierIcon: '🛡️',
          tierReward: 'Bronze shield',
          verifiedReports: 4,
          accuracyPercentage: 100,
        );

        // (40 - 51) / (151 - 51) = -11 / 100 = -0.11, clamped to 0.0
        expect(userScore.progressToNextTier, equals(0.0));
      });

      test('clamps progress > 1.0 to 1.0 (data inconsistency)', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 200,
          reportsCount: 20,
          confirmationsCount: 0,
          currentTier: 2, // Inconsistent: should be tier 3 with 200 points
          tierName: 'Neighborhood Watch',
          tierIcon: '🛡️',
          tierReward: 'Bronze shield',
          verifiedReports: 18,
          accuracyPercentage: 90,
        );

        // (200 - 51) / (151 - 51) = 149 / 100 = 1.49, clamped to 1.0
        expect(userScore.progressToNextTier, equals(1.0));
      });
    });

    group('pointsToNextTier', () {
      test('returns points needed to reach next tier', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 125,
          reportsCount: 10,
          confirmationsCount: 15,
          currentTier: 2,
          tierName: 'Neighborhood Watch',
          tierIcon: '🛡️',
          tierReward: 'Bronze shield',
          verifiedReports: 9,
          accuracyPercentage: 90,
        );

        // Need 151 points for tier 3, have 125, need 26 more
        expect(userScore.pointsToNextTier, equals(26));
      });

      test('returns 0 for max tier', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 1200,
          reportsCount: 100,
          confirmationsCount: 120,
          currentTier: 7,
          tierName: 'Legendary Watchmaster',
          tierIcon: '🌟',
          tierReward: 'Legendary frame',
          verifiedReports: 95,
          accuracyPercentage: 95,
        );

        expect(userScore.pointsToNextTier, equals(0));
      });

      test('returns 0 when points exceed next tier threshold', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 200,
          reportsCount: 20,
          confirmationsCount: 0,
          currentTier: 2, // Inconsistent: should be tier 3
          tierName: 'Neighborhood Watch',
          tierIcon: '🛡️',
          tierReward: 'Bronze shield',
          verifiedReports: 18,
          accuracyPercentage: 90,
        );

        // Has 200 points, next tier at 151, so 0 more needed
        expect(userScore.pointsToNextTier, equals(0));
      });
    });

    group('pointsInCurrentTier', () {
      test('returns points earned in current tier', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 125,
          reportsCount: 10,
          confirmationsCount: 15,
          currentTier: 2,
          tierName: 'Neighborhood Watch',
          tierIcon: '🛡️',
          tierReward: 'Bronze shield',
          verifiedReports: 9,
          accuracyPercentage: 90,
        );

        // Tier 2 starts at 51, have 125, so 74 points in current tier
        expect(userScore.pointsInCurrentTier, equals(74));
      });

      test('returns 0 when just entered tier', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 51,
          reportsCount: 5,
          confirmationsCount: 1,
          currentTier: 2,
          tierName: 'Neighborhood Watch',
          tierIcon: '🛡️',
          tierReward: 'Bronze shield',
          verifiedReports: 5,
          accuracyPercentage: 100,
        );

        expect(userScore.pointsInCurrentTier, equals(0));
      });

      test('clamps to 0 for negative values', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 40,
          reportsCount: 4,
          confirmationsCount: 0,
          currentTier: 2, // Inconsistent data
          tierName: 'Neighborhood Watch',
          tierIcon: '🛡️',
          tierReward: 'Bronze shield',
          verifiedReports: 4,
          accuracyPercentage: 100,
        );

        expect(userScore.pointsInCurrentTier, equals(0));
      });
    });

    group('pointsNeededInCurrentTier', () {
      test('returns total points needed in tier', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 125,
          reportsCount: 10,
          confirmationsCount: 15,
          currentTier: 2,
          tierName: 'Neighborhood Watch',
          tierIcon: '🛡️',
          tierReward: 'Bronze shield',
          verifiedReports: 9,
          accuracyPercentage: 90,
        );

        // Tier 2 spans from 51 to 151, so 100 points total
        expect(userScore.pointsNeededInCurrentTier, equals(100));
      });

      test('returns 0 for max tier', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 1200,
          reportsCount: 100,
          confirmationsCount: 120,
          currentTier: 7,
          tierName: 'Legendary Watchmaster',
          tierIcon: '🌟',
          tierReward: 'Legendary frame',
          verifiedReports: 95,
          accuracyPercentage: 95,
        );

        expect(userScore.pointsNeededInCurrentTier, equals(0));
      });

      test('returns correct values for tier 1', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 25,
          reportsCount: 2,
          confirmationsCount: 1,
          currentTier: 1,
          tierName: 'Fresh Eye Scout',
          tierIcon: '👁️',
          tierReward: 'New Watcher badge',
          verifiedReports: 2,
          accuracyPercentage: 100,
        );

        // Tier 1 spans from 0 to 51, so 51 points total
        expect(userScore.pointsNeededInCurrentTier, equals(51));
      });

      test('returns correct values for tier 6', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 1000,
          reportsCount: 80,
          confirmationsCount: 100,
          currentTier: 6,
          tierName: 'Safety Sentinel',
          tierIcon: '👑',
          tierReward: 'Crown with sparkles',
          verifiedReports: 75,
          accuracyPercentage: 93.8,
        );

        // Tier 6 spans from 801 to 1200, so 399 points total
        expect(userScore.pointsNeededInCurrentTier, equals(399));
      });
    });

    group('nextTierThreshold', () {
      test('returns 51 for tier 1', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 25,
          reportsCount: 2,
          confirmationsCount: 1,
          currentTier: 1,
          tierName: 'Fresh Eye Scout',
          tierIcon: '👁️',
          tierReward: 'New Watcher badge',
          verifiedReports: 2,
          accuracyPercentage: 100,
        );

        expect(userScore.nextTierThreshold, equals(51));
      });

      test('returns 151 for tier 2', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 125,
          reportsCount: 10,
          confirmationsCount: 15,
          currentTier: 2,
          tierName: 'Neighborhood Watch',
          tierIcon: '🛡️',
          tierReward: 'Bronze shield',
          verifiedReports: 9,
          accuracyPercentage: 90,
        );

        expect(userScore.nextTierThreshold, equals(151));
      });

      test('returns 301 for tier 3', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 200,
          reportsCount: 18,
          confirmationsCount: 20,
          currentTier: 3,
          tierName: 'Urban Detective',
          tierIcon: '🔍',
          tierReward: 'Silver magnifier',
          verifiedReports: 17,
          accuracyPercentage: 94.4,
        );

        expect(userScore.nextTierThreshold, equals(301));
      });

      test('returns 501 for tier 4', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 400,
          reportsCount: 35,
          confirmationsCount: 40,
          currentTier: 4,
          tierName: 'Community Guardian',
          tierIcon: '🦸',
          tierReward: 'Gold hero badge',
          verifiedReports: 33,
          accuracyPercentage: 94.3,
        );

        expect(userScore.nextTierThreshold, equals(501));
      });

      test('returns 801 for tier 5', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 650,
          reportsCount: 55,
          confirmationsCount: 60,
          currentTier: 5,
          tierName: 'Truth Blazer',
          tierIcon: '🔥',
          tierReward: 'Animated fire icon',
          verifiedReports: 52,
          accuracyPercentage: 94.5,
        );

        expect(userScore.nextTierThreshold, equals(801));
      });

      test('returns 1200 for tier 6', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 1000,
          reportsCount: 80,
          confirmationsCount: 100,
          currentTier: 6,
          tierName: 'Safety Sentinel',
          tierIcon: '👑',
          tierReward: 'Crown with sparkles',
          verifiedReports: 75,
          accuracyPercentage: 93.8,
        );

        expect(userScore.nextTierThreshold, equals(1200));
      });

      test('returns 1200 for tier 7 (max tier)', () {
        const userScore = UserScore(
          id: 1,
          totalPoints: 1500,
          reportsCount: 120,
          confirmationsCount: 150,
          currentTier: 7,
          tierName: 'Legendary Watchmaster',
          tierIcon: '🌟',
          tierReward: 'Legendary frame',
          verifiedReports: 115,
          accuracyPercentage: 95.8,
        );

        expect(userScore.nextTierThreshold, equals(1200));
      });
    });
  });
}
