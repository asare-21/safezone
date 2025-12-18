import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_zone/emergency_services/models/emergency_service_model.dart';

void main() {
  group('EmergencyServiceType Extension', () {
    test('displayName returns correct name', () {
      expect(EmergencyServiceType.police.displayName, 'Police Station');
      expect(EmergencyServiceType.hospital.displayName, 'Hospital');
      expect(EmergencyServiceType.fireStation.displayName, 'Fire Station');
      expect(EmergencyServiceType.ambulance.displayName, 'Ambulance');
    });

    test('icon returns different icons for each type', () {
      expect(EmergencyServiceType.police.icon, Icons.local_police);
      expect(EmergencyServiceType.hospital.icon, Icons.local_hospital);
      expect(
        EmergencyServiceType.fireStation.icon,
        Icons.local_fire_department,
      );
      expect(EmergencyServiceType.ambulance.icon, Icons.emergency);
    });

    test('color returns different colors for each type', () {
      expect(
        EmergencyServiceType.police.color,
        const Color(0xFF007AFF),
      );
      expect(
        EmergencyServiceType.hospital.color,
        const Color(0xFFFF4C4C),
      );
      expect(
        EmergencyServiceType.fireStation.color,
        const Color(0xFFFF9500),
      );
      expect(
        EmergencyServiceType.ambulance.color,
        const Color(0xFF34C759),
      );
    });
  });

  group('EmergencyService Model', () {
    test('creates instance with required fields', () {
      final service = EmergencyService(
        id: 'test_1',
        name: 'Test Hospital',
        type: EmergencyServiceType.hospital,
        location: const LatLng(40.7128, -74.0060),
        phoneNumber: '+1-212-555-0000',
      );

      expect(service.id, 'test_1');
      expect(service.name, 'Test Hospital');
      expect(service.type, EmergencyServiceType.hospital);
      expect(service.phoneNumber, '+1-212-555-0000');
    });

    test('formattedDistance returns meters for distance < 1km', () {
      final service = EmergencyService(
        id: 'test_1',
        name: 'Test Hospital',
        type: EmergencyServiceType.hospital,
        location: const LatLng(40.7128, -74.0060),
        phoneNumber: '+1-212-555-0000',
        distance: 0.5,
      );

      expect(service.formattedDistance, '500m away');
    });

    test('formattedDistance returns km for distance >= 1km', () {
      final service = EmergencyService(
        id: 'test_1',
        name: 'Test Hospital',
        type: EmergencyServiceType.hospital,
        location: const LatLng(40.7128, -74.0060),
        phoneNumber: '+1-212-555-0000',
        distance: 2.5,
      );

      expect(service.formattedDistance, '2.5km away');
    });

    test('formattedDistance returns empty string when distance is null', () {
      final service = EmergencyService(
        id: 'test_1',
        name: 'Test Hospital',
        type: EmergencyServiceType.hospital,
        location: const LatLng(40.7128, -74.0060),
        phoneNumber: '+1-212-555-0000',
      );

      expect(service.formattedDistance, '');
    });
  });
}
