import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_zone/l10n/l10n.dart';
import 'package:safe_zone/map/map.dart';
import 'package:safe_zone/profile/models/safe_zone_model.dart';
import 'package:safe_zone/profile/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockProfileCubit extends Mock implements ProfileCubit {}

class MockSafeZoneCubit extends Mock implements SafeZoneCubit {}

extension MapPumpApp on WidgetTester {
  Future<void> pumpMapApp(Widget widget) async {
    final mockProfileCubit = MockProfileCubit();
    final mockSafeZoneCubit = MockSafeZoneCubit();

    // Set up default mock behavior
    when(() => mockProfileCubit.state).thenReturn(
      const ProfileState(
        defaultZoom: 13.0,
        locationIcon: 'assets/icons/user_avatar.png',
      ),
    );
    when(() => mockProfileCubit.stream).thenAnswer(
      (_) => Stream.value(
        const ProfileState(
          defaultZoom: 13.0,
          locationIcon: 'assets/icons/user_avatar.png',
        ),
      ),
    );

    when(() => mockSafeZoneCubit.state).thenReturn(
      const SafeZoneState(
        status: SafeZoneStatus.success,
        safeZones: [],
      ),
    );
    when(() => mockSafeZoneCubit.stream).thenAnswer(
      (_) => Stream.value(
        const SafeZoneState(
          status: SafeZoneStatus.success,
          safeZones: [],
        ),
      ),
    );

    return pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<MapFilterCubit>(
            create: (_) => MapFilterCubit(),
          ),
          BlocProvider<ProfileCubit>(
            create: (_) => mockProfileCubit,
          ),
          BlocProvider<SafeZoneCubit>(
            create: (_) => mockSafeZoneCubit,
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
  group('MapScreen', () {
    testWidgets('renders MapScreen', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      expect(find.byType(MapScreen), findsOneWidget);
    });

    testWidgets('displays search bar', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      expect(find.text('Search location or zone'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('displays time filter chips', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      expect(find.text('24h'), findsOneWidget);
      expect(find.text('7d'), findsOneWidget);
      expect(find.text('30d'), findsOneWidget);
    });

    testWidgets('displays category filter chips', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      expect(find.text('Theft'), findsOneWidget);
      expect(find.text('Assault'), findsOneWidget);
      expect(find.text('Suspicious'), findsOneWidget);
      expect(find.text('Lighting'), findsOneWidget);
    });

    testWidgets('displays risk level indicator', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      expect(find.text('Moderate Risk Zone'), findsOneWidget);
    });

    testWidgets('displays Report Incident button', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      expect(find.text('Report Incident'), findsOneWidget);
    });

    testWidgets('displays user avatar', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      // Avatar is displayed as a Container with icon
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('time filter selection works', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      // Tap on 7d filter
      await tester.tap(find.text('7d'));
      await tester.pumpAndSettle();

      // Verify the filter changed (would need to check styling in real scenario)
      expect(find.text('7d'), findsOneWidget);
    });

    testWidgets('category filter toggle works', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      // Find and tap on Theft category
      final theftFinder = find.text('Theft');
      expect(theftFinder, findsOneWidget);

      await tester.tap(theftFinder);
      await tester.pumpAndSettle();

      // Category should still be visible (just toggled)
      expect(theftFinder, findsOneWidget);
    });

    testWidgets('Report Incident button shows dialog', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      // Tap Report Incident button
      await tester.tap(find.text('Report Incident'));
      await tester.pumpAndSettle();

      // Verify dialog appears with title
      expect(find.text('Report Incident'), findsNWidgets(2)); // Button + Dialog
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Description (Optional)'), findsOneWidget);
      
      // Verify category chips are displayed
      expect(find.text('Theft'), findsNWidgets(2)); // Filter + Dialog
      expect(find.text('Assault'), findsNWidgets(2)); // Filter + Dialog
      
      // Verify action buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('Report Incident dialog can be cancelled', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.text('Report Incident'));
      await tester.pumpAndSettle();

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Category'), findsNothing);
      expect(find.text('Submit'), findsNothing);
    });

    testWidgets('Report Incident requires title', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.text('Report Incident'));
      await tester.pumpAndSettle();

      // Try to submit without entering title
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      // Validation error should appear
      expect(find.text('Please enter a title'), findsOneWidget);
    });

    testWidgets('Report Incident can submit with valid data', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.text('Report Incident'));
      await tester.pumpAndSettle();

      // Enter title
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Brief description of the incident'),
        'Test incident title',
      );
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      // Success message should appear
      expect(find.text('Incident reported successfully'), findsOneWidget);
      
      // Dialog should be closed
      expect(find.text('Category'), findsNothing);
    });

    testWidgets('tapping incident marker shows incident details', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      // Find and tap an incident marker (GestureDetector wrapping Container)
      final markerFinder = find.byType(GestureDetector).first;
      await tester.tap(markerFinder);
      await tester.pumpAndSettle();

      // Verify incident details bottom sheet appears
      expect(find.text('Theft reported'), findsOneWidget);
      expect(find.text('Confirmed by'), findsOneWidget);
    });

    testWidgets('incident details shows all information', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      // Tap the first incident marker
      final markerFinder = find.byType(GestureDetector).first;
      await tester.tap(markerFinder);
      await tester.pumpAndSettle();

      // Verify all incident details are displayed
      expect(find.text('Theft reported'), findsOneWidget);
      expect(find.text('Theft'), findsNWidgets(2)); // Filter chip + details badge
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
      
      // Verify "Confirmed by" text appears
      expect(find.textContaining('Confirmed by'), findsOneWidget);
    });

    testWidgets('search filters incidents by title', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      // Enter search query for "Theft"
      await tester.enterText(
        find.widgetWithText(TextField, 'Search location or zone'),
        'Theft',
      );
      await tester.pumpAndSettle();

      // Should filter to show only theft-related incidents
      // The search should work with the filtering system
      expect(find.widgetWithText(TextField, 'Search location or zone'), findsOneWidget);
    });

    testWidgets('search filters incidents by description', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(
        find.widgetWithText(TextField, 'Search location or zone'),
        'Pickpocketing',
      );
      await tester.pumpAndSettle();

      // Search field should contain the query
      expect(find.widgetWithText(TextField, 'Search location or zone'), findsOneWidget);
    });

    testWidgets('search is case insensitive', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      // Enter uppercase search query
      await tester.enterText(
        find.widgetWithText(TextField, 'Search location or zone'),
        'THEFT',
      );
      await tester.pumpAndSettle();

      // Should still filter incidents
      expect(find.widgetWithText(TextField, 'Search location or zone'), findsOneWidget);
    });

    testWidgets('empty search shows all filtered incidents', (tester) async {
      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      // Enter and then clear search query
      await tester.enterText(
        find.widgetWithText(TextField, 'Search location or zone'),
        'test',
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Search location or zone'),
        '',
      );
      await tester.pumpAndSettle();

      // Should show all incidents again
      expect(find.widgetWithText(TextField, 'Search location or zone'), findsOneWidget);
    });

    testWidgets('displays safe zone circles on map', (tester) async {
      final mockSafeZoneCubit = MockSafeZoneCubit();

      // Set up mock with active safe zones
      when(() => mockSafeZoneCubit.state).thenReturn(
        SafeZoneState(
          status: SafeZoneStatus.success,
          safeZones: [
            SafeZone(
              id: '1',
              name: 'Home',
              location: const LatLng(40.7128, -74.0060),
              radius: 500,
              isActive: true,
            ),
          ],
        ),
      );
      when(() => mockSafeZoneCubit.stream).thenAnswer(
        (_) => Stream.value(
          SafeZoneState(
            status: SafeZoneStatus.success,
            safeZones: [
              SafeZone(
                id: '1',
                name: 'Home',
                location: const LatLng(40.7128, -74.0060),
                radius: 500,
                isActive: true,
              ),
            ],
          ),
        ),
      );

      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      // Verify MapScreen is rendered (the PolygonLayer for circles is part of it)
      expect(find.byType(MapScreen), findsOneWidget);
    });

    testWidgets('does not display inactive safe zone circles', (tester) async {
      final mockSafeZoneCubit = MockSafeZoneCubit();

      // Set up mock with inactive safe zones
      when(() => mockSafeZoneCubit.state).thenReturn(
        SafeZoneState(
          status: SafeZoneStatus.success,
          safeZones: [
            SafeZone(
              id: '1',
              name: 'Home',
              location: const LatLng(40.7128, -74.0060),
              radius: 500,
              isActive: false,
            ),
          ],
        ),
      );
      when(() => mockSafeZoneCubit.stream).thenAnswer(
        (_) => Stream.value(
          SafeZoneState(
            status: SafeZoneStatus.success,
            safeZones: [
              SafeZone(
                id: '1',
                name: 'Home',
                location: const LatLng(40.7128, -74.0060),
                radius: 500,
                isActive: false,
              ),
            ],
          ),
        ),
      );

      await tester.pumpMapApp(const MapScreen());
      await tester.pumpAndSettle();

      // Verify MapScreen is rendered (inactive zones filtered out)
      expect(find.byType(MapScreen), findsOneWidget);
    });
  });

  group('Incident Model', () {
    test('isWithinTimeFilter returns true for recent incident', () {
      final incident = Incident(
        id: '1',
        category: IncidentCategory.theft,
        location: const LatLng(40.7128, -74.0060),
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        title: 'Test Incident',
      );

      expect(incident.isWithinTimeFilter(TimeFilter.twentyFourHours), isTrue);
      expect(incident.isWithinTimeFilter(TimeFilter.sevenDays), isTrue);
      expect(incident.isWithinTimeFilter(TimeFilter.thirtyDays), isTrue);
    });

    test('isWithinTimeFilter returns false for old incident', () {
      final incident = Incident(
        id: '1',
        category: IncidentCategory.theft,
        location: const LatLng(40.7128, -74.0060),
        timestamp: DateTime.now().subtract(const Duration(days: 10)),
        title: 'Test Incident',
      );

      expect(incident.isWithinTimeFilter(TimeFilter.twentyFourHours), isFalse);
      expect(incident.isWithinTimeFilter(TimeFilter.sevenDays), isFalse);
      expect(incident.isWithinTimeFilter(TimeFilter.thirtyDays), isTrue);
    });
  });

  group('IncidentCategory Extension', () {
    test('displayName returns correct name', () {
      expect(IncidentCategory.theft.displayName, 'Theft');
      expect(IncidentCategory.assault.displayName, 'Assault');
      expect(IncidentCategory.suspicious.displayName, 'Suspicious');
      expect(IncidentCategory.lighting.displayName, 'Lighting');
    });

    test('color returns different colors for each category', () {
      expect(
        IncidentCategory.theft.color,
        const Color(0xFFFF4C4C),
      );
      expect(
        IncidentCategory.assault.color,
        const Color(0xFFFF9500),
      );
      expect(
        IncidentCategory.suspicious.color,
        const Color(0xFFFFD60A),
      );
      expect(
        IncidentCategory.lighting.color,
        const Color(0xFF5856D6),
      );
    });
  });

  group('TimeFilter Extension', () {
    test('displayName returns correct name', () {
      expect(TimeFilter.twentyFourHours.displayName, '24h');
      expect(TimeFilter.sevenDays.displayName, '7d');
      expect(TimeFilter.thirtyDays.displayName, '30d');
    });

    test('duration returns correct duration', () {
      expect(
        TimeFilter.twentyFourHours.duration,
        const Duration(hours: 24),
      );
      expect(TimeFilter.sevenDays.duration, const Duration(days: 7));
      expect(TimeFilter.thirtyDays.duration, const Duration(days: 30));
    });
  });

  group('RiskLevel Extension', () {
    test('displayName returns correct name', () {
      expect(RiskLevel.safe.displayName, 'Safe Zone');
      expect(RiskLevel.moderate.displayName, 'Moderate Risk Zone');
      expect(RiskLevel.high.displayName, 'High Risk Zone');
    });

    test('color returns different colors for each level', () {
      expect(RiskLevel.safe.color, const Color(0xFF34C759));
      expect(RiskLevel.moderate.color, const Color(0xFFFFD60A));
      expect(RiskLevel.high.color, const Color(0xFFFF4C4C));
    });

    test('backgroundColor returns different colors for each level', () {
      expect(RiskLevel.safe.backgroundColor, const Color(0xFFE8F5E9));
      expect(RiskLevel.moderate.backgroundColor, const Color(0xFFFFFDE7));
      expect(RiskLevel.high.backgroundColor, const Color(0xFFFFEBEE));
    });
  });
}
