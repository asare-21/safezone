import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_zone/l10n/l10n.dart';
import 'package:safe_zone/map/models/incident_model.dart';
import 'package:safe_zone/profile/cubit/incident_history_cubit.dart';
import 'package:safe_zone/profile/models/user_incident_model.dart';
import 'package:safe_zone/profile/models/user_score_model.dart';
import 'package:safe_zone/profile/view/incident_history_screen.dart';

class MockIncidentHistoryCubit extends MockCubit<IncidentHistoryState>
    implements IncidentHistoryCubit {}

extension IncidentHistoryPumpApp on WidgetTester {
  Future<void> pumpIncidentHistoryApp(
    Widget widget, {
    IncidentHistoryCubit? cubit,
  }) {
    return pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<IncidentHistoryCubit>.value(
          value: cubit ?? MockIncidentHistoryCubit(),
          child: widget,
        ),
      ),
    );
  }
}

List<ReportedIncident> getMockReportedIncidents() {
  return [
    ReportedIncident(
      id: 1,
      category: 'theft',
      title: 'Bike theft at shopping district',
      description: 'Witnessed a bike being stolen from the rack.',
      latitude: 40.7580,
      longitude: -73.9855,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      confirmedBy: 8,
      status: 'verified',
      impactScore: 25,
    ),
    ReportedIncident(
      id: 2,
      category: 'suspicious',
      title: 'Suspicious activity near parking lot',
      description: 'Group of individuals acting suspiciously.',
      latitude: 40.7614,
      longitude: -73.9776,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      confirmedBy: 2,
      status: 'pending',
      impactScore: 10,
    ),
    ReportedIncident(
      id: 3,
      category: 'lighting',
      title: 'Broken street lights in tunnel',
      description: 'Multiple street lights are out in the tunnel.',
      latitude: 40.7489,
      longitude: -73.9680,
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      confirmedBy: 15,
      status: 'verified',
      impactScore: 40,
    ),
  ];
}

void main() {
  late MockIncidentHistoryCubit mockCubit;

  setUp(() {
    mockCubit = MockIncidentHistoryCubit();
  });

  group('IncidentHistoryScreen', () {
    testWidgets('renders IncidentHistoryScreen with app bar', (tester) async {
      when(() => mockCubit.state).thenReturn(IncidentHistoryInitial());

      await tester.pumpIncidentHistoryApp(
        const IncidentHistoryScreen(),
        cubit: mockCubit,
      );

      expect(find.text('My Incident History'), findsOneWidget);
    });

    testWidgets('displays loading indicator when loading', (tester) async {
      when(() => mockCubit.state).thenReturn(IncidentHistoryLoading());

      await tester.pumpIncidentHistoryApp(
        const IncidentHistoryScreen(),
        cubit: mockCubit,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error state with retry button', (tester) async {
      when(() => mockCubit.state).thenReturn(
        const IncidentHistoryError('Network error'),
      );

      await tester.pumpIncidentHistoryApp(
        const IncidentHistoryScreen(),
        cubit: mockCubit,
      );

      expect(find.text('Failed to load incidents'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('displays statistics cards when loaded', (tester) async {
      when(() => mockCubit.state).thenReturn(
        IncidentHistoryLoaded(getMockReportedIncidents()),
      );

      await tester.pumpIncidentHistoryApp(
        const IncidentHistoryScreen(),
        cubit: mockCubit,
      );

      expect(find.text('Total Reports'), findsOneWidget);
      expect(find.text('Verified'), findsWidgets);
      expect(find.text('Impact Score'), findsOneWidget);
    });

    testWidgets('displays Your Reports section when loaded', (tester) async {
      when(() => mockCubit.state).thenReturn(
        IncidentHistoryLoaded(getMockReportedIncidents()),
      );

      await tester.pumpIncidentHistoryApp(
        const IncidentHistoryScreen(),
        cubit: mockCubit,
      );

      expect(find.text('Your Reports'), findsOneWidget);
      expect(find.textContaining('INCIDENTS'), findsOneWidget);
    });

    testWidgets('displays incident cards when loaded', (tester) async {
      when(() => mockCubit.state).thenReturn(
        IncidentHistoryLoaded(getMockReportedIncidents()),
      );

      await tester.pumpIncidentHistoryApp(
        const IncidentHistoryScreen(),
        cubit: mockCubit,
      );

      expect(find.text('Bike theft at shopping district'), findsOneWidget);
      expect(find.text('Suspicious activity near parking lot'), findsOneWidget);
      expect(find.text('Broken street lights in tunnel'), findsOneWidget);
    });

    testWidgets('displays correct status badges when loaded', (tester) async {
      when(() => mockCubit.state).thenReturn(
        IncidentHistoryLoaded(getMockReportedIncidents()),
      );

      await tester.pumpIncidentHistoryApp(
        const IncidentHistoryScreen(),
        cubit: mockCubit,
      );

      expect(find.text('Verified'), findsWidgets);
      expect(find.text('Pending'), findsWidgets);
    });

    testWidgets('displays empty state when no incidents', (tester) async {
      when(() => mockCubit.state).thenReturn(
        const IncidentHistoryLoaded([]),
      );

      await tester.pumpIncidentHistoryApp(
        const IncidentHistoryScreen(),
        cubit: mockCubit,
      );

      expect(find.text('No Incidents Yet'), findsOneWidget);
    });

    testWidgets('navigates to incident detail when card is tapped',
        (tester) async {
      when(() => mockCubit.state).thenReturn(
        IncidentHistoryLoaded(getMockReportedIncidents()),
      );

      await tester.pumpIncidentHistoryApp(
        const IncidentHistoryScreen(),
        cubit: mockCubit,
      );

      // Find and tap the first incident card
      final incidentCard = find.text('Bike theft at shopping district');
      expect(incidentCard, findsOneWidget);

      await tester.tap(incidentCard);
      await tester.pumpAndSettle();

      // Verify navigation to incident detail screen
      expect(find.text('Incident Details'), findsOneWidget);
      expect(find.text('Bike theft at shopping district'), findsOneWidget);
    });

    testWidgets('displays incident confirmations', (tester) async {
      when(() => mockCubit.state).thenReturn(
        IncidentHistoryLoaded(getMockReportedIncidents()),
      );

      await tester.pumpIncidentHistoryApp(
        const IncidentHistoryScreen(),
        cubit: mockCubit,
      );

      expect(find.textContaining('confirmed'), findsWidgets);
      expect(find.textContaining('pts'), findsWidgets);
    });
  });

  group('IncidentDetailScreen', () {
    testWidgets('displays incident details correctly', (tester) async {
      when(() => mockCubit.state).thenReturn(
        IncidentHistoryLoaded(getMockReportedIncidents()),
      );

      await tester.pumpIncidentHistoryApp(
        const IncidentHistoryScreen(),
        cubit: mockCubit,
      );

      // Navigate to detail screen
      await tester.tap(find.text('Bike theft at shopping district'));
      await tester.pumpAndSettle();

      expect(find.text('Incident Details'), findsOneWidget);
      expect(find.text('Bike theft at shopping district'), findsOneWidget);
      expect(find.text('Information'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('displays information fields', (tester) async {
      when(() => mockCubit.state).thenReturn(
        IncidentHistoryLoaded(getMockReportedIncidents()),
      );

      await tester.pumpIncidentHistoryApp(
        const IncidentHistoryScreen(),
        cubit: mockCubit,
      );

      // Navigate to detail screen
      await tester.tap(find.text('Bike theft at shopping district'));
      await tester.pumpAndSettle();

      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Date Reported'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('Confirmed By'), findsOneWidget);
      expect(find.text('Impact Score'), findsOneWidget);
    });

    testWidgets('back button navigates back to history screen', (tester) async {
      when(() => mockCubit.state).thenReturn(
        IncidentHistoryLoaded(getMockReportedIncidents()),
      );

      await tester.pumpIncidentHistoryApp(
        const IncidentHistoryScreen(),
        cubit: mockCubit,
      );

      // Navigate to detail screen
      await tester.tap(find.text('Bike theft at shopping district'));
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back).first);
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
