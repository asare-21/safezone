import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_zone/profile/models/safe_zone_model.dart';

void main() {
  group('SafeZone', () {
    test('creates a safe zone with required fields', () {
      const safeZone = SafeZone(
        id: '1',
        name: 'Home',
        location: LatLng(37.7749, -122.4194),
        radius: 500,
      );

      expect(safeZone.id, '1');
      expect(safeZone.name, 'Home');
      expect(safeZone.location.latitude, 37.7749);
      expect(safeZone.location.longitude, -122.4194);
      expect(safeZone.radius, 500);
      expect(safeZone.type, SafeZoneType.custom);
      expect(safeZone.isActive, true);
      expect(safeZone.notifyOnEnter, true);
      expect(safeZone.notifyOnExit, true);
    });

    test('creates a safe zone with all fields', () {
      const safeZone = SafeZone(
        id: '2',
        name: 'Work',
        location: LatLng(37.7749, -122.4194),
        radius: 1000,
        type: SafeZoneType.work,
        isActive: false,
        notifyOnEnter: false,
      );

      expect(safeZone.id, '2');
      expect(safeZone.name, 'Work');
      expect(safeZone.type, SafeZoneType.work);
      expect(safeZone.isActive, false);
      expect(safeZone.notifyOnEnter, false);
      expect(safeZone.notifyOnExit, true);
    });

    test('copyWith updates specified fields', () {
      const safeZone = SafeZone(
        id: '1',
        name: 'Home',
        location: LatLng(37.7749, -122.4194),
        radius: 500,
      );

      final updated = safeZone.copyWith(
        name: 'Home Sweet Home',
        radius: 1000,
        isActive: false,
      );

      expect(updated.id, '1');
      expect(updated.name, 'Home Sweet Home');
      expect(updated.radius, 1000);
      expect(updated.isActive, false);
      expect(updated.location, safeZone.location);
    });

    test('toJson serializes correctly', () {
      const safeZone = SafeZone(
        id: '1',
        name: 'School',
        location: LatLng(37.7749, -122.4194),
        radius: 750,
        type: SafeZoneType.school,
        isActive: false,
        notifyOnEnter: false,
        notifyOnExit: false,
      );

      final json = safeZone.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'School');
      expect(json['latitude'], 37.7749);
      expect(json['longitude'], -122.4194);
      expect(json['radius'], 750);
      expect(json['type'], 'school');
      expect(json['isActive'], false);
      expect(json['notifyOnEnter'], false);
      expect(json['notifyOnExit'], false);
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': '1',
        'name': 'Home',
        'latitude': 37.7749,
        'longitude': -122.4194,
        'radius': 500.0,
        'type': 'home',
        'isActive': true,
        'notifyOnEnter': true,
        'notifyOnExit': false,
      };

      final safeZone = SafeZone.fromJson(json);

      expect(safeZone.id, '1');
      expect(safeZone.name, 'Home');
      expect(safeZone.location.latitude, 37.7749);
      expect(safeZone.location.longitude, -122.4194);
      expect(safeZone.radius, 500);
      expect(safeZone.type, SafeZoneType.home);
      expect(safeZone.isActive, true);
      expect(safeZone.notifyOnEnter, true);
      expect(safeZone.notifyOnExit, false);
    });

    test('contains returns true for position inside zone', () {
      const safeZone = SafeZone(
        id: '1',
        name: 'Home',
        location: LatLng(37.7749, -122.4194),
        radius: 500, // 500 meters
      );

      // Position very close to center (within 500m)
      const nearbyPosition = LatLng(37.7750, -122.4195);

      expect(safeZone.contains(nearbyPosition), true);
    });

    test('contains returns false for position outside zone', () {
      const safeZone = SafeZone(
        id: '1',
        name: 'Home',
        location: LatLng(37.7749, -122.4194),
        radius: 100, // 100 meters
      );

      // Position far from center (more than 100m)
      const farPosition = LatLng(37.7850, -122.4294);

      expect(safeZone.contains(farPosition), false);
    });
  });

  group('SafeZoneType', () {
    test('displayName returns correct names', () {
      expect(SafeZoneType.home.displayName, 'Home');
      expect(SafeZoneType.work.displayName, 'Work');
      expect(SafeZoneType.school.displayName, 'School');
      expect(SafeZoneType.custom.displayName, 'Custom');
    });
  });
}
