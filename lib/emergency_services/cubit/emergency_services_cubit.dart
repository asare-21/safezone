import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_zone/emergency_services/cubit/emergency_services_state.dart';
import 'package:safe_zone/emergency_services/models/emergency_service_model.dart';
import 'package:safe_zone/emergency_services/repository/emergency_services_repository.dart';

class EmergencyServicesCubit extends Cubit<EmergencyServicesState> {
  EmergencyServicesCubit({
    EmergencyServicesRepository? repository,
  })  : _repository = repository ?? EmergencyServicesRepository(),
        super(const EmergencyServicesState());

  final EmergencyServicesRepository _repository;

  Future<void> loadServices({LatLng? userLocation}) async {
    emit(state.copyWith(status: EmergencyServicesStatus.loading));

    try {
      List<EmergencyService> services;

      if (userLocation != null) {
        // Load services near user location
        services = _repository.getServicesNearLocation(userLocation);
      } else {
        // Try to get user's current location
        try {
          final position = await _getCurrentPosition();
          final location = LatLng(position.latitude, position.longitude);
          services = _repository.getServicesNearLocation(location);
        } catch (e) {
          // If location is not available, show all services
          services = _repository.getAllServices();
        }
      }

      emit(
        state.copyWith(
          status: EmergencyServicesStatus.success,
          services: services,
          filteredServices: services,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: EmergencyServicesStatus.error,
          errorMessage: 'Failed to load emergency services: ${e.toString()}',
        ),
      );
    }
  }

  void toggleServiceType(EmergencyServiceType type) {
    final newSelectedTypes = Set<EmergencyServiceType>.from(state.selectedTypes);
    
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
    return await Geolocator.getCurrentPosition();
  }
}
