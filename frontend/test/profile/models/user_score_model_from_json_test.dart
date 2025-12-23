import 'package:flutter_test/flutter_test.dart';
import 'package:safe_zone/profile/models/user_score_model.dart';

void main() {
  group('UserScore.fromJson', () {
    test('parses JSON from backend correctly', () {
      // Simulate the actual backend response (without device_id)
      final json = {
        'id': 1,
        'total_points': 100,
        'reports_count': 5,
        'confirmations_count': 3,
        'current_tier': 2,
        'tier_name': 'Neighborhood Watch',
        'tier_icon': '🛡️',
        'tier_reward': 'Bronze shield',
        'verified_reports': 4,
        'accuracy_percentage': 80.0,
        'badges': [],
        'created_at': '2025-12-23T10:00:00Z',
        'updated_at': '2025-12-23T10:00:00Z',
      };

      final userScore = UserScore.fromJson(json);

      expect(userScore.id, equals(1));
      expect(userScore.totalPoints, equals(100));
      expect(userScore.reportsCount, equals(5));
      expect(userScore.confirmationsCount, equals(3));
      expect(userScore.currentTier, equals(2));
      expect(userScore.tierName, equals('Neighborhood Watch'));
      expect(userScore.tierIcon, equals('🛡️'));
      expect(userScore.tierReward, equals('Bronze shield'));
      expect(userScore.verifiedReports, equals(4));
      expect(userScore.accuracyPercentage, equals(80.0));
      expect(userScore.badges, isEmpty);
      expect(userScore.createdAt, isNotNull);
      expect(userScore.updatedAt, isNotNull);
    });

    test('parses JSON with badges correctly', () {
      final json = {
        'id': 1,
        'total_points': 200,
        'reports_count': 15,
        'confirmations_count': 10,
        'current_tier': 3,
        'tier_name': 'Urban Detective',
        'tier_icon': '🔍',
        'tier_reward': 'Silver magnifier',
        'verified_reports': 14,
        'accuracy_percentage': 93.3,
        'badges': [
          {
            'id': 1,
            'badge_type': 'truth_triangulator',
            'badge_display_name': 'Truth Triangulator',
            'badge_icon': '🎯',
            'badge_description': '5+ confirmations earned',
            'earned_at': '2025-12-23T09:00:00Z',
          }
        ],
        'created_at': '2025-12-20T10:00:00Z',
        'updated_at': '2025-12-23T10:00:00Z',
      };

      final userScore = UserScore.fromJson(json);

      expect(userScore.id, equals(1));
      expect(userScore.totalPoints, equals(200));
      expect(userScore.badges, hasLength(1));
      expect(userScore.badges![0].badgeType, equals('truth_triangulator'));
      expect(userScore.badges![0].badgeDisplayName, equals('Truth Triangulator'));
      expect(userScore.badges![0].badgeIcon, equals('🎯'));
    });

    test('parses JSON with null badges', () {
      final json = {
        'id': 1,
        'total_points': 50,
        'reports_count': 5,
        'confirmations_count': 0,
        'current_tier': 1,
        'tier_name': 'Fresh Eye Scout',
        'tier_icon': '👁️',
        'tier_reward': 'New Watcher badge',
        'verified_reports': 5,
        'accuracy_percentage': 100.0,
        'badges': null,
        'created_at': null,
        'updated_at': null,
      };

      final userScore = UserScore.fromJson(json);

      expect(userScore.totalPoints, equals(50));
      expect(userScore.badges, isNull);
      expect(userScore.createdAt, isNull);
      expect(userScore.updatedAt, isNull);
    });

    test('handles zero points correctly', () {
      final json = {
        'id': 1,
        'total_points': 0,
        'reports_count': 0,
        'confirmations_count': 0,
        'current_tier': 1,
        'tier_name': 'Fresh Eye Scout',
        'tier_icon': '👁️',
        'tier_reward': 'New Watcher badge',
        'verified_reports': 0,
        'accuracy_percentage': 0.0,
        'badges': [],
        'created_at': '2025-12-23T10:00:00Z',
        'updated_at': '2025-12-23T10:00:00Z',
      };

      final userScore = UserScore.fromJson(json);

      expect(userScore.totalPoints, equals(0));
      expect(userScore.reportsCount, equals(0));
      expect(userScore.confirmationsCount, equals(0));
      expect(userScore.currentTier, equals(1));
    });
  });
}
