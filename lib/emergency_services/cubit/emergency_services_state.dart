import 'package:equatable/equatable.dart';
import 'package:safe_zone/emergency_services/models/emergency_service_model.dart';

enum EmergencyServicesStatus { initial, loading, success, error }

class EmergencyServicesState extends Equatable {
  const EmergencyServicesState({
    this.status = EmergencyServicesStatus.initial,
    this.services = const [],
    this.filteredServices = const [],
    this.selectedTypes = const {},
    this.errorMessage,
  });

  final EmergencyServicesStatus status;
  final List<EmergencyService> services;
  final List<EmergencyService> filteredServices;
  final Set<EmergencyServiceType> selectedTypes;
  final String? errorMessage;

  EmergencyServicesState copyWith({
    EmergencyServicesStatus? status,
    List<EmergencyService>? services,
    List<EmergencyService>? filteredServices,
    Set<EmergencyServiceType>? selectedTypes,
    String? errorMessage,
  }) {
    return EmergencyServicesState(
      status: status ?? this.status,
      services: services ?? this.services,
      filteredServices: filteredServices ?? this.filteredServices,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        services,
        filteredServices,
        selectedTypes,
        errorMessage,
      ];
}
