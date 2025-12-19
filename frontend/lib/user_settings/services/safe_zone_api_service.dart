import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:safe_zone/profile/models/safe_zone_model.dart';

/// Service for managing safe zones via API
class SafeZoneApiService {
  SafeZoneApiService({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  /// Get all safe zones for a device
  Future<List<SafeZone>> getSafeZones(String deviceId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/api/safe-zones/?device_id=$deviceId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;

        return results.map((json) => _safeZoneFromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load safe zones: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching safe zones: $e');
    }
  }

  /// Create a new safe zone
  Future<SafeZone> createSafeZone({
    required String deviceId,
    required SafeZone safeZone,
  }) async {
    try {
      final body = json.encode({
        'device_id': deviceId,
        'name': safeZone.name,
        'latitude': safeZone.location.latitude,
        'longitude': safeZone.location.longitude,
        'radius': safeZone.radius,
        'zone_type': _zoneTypeToString(safeZone.type),
        'is_active': safeZone.isActive,
        'notify_on_enter': safeZone.notifyOnEnter,
        'notify_on_exit': safeZone.notifyOnExit,
      });

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/api/safe-zones/'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return _safeZoneFromJson(data);
      } else {
        throw Exception(
          'Failed to create safe zone: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error creating safe zone: $e');
    }
  }

  /// Update an existing safe zone
  Future<SafeZone> updateSafeZone({
    required String deviceId,
    required SafeZone safeZone,
  }) async {
    try {
      final body = json.encode({
        'device_id': deviceId,
        'name': safeZone.name,
        'latitude': safeZone.location.latitude,
        'longitude': safeZone.location.longitude,
        'radius': safeZone.radius,
        'zone_type': _zoneTypeToString(safeZone.type),
        'is_active': safeZone.isActive,
        'notify_on_enter': safeZone.notifyOnEnter,
        'notify_on_exit': safeZone.notifyOnExit,
      });

      final response = await _httpClient.put(
        Uri.parse('$baseUrl/api/safe-zones/${safeZone.id}/'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return _safeZoneFromJson(data);
      } else {
        throw Exception(
          'Failed to update safe zone: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error updating safe zone: $e');
    }
  }

  /// Delete a safe zone
  Future<void> deleteSafeZone(String id) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('$baseUrl/api/safe-zones/$id/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(
          'Failed to delete safe zone: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error deleting safe zone: $e');
    }
  }

  /// Convert API JSON to SafeZone model
  SafeZone _safeZoneFromJson(Map<String, dynamic> json) {
    return SafeZone.fromJson({
      'id': json['id'].toString(),
      'name': json['name'] as String,
      'latitude': json['latitude'] as double,
      'longitude': json['longitude'] as double,
      'radius': json['radius'] as double,
      'type': _zoneTypeFromString(json['zone_type'] as String),
      'isActive': json['is_active'] as bool,
      'notifyOnEnter': json['notify_on_enter'] as bool,
      'notifyOnExit': json['notify_on_exit'] as bool,
    });
  }

  /// Convert SafeZoneType enum to string for API
  String _zoneTypeToString(SafeZoneType type) {
    switch (type) {
      case SafeZoneType.home:
        return 'home';
      case SafeZoneType.work:
        return 'work';
      case SafeZoneType.school:
        return 'school';
      case SafeZoneType.custom:
        return 'custom';
    }
  }

  /// Convert string to SafeZoneType enum
  String _zoneTypeFromString(String type) {
    switch (type) {
      case 'home':
        return 'home';
      case 'work':
        return 'work';
      case 'school':
        return 'school';
      default:
        return 'custom';
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
