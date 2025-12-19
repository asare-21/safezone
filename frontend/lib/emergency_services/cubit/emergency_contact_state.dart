import 'package:equatable/equatable.dart';
import 'package:safe_zone/emergency_services/models/emergency_contact_model.dart';

enum EmergencyContactStatus { initial, loading, success, error }

class EmergencyContactState extends Equatable {
  const EmergencyContactState({
    this.status = EmergencyContactStatus.initial,
    this.contacts = const [],
    this.errorMessage,
  });

  final EmergencyContactStatus status;
  final List<EmergencyContact> contacts;
  final String? errorMessage;

  EmergencyContactState copyWith({
    EmergencyContactStatus? status,
    List<EmergencyContact>? contacts,
    String? errorMessage,
  }) {
    return EmergencyContactState(
      status: status ?? this.status,
      contacts: contacts ?? this.contacts,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, contacts, errorMessage];
}
