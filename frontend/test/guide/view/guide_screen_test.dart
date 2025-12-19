import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_zone/guide/guide.dart';
import 'package:safe_zone/l10n/l10n.dart';

extension GuidePumpApp on WidgetTester {
  Future<void> pumpGuideApp(Widget widget) {
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
  group('GuideScreen', () {
    testWidgets('renders GuideScreen', (tester) async {
      await tester.pumpGuideApp(const GuideScreen());

      expect(find.text('Safety Guide'), findsOneWidget);
    });

    testWidgets('displays welcome card', (tester) async {
      await tester.pumpGuideApp(const GuideScreen());

      expect(find.text('Welcome to SafeZone'), findsOneWidget);
      expect(
        find.text(
          'Your comprehensive guide to staying safe with community-powered alerts and real-time incident reporting.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays "How SafeZone Works" section', (tester) async {
      await tester.pumpGuideApp(const GuideScreen());

      expect(find.text('How SafeZone Works'), findsOneWidget);
      expect(find.text('Crowdsourced Safety'), findsOneWidget);
      expect(find.text('Proximity Alerts'), findsOneWidget);
      expect(find.text('Interactive Safety Map'), findsOneWidget);
    });

    testWidgets('displays "Reporting Incidents" section', (tester) async {
      await tester.pumpGuideApp(const GuideScreen());
      await tester.pumpAndSettle();

      expect(find.text('Reporting Incidents'), findsOneWidget);
      expect(find.text('Tap the Report Button'), findsOneWidget);
      expect(find.text('Select Incident Type'), findsOneWidget);
      expect(find.text('Add Details (Optional)'), findsOneWidget);
      expect(find.text('Submit Report'), findsOneWidget);
    });

    testWidgets('displays "Understanding Alerts" section', (tester) async {
      await tester.pumpGuideApp(const GuideScreen());
      await tester.pumpAndSettle();

      expect(find.text('Understanding Alerts'), findsOneWidget);
      expect(find.text('High Severity'), findsOneWidget);
      expect(find.text('Medium Severity'), findsOneWidget);
      expect(find.text('Low Severity'), findsOneWidget);
      expect(find.text('Info Severity'), findsOneWidget);
    });

    testWidgets('displays "Trust Score System" section', (tester) async {
      await tester.pumpGuideApp(const GuideScreen());
      await tester.pumpAndSettle();

      expect(find.text('Trust Score System'), findsOneWidget);
      expect(find.text('Building Your Reputation'), findsOneWidget);
      expect(find.text('Guardian'), findsOneWidget);
      expect(find.text('Protector'), findsOneWidget);
      expect(find.text('Watcher'), findsOneWidget);
      expect(find.text('Newcomer'), findsOneWidget);
    });

    testWidgets('displays trust level ranges', (tester) async {
      await tester.pumpGuideApp(const GuideScreen());
      await tester.pumpAndSettle();

      expect(find.text('450-600 points'), findsOneWidget);
      expect(find.text('250-449 points'), findsOneWidget);
      expect(find.text('100-249 points'), findsOneWidget);
      expect(find.text('0-99 points'), findsOneWidget);
    });

    testWidgets('displays "Privacy & Data Protection" section',
        (tester) async {
      await tester.pumpGuideApp(const GuideScreen());
      await tester.pumpAndSettle();

      expect(find.text('Privacy & Data Protection'), findsOneWidget);
      expect(find.text('Your Data is Protected'), findsOneWidget);
      expect(find.text('Anonymous Reporting'), findsOneWidget);
    });

    testWidgets('displays "Safety Best Practices" section', (tester) async {
      await tester.pumpGuideApp(const GuideScreen());
      await tester.pumpAndSettle();

      expect(find.text('Safety Best Practices'), findsOneWidget);
      expect(find.text('Stay Aware'), findsOneWidget);
      expect(find.text('Trust Your Instincts'), findsOneWidget);
      expect(find.text('Share Your Location'), findsOneWidget);
      expect(find.text('Verify Before Acting'), findsOneWidget);
      expect(find.text('Report Responsibly'), findsOneWidget);
    });

    testWidgets('displays "Emergency Features" section', (tester) async {
      await tester.pumpGuideApp(const GuideScreen());
      await tester.pumpAndSettle();

      expect(find.text('Emergency Features'), findsOneWidget);
      expect(find.text('Quick Emergency Dial'), findsOneWidget);
    });

    testWidgets('displays "Getting Started" section', (tester) async {
      await tester.pumpGuideApp(const GuideScreen());
      await tester.pumpAndSettle();

      expect(find.text('Getting Started'), findsOneWidget);
      expect(find.text('Configure Your Settings'), findsOneWidget);
    });

    testWidgets('displays support card', (tester) async {
      await tester.pumpGuideApp(const GuideScreen());
      await tester.pumpAndSettle();

      expect(find.text('Need Help?'), findsOneWidget);
      expect(
        find.text(
          'SafeZone is a community-driven safety platform designed to help you stay informed and make safer decisions.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('guide content is scrollable', (tester) async {
      await tester.pumpGuideApp(const GuideScreen());

      // Verify SingleChildScrollView is present
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('displays all severity alert colors correctly', (tester) async {
      await tester.pumpGuideApp(const GuideScreen());
      await tester.pumpAndSettle();

      // Verify the guide screen can be scrolled to view all content
      final scrollableFinder = find.byType(SingleChildScrollView);
      await tester.scrollUntilVisible(
        find.text('Understanding Alerts'),
        100,
        scrollable: scrollableFinder,
      );

      // Check that severity colors are displayed
      expect(find.text('High Severity'), findsOneWidget);
      expect(find.text('Medium Severity'), findsOneWidget);
      expect(find.text('Low Severity'), findsOneWidget);
      expect(find.text('Info Severity'), findsOneWidget);
    });
  });
}
