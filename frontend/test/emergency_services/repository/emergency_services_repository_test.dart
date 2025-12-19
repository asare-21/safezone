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

    test('getServicesByCountry returns US services', () {
      final services = repository.getServicesByCountry('US');

      expect(services, isNotEmpty);
      expect(services.every((s) => s.id.startsWith('us_')), isTrue);
    });

    test('getServicesByCountry returns UK services', () {
      final services = repository.getServicesByCountry('GB');

      expect(services, isNotEmpty);
      expect(services.every((s) => s.id.startsWith('uk_')), isTrue);
    });

    test('getServicesByCountry returns Ghana services', () {
      final services = repository.getServicesByCountry('GH');

      expect(services, isNotEmpty);
      expect(services.every((s) => s.id.startsWith('gh_')), isTrue);
    });

    test('getServicesByCountry returns generic services for unknown country', () {
      final services = repository.getServicesByCountry('XX');

      expect(services, isNotEmpty);
      expect(services.every((s) => s.id.startsWith('generic_')), isTrue);
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
      const userLocation = LatLng(40.7128, -74.0060);
      final nearbyServices = repository.getServicesNearLocation(
        userLocation,
        countryCode: 'US',
      );

      expect(nearbyServices, isNotEmpty);
      expect(
        nearbyServices.every((s) => s.distance != null),
        isTrue,
      );
    });

    test('getServicesNearLocation filters by radius', () {
      const userLocation = LatLng(40.7128, -74.0060);
      const radiusKm = 1.0;
      final nearbyServices = repository.getServicesNearLocation(
        userLocation,
        radiusKm: radiusKm,
        countryCode: 'US',
      );

      expect(
        nearbyServices.every((s) => s.distance! <= radiusKm),
        isTrue,
      );
    });

    test('getServicesNearLocation sorts by distance', () {
      const userLocation = LatLng(40.7128, -74.0060);
      final nearbyServices = repository.getServicesNearLocation(
        userLocation,
        countryCode: 'US',
      );

      for (var i = 0; i < nearbyServices.length - 1; i++) {
        expect(
          nearbyServices[i].distance! <= nearbyServices[i + 1].distance!,
          isTrue,
        );
      }
    });

    test('getServicesNearLocation uses country-specific services', () {
      const userLocation = LatLng(5.6037, -0.1870); // Accra, Ghana
      final nearbyServices = repository.getServicesNearLocation(
        userLocation,
        countryCode: 'GH',
      );

      expect(nearbyServices, isNotEmpty);
      expect(nearbyServices.every((s) => s.id.startsWith('gh_')), isTrue);
    });
  });
}
