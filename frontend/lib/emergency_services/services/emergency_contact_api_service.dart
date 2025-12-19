import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:safe_zone/emergency_services/models/emergency_contact_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContactApiService {
  // Use the same base URL pattern as other services
  static const String baseUrl = kDebugMode
      ? 'http://10.0.2.2:8000'  // Android emulator
      : 'https://your-production-url.com';

  Future<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('device_id');

      if (deviceId == null) {
        debugPrint('No device ID found');
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/emergency-contacts/?device_id=$deviceId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        return results
            .map((json) => EmergencyContact.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('Failed to load emergency contacts: ${response.statusCode}');
        throw Exception('Failed to load emergency contacts');
      }
    } catch (e) {
      debugPrint('Error loading emergency contacts: $e');
      rethrow;
    }
  }

  Future<EmergencyContact> createEmergencyContact({
    required String name,
    required String phoneNumber,
    String? email,
    required String relationship,
    required int priority,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('device_id');

      if (deviceId == null) {
        throw Exception('No device ID found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/emergency-contacts/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'device_id': deviceId,
          'name': name,
          'phone_number': phoneNumber,
          if (email != null && email.isNotEmpty) 'email': email,
          'relationship': relationship,
          'priority': priority,
          'is_active': true,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('Emergency contact created successfully');
        return EmergencyContact.fromJson(data);
      } else {
        debugPrint('Failed to create emergency contact: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('Failed to create emergency contact');
      }
    } catch (e) {
      debugPrint('Error creating emergency contact: $e');
      rethrow;
    }
  }

  Future<EmergencyContact> updateEmergencyContact({
    required int id,
    String? name,
    String? phoneNumber,
    String? email,
    String? relationship,
    int? priority,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('device_id');

      if (deviceId == null) {
        throw Exception('No device ID found');
      }

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phoneNumber != null) body['phone_number'] = phoneNumber;
      if (email != null) body['email'] = email;
      if (relationship != null) body['relationship'] = relationship;
      if (priority != null) body['priority'] = priority;

      final response = await http.patch(
        Uri.parse('$baseUrl/api/emergency-contacts/$id/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('Emergency contact updated successfully');
        return EmergencyContact.fromJson(data);
      } else {
        debugPrint('Failed to update emergency contact: ${response.statusCode}');
        throw Exception('Failed to update emergency contact');
      }
    } catch (e) {
      debugPrint('Error updating emergency contact: $e');
      rethrow;
    }
  }

  Future<void> deleteEmergencyContact(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/emergency-contacts/$id/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 204) {
        debugPrint('Emergency contact deleted successfully');
      } else {
        debugPrint('Failed to delete emergency contact: ${response.statusCode}');
        throw Exception('Failed to delete emergency contact');
      }
    } catch (e) {
      debugPrint('Error deleting emergency contact: $e');
      rethrow;
    }
  }
}
