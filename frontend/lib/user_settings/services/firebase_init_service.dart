import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:safe_zone/user_settings/services/device_api_service.dart';
import 'package:safe_zone/utils/device_id_utils.dart';

/// Service to initialize Firebase Cloud Messaging and register device with backend
class FirebaseInitService {
  FirebaseInitService({
    required this.deviceApiService,
  });

  final DeviceApiService deviceApiService;

  /// Initialize Firebase Messaging and register device with backend
  Future<void> initialize() async {
    // Get and save device ID first (before any Firebase operations that might fail)
    // This ensures the scoring system works even if push notifications are declined
    final deviceId = await DeviceIdUtils.getDeviceId();
    
    try {
      // Request notification permissions
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();

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

      final platform = _getPlatform();

      // Register device with backend
      try {
        await deviceApiService.registerDevice(
          deviceId: deviceId,
          fcmToken: fcmToken,
          platform: platform,
        );
        debugPrint('Device registered with backend successfully');
      } catch (e) {
        debugPrint('Failed to register device with backend: $e');
        // Don't fail app initialization if backend registration fails
      }

      // Listen for token refresh
      messaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM token refreshed: $newToken');
        // Re-register with new token
        deviceApiService
            .registerDevice(
              deviceId: deviceId,
              fcmToken: newToken,
              platform: platform,
            )
            .catchError((Object e) {
              debugPrint('Failed to update token: $e');
              return {
                'success': false,
                'error': e.toString(),
              };
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
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
    }
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
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
  debugPrint('Message data: ${message.data}');
}
