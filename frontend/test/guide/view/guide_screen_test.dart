import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_zone/guide/guide.dart';
import 'package:safe_zone/l10n/l10n.dart';

class MockGuideCubit extends MockCubit<GuideState> implements GuideCubit {}

extension GuidePumpApp on WidgetTester {
  Future<void> pumpGuideApp(
    Widget widget, {
    GuideCubit? guideCubit,
  }) {
    return pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: guideCubit != null
            ? BlocProvider<GuideCubit>.value(
                value: guideCubit,
                child: widget,
              )
            : widget,
      ),
    );
  }
}

void main() {
  late MockGuideCubit mockGuideCubit;

  setUp(() {
    mockGuideCubit = MockGuideCubit();
  });

  group('GuideScreen', () {
    final testGuides = [
      Guide(
        id: 1,
        section: GuideSection.howItWorks,
        title: 'Crowdsourced Safety',
        content:
            'SafeZone uses community-reported incidents to create a real-time safety network.',
        icon: 'shield',
        order: 1,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Guide(
        id: 2,
        section: GuideSection.howItWorks,
        title: 'Proximity Alerts',
        content: 'Get notified automatically when you approach areas.',
        icon: 'map_marker',
        order: 2,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final testGuidesBySection = <GuideSection, List<Guide>>{
      GuideSection.howItWorks: testGuides,
    };

    testWidgets('renders GuideScreen with header', (tester) async {
      when(() => mockGuideCubit.state).thenReturn(const GuideInitial());

      await tester.pumpGuideApp(
        const GuideScreen(),
        guideCubit: mockGuideCubit,
      );

      expect(find.text('Safety Guide'), findsOneWidget);
    });

    testWidgets('displays loading indicator when state is GuideLoading',
        (tester) async {
      when(() => mockGuideCubit.state).thenReturn(const GuideLoading());

      await tester.pumpGuideApp(
        const GuideScreen(),
        guideCubit: mockGuideCubit,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message when state is GuideError',
        (tester) async {
      when(() => mockGuideCubit.state)
          .thenReturn(const GuideError('Failed to load guides'));

      await tester.pumpGuideApp(
        const GuideScreen(),
        guideCubit: mockGuideCubit,
      );

      expect(find.text('Failed to load guides'), findsOneWidget);
      expect(find.text('Failed to load guides: Failed to load guides'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('displays guides when state is GuideLoaded', (tester) async {
      when(() => mockGuideCubit.state).thenReturn(
        GuideLoaded(
          guides: testGuides,
          guidesBySection: testGuidesBySection,
        ),
      );

      await tester.pumpGuideApp(
        const GuideScreen(),
        guideCubit: mockGuideCubit,
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome to SafeZone'), findsOneWidget);
      expect(find.text('Crowdsourced Safety'), findsOneWidget);
      expect(find.text('Proximity Alerts'), findsOneWidget);
    });

    testWidgets('calls refreshGuides when refresh icon is tapped',
        (tester) async {
      when(() => mockGuideCubit.state).thenReturn(
        GuideLoaded(
          guides: testGuides,
          guidesBySection: testGuidesBySection,
        ),
      );
      when(() => mockGuideCubit.refreshGuides()).thenAnswer((_) async {});

      await tester.pumpGuideApp(
        const GuideScreen(),
        guideCubit: mockGuideCubit,
      );

      final refreshButton = find.byIcon(Icons.sync);
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pump();

      verify(() => mockGuideCubit.refreshGuides()).called(1);
    });

    testWidgets('calls loadGuides when retry button is tapped',
        (tester) async {
      when(() => mockGuideCubit.state)
          .thenReturn(const GuideError('Network error'));
      when(() => mockGuideCubit.loadGuides()).thenAnswer((_) async {});

      await tester.pumpGuideApp(
        const GuideScreen(),
        guideCubit: mockGuideCubit,
      );

      final retryButton = find.text('Retry');
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      await tester.pump();

      verify(() => mockGuideCubit.loadGuides()).called(1);
    });

    testWidgets('displays welcome card', (tester) async {
      when(() => mockGuideCubit.state).thenReturn(
        GuideLoaded(
          guides: testGuides,
          guidesBySection: testGuidesBySection,
        ),
      );

      await tester.pumpGuideApp(
        const GuideScreen(),
        guideCubit: mockGuideCubit,
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome to SafeZone'), findsOneWidget);
      expect(
        find.text(
          'Your comprehensive guide to staying safe with community-powered alerts and real-time incident reporting.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays support card', (tester) async {
      when(() => mockGuideCubit.state).thenReturn(
        GuideLoaded(
          guides: testGuides,
          guidesBySection: testGuidesBySection,
        ),
      );

      await tester.pumpGuideApp(
        const GuideScreen(),
        guideCubit: mockGuideCubit,
      );
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
      when(() => mockGuideCubit.state).thenReturn(
        GuideLoaded(
          guides: testGuides,
          guidesBySection: testGuidesBySection,
        ),
      );

      await tester.pumpGuideApp(
        const GuideScreen(),
        guideCubit: mockGuideCubit,
      );

      // Verify SingleChildScrollView is present
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('supports pull to refresh', (tester) async {
      when(() => mockGuideCubit.state).thenReturn(
        GuideLoaded(
          guides: testGuides,
          guidesBySection: testGuidesBySection,
        ),
      );
      when(() => mockGuideCubit.refreshGuides()).thenAnswer((_) async {});

      await tester.pumpGuideApp(
        const GuideScreen(),
        guideCubit: mockGuideCubit,
      );
      await tester.pumpAndSettle();

      // Find RefreshIndicator
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
