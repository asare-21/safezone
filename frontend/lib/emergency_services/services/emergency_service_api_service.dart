import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:safe_zone/emergency_services/models/emergency_service_model.dart';

class EmergencyServiceApiService {
  EmergencyServiceApiService({
    String? baseUrl,
    http.Client? httpClient,
  })  : _baseUrl = baseUrl ??
            (kDebugMode
                ? 'http://127.0.0.1:8000' // Android emulator
                : 'https://your-production-url.com'),
        _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final http.Client _httpClient;

  Future<List<EmergencyService>> getEmergencyServices({
    required String countryCode,
    String? serviceType,
  }) async {
    try {
      final queryParams = <String, String>{
        'country_code': countryCode,
      };

      if (serviceType != null) {
        queryParams['service_type'] = serviceType;
      }

      final uri = Uri.parse('$_baseUrl/api/emergency-services/').replace(
        queryParameters: queryParams,
      );

      final response = await _httpClient.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;

        return results.map((json) {
          final serviceJson = json as Map<String, dynamic>;

          // Map service_type from backend to frontend enum
          EmergencyServiceType type;
          switch (serviceJson['service_type'] as String) {
            case 'police':
              type = EmergencyServiceType.police;
            case 'hospital':
              type = EmergencyServiceType.hospital;
            case 'fireStation':
              type = EmergencyServiceType.fireStation;
            case 'ambulance':
              type = EmergencyServiceType.ambulance;
            default:
              type = EmergencyServiceType.police;
          }

          return EmergencyService(
            id: serviceJson['id'].toString(),
            name: serviceJson['name'] as String,
            type: type,
            location: LatLng(
              (serviceJson['latitude'] as num).toDouble(),
              (serviceJson['longitude'] as num).toDouble(),
            ),
            phoneNumber: serviceJson['phone_number'] as String,
            address: serviceJson['address'] as String?,
            hours: serviceJson['hours'] as String?,
          );
        }).toList();
      } else {
        debugPrint(
          'Failed to load emergency services: ${response.statusCode}',
        );
        throw Exception('Failed to load emergency services');
      }
    } catch (e) {
      debugPrint('Error loading emergency services: $e');
      rethrow;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
