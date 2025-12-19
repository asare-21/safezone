import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service for managing user devices and FCM tokens
class DeviceApiService {
  DeviceApiService({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  /// Register or update device with FCM token
  Future<Map<String, dynamic>> registerDevice({
    required String deviceId,
    required String fcmToken,
    required String platform,
  }) async {
    try {
      final body = json.encode({
        'device_id': deviceId,
        'fcm_token': fcmToken,
        'platform': platform,
        'is_active': true,
      });

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/api/devices/register/'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('Device registered successfully: ${data['device_id']}');
        return data;
      } else {
        throw Exception(
          'Failed to register device: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error registering device: $e');
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
