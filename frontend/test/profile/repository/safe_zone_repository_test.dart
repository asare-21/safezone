import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_zone/profile/models/safe_zone_model.dart';
import 'package:safe_zone/profile/repository/safe_zone_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('SafeZoneRepository', () {
    late MockSharedPreferences mockSharedPreferences;
    late SafeZoneRepository repository;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      repository = SafeZoneRepository(
        sharedPreferences: mockSharedPreferences,
      );
    });

    group('loadSafeZones', () {
      test('returns empty list when no data is stored', () async {
        when(() => mockSharedPreferences.getString(any())).thenReturn(null);

        final zones = await repository.loadSafeZones();

        expect(zones, isEmpty);
      });

      test('returns list of safe zones when data is stored', () async {
        const jsonString = '''
          [
            {
              "id": "1",
              "name": "Home",
              "latitude": 37.7749,
              "longitude": -122.4194,
              "radius": 500.0,
              "type": "home",
              "isActive": true,
              "notifyOnEnter": true,
              "notifyOnExit": true
            },
            {
              "id": "2",
              "name": "Work",
              "latitude": 37.7849,
              "longitude": -122.4294,
              "radius": 1000.0,
              "type": "work",
              "isActive": false,
              "notifyOnEnter": false,
              "notifyOnExit": true
            }
          ]
        ''';

        when(() => mockSharedPreferences.getString(any()))
            .thenReturn(jsonString);

        final zones = await repository.loadSafeZones();

        expect(zones.length, 2);
        expect(zones[0].id, '1');
        expect(zones[0].name, 'Home');
        expect(zones[1].id, '2');
        expect(zones[1].name, 'Work');
      });

      test('returns empty list when JSON parsing fails', () async {
        when(() => mockSharedPreferences.getString(any()))
            .thenReturn('invalid json');

        final zones = await repository.loadSafeZones();

        expect(zones, isEmpty);
      });
    });

    group('saveSafeZones', () {
      test('saves safe zones to shared preferences', () async {
        final zones = [
          const SafeZone(
            id: '1',
            name: 'Home',
            location: LatLng(37.7749, -122.4194),
            radius: 500,
          ),
        ];

        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        await repository.saveSafeZones(zones);

        verify(
          () => mockSharedPreferences.setString(
            'safe_zones',
            any(),
          ),
        ).called(1);
      });
    });

    group('addSafeZone', () {
      test('adds a safe zone to existing list', () async {
        const existingJsonString = '''
          [
            {
              "id": "1",
              "name": "Home",
              "latitude": 37.7749,
              "longitude": -122.4194,
              "radius": 500.0,
              "type": "home",
              "isActive": true,
              "notifyOnEnter": true,
              "notifyOnExit": true
            }
          ]
        ''';

        when(() => mockSharedPreferences.getString(any()))
            .thenReturn(existingJsonString);
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        const newZone = SafeZone(
          id: '2',
          name: 'Work',
          location: LatLng(37.7849, -122.4294),
          radius: 1000,
        );

        await repository.addSafeZone(newZone);

        verify(
          () => mockSharedPreferences.setString('safe_zones', any()),
        ).called(1);
      });
    });

    group('updateSafeZone', () {
      test('updates an existing safe zone', () async {
        const existingJsonString = '''
          [
            {
              "id": "1",
              "name": "Home",
              "latitude": 37.7749,
              "longitude": -122.4194,
              "radius": 500.0,
              "type": "home",
              "isActive": true,
              "notifyOnEnter": true,
              "notifyOnExit": true
            }
          ]
        ''';

        when(() => mockSharedPreferences.getString(any()))
            .thenReturn(existingJsonString);
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        const updatedZone = SafeZone(
          id: '1',
          name: 'Home Sweet Home',
          location: LatLng(37.7749, -122.4194),
          radius: 750,
        );

        await repository.updateSafeZone(updatedZone);

        verify(
          () => mockSharedPreferences.setString('safe_zones', any()),
        ).called(1);
      });
    });

    group('deleteSafeZone', () {
      test('deletes a safe zone by id', () async {
        const existingJsonString = '''
          [
            {
              "id": "1",
              "name": "Home",
              "latitude": 37.7749,
              "longitude": -122.4194,
              "radius": 500.0,
              "type": "home",
              "isActive": true,
              "notifyOnEnter": true,
              "notifyOnExit": true
            },
            {
              "id": "2",
              "name": "Work",
              "latitude": 37.7849,
              "longitude": -122.4294,
              "radius": 1000.0,
              "type": "work",
              "isActive": true,
              "notifyOnEnter": true,
              "notifyOnExit": true
            }
          ]
        ''';

        when(() => mockSharedPreferences.getString(any()))
            .thenReturn(existingJsonString);
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        await repository.deleteSafeZone('1');

        verify(
          () => mockSharedPreferences.setString('safe_zones', any()),
        ).called(1);
      });
    });

    group('clearSafeZones', () {
      test('removes all safe zones from storage', () async {
        when(() => mockSharedPreferences.remove(any()))
            .thenAnswer((_) async => true);

        await repository.clearSafeZones();

        verify(() => mockSharedPreferences.remove('safe_zones')).called(1);
      });
    });
  });
}
