import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_zone/map/models/incident_model.dart';

void main() {
  group('Incident', () {
    test('can be instantiated with required fields', () {
      final incident = Incident(
        id: '1',
        category: IncidentCategory.theft,
        location: const LatLng(40.7128, -74.0060),
        timestamp: DateTime.now(),
        title: 'Test Incident',
      );

      expect(incident.id, '1');
      expect(incident.category, IncidentCategory.theft);
      expect(incident.title, 'Test Incident');
      expect(incident.confirmedBy, 0);
      expect(incident.mediaUrls, isEmpty);
      expect(incident.notifyNearby, false);
    });

    test('supports optional description', () {
      final incident = Incident(
        id: '1',
        category: IncidentCategory.theft,
        location: const LatLng(40.7128, -74.0060),
        timestamp: DateTime.now(),
        title: 'Test Incident',
        description: 'Test description',
      );

      expect(incident.description, 'Test description');
    });

    test('supports media URLs', () {
      final incident = Incident(
        id: '1',
        category: IncidentCategory.theft,
        location: const LatLng(40.7128, -74.0060),
        timestamp: DateTime.now(),
        title: 'Test Incident',
        mediaUrls: ['/path/to/image1.jpg', '/path/to/image2.jpg'],
      );

      expect(incident.mediaUrls.length, 2);
      expect(incident.mediaUrls[0], '/path/to/image1.jpg');
      expect(incident.mediaUrls[1], '/path/to/image2.jpg');
    });

    test('supports notify nearby flag', () {
      final incident = Incident(
        id: '1',
        category: IncidentCategory.theft,
        location: const LatLng(40.7128, -74.0060),
        timestamp: DateTime.now(),
        title: 'Test Incident',
        notifyNearby: true,
      );

      expect(incident.notifyNearby, true);
    });

    test('isWithinTimeFilter returns correct value for 24h', () {
      final recentIncident = Incident(
        id: '1',
        category: IncidentCategory.theft,
        location: const LatLng(40.7128, -74.0060),
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        title: 'Recent Incident',
      );

      final oldIncident = Incident(
        id: '2',
        category: IncidentCategory.theft,
        location: const LatLng(40.7128, -74.0060),
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        title: 'Old Incident',
      );

      expect(
        recentIncident.isWithinTimeFilter(TimeFilter.twentyFourHours),
        true,
      );
      expect(oldIncident.isWithinTimeFilter(TimeFilter.twentyFourHours), false);
    });

    test('isWithinTimeFilter returns correct value for 7d', () {
      final recentIncident = Incident(
        id: '1',
        category: IncidentCategory.theft,
        location: const LatLng(40.7128, -74.0060),
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        title: 'Recent Incident',
      );

      final oldIncident = Incident(
        id: '2',
        category: IncidentCategory.theft,
        location: const LatLng(40.7128, -74.0060),
        timestamp: DateTime.now().subtract(const Duration(days: 10)),
        title: 'Old Incident',
      );

      expect(recentIncident.isWithinTimeFilter(TimeFilter.sevenDays), true);
      expect(oldIncident.isWithinTimeFilter(TimeFilter.sevenDays), false);
    });
  });

  group('IncidentCategory', () {
    test('has correct display names', () {
      expect(IncidentCategory.theft.displayName, 'Theft');
      expect(IncidentCategory.assault.displayName, 'Assault');
      expect(IncidentCategory.harassment.displayName, 'Harassment');
      expect(IncidentCategory.accident.displayName, 'Accident');
      expect(IncidentCategory.suspicious.displayName, 'Suspicious');
      expect(IncidentCategory.lighting.displayName, 'Lighting');
    });

    test('has icons for all categories', () {
      expect(IncidentCategory.theft.icon, Icons.error);
      expect(IncidentCategory.assault.icon, Icons.back_hand);
      expect(IncidentCategory.harassment.icon, Icons.warning);
      expect(IncidentCategory.accident.icon, Icons.car_crash);
      expect(IncidentCategory.suspicious.icon, Icons.visibility);
      expect(IncidentCategory.lighting.icon, Icons.lightbulb);
    });

    test('has colors for all categories', () {
      expect(IncidentCategory.theft.color, const Color(0xFFFF4C4C));
      expect(IncidentCategory.assault.color, const Color(0xFFFF9500));
      expect(IncidentCategory.harassment.color, const Color(0xFFFF6B6B));
      expect(IncidentCategory.accident.color, const Color(0xFFFF3B30));
      expect(IncidentCategory.suspicious.color, const Color(0xFFFFD60A));
      expect(IncidentCategory.lighting.color, const Color(0xFF5856D6));
    });
  });

  group('TimeFilter', () {
    test('has correct display names', () {
      expect(TimeFilter.twentyFourHours.displayName, '24h');
      expect(TimeFilter.sevenDays.displayName, '7d');
      expect(TimeFilter.thirtyDays.displayName, '30d');
    });

    test('has correct durations', () {
      expect(
        TimeFilter.twentyFourHours.duration,
        const Duration(hours: 24),
      );
      expect(TimeFilter.sevenDays.duration, const Duration(days: 7));
      expect(TimeFilter.thirtyDays.duration, const Duration(days: 30));
    });
  });

  group('RiskLevel', () {
    test('has correct display names', () {
      expect(RiskLevel.safe.displayName, 'Safe Zone');
      expect(RiskLevel.moderate.displayName, 'Moderate Risk Zone');
      expect(RiskLevel.high.displayName, 'High Risk Zone');
    });

    test('has correct colors', () {
      expect(RiskLevel.safe.color, const Color(0xFF34C759));
      expect(RiskLevel.moderate.color, const Color(0xFFFFD60A));
      expect(RiskLevel.high.color, const Color(0xFFFF4C4C));
    });

    test('has correct background colors', () {
      expect(RiskLevel.safe.backgroundColor, const Color(0xFFE8F5E9));
      expect(RiskLevel.moderate.backgroundColor, const Color(0xFFFFFDE7));
      expect(RiskLevel.high.backgroundColor, const Color(0xFFFFEBEE));
    });
  });
}
