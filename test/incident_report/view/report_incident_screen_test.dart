import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_zone/incident_report/incident_report.dart';
import 'package:safe_zone/l10n/l10n.dart';
import 'package:safe_zone/map/models/incident_model.dart';

extension ReportIncidentPumpApp on WidgetTester {
  Future<void> pumpReportIncidentApp({
    required void Function(
      IncidentCategory category,
      String title,
      String description,
      bool notifyNearby,
    ) onSubmit,
  }) {
    return pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ReportIncidentScreen(onSubmit: onSubmit),
      ),
    );
  }
}

void main() {
  group('ReportIncidentScreen', () {
    testWidgets('renders ReportIncidentScreen', (tester) async {
      await tester.pumpReportIncidentApp(
        onSubmit: (category, title, description, notifyNearby) {},
      );
      await tester.pumpAndSettle();

      expect(find.byType(ReportIncidentScreen), findsOneWidget);
      expect(find.text('Report Incident'), findsOneWidget);
    });

    testWidgets('displays category selection', (tester) async {
      await tester.pumpReportIncidentApp(
        onSubmit: (category, title, description, notifyNearby) {},
      );
      await tester.pumpAndSettle();

      expect(find.text('Select Incident Category'), findsOneWidget);
      // Should display all 18 categories
      expect(find.text('Accident'), findsOneWidget);
      expect(find.text('Fire'), findsOneWidget);
      expect(find.text('Theft'), findsOneWidget);
      expect(find.text('Suspicious Activity'), findsOneWidget);
      expect(find.text('Lighting Issue'), findsOneWidget);
      expect(find.text('Assault'), findsOneWidget);
      expect(find.text('Vandalism'), findsOneWidget);
      expect(find.text('Harassment'), findsOneWidget);
      expect(find.text('Road Hazard'), findsOneWidget);
      expect(find.text('Animal Danger'), findsOneWidget);
      expect(find.text('Medical Emergency'), findsOneWidget);
      expect(find.text('Natural Disaster'), findsOneWidget);
      expect(find.text('Power Outage'), findsOneWidget);
      expect(find.text('Water Issue'), findsOneWidget);
      expect(find.text('Noise Complaint'), findsOneWidget);
      expect(find.text('Trespassing'), findsOneWidget);
      expect(find.text('Drug Activity'), findsOneWidget);
      expect(find.text('Weapon Sighting'), findsOneWidget);
    });

    testWidgets('displays notify nearby toggle', (tester) async {
      await tester.pumpReportIncidentApp(
        onSubmit: (category, title, description, notifyNearby) {},
      );
      await tester.pumpAndSettle();

      expect(find.text('Notify Nearby Users'), findsOneWidget);
      expect(
        find.text('Alert community members in this area'),
        findsOneWidget,
      );
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('notify nearby toggle is enabled by default', (tester) async {
      await tester.pumpReportIncidentApp(
        onSubmit: (category, title, description, notifyNearby) {},
      );
      await tester.pumpAndSettle();

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('can toggle notify nearby switch', (tester) async {
      await tester.pumpReportIncidentApp(
        onSubmit: (category, title, description, notifyNearby) {},
      );
      await tester.pumpAndSettle();

      // Initially enabled
      var switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);

      // Tap to disable
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    });

    testWidgets('can select a category', (tester) async {
      await tester.pumpReportIncidentApp(
        onSubmit: (category, title, description, notifyNearby) {},
      );
      await tester.pumpAndSettle();

      // Tap on Fire category
      await tester.tap(find.text('Fire'));
      await tester.pumpAndSettle();

      // Should show check icon for selected category
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('submit button is disabled when no category selected', 
        (tester) async {
      await tester.pumpReportIncidentApp(
        onSubmit: (category, title, description, notifyNearby) {},
      );
      await tester.pumpAndSettle();

      final submitButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Submit Report'),
      );
      expect(submitButton.onPressed, isNull);
    });

    testWidgets('calls onSubmit with correct auto-generated data', 
        (tester) async {
      IncidentCategory? submittedCategory;
      String? submittedTitle;
      String? submittedDescription;
      bool? submittedNotifyNearby;

      await tester.pumpReportIncidentApp(
        onSubmit: (category, title, description, notifyNearby) {
          submittedCategory = category;
          submittedTitle = title;
          submittedDescription = description;
          submittedNotifyNearby = notifyNearby;
        },
      );
      await tester.pumpAndSettle();

      // Select Theft category
      await tester.tap(find.text('Theft'));
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Submit Report'));
      await tester.pumpAndSettle();

      expect(submittedCategory, IncidentCategory.theft);
      expect(submittedTitle, 'Theft');
      expect(submittedDescription, 
          'A theft incident has been reported in this area');
      expect(submittedNotifyNearby, isTrue);
    });

    testWidgets('calls onSubmit with correct data for new categories', 
        (tester) async {
      IncidentCategory? submittedCategory;
      String? submittedTitle;
      String? submittedDescription;
      bool? submittedNotifyNearby;

      await tester.pumpReportIncidentApp(
        onSubmit: (category, title, description, notifyNearby) {
          submittedCategory = category;
          submittedTitle = title;
          submittedDescription = description;
          submittedNotifyNearby = notifyNearby;
        },
      );
      await tester.pumpAndSettle();

      // Select Medical Emergency category
      await tester.tap(find.text('Medical Emergency'));
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Submit Report'));
      await tester.pumpAndSettle();

      expect(submittedCategory, IncidentCategory.medicalEmergency);
      expect(submittedTitle, 'Medical Emergency');
      expect(submittedDescription, 
          'A medical emergency has been reported in this area');
      expect(submittedNotifyNearby, isTrue);
    });

    testWidgets('displays info banner', (tester) async {
      await tester.pumpReportIncidentApp(
        onSubmit: (category, title, description, notifyNearby) {},
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Your report helps keep the community safe'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('has close button in app bar', (tester) async {
      await tester.pumpReportIncidentApp(
        onSubmit: (category, title, description, notifyNearby) {},
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
