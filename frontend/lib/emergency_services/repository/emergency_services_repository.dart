import 'package:latlong2/latlong.dart';
import 'package:safe_zone/emergency_services/models/emergency_service_model.dart';
import 'package:safe_zone/emergency_services/services/emergency_service_api_service.dart';

class EmergencyServicesRepository {
  EmergencyServicesRepository({
    EmergencyServiceApiService? apiService,
    String? baseUrl,
  }) : _apiService = apiService ?? EmergencyServiceApiService(baseUrl: baseUrl);
  
  final EmergencyServiceApiService _apiService;
  
  // Get services based on country code from backend API
  Future<List<EmergencyService>> getServicesByCountry(
    String countryCode,
  ) async {
    return _apiService.getEmergencyServices(countryCode: countryCode);
  }

  // Get all services for a country (kept for backwards compatibility)
  Future<List<EmergencyService>> getAllServices(String countryCode) async {
    return getServicesByCountry(countryCode);
  }

  Future<List<EmergencyService>> getServicesByType(
    EmergencyServiceType type,
    String countryCode,
  ) async {
    final serviceTypeStr = _serviceTypeToString(type);
    return _apiService.getEmergencyServices(
      countryCode: countryCode,
      serviceType: serviceTypeStr,
    );
  }

  Future<List<EmergencyService>> getServicesNearLocation(
    LatLng userLocation, {
    required String countryCode, double radiusKm = 10.0,
  }) async {
    const distance = Distance();
    
    // Get all services for the country
    final services = await getServicesByCountry(countryCode);
    
    // Calculate distance for each service
    final servicesWithDistance = services.map((service) {
      final distanceInMeters = distance.as(
        LengthUnit.Meter,
        userLocation,
        service.location,
      );
      final distanceInKm = distanceInMeters / 1000;
      
      return EmergencyService(
        id: service.id,
        name: service.name,
        type: service.type,
        location: service.location,
        phoneNumber: service.phoneNumber,
        address: service.address,
        hours: service.hours,
        distance: distanceInKm,
      );
    }).toList();
    
    // Filter by radius and sort by distance
    final nearbyServices = servicesWithDistance
        .where((service) => service.distance! <= radiusKm)
        .toList()
      ..sort((a, b) => a.distance!.compareTo(b.distance!));
    
    return nearbyServices;
  }
  
  String _serviceTypeToString(EmergencyServiceType type) {
    switch (type) {
      case EmergencyServiceType.police:
        return 'police';
      case EmergencyServiceType.hospital:
        return 'hospital';
      case EmergencyServiceType.fireStation:
        return 'fireStation';
      case EmergencyServiceType.ambulance:
        return 'ambulance';
    }
  }
}
