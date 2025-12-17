import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:line_icons/line_icons.dart';
import 'package:safe_zone/alerts/alerts.dart';
import 'package:safe_zone/home/home.dart';
import 'package:safe_zone/l10n/l10n.dart';

extension AlertsPumpApp on WidgetTester {
  Future<void> pumpAlertsApp(Widget widget) {
    return pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AlertFilterCubit(),
          ),
          BlocProvider(
            create: (_) => BottomNavigationCubit(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: widget,
        ),
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
      expect(find.text('Critical'), findsOneWidget);
      expect(find.text('Recent'), findsOneWidget);
      expect(find.text('Nearby'), findsOneWidget);
    });

    testWidgets('displays safe zone status card', (tester) async {
      await tester.pumpAlertsApp(const AlertsScreen());

      expect(find.text('You\'re in a Safe Zone'), findsOneWidget);
      expect(
        find.text('No immediate threats detected in your vicinity.'),
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

    testWidgets('navigates to alert details when alert card is tapped',
        (tester) async {
      await tester.pumpAlertsApp(const AlertsScreen());

      // Find and tap the first alert card
      final alertCard = find.text('Entering High-Risk Area');
      expect(alertCard, findsOneWidget);

      await tester.tap(alertCard);
      await tester.pumpAndSettle();

      // Verify navigation to alert details screen
      expect(find.text('Alert Details'), findsOneWidget);
      expect(find.text('Entering High-Risk Area'), findsOneWidget);
    });

    testWidgets('opens filter dialog when filter button is tapped',
        (tester) async {
      await tester.pumpAlertsApp(const AlertsScreen());

      // Find and tap the filter button
      final filterButton = find.byIcon(LineIcons.horizontalSliders);
      expect(filterButton, findsOneWidget);

      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // Verify filter bottom sheet is displayed
      expect(find.text('Filter Alerts'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Severity'), findsOneWidget);
      expect(find.text('Alert Type'), findsOneWidget);
      expect(find.text('Time Range'), findsOneWidget);
    });

    testWidgets('filter dialog displays all severity options', (tester) async {
      await tester.pumpAlertsApp(const AlertsScreen());

      // Open filter dialog
      await tester.tap(find.byIcon(LineIcons.horizontalSliders));
      await tester.pumpAndSettle();

      // Verify all severity options are displayed
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Low'), findsOneWidget);
      expect(find.text('Info'), findsOneWidget);
    });

    testWidgets('filter dialog displays all alert type options',
        (tester) async {
      await tester.pumpAlertsApp(const AlertsScreen());

      // Open filter dialog
      await tester.tap(find.byIcon(LineIcons.horizontalSliders));
      await tester.pumpAndSettle();

      // Verify all alert type options are displayed
      expect(find.text('High Risk'), findsOneWidget);
      expect(find.text('Theft'), findsOneWidget);
      expect(find.text('Event Crowd'), findsOneWidget);
      expect(find.text('Traffic Cleared'), findsOneWidget);
    });

    testWidgets('filter dialog displays all time filter options',
        (tester) async {
      await tester.pumpAlertsApp(const AlertsScreen());

      // Open filter dialog
      await tester.tap(find.byIcon(LineIcons.horizontalSliders));
      await tester.pumpAndSettle();

      // Verify all time filter options are displayed
      expect(find.text('Last Hour'), findsOneWidget);
      expect(find.text('Last 24 Hours'), findsOneWidget);
      expect(find.text('Last Week'), findsOneWidget);
      expect(find.text('All Time'), findsOneWidget);
    });

    testWidgets('can toggle severity filters', (tester) async {
      await tester.pumpAlertsApp(const AlertsScreen());

      // Open filter dialog
      await tester.tap(find.byIcon(LineIcons.horizontalSliders));
      await tester.pumpAndSettle();

      // Tap 'High' severity to deselect it
      await tester.tap(find.text('High'));
      await tester.pumpAndSettle();

      // Apply filters
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      // High severity alert should not be visible
      expect(find.text('Entering High-Risk Area'), findsNothing);
      // Other alerts should still be visible
      expect(find.text('Recent Theft Reported'), findsOneWidget);
    });

    testWidgets('clear all resets filters to default', (tester) async {
      await tester.pumpAlertsApp(const AlertsScreen());

      // Open filter dialog
      await tester.tap(find.byIcon(LineIcons.horizontalSliders));
      await tester.pumpAndSettle();

      // Deselect some filters
      await tester.tap(find.text('High'));
      await tester.pumpAndSettle();

      // Tap Reset
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Apply filters
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      // All alerts should be visible again
      expect(find.text('Entering High-Risk Area'), findsOneWidget);
      expect(find.text('Recent Theft Reported'), findsOneWidget);
    });

    testWidgets('displays empty state when no alerts match filters',
        (tester) async {
      await tester.pumpAlertsApp(const AlertsScreen());

      // Open filter dialog
      await tester.tap(find.byIcon(LineIcons.horizontalSliders));
      await tester.pumpAndSettle();

      // Deselect all severities to ensure no alerts match
      await tester.tap(find.text('High'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Medium'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Low'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Info'));
      await tester.pumpAndSettle();

      // Apply filters
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      // Verify empty state is displayed
      expect(find.text('No alerts match your filters'), findsOneWidget);
      expect(
        find.text('Try adjusting your filters or check back later'),
        findsOneWidget,
      );
      expect(find.text('Reset Filters'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
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
