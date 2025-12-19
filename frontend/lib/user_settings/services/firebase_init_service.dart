import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:safe_zone/user_settings/services/device_api_service.dart';

/// Service to initialize Firebase Cloud Messaging and register device with backend
class FirebaseInitService {
  FirebaseInitService({
    required this.deviceApiService,
  });

  final DeviceApiService deviceApiService;

  /// Initialize Firebase Messaging and register device with backend
  Future<void> initialize() async {
    try {
      // Request notification permissions
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('User granted provisional permission');
      } else {
        debugPrint('User declined or has not accepted permission');
        return;
      }

      // Get FCM token
      final fcmToken = await messaging.getToken();
      if (fcmToken == null) {
        debugPrint('Failed to get FCM token');
        return;
      }

      debugPrint('FCM Token: $fcmToken');

      // Get device ID
      final deviceId = await _getDeviceId();
      final platform = _getPlatform();

      // Register device with backend
      try {
        await deviceApiService.registerDevice(
          deviceId: deviceId,
          fcmToken: fcmToken,
          platform: platform,
        );
        debugPrint('Device registered with backend successfully');

        // Save device ID for future use
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('device_id', deviceId);
      } catch (e) {
        debugPrint('Failed to register device with backend: $e');
        // Don't fail app initialization if backend registration fails
      }

      // Listen for token refresh
      messaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM token refreshed: $newToken');
        // Re-register with new token
        deviceApiService.registerDevice(
          deviceId: deviceId,
          fcmToken: newToken,
          platform: platform,
        ).catchError((e) {
          debugPrint('Failed to update token: $e');
        });
      });

      // Setup foreground message handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint(
            'Message also contained a notification: ${message.notification}',
          );
        }
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
    }
  }

  /// Get unique device ID
  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString('device_id');

    if (deviceId != null) {
      return deviceId;
    }

    // Generate device ID from device info
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? _generateRandomId();
      } else {
        deviceId = _generateRandomId();
      }
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      deviceId = _generateRandomId();
    }

    await prefs.setString('device_id', deviceId);
    return deviceId;
  }

  /// Get platform name
  String _getPlatform() {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else {
      return 'web';
    }
  }

  /// Generate random ID as fallback
  String _generateRandomId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'device_$timestamp';
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
  debugPrint('Message data: ${message.data}');
}
