import 'package:latlong2/latlong.dart';
import 'package:safe_zone/emergency_services/models/emergency_service_model.dart';

class EmergencyServicesRepository {
  // Mock data - in a real app, this would fetch from an API or database
  List<EmergencyService> getAllServices() {
    return [
      // Police Stations
      EmergencyService(
        id: 'police_1',
        name: 'Central Police Precinct',
        type: EmergencyServiceType.police,
        location: const LatLng(40.7580, -73.9855),
        phoneNumber: '+1-212-555-0101',
        address: '350 5th Ave, New York, NY 10118',
        hours: '24/7',
      ),
      EmergencyService(
        id: 'police_2',
        name: 'Downtown Police Station',
        type: EmergencyServiceType.police,
        location: const LatLng(40.7128, -74.0060),
        phoneNumber: '+1-212-555-0102',
        address: '1 Police Plaza, New York, NY 10038',
        hours: '24/7',
      ),
      EmergencyService(
        id: 'police_3',
        name: 'Midtown South Precinct',
        type: EmergencyServiceType.police,
        location: const LatLng(40.7489, -73.9680),
        phoneNumber: '+1-212-555-0103',
        address: '357 W 35th St, New York, NY 10001',
        hours: '24/7',
      ),
      
      // Hospitals
      EmergencyService(
        id: 'hospital_1',
        name: 'New York General Hospital',
        type: EmergencyServiceType.hospital,
        location: const LatLng(40.7614, -73.9776),
        phoneNumber: '+1-212-555-0201',
        address: '1000 10th Ave, New York, NY 10019',
        hours: '24/7 Emergency',
      ),
      EmergencyService(
        id: 'hospital_2',
        name: 'Metropolitan Medical Center',
        type: EmergencyServiceType.hospital,
        location: const LatLng(40.7282, -74.0776),
        phoneNumber: '+1-212-555-0202',
        address: '170 William St, New York, NY 10038',
        hours: '24/7 Emergency',
      ),
      EmergencyService(
        id: 'hospital_3',
        name: 'East Side Emergency Clinic',
        type: EmergencyServiceType.hospital,
        location: const LatLng(40.7589, -73.9851),
        phoneNumber: '+1-212-555-0203',
        address: '525 E 68th St, New York, NY 10065',
        hours: '24/7 Emergency',
      ),
      
      // Fire Stations
      EmergencyService(
        id: 'fire_1',
        name: 'Fire Station 54',
        type: EmergencyServiceType.fireStation,
        location: const LatLng(40.7580, -73.9900),
        phoneNumber: '+1-212-555-0301',
        address: '782 8th Ave, New York, NY 10036',
        hours: '24/7',
      ),
      EmergencyService(
        id: 'fire_2',
        name: 'Fire Station 10',
        type: EmergencyServiceType.fireStation,
        location: const LatLng(40.7108, -74.0134),
        phoneNumber: '+1-212-555-0302',
        address: '124 Liberty St, New York, NY 10006',
        hours: '24/7',
      ),
      
      // Ambulance Services
      EmergencyService(
        id: 'ambulance_1',
        name: 'Emergency Medical Services',
        type: EmergencyServiceType.ambulance,
        location: const LatLng(40.7489, -73.9750),
        phoneNumber: '911',
        address: 'Main Emergency Dispatch',
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
  }) {
    final distance = const Distance();
    final services = getAllServices();
    
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
