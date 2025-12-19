import 'package:latlong2/latlong.dart';
import 'package:safe_zone/emergency_services/models/emergency_service_model.dart';
import 'package:safe_zone/emergency_services/services/emergency_service_api_service.dart';

class EmergencyServicesRepository {
  EmergencyServicesRepository({EmergencyServiceApiService? apiService})
      : _apiService = apiService ?? EmergencyServiceApiService();
  
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
    double radiusKm = 10.0,
    required String countryCode,
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
      ),
      
      // Hospitals
      EmergencyService(
        id: 'us_hospital_1',
        name: 'Emergency Services',
        type: EmergencyServiceType.hospital,
        location: const LatLng(40.7614, -73.9776),
        phoneNumber: '911',
        address: 'Emergency Medical Services',
        hours: '24/7 Emergency',
      ),
      
      // Ambulance Services
      EmergencyService(
        id: 'us_ambulance_1',
        name: 'Emergency Medical Services',
        type: EmergencyServiceType.ambulance,
        location: const LatLng(40.7489, -73.9750),
        phoneNumber: '911',
        address: 'Main Emergency Dispatch',
        hours: '24/7',
      ),
    ];
  }

  List<EmergencyService> _getUKServices() {
    return [
      EmergencyService(
        id: 'uk_police_1',
        name: 'Metropolitan Police Service',
        type: EmergencyServiceType.police,
        location: const LatLng(51.5074, -0.1278),
        phoneNumber: '999',
        address: 'New Scotland Yard, London',
        hours: '24/7',
      ),
      EmergencyService(
        id: 'uk_hospital_1',
        name: 'NHS Emergency Services',
        type: EmergencyServiceType.hospital,
        location: const LatLng(51.5074, -0.1278),
        phoneNumber: '999',
        address: 'Emergency Medical Services',
        hours: '24/7 Emergency',
      ),
      EmergencyService(
        id: 'uk_ambulance_1',
        name: 'NHS Ambulance Service',
        type: EmergencyServiceType.ambulance,
        location: const LatLng(51.5074, -0.1278),
        phoneNumber: '999',
        address: 'Emergency Ambulance Dispatch',
        hours: '24/7',
      ),
    ];
  }

  List<EmergencyService> _getGhanaServices() {
    return [
      EmergencyService(
        id: 'gh_police_1',
        name: 'Ghana Police Service',
        type: EmergencyServiceType.police,
        location: const LatLng(5.6037, -0.1870),
        phoneNumber: '191',
        address: 'Police Headquarters, Accra',
        hours: '24/7',
      ),
      EmergencyService(
        id: 'gh_ambulance_1',
        name: 'National Ambulance Service',
        type: EmergencyServiceType.ambulance,
        location: const LatLng(5.6037, -0.1870),
        phoneNumber: '193',
        address: 'Emergency Ambulance Service',
        hours: '24/7',
      ),
      EmergencyService(
        id: 'gh_fire_1',
        name: 'Ghana National Fire Service',
        type: EmergencyServiceType.fireStation,
        location: const LatLng(5.6037, -0.1870),
        phoneNumber: '192',
        address: 'Fire Service Headquarters, Accra',
        hours: '24/7',
      ),
    ];
  }

  List<EmergencyService> _getNigeriaServices() {
    return [
      EmergencyService(
        id: 'ng_police_1',
        name: 'Nigeria Police Force',
        type: EmergencyServiceType.police,
        location: const LatLng(9.0765, 7.3986),
        phoneNumber: '112',
        address: 'Emergency Response',
        hours: '24/7',
      ),
      EmergencyService(
        id: 'ng_ambulance_1',
        name: 'Emergency Medical Services',
        type: EmergencyServiceType.ambulance,
        location: const LatLng(9.0765, 7.3986),
        phoneNumber: '112',
        address: 'National Emergency Number',
        hours: '24/7',
      ),
    ];
  }

  List<EmergencyService> _getKenyaServices() {
    return [
      EmergencyService(
        id: 'ke_police_1',
        name: 'Kenya Police Service',
        type: EmergencyServiceType.police,
        location: const LatLng(-1.2921, 36.8219),
        phoneNumber: '999',
        address: 'Police Emergency Response',
        hours: '24/7',
      ),
      EmergencyService(
        id: 'ke_ambulance_1',
        name: 'Emergency Medical Services',
        type: EmergencyServiceType.ambulance,
        location: const LatLng(-1.2921, 36.8219),
        phoneNumber: '999',
        address: 'Ambulance Emergency Services',
        hours: '24/7',
      ),
    ];
  }

  List<EmergencyService> _getGenericServices() {
    // Generic international emergency services
    // Note: Using (0, 0) as placeholder location since these are
    // general emergency numbers without specific physical locations
    return [
      EmergencyService(
        id: 'generic_emergency_1',
        name: 'International Emergency Services',
        type: EmergencyServiceType.ambulance,
        location: const LatLng(0, 0),
        phoneNumber: '112',
        address: 'International Emergency Number',
        hours: '24/7',
      ),
      EmergencyService(
        id: 'generic_police_1',
        name: 'Local Police',
        type: EmergencyServiceType.police,
        location: const LatLng(0, 0),
        phoneNumber: '112',
        address: 'Contact local emergency services',
        hours: '24/7',
      ),
    ];
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
    double radiusKm = 10.0,
    required String countryCode,
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
