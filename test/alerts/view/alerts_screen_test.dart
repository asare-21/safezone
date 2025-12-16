import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_zone/alerts/alerts.dart';
import 'package:safe_zone/l10n/l10n.dart';

extension AlertsPumpApp on WidgetTester {
  Future<void> pumpAlertsApp(Widget widget) {
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
  group('AlertsScreen', () {
    testWidgets('renders AlertsScreen', (tester) async {
      await tester.pumpAlertsApp(const AlertsScreen());

      expect(find.text('Safety Alerts'), findsOneWidget);
    });

    testWidgets('displays filter chips', (tester) async {
      await tester.pumpAlertsApp(const AlertsScreen());

      expect(find.text('All Alerts'), findsOneWidget);
      expect(find.text('High Severity'), findsOneWidget);
      expect(find.text('Recent'), findsOneWidget);
      expect(find.text('Nearby'), findsOneWidget);
    });

    testWidgets('displays safe zone status card', (tester) async {
      await tester.pumpAlertsApp(const AlertsScreen());

      expect(find.text('You are in a Safe Zone'), findsOneWidget);
      expect(
        find.text('No immediate threats detected in your current vicinity.'),
        findsOneWidget,
      );
    });

    testWidgets('displays real-time alerts section', (tester) async {
      await tester.pumpAlertsApp(const AlertsScreen());

      expect(find.text('Real-time Alerts'), findsOneWidget);
      expect(find.text('SORTED BY TIME'), findsOneWidget);
    });

    testWidgets('displays mock alert cards', (tester) async {
      await tester.pumpAlertsApp(const AlertsScreen());

      expect(find.text('Entering High-Risk Area'), findsOneWidget);
      expect(find.text('Recent Theft Reported'), findsOneWidget);
      expect(find.text('Public Event Crowd'), findsOneWidget);
      expect(find.text('Traffic Accident Cleared'), findsOneWidget);
    });

    testWidgets('displays Map View FAB', (tester) async {
      await tester.pumpAlertsApp(const AlertsScreen());

      expect(find.text('Map View'), findsOneWidget);
      expect(find.byIcon(Icons.map), findsOneWidget);
    });
  });

  group('Alert Model', () {
    test('timeAgo returns correct format for minutes', () {
      final alert = Alert(
        id: '1',
        type: AlertType.highRisk,
        severity: AlertSeverity.high,
        title: 'Test Alert',
        location: 'Test Location',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      );

      expect(alert.timeAgo, contains('mins ago'));
    });

    test('timeAgo returns correct format for hours', () {
      final alert = Alert(
        id: '1',
        type: AlertType.highRisk,
        severity: AlertSeverity.high,
        title: 'Test Alert',
        location: 'Test Location',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      );

      expect(alert.timeAgo, contains('hour'));
    });

    test('severityColor returns correct color for high severity', () {
      final alert = Alert(
        id: '1',
        type: AlertType.highRisk,
        severity: AlertSeverity.high,
        title: 'Test Alert',
        location: 'Test Location',
        timestamp: DateTime.now(),
      );

      expect(alert.severityColor, const Color(0xFFFF4C4C));
    });
  });
}
