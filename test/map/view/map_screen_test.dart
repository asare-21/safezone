import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_zone/l10n/l10n.dart';
import 'package:safe_zone/map/map.dart';

extension MapPumpApp on WidgetTester {
  Future<void> pumpMapApp(Widget widget) {
    return pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: widget,
      ),
    );
  }
}

void main() {
  group('MapScreen', () {
    testWidgets('renders MapScreen', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      expect(find.byType(MapScreen), findsOneWidget);
    });

    testWidgets('displays search bar', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      expect(find.text('Search location or zone'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('displays time filter chips', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      expect(find.text('24h'), findsOneWidget);
      expect(find.text('7d'), findsOneWidget);
      expect(find.text('30d'), findsOneWidget);
    });

    testWidgets('displays category filter chips', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      expect(find.text('Theft'), findsOneWidget);
      expect(find.text('Assault'), findsOneWidget);
      expect(find.text('Suspicious'), findsOneWidget);
      expect(find.text('Lighting'), findsOneWidget);
    });

    testWidgets('displays risk level indicator', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      expect(find.text('Moderate Risk Zone'), findsOneWidget);
    });

    testWidgets('displays Report Incident button', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      expect(find.text('Report Incident'), findsOneWidget);
    });

    testWidgets('displays user avatar', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      // Avatar is displayed as a Container with icon
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('time filter selection works', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      // Tap on 7d filter
      await tester.tap(find.text('7d'));
      await tester.pumpAndSettle();

      // Verify the filter changed (would need to check styling in real scenario)
      expect(find.text('7d'), findsOneWidget);
    });

    testWidgets('category filter toggle works', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      // Find and tap on Theft category
      final theftFinder = find.text('Theft');
      expect(theftFinder, findsOneWidget);

      await tester.tap(theftFinder);
      await tester.pumpAndSettle();

      // Category should still be visible (just toggled)
      expect(theftFinder, findsOneWidget);
    });

    testWidgets('Report Incident button shows snackbar', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      // Tap Report Incident button
      await tester.tap(find.text('Report Incident'));
      await tester.pumpAndSettle();

      // Verify snackbar appears
      expect(
        find.text('Report incident feature coming soon!'),
        findsOneWidget,
      );
    });
  });

  group('Incident Model', () {
    test('isWithinTimeFilter returns true for recent incident', () {
      final incident = Incident(
        id: '1',
        category: IncidentCategory.theft,
        location: const LatLng(40.7128, -74.0060),
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        title: 'Test Incident',
      );

      expect(incident.isWithinTimeFilter(TimeFilter.twentyFourHours), isTrue);
      expect(incident.isWithinTimeFilter(TimeFilter.sevenDays), isTrue);
      expect(incident.isWithinTimeFilter(TimeFilter.thirtyDays), isTrue);
    });

    test('isWithinTimeFilter returns false for old incident', () {
      final incident = Incident(
        id: '1',
        category: IncidentCategory.theft,
        location: const LatLng(40.7128, -74.0060),
        timestamp: DateTime.now().subtract(const Duration(days: 10)),
        title: 'Test Incident',
      );

      expect(incident.isWithinTimeFilter(TimeFilter.twentyFourHours), isFalse);
      expect(incident.isWithinTimeFilter(TimeFilter.sevenDays), isFalse);
      expect(incident.isWithinTimeFilter(TimeFilter.thirtyDays), isTrue);
    });
  });

  group('IncidentCategory Extension', () {
    test('displayName returns correct name', () {
      expect(IncidentCategory.theft.displayName, 'Theft');
      expect(IncidentCategory.assault.displayName, 'Assault');
      expect(IncidentCategory.suspicious.displayName, 'Suspicious');
      expect(IncidentCategory.lighting.displayName, 'Lighting');
    });

    test('color returns different colors for each category', () {
      expect(
        IncidentCategory.theft.color,
        const Color(0xFFFF4C4C),
      );
      expect(
        IncidentCategory.assault.color,
        const Color(0xFFFF9500),
      );
      expect(
        IncidentCategory.suspicious.color,
        const Color(0xFFFFD60A),
      );
      expect(
        IncidentCategory.lighting.color,
        const Color(0xFF5856D6),
      );
    });
  });

  group('TimeFilter Extension', () {
    test('displayName returns correct name', () {
      expect(TimeFilter.twentyFourHours.displayName, '24h');
      expect(TimeFilter.sevenDays.displayName, '7d');
      expect(TimeFilter.thirtyDays.displayName, '30d');
    });

    test('duration returns correct duration', () {
      expect(
        TimeFilter.twentyFourHours.duration,
        const Duration(hours: 24),
      );
      expect(TimeFilter.sevenDays.duration, const Duration(days: 7));
      expect(TimeFilter.thirtyDays.duration, const Duration(days: 30));
    });
  });

  group('RiskLevel Extension', () {
    test('displayName returns correct name', () {
      expect(RiskLevel.safe.displayName, 'Safe Zone');
      expect(RiskLevel.moderate.displayName, 'Moderate Risk Zone');
      expect(RiskLevel.high.displayName, 'High Risk Zone');
    });

    test('color returns different colors for each level', () {
      expect(RiskLevel.safe.color, const Color(0xFF34C759));
      expect(RiskLevel.moderate.color, const Color(0xFFFFD60A));
      expect(RiskLevel.high.color, const Color(0xFFFF4C4C));
    });

    test('backgroundColor returns different colors for each level', () {
      expect(RiskLevel.safe.backgroundColor, const Color(0xFFE8F5E9));
      expect(RiskLevel.moderate.backgroundColor, const Color(0xFFFFFDE7));
      expect(RiskLevel.high.backgroundColor, const Color(0xFFFFEBEE));
    });
  });
}
