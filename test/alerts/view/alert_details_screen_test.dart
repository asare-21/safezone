import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_zone/alerts/alerts.dart';
import 'package:safe_zone/home/home.dart';
import 'package:safe_zone/l10n/l10n.dart';

class MockBottomNavigationCubit extends MockCubit<BottomNavigationState>
    implements BottomNavigationCubit {}

extension AlertDetailsPumpApp on WidgetTester {
  Future<void> pumpAlertDetailsApp(Widget widget) {
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
  group('AlertDetailsScreen', () {
    late Alert testAlert;

    setUp(() {
      testAlert = Alert(
        id: '1',
        type: AlertType.highRisk,
        severity: AlertSeverity.high,
        title: 'Entering High-Risk Area',
        location: 'Market St & 5th Ave',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        icon: Icons.warning,
        iconColor: const Color(0xFFFF4C4C),
        iconBackgroundColor: const Color(0xFFFFF0F0),
      );
    });

    testWidgets('renders AlertDetailsScreen', (tester) async {
      await tester.pumpAlertDetailsApp(AlertDetailsScreen(alert: testAlert));

      expect(find.text('Alert Details'), findsOneWidget);
    });

    testWidgets('displays alert title', (tester) async {
      await tester.pumpAlertDetailsApp(AlertDetailsScreen(alert: testAlert));

      expect(find.text('Entering High-Risk Area'), findsOneWidget);
    });

    testWidgets('displays alert severity', (tester) async {
      await tester.pumpAlertDetailsApp(AlertDetailsScreen(alert: testAlert));

      expect(find.text('High Severity'), findsOneWidget);
    });

    testWidgets('displays alert location', (tester) async {
      await tester.pumpAlertDetailsApp(AlertDetailsScreen(alert: testAlert));

      expect(find.text('Market St & 5th Ave'), findsOneWidget);
    });

    testWidgets('displays Information section', (tester) async {
      await tester.pumpAlertDetailsApp(AlertDetailsScreen(alert: testAlert));

      expect(find.text('Information'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Reported'), findsOneWidget);
      expect(find.text('Type'), findsOneWidget);
    });

    testWidgets('displays Description section', (tester) async {
      await tester.pumpAlertDetailsApp(AlertDetailsScreen(alert: testAlert));

      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('displays View on Map button', (tester) async {
      await tester.pumpAlertDetailsApp(AlertDetailsScreen(alert: testAlert));

      expect(find.text('View on Map'), findsOneWidget);
      expect(find.byIcon(Icons.map), findsOneWidget);
    });

    testWidgets('displays back button', (tester) async {
      await tester.pumpAlertDetailsApp(AlertDetailsScreen(alert: testAlert));

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('displays confirmed by when provided', (tester) async {
      final alertWithConfirmation = Alert(
        id: '2',
        type: AlertType.theft,
        severity: AlertSeverity.medium,
        title: 'Recent Theft Reported',
        location: 'Central Park Entrance',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        confirmedBy: 3,
        icon: Icons.star,
        iconColor: const Color(0xFFFF9500),
        iconBackgroundColor: const Color(0xFFFFF4E5),
      );

      await tester.pumpAlertDetailsApp(
        AlertDetailsScreen(alert: alertWithConfirmation),
      );

      expect(find.text('Confirmed By'), findsOneWidget);
      expect(find.text('3 users'), findsOneWidget);
    });

    testWidgets('displays correct type text for each alert type',
        (tester) async {
      final alertTypes = [
        (AlertType.highRisk, 'High Risk Area'),
        (AlertType.theft, 'Theft'),
        (AlertType.eventCrowd, 'Event Crowd'),
        (AlertType.trafficCleared, 'Traffic Cleared'),
      ];

      for (final (type, expectedText) in alertTypes) {
        final alert = Alert(
          id: '1',
          type: type,
          severity: AlertSeverity.high,
          title: 'Test Alert',
          location: 'Test Location',
          timestamp: DateTime.now(),
        );

        await tester.pumpAlertDetailsApp(AlertDetailsScreen(alert: alert));
        expect(find.text(expectedText), findsOneWidget);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('displays correct severity text for each severity level',
        (tester) async {
      final severityLevels = [
        (AlertSeverity.high, 'High Severity'),
        (AlertSeverity.medium, 'Medium Severity'),
        (AlertSeverity.low, 'Low Severity'),
        (AlertSeverity.info, 'Informational'),
      ];

      for (final (severity, expectedText) in severityLevels) {
        final alert = Alert(
          id: '1',
          type: AlertType.highRisk,
          severity: severity,
          title: 'Test Alert',
          location: 'Test Location',
          timestamp: DateTime.now(),
        );

        await tester.pumpAlertDetailsApp(AlertDetailsScreen(alert: alert));
        expect(find.text(expectedText), findsOneWidget);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('back button pops the screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          AlertDetailsScreen(alert: testAlert),
                    ),
                  );
                },
                child: const Text('Open Details'),
              ),
            ),
          ),
        ),
      );

      // Open the details screen
      await tester.tap(find.text('Open Details'));
      await tester.pumpAndSettle();

      // Verify we're on the details screen
      expect(find.text('Alert Details'), findsOneWidget);

      // Tap the back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back on the original screen
      expect(find.text('Alert Details'), findsNothing);
      expect(find.text('Open Details'), findsOneWidget);
    });

    testWidgets('View on Map button navigates to map and pops screen',
        (tester) async {
      final mockCubit = MockBottomNavigationCubit();
      when(() => mockCubit.state).thenReturn(const BottomNavigationState());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<BottomNavigationCubit>.value(
            value: mockCubit,
            child: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) =>
                            AlertDetailsScreen(alert: testAlert),
                      ),
                    );
                  },
                  child: const Text('Open Details'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open the details screen
      await tester.tap(find.text('Open Details'));
      await tester.pumpAndSettle();

      // Verify we're on the details screen
      expect(find.text('Alert Details'), findsOneWidget);

      // Tap the "View on Map" button
      await tester.tap(find.text('View on Map'));
      await tester.pumpAndSettle();

      // Verify navigateToMap was called
      verify(() => mockCubit.navigateToMap()).called(1);

      // Verify we're back on the original screen (screen was popped)
      expect(find.text('Alert Details'), findsNothing);
      expect(find.text('Open Details'), findsOneWidget);
    });
  });
}
