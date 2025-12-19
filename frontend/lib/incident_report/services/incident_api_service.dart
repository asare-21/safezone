import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:safe_zone/map/models/incident_model.dart';

/// Service for interacting with the incident reporting API
class IncidentApiService {
  IncidentApiService({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  /// Fetch all incidents from the API
  Future<List<Incident>> getIncidents() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/api/incidents/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;

        return results
            .map((json) => _incidentFromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to load incidents: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching incidents: $e');
    }
  }

  /// Create a new incident report
  Future<Incident> createIncident({
    required IncidentCategory category,
    required LatLng location,
    required String title,
    String? description,
    required bool notifyNearby,
  }) async {
    try {
      final body = json.encode({
        'category': _categoryToString(category),
        'latitude': location.latitude,
        'longitude': location.longitude,
        'title': title,
        'description': description ?? '',
        'notify_nearby': notifyNearby,
      });

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/api/incidents/'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return _incidentFromJson(data);
      } else {
        throw Exception(
          'Failed to create incident: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error creating incident: $e');
    }
  }

  /// Get a specific incident by ID
  Future<Incident> getIncident(String id) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/api/incidents/$id/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return _incidentFromJson(data);
      } else {
        throw Exception(
          'Failed to load incident: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching incident: $e');
    }
  }

  /// Convert JSON to Incident model
  Incident _incidentFromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'].toString(),
      category: _categoryFromString(json['category'] as String),
      location: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      confirmedBy: json['confirmed_by'] as int? ?? 1,
      notifyNearby: json['notify_nearby'] as bool? ?? false,
    );
  }

  /// Convert IncidentCategory enum to string for API
  String _categoryToString(IncidentCategory category) {
    switch (category) {
      case IncidentCategory.accident:
        return 'accident';
      case IncidentCategory.fire:
        return 'fire';
      case IncidentCategory.theft:
        return 'theft';
      case IncidentCategory.suspicious:
        return 'suspicious';
      case IncidentCategory.lighting:
        return 'lighting';
      case IncidentCategory.assault:
        return 'assault';
      case IncidentCategory.vandalism:
        return 'vandalism';
      case IncidentCategory.harassment:
        return 'harassment';
      case IncidentCategory.roadHazard:
        return 'roadHazard';
      case IncidentCategory.animalDanger:
        return 'animalDanger';
      case IncidentCategory.medicalEmergency:
        return 'medicalEmergency';
      case IncidentCategory.naturalDisaster:
        return 'naturalDisaster';
      case IncidentCategory.powerOutage:
        return 'powerOutage';
      case IncidentCategory.waterIssue:
        return 'waterIssue';
      case IncidentCategory.noise:
        return 'noise';
      case IncidentCategory.trespassing:
        return 'trespassing';
      case IncidentCategory.drugActivity:
        return 'drugActivity';
      case IncidentCategory.weaponSighting:
        return 'weaponSighting';
    }
  }

  /// Convert string to IncidentCategory enum
  IncidentCategory _categoryFromString(String category) {
    switch (category) {
      case 'accident':
        return IncidentCategory.accident;
      case 'fire':
        return IncidentCategory.fire;
      case 'theft':
        return IncidentCategory.theft;
      case 'suspicious':
        return IncidentCategory.suspicious;
      case 'lighting':
        return IncidentCategory.lighting;
      case 'assault':
        return IncidentCategory.assault;
      case 'vandalism':
        return IncidentCategory.vandalism;
      case 'harassment':
        return IncidentCategory.harassment;
      case 'roadHazard':
        return IncidentCategory.roadHazard;
      case 'animalDanger':
        return IncidentCategory.animalDanger;
      case 'medicalEmergency':
        return IncidentCategory.medicalEmergency;
      case 'naturalDisaster':
        return IncidentCategory.naturalDisaster;
      case 'powerOutage':
        return IncidentCategory.powerOutage;
      case 'waterIssue':
        return IncidentCategory.waterIssue;
      case 'noise':
        return IncidentCategory.noise;
      case 'trespassing':
        return IncidentCategory.trespassing;
      case 'drugActivity':
        return IncidentCategory.drugActivity;
      case 'weaponSighting':
        return IncidentCategory.weaponSighting;
      default:
        // Log unrecognized category for debugging
        debugPrint('Unknown incident category: $category');
        return IncidentCategory.suspicious;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
