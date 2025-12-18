import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_zone/emergency_services/models/emergency_service_model.dart';
import 'package:safe_zone/emergency_services/repository/emergency_services_repository.dart';

void main() {
  late EmergencyServicesRepository repository;

  setUp(() {
    repository = EmergencyServicesRepository();
  });

  group('EmergencyServicesRepository', () {
    test('getAllServices returns a list of services', () {
      final services = repository.getAllServices();

      expect(services, isNotEmpty);
      expect(services, isA<List<EmergencyService>>());
    });

    test('getAllServices returns services of all types', () {
      final services = repository.getAllServices();

      final hasPolice = services.any(
        (s) => s.type == EmergencyServiceType.police,
      );
      final hasHospital = services.any(
        (s) => s.type == EmergencyServiceType.hospital,
      );
      final hasFireStation = services.any(
        (s) => s.type == EmergencyServiceType.fireStation,
      );
      final hasAmbulance = services.any(
        (s) => s.type == EmergencyServiceType.ambulance,
      );

      expect(hasPolice, isTrue);
      expect(hasHospital, isTrue);
      expect(hasFireStation, isTrue);
      expect(hasAmbulance, isTrue);
    });

    test('getServicesByType filters by type correctly', () {
      final policeStations = repository.getServicesByType(
        EmergencyServiceType.police,
      );

      expect(policeStations, isNotEmpty);
      expect(
        policeStations.every((s) => s.type == EmergencyServiceType.police),
        isTrue,
      );
    });

    test('getServicesNearLocation returns services with distance', () {
      final userLocation = const LatLng(40.7128, -74.0060);
      final nearbyServices = repository.getServicesNearLocation(userLocation);

      expect(nearbyServices, isNotEmpty);
      expect(
        nearbyServices.every((s) => s.distance != null),
        isTrue,
      );
    });

    test('getServicesNearLocation filters by radius', () {
      final userLocation = const LatLng(40.7128, -74.0060);
      final radiusKm = 1.0;
      final nearbyServices = repository.getServicesNearLocation(
        userLocation,
        radiusKm: radiusKm,
      );

      expect(
        nearbyServices.every((s) => s.distance! <= radiusKm),
        isTrue,
      );
    });

    test('getServicesNearLocation sorts by distance', () {
      final userLocation = const LatLng(40.7128, -74.0060);
      final nearbyServices = repository.getServicesNearLocation(userLocation);

      for (var i = 0; i < nearbyServices.length - 1; i++) {
        expect(
          nearbyServices[i].distance! <= nearbyServices[i + 1].distance!,
          isTrue,
        );
      }
    });
  });
}
