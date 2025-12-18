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
      expect(find.text('Report Accident'), findsOneWidget);
    });

    testWidgets('displays title and description fields', (tester) async {
      await tester.pumpReportIncidentApp(
        onSubmit: (category, title, description, notifyNearby) {},
      );
      await tester.pumpAndSettle();

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Description (Optional)'), findsOneWidget);
      expect(
        find.text('Brief description of the accident'),
        findsOneWidget,
      );
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

    testWidgets('validates title field is required', (tester) async {
      await tester.pumpReportIncidentApp(
        onSubmit: (category, title, description, notifyNearby) {},
      );
      await tester.pumpAndSettle();

      // Tap submit without entering title
      await tester.tap(find.text('Submit Report'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a title'), findsOneWidget);
    });

    testWidgets('calls onSubmit with correct data', (tester) async {
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

      // Enter title
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Brief description of the accident'),
        'Test Accident',
      );

      // Enter description
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Add more details about what happened...',
        ),
        'Test Description',
      );

      // Submit
      await tester.tap(find.text('Submit Report'));
      await tester.pumpAndSettle();

      expect(submittedCategory, IncidentCategory.accident);
      expect(submittedTitle, 'Test Accident');
      expect(submittedDescription, 'Test Description');
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
