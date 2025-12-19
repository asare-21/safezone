import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:line_icons/line_icons.dart';
import 'package:safe_zone/l10n/l10n.dart';
import 'package:safe_zone/map/models/incident_model.dart';
import 'package:safe_zone/profile/models/user_incident_model.dart';
import 'package:safe_zone/profile/view/incident_history_screen.dart';

extension IncidentHistoryPumpApp on WidgetTester {
  Future<void> pumpIncidentHistoryApp(Widget widget) {
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
  group('IncidentHistoryScreen', () {
    testWidgets('renders IncidentHistoryScreen', (tester) async {
      await tester.pumpIncidentHistoryApp(const IncidentHistoryScreen());

      expect(find.text('My Incident History'), findsOneWidget);
    });

    testWidgets('displays statistics cards', (tester) async {
      await tester.pumpIncidentHistoryApp(const IncidentHistoryScreen());

      expect(find.text('Total Reports'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('Impact Score'), findsOneWidget);
    });

    testWidgets('displays filter button', (tester) async {
      await tester.pumpIncidentHistoryApp(const IncidentHistoryScreen());

      expect(find.byIcon(LineIcons.horizontalSliders), findsOneWidget);
    });

    testWidgets('displays Your Reports section', (tester) async {
      await tester.pumpIncidentHistoryApp(const IncidentHistoryScreen());

      expect(find.text('Your Reports'), findsOneWidget);
      expect(find.textContaining('INCIDENTS'), findsOneWidget);
    });

    testWidgets('displays mock incident cards', (tester) async {
      await tester.pumpIncidentHistoryApp(const IncidentHistoryScreen());

      expect(find.text('Bike theft at shopping district'), findsOneWidget);
      expect(find.text('Suspicious activity near parking lot'), findsOneWidget);
      expect(find.text('Broken street lights in tunnel'), findsOneWidget);
    });

    testWidgets('displays correct status badges', (tester) async {
      await tester.pumpIncidentHistoryApp(const IncidentHistoryScreen());

      expect(find.text('Verified'), findsWidgets);
      expect(find.text('Pending'), findsWidgets);
      expect(find.text('Resolved'), findsWidgets);
    });

    testWidgets('opens filter dialog when filter button is tapped',
        (tester) async {
      await tester.pumpIncidentHistoryApp(const IncidentHistoryScreen());

      // Find and tap the filter button
      final filterButton = find.byIcon(LineIcons.horizontalSliders);
      expect(filterButton, findsOneWidget);

      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // Verify filter dialog is displayed
      expect(find.text('Filter & Sort'), findsOneWidget);
      expect(find.text('Clear All'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Sort By'), findsOneWidget);
    });

    testWidgets('filter dialog displays all category options', (tester) async {
      await tester.pumpIncidentHistoryApp(const IncidentHistoryScreen());

      // Open filter dialog
      await tester.tap(find.byIcon(LineIcons.horizontalSliders));
      await tester.pumpAndSettle();

      // Verify all category options are displayed
      expect(find.text('All'), findsWidgets);
      expect(find.text('Theft'), findsWidgets);
      expect(find.text('Assault'), findsWidgets);
      expect(find.text('Suspicious'), findsWidgets);
      expect(find.text('Lighting'), findsWidgets);
    });

    testWidgets('filter dialog displays all status options', (tester) async {
      await tester.pumpIncidentHistoryApp(const IncidentHistoryScreen());

      // Open filter dialog
      await tester.tap(find.byIcon(LineIcons.horizontalSliders));
      await tester.pumpAndSettle();

      // Verify all status options are displayed
      expect(find.text('Pending'), findsWidgets);
      expect(find.text('Verified'), findsWidgets);
      expect(find.text('Resolved'), findsWidgets);
      expect(find.text('Disputed'), findsWidgets);
    });

    testWidgets('filter dialog displays all sort options', (tester) async {
      await tester.pumpIncidentHistoryApp(const IncidentHistoryScreen());

      // Open filter dialog
      await tester.tap(find.byIcon(LineIcons.horizontalSliders));
      await tester.pumpAndSettle();

      // Verify all sort options are displayed
      expect(find.text('Recent'), findsWidgets);
      expect(find.text('Oldest'), findsWidgets);
      expect(find.text('Most Confirmed'), findsWidgets);
    });

    testWidgets('navigates to incident detail when card is tapped',
        (tester) async {
      await tester.pumpIncidentHistoryApp(const IncidentHistoryScreen());

      // Find and tap the first incident card
      final incidentCard = find.text('Bike theft at shopping district');
      expect(incidentCard, findsOneWidget);

      await tester.tap(incidentCard);
      await tester.pumpAndSettle();

      // Verify navigation to incident detail screen
      expect(find.text('Incident Details'), findsOneWidget);
      expect(find.text('Bike theft at shopping district'), findsOneWidget);
    });

    testWidgets('can filter incidents by category', (tester) async {
      await tester.pumpIncidentHistoryApp(const IncidentHistoryScreen());

      // Open filter dialog
      await tester.tap(find.byIcon(LineIcons.horizontalSliders));
      await tester.pumpAndSettle();

      // Select 'Theft' category (find the second occurrence to avoid the header)
      final theftOptions = find.text('Theft');
      await tester.tap(theftOptions.last);
      await tester.pumpAndSettle();

      // Apply filters
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Verify active filter is displayed
      expect(find.byType(Chip), findsWidgets);

      // Only theft incidents should be visible
      expect(find.text('Bike theft at shopping district'), findsOneWidget);
      expect(find.text('Pickpocketing at subway station'), findsOneWidget);
      // Non-theft incidents should not be visible
      expect(find.text('Suspicious activity near parking lot'), findsNothing);
    });

    testWidgets('can clear filters', (tester) async {
      await tester.pumpIncidentHistoryApp(const IncidentHistoryScreen());

      // Open filter dialog
      await tester.tap(find.byIcon(LineIcons.horizontalSliders));
      await tester.pumpAndSettle();

      // Select a filter
      final theftOptions = find.text('Theft');
      await tester.tap(theftOptions.last);
      await tester.pumpAndSettle();

      // Clear all
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      // Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // All incidents should be visible
      expect(find.text('Bike theft at shopping district'), findsOneWidget);
      expect(find.text('Suspicious activity near parking lot'), findsOneWidget);
      expect(find.text('Broken street lights in tunnel'), findsOneWidget);
    });

    testWidgets('displays incident location and confirmations', (tester) async {
      await tester.pumpIncidentHistoryApp(const IncidentHistoryScreen());

      expect(
        find.textContaining('Market St & 5th Ave, Downtown'),
        findsOneWidget,
      );
      expect(find.textContaining('confirmed'), findsWidgets);
      expect(find.textContaining('pts'), findsWidgets);
    });
  });

  group('IncidentDetailScreen', () {
    testWidgets('displays incident details correctly', (tester) async {
      await tester.pumpIncidentHistoryApp(const IncidentHistoryScreen());

      // Navigate to detail screen
      await tester.tap(find.text('Bike theft at shopping district'));
      await tester.pumpAndSettle();

      expect(find.text('Incident Details'), findsOneWidget);
      expect(find.text('Bike theft at shopping district'), findsOneWidget);
      expect(find.text('Information'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('displays information fields', (tester) async {
      await tester.pumpIncidentHistoryApp(const IncidentHistoryScreen());

      // Navigate to detail screen
      await tester.tap(find.text('Bike theft at shopping district'));
      await tester.pumpAndSettle();

      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Date Reported'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('Confirmed By'), findsOneWidget);
      expect(find.text('Impact Score'), findsOneWidget);
    });

    testWidgets('displays action buttons', (tester) async {
      await tester.pumpIncidentHistoryApp(const IncidentHistoryScreen());

      // Navigate to detail screen
      await tester.tap(find.text('Bike theft at shopping district'));
      await tester.pumpAndSettle();

      expect(find.text('Share'), findsOneWidget);
      expect(find.text('View on Map'), findsOneWidget);
    });

    testWidgets('back button navigates back to history screen', (tester) async {
      await tester.pumpIncidentHistoryApp(const IncidentHistoryScreen());

      // Navigate to detail screen
      await tester.tap(find.text('Bike theft at shopping district'));
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back on history screen
      expect(find.text('My Incident History'), findsOneWidget);
      expect(find.text('Your Reports'), findsOneWidget);
    });
  });

  group('UserIncident Model', () {
    test('formattedDate returns correct format', () {
      final incident = UserIncident(
        id: '1',
        category: IncidentCategory.theft,
        locationName: 'Test Location',
        timestamp: DateTime(2024, 3, 15),
        title: 'Test Incident',
        status: IncidentStatus.pending,
      );

      expect(incident.formattedDate, '03/15/2024');
    });

    test('timeAgo returns correct format for hours', () {
      final incident = UserIncident(
        id: '1',
        category: IncidentCategory.theft,
        locationName: 'Test Location',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        title: 'Test Incident',
        status: IncidentStatus.pending,
      );

      expect(incident.timeAgo, contains('hour'));
    });

    test('timeAgo returns correct format for days', () {
      final incident = UserIncident(
        id: '1',
        category: IncidentCategory.theft,
        locationName: 'Test Location',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        title: 'Test Incident',
        status: IncidentStatus.pending,
      );

      expect(incident.timeAgo, contains('day'));
    });

    test('timeAgo returns correct format for months', () {
      final incident = UserIncident(
        id: '1',
        category: IncidentCategory.theft,
        locationName: 'Test Location',
        timestamp: DateTime.now().subtract(const Duration(days: 45)),
        title: 'Test Incident',
        status: IncidentStatus.pending,
      );

      expect(incident.timeAgo, contains('month'));
    });
  });

  group('IncidentStatus Extension', () {
    test('displayName returns correct values', () {
      expect(IncidentStatus.pending.displayName, 'Pending');
      expect(IncidentStatus.verified.displayName, 'Verified');
      expect(IncidentStatus.resolved.displayName, 'Resolved');
      expect(IncidentStatus.disputed.displayName, 'Disputed');
    });

    test('color returns correct values', () {
      expect(IncidentStatus.pending.color, const Color(0xFFFF9500));
      expect(IncidentStatus.verified.color, const Color(0xFF34C759));
      expect(IncidentStatus.resolved.color, const Color(0xFF8E8E93));
      expect(IncidentStatus.disputed.color, const Color(0xFFFF4C4C));
    });

    test('icon returns correct values', () {
      expect(IncidentStatus.pending.icon, Icons.schedule);
      expect(IncidentStatus.verified.icon, Icons.verified);
      expect(IncidentStatus.resolved.icon, Icons.check_circle);
      expect(IncidentStatus.disputed.icon, Icons.report_problem);
    });
  });
}
