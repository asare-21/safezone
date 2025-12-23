import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_zone/emergency_services/cubit/emergency_services_state.dart';
import 'package:safe_zone/emergency_services/models/emergency_service_model.dart';
import 'package:safe_zone/emergency_services/repository/emergency_services_repository.dart';

class EmergencyServicesCubit extends Cubit<EmergencyServicesState> {
  EmergencyServicesCubit({
    EmergencyServicesRepository? repository,
    String? baseUrl,
  }) : _repository = repository ?? EmergencyServicesRepository(baseUrl: baseUrl),
       super(const EmergencyServicesState());

  final EmergencyServicesRepository _repository;

  Future<void> loadServices({LatLng? userLocation}) async {
    emit(state.copyWith(status: EmergencyServicesStatus.loading));

    try {
      List<EmergencyService> services;
      String? countryCode;

      if (userLocation != null) {
        // Get country code from provided location
        countryCode = await _getCountryCode(
          userLocation.latitude,
          userLocation.longitude,
        );
        
        // Default to US if country code not found
        countryCode ??= 'US';
        
        // Load services near user location with fallback
        services = await _getServicesWithFallback(userLocation, countryCode);
      } else {
        // Try to get user's current location
        try {
          final position = await _getCurrentPosition();
          final location = LatLng(position.latitude, position.longitude);

          // Get country code from current location
          countryCode = await _getCountryCode(
            position.latitude,
            position.longitude,
          );
          
          // Default to US if country code not found
          countryCode ??= 'US';

          // Load services near current location with fallback
          services = await _getServicesWithFallback(location, countryCode);
        } on Exception catch (e) {
          // If location is not available, show services for default country (US)
          services = await _repository.getServicesByCountry('US');
          if (kDebugMode) {
            print(e);
          }
        }
      }

      emit(
        state.copyWith(
          status: EmergencyServicesStatus.success,
          services: services,
          filteredServices: services,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: EmergencyServicesStatus.error,
          errorMessage: 'Failed to load emergency services: $e',
        ),
      );
    }
  }

  void toggleServiceType(EmergencyServiceType type) {
    final newSelectedTypes = Set<EmergencyServiceType>.from(
      state.selectedTypes,
    );

    if (newSelectedTypes.contains(type)) {
      newSelectedTypes.remove(type);
    } else {
      newSelectedTypes.add(type);
    }

    _applyFilters(newSelectedTypes);
  }

  void clearFilters() {
    emit(
      state.copyWith(
        selectedTypes: {},
        filteredServices: state.services,
      ),
    );
  }

  void _applyFilters(Set<EmergencyServiceType> selectedTypes) {
    List<EmergencyService> filtered;

    if (selectedTypes.isEmpty) {
      filtered = state.services;
    } else {
      filtered = state.services
          .where((service) => selectedTypes.contains(service.type))
          .toList();
    }

    emit(
      state.copyWith(
        selectedTypes: selectedTypes,
        filteredServices: filtered,
      ),
    );
  }

  Future<List<EmergencyService>> _getServicesWithFallback(
    LatLng location,
    String countryCode,
  ) async {
    // Try to get services near location
    var services = await _repository.getServicesNearLocation(
      location,
      countryCode: countryCode,
    );
    
    // If no services found within radius, show all services for the country
    if (services.isEmpty) {
      services = await _repository.getServicesByCountry(countryCode);
    }
    
    return services;
  }

  Future<String?> _getCountryCode(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        return placemarks.first.isoCountryCode;
      }
    } on Exception catch (e) {
      // If geocoding fails, return null to use default services
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
    return null;
  }

  Future<Position> _getCurrentPosition() async {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check location permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied',
      );
    }

    // Get current position
    return Geolocator.getCurrentPosition();
  }
}
