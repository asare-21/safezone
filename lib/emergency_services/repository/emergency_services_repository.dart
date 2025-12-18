import 'package:latlong2/latlong.dart';
import 'package:safe_zone/emergency_services/models/emergency_service_model.dart';

class EmergencyServicesRepository {
  // Get services based on country code
  List<EmergencyService> getServicesByCountry(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'US':
        return _getUSServices();
      case 'GB':
      case 'UK':
        return _getUKServices();
      case 'GH':
        return _getGhanaServices();
      case 'NG':
        return _getNigeriaServices();
      case 'KE':
        return _getKenyaServices();
      default:
        // Return a generic set of international emergency numbers
        return _getGenericServices();
    }
  }

  // Mock data - in a real app, this would fetch from an API or database
  List<EmergencyService> getAllServices() {
    // Default to US services for backwards compatibility
    return _getUSServices();
  }

  List<EmergencyService> _getUSServices() {
    return [
      // Police Stations
      EmergencyService(
        id: 'us_police_1',
        name: 'Central Police Precinct',
        type: EmergencyServiceType.police,
        location: const LatLng(40.7580, -73.9855),
        phoneNumber: '911',
        address: '350 5th Ave, New York, NY 10118',
        hours: '24/7',
      ),
      EmergencyService(
        id: 'us_police_2',
        name: 'Downtown Police Station',
        type: EmergencyServiceType.police,
        location: const LatLng(40.7128, -74.0060),
        phoneNumber: '911',
        address: '1 Police Plaza, New York, NY 10038',
        hours: '24/7',
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
    return [
      EmergencyService(
        id: 'generic_emergency_1',
        name: 'Local Emergency Services',
        type: EmergencyServiceType.ambulance,
        location: const LatLng(0, 0),
        phoneNumber: '112',
        address: 'International Emergency Number',
        hours: '24/7',
      ),
    ];
  }

  List<EmergencyService> getServicesByType(EmergencyServiceType type) {
    return getAllServices().where((service) => service.type == type).toList();
  }

  List<EmergencyService> getServicesNearLocation(
    LatLng userLocation, {
    double radiusKm = 10.0,
    String? countryCode,
  }) {
    final distance = const Distance();
    // Get services for the specific country if provided
    final services = countryCode != null 
        ? getServicesByCountry(countryCode)
        : getAllServices();
    
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
}
