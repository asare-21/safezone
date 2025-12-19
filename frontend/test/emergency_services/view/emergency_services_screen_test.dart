import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_zone/emergency_services/emergency_services.dart';
import 'package:safe_zone/l10n/l10n.dart';

extension EmergencyServicesPumpApp on WidgetTester {
  Future<void> pumpEmergencyServicesApp(Widget widget) {
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
  group('EmergencyServicesScreen', () {
    testWidgets('renders EmergencyServicesScreen', (tester) async {
      await tester.pumpEmergencyServicesApp(const EmergencyServicesScreen());
      await tester.pump();

      expect(find.byType(EmergencyServicesScreen), findsOneWidget);
    });

    testWidgets('displays app bar with title', (tester) async {
      await tester.pumpEmergencyServicesApp(const EmergencyServicesScreen());
      await tester.pump();

      expect(find.text('Emergency Services'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('displays loading indicator initially', (tester) async {
      await tester.pumpEmergencyServicesApp(const EmergencyServicesScreen());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays filter section after loading', (tester) async {
      await tester.pumpEmergencyServicesApp(const EmergencyServicesScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Filter by Type'), findsOneWidget);
    });

    testWidgets('displays all service type filter chips', (tester) async {
      await tester.pumpEmergencyServicesApp(const EmergencyServicesScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Police Station'), findsAtLeastNWidgets(1));
      expect(find.text('Hospital'), findsAtLeastNWidgets(1));
      expect(find.text('Fire Station'), findsAtLeastNWidgets(1));
      expect(find.text('Ambulance'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays service cards', (tester) async {
      await tester.pumpEmergencyServicesApp(const EmergencyServicesScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsAtLeastNWidgets(1));
    });

    testWidgets('service card displays phone button', (tester) async {
      await tester.pumpEmergencyServicesApp(const EmergencyServicesScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.phone), findsAtLeastNWidgets(1));
    });

    testWidgets('filter chips can be selected', (tester) async {
      await tester.pumpEmergencyServicesApp(const EmergencyServicesScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Find and tap the Police Station filter chip
      final policeChip = find.widgetWithText(FilterChip, 'Police Station');
      expect(policeChip, findsOneWidget);

      await tester.tap(policeChip);
      await tester.pumpAndSettle();

      // Clear button should appear when filter is active
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('clear button clears filters', (tester) async {
      await tester.pumpEmergencyServicesApp(const EmergencyServicesScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Select a filter
      final policeChip = find.widgetWithText(FilterChip, 'Police Station');
      await tester.tap(policeChip);
      await tester.pumpAndSettle();

      // Tap clear button
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // Clear button should disappear
      expect(find.text('Clear'), findsNothing);
    });

    testWidgets('refresh button reloads services', (tester) async {
      await tester.pumpEmergencyServicesApp(const EmergencyServicesScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('tapping service card shows details bottom sheet', (tester) async {
      await tester.pumpEmergencyServicesApp(const EmergencyServicesScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Tap the first service card
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle();

        // Bottom sheet should appear with "Call Now" button
        expect(find.text('Call Now'), findsOneWidget);
      }
    });
  });

  group('EmergencyService Model Display', () {
    testWidgets('service card displays service name', (tester) async {
      await tester.pumpEmergencyServicesApp(const EmergencyServicesScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Check that service names are displayed
      expect(
        find.textContaining('Police', findRichText: true),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('service card displays phone number', (tester) async {
      await tester.pumpEmergencyServicesApp(const EmergencyServicesScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Check that phone numbers are displayed
      expect(
        find.textContaining('+1-212', findRichText: true),
        findsAtLeastNWidgets(1),
      );
    });
  });
}
