import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:safe_zone/alerts/models/alert_model.dart';

/// Service for interacting with the alerts API
class AlertApiService {
  AlertApiService({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  /// Fetch alerts from the API with optional filters
  Future<List<Alert>> getAlerts({
    AlertSeverity? severity,
    AlertType? alertType,
    int? hours,
    LatLng? userLocation,
    double? radiusKm,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};

      if (severity != null) {
        queryParams['severity'] = _severityToString(severity);
      }

      if (alertType != null) {
        queryParams['alert_type'] = _alertTypeToString(alertType);
      }

      if (hours != null) {
        queryParams['hours'] = hours.toString();
      }

      if (userLocation != null) {
        queryParams['latitude'] = userLocation.latitude.toString();
        queryParams['longitude'] = userLocation.longitude.toString();

        if (radiusKm != null) {
          queryParams['radius_km'] = radiusKm.toString();
        }
      }

      final uri = Uri.parse('$baseUrl/api/alerts/').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await _httpClient.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;

        return results
            .map((json) => _alertFromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to load alerts: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching alerts: $e');
      throw Exception('Error fetching alerts: $e');
    }
  }

  /// Get a specific alert by ID
  Future<Alert> getAlert(String id) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/api/alerts/$id/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return _alertFromJson(data);
      } else {
        throw Exception(
          'Failed to load alert: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching alert: $e');
      throw Exception('Error fetching alert: $e');
    }
  }

  /// Generate alerts based on user location and nearby incidents
  Future<List<Alert>> generateAlerts({
    required LatLng userLocation,
    double radiusKm = 5.0,
    int hours = 24,
  }) async {
    try {
      final body = json.encode({
        'latitude': userLocation.latitude,
        'longitude': userLocation.longitude,
        'radius_km': radiusKm,
        'hours': hours,
      });

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/api/alerts/generate/'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final alerts = data['alerts'] as List<dynamic>;

        return alerts
            .map((json) => _alertFromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to generate alerts: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error generating alerts: $e');
      throw Exception('Error generating alerts: $e');
    }
  }

  /// Convert JSON to Alert model
  Alert _alertFromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id']?.toString() ?? '',
      type: _alertTypeFromString(json['alert_type'] as String? ?? 'highRisk'),
      severity: _severityFromString(json['severity'] as String? ?? 'medium'),
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      confirmedBy: json['confirmed_by'] as int?,
      icon: _getIconForAlertType(
        json['alert_type'] as String? ?? 'highRisk',
      ),
      iconColor: _getColorForSeverity(
        json['severity'] as String? ?? 'medium',
      ).iconColor,
      iconBackgroundColor: _getColorForSeverity(
        json['severity'] as String? ?? 'medium',
      ).backgroundColor,
    );
  }

  String _severityToString(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.high:
        return 'high';
      case AlertSeverity.medium:
        return 'medium';
      case AlertSeverity.low:
        return 'low';
      case AlertSeverity.info:
        return 'info';
    }
  }

  AlertSeverity _severityFromString(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return AlertSeverity.high;
      case 'medium':
        return AlertSeverity.medium;
      case 'low':
        return AlertSeverity.low;
      case 'info':
        return AlertSeverity.info;
      default:
        debugPrint('Unknown severity: $severity');
        return AlertSeverity.medium;
    }
  }

  String _alertTypeToString(AlertType type) {
    switch (type) {
      case AlertType.highRisk:
        return 'highRisk';
      case AlertType.theft:
        return 'theft';
      case AlertType.eventCrowd:
        return 'eventCrowd';
      case AlertType.trafficCleared:
        return 'trafficCleared';
    }
  }

  AlertType _alertTypeFromString(String type) {
    switch (type) {
      case 'highRisk':
        return AlertType.highRisk;
      case 'theft':
        return AlertType.theft;
      case 'eventCrowd':
        return AlertType.eventCrowd;
      case 'trafficCleared':
        return AlertType.trafficCleared;
      default:
        debugPrint('Unknown alert type: $type');
        return AlertType.highRisk;
    }
  }

  IconData _getIconForAlertType(String type) {
    switch (type) {
      case 'highRisk':
        return Icons.warning;
      case 'theft':
        return Icons.star;
      case 'eventCrowd':
        return Icons.people;
      case 'trafficCleared':
        return Icons.check_circle;
      default:
        return Icons.warning;
    }
  }

  ({Color iconColor, Color backgroundColor}) _getColorForSeverity(
    String severity,
  ) {
    switch (severity.toLowerCase()) {
      case 'high':
        return (
          iconColor: const Color(0xFFFF4C4C),
          backgroundColor: const Color(0xFFFFF0F0),
        );
      case 'medium':
        return (
          iconColor: const Color(0xFFFF9500),
          backgroundColor: const Color(0x00fff4e5),
        );
      case 'low':
        return (
          iconColor: const Color(0xFF5856D6),
          backgroundColor: const Color(0xFFF0F0FF),
        );
      case 'info':
        return (
          iconColor: const Color(0xFF8E8E93),
          backgroundColor: const Color(0xFFF5F5F5),
        );
      default:
        return (
          iconColor: const Color(0xFF8E8E93),
          backgroundColor: const Color(0xFFF5F5F5),
        );
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
