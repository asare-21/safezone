import 'package:bloc/bloc.dart';
import 'package:safe_zone/emergency_services/cubit/emergency_contact_state.dart';
import 'package:safe_zone/emergency_services/models/emergency_contact_model.dart';
import 'package:safe_zone/emergency_services/repository/emergency_contact_repository.dart';

class EmergencyContactCubit extends Cubit<EmergencyContactState> {
  EmergencyContactCubit({EmergencyContactRepository? repository})
      : _repository = repository ?? EmergencyContactRepository(),
        super(const EmergencyContactState());

  final EmergencyContactRepository _repository;

  Future<void> loadContacts() async {
    emit(state.copyWith(status: EmergencyContactStatus.loading));

    try {
      final contacts = await _repository.getContacts();
      emit(
        state.copyWith(
          status: EmergencyContactStatus.success,
          contacts: contacts,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: EmergencyContactStatus.error,
          errorMessage: 'Failed to load emergency contacts: $e',
        ),
      );
    }
  }

  Future<void> addContact({
    required String name,
    required String phoneNumber,
    String? email,
    required String relationship,
    required int priority,
  }) async {
    try {
      emit(state.copyWith(status: EmergencyContactStatus.loading));

      final contact = await _repository.createContact(
        name: name,
        phoneNumber: phoneNumber,
        email: email,
        relationship: relationship,
        priority: priority,
      );

      final updatedContacts = List<EmergencyContact>.from(state.contacts)
        ..add(contact)
        ..sort((a, b) => a.priority.compareTo(b.priority));

      emit(
        state.copyWith(
          status: EmergencyContactStatus.success,
          contacts: updatedContacts,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: EmergencyContactStatus.error,
          errorMessage: 'Failed to add emergency contact: $e',
        ),
      );
    }
  }

  Future<void> updateContact({
    required int id,
    String? name,
    String? phoneNumber,
    String? email,
    String? relationship,
    int? priority,
  }) async {
    try {
      emit(state.copyWith(status: EmergencyContactStatus.loading));

      final updatedContact = await _repository.updateContact(
        id: id,
        name: name,
        phoneNumber: phoneNumber,
        email: email,
        relationship: relationship,
        priority: priority,
      );

      final updatedContacts = state.contacts.map((contact) {
        return contact.id == id ? updatedContact : contact;
      }).toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));

      emit(
        state.copyWith(
          status: EmergencyContactStatus.success,
          contacts: updatedContacts,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: EmergencyContactStatus.error,
          errorMessage: 'Failed to update emergency contact: $e',
        ),
      );
    }
  }

  Future<void> deleteContact(int id) async {
    try {
      emit(state.copyWith(status: EmergencyContactStatus.loading));

      await _repository.deleteContact(id);

      final updatedContacts = state.contacts
          .where((contact) => contact.id != id)
          .toList();

      emit(
        state.copyWith(
          status: EmergencyContactStatus.success,
          contacts: updatedContacts,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: EmergencyContactStatus.error,
          errorMessage: 'Failed to delete emergency contact: $e',
        ),
      );
    }
  }
}
