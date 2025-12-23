import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Utility class for managing device ID across the app.
/// Ensures consistent device ID retrieval and storage.
class DeviceIdUtils {
  /// Get the device ID, generating and saving it if necessary.
  /// This ensures consistent device ID across the app.
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString('device_id');

    if (deviceId != null) {
      return deviceId;
    }

    // Generate device ID from device info
    deviceId = await _generateDeviceId();

    // Save to SharedPreferences
    await prefs.setString('device_id', deviceId);
    return deviceId;
  }

  /// Generate device ID from device info
  static Future<String> _generateDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? _generateRandomId();
      } else {
        return _generateRandomId();
      }
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      return _generateRandomId();
    }
  }

  /// Generate random ID as fallback
  static String _generateRandomId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'device_$timestamp';
  }
}
