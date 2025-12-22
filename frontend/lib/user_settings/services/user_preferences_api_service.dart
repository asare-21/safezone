import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Model for user preferences
class UserPreferencesModel {
  UserPreferencesModel({
    required this.deviceId,
    required this.alertRadius,
    required this.defaultZoom,
    required this.locationIcon,
    required this.pushNotifications,
    required this.proximityAlerts,
    required this.soundVibration,
    required this.anonymousReporting,
  });

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      deviceId: json['device_id'] as String? ?? '',
      alertRadius: (json['alert_radius'] as num?)?.toDouble() ?? 5.0,
      defaultZoom: (json['default_zoom'] as num?)?.toDouble() ?? 15.0,
      locationIcon: json['location_icon'] as String? ?? 'default',
      pushNotifications: json['push_notifications'] as bool? ?? true,
      proximityAlerts: json['proximity_alerts'] as bool? ?? true,
      soundVibration: json['sound_vibration'] as bool? ?? true,
      anonymousReporting: json['anonymous_reporting'] as bool? ?? false,
    );
  }

  final String deviceId;
  final double alertRadius;
  final double defaultZoom;
  final String locationIcon;
  final bool pushNotifications;
  final bool proximityAlerts;
  final bool soundVibration;
  final bool anonymousReporting;

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'alert_radius': alertRadius,
      'default_zoom': defaultZoom,
      'location_icon': locationIcon,
      'push_notifications': pushNotifications,
      'proximity_alerts': proximityAlerts,
      'sound_vibration': soundVibration,
      'anonymous_reporting': anonymousReporting,
    };
  }

  UserPreferencesModel copyWith({
    String? deviceId,
    double? alertRadius,
    double? defaultZoom,
    String? locationIcon,
    bool? pushNotifications,
    bool? proximityAlerts,
    bool? soundVibration,
    bool? anonymousReporting,
  }) {
    return UserPreferencesModel(
      deviceId: deviceId ?? this.deviceId,
      alertRadius: alertRadius ?? this.alertRadius,
      defaultZoom: defaultZoom ?? this.defaultZoom,
      locationIcon: locationIcon ?? this.locationIcon,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      proximityAlerts: proximityAlerts ?? this.proximityAlerts,
      soundVibration: soundVibration ?? this.soundVibration,
      anonymousReporting: anonymousReporting ?? this.anonymousReporting,
    );
  }
}

/// Service for managing user preferences via API
class UserPreferencesApiService {
  UserPreferencesApiService({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  /// Get user preferences for a device
  Future<UserPreferencesModel> getPreferences(String deviceId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/api/preferences/$deviceId/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return UserPreferencesModel.fromJson(data);
      } else {
        throw Exception(
          'Failed to load preferences: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching preferences: $e');
      rethrow;
    }
  }

  /// Update user preferences for a device
  Future<UserPreferencesModel> updatePreferences({
    required String deviceId,
    double? alertRadius,
    double? defaultZoom,
    String? locationIcon,
    bool? pushNotifications,
    bool? proximityAlerts,
    bool? soundVibration,
    bool? anonymousReporting,
  }) async {
    try {
      final body = <String, dynamic>{};
      
      if (alertRadius != null) body['alert_radius'] = alertRadius;
      if (defaultZoom != null) body['default_zoom'] = defaultZoom;
      if (locationIcon != null) body['location_icon'] = locationIcon;
      if (pushNotifications != null) {
        body['push_notifications'] = pushNotifications;
      }
      if (proximityAlerts != null) {
        body['proximity_alerts'] = proximityAlerts;
      }
      if (soundVibration != null) body['sound_vibration'] = soundVibration;
      if (anonymousReporting != null) {
        body['anonymous_reporting'] = anonymousReporting;
      }

      final response = await _httpClient.patch(
        Uri.parse('$baseUrl/api/preferences/$deviceId/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return UserPreferencesModel.fromJson(data);
      } else {
        throw Exception(
          'Failed to update preferences: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error updating preferences: $e');
      rethrow;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
