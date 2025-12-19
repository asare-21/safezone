import 'package:safe_zone/emergency_services/models/emergency_contact_model.dart';
import 'package:safe_zone/emergency_services/services/emergency_contact_api_service.dart';

class EmergencyContactRepository {
  EmergencyContactRepository({EmergencyContactApiService? apiService})
      : _apiService = apiService ?? EmergencyContactApiService();

  final EmergencyContactApiService _apiService;

  Future<List<EmergencyContact>> getContacts() async {
    return _apiService.getEmergencyContacts();
  }

  Future<EmergencyContact> createContact({
    required String name,
    required String phoneNumber,
    String? email,
    required String relationship,
    required int priority,
  }) async {
    return _apiService.createEmergencyContact(
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      relationship: relationship,
      priority: priority,
    );
  }

  Future<EmergencyContact> updateContact({
    required int id,
    String? name,
    String? phoneNumber,
    String? email,
    String? relationship,
    int? priority,
  }) async {
    return _apiService.updateEmergencyContact(
      id: id,
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      relationship: relationship,
      priority: priority,
    );
  }

  Future<void> deleteContact(int id) async {
    return _apiService.deleteEmergencyContact(id);
  }
}
