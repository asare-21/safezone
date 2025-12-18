import 'package:flutter/foundation.dart';
import 'package:safe_zone/profile/models/safe_zone_model.dart';
import 'package:safe_zone/profile/repository/geofencing_service.dart';

/// Helper class to manage geofencing notifications
class GeofencingNotificationHelper {
  GeofencingNotificationHelper({
    GeofencingService? geofencingService,
  }) : _geofencingService = geofencingService ?? GeofencingService() {
    _setupNotifications();
  }

  final GeofencingService _geofencingService;

  /// Setup geofencing notifications
  void _setupNotifications() {
    _geofencingService.onGeofenceEvent(_onGeofenceEvent);
  }

  /// Start monitoring geofences
  Future<void> startMonitoring() async {
    await _geofencingService.startMonitoring();
  }

  /// Stop monitoring geofences
  void stopMonitoring() {
    _geofencingService.stopMonitoring();
  }

  /// Handle geofence events
  void _onGeofenceEvent(SafeZone zone, GeofenceEvent event) {
    // This would integrate with the actual notification system
    // For now, we'll just log the event
    if (kDebugMode) {
      final eventType = event == GeofenceEvent.enter ? 'Entered' : 'Exited';
      print('$eventType safe zone: ${zone.name}');
    }

    // In a real implementation, this would trigger a notification
    // through Firebase Cloud Messaging or local notifications
    _showNotification(zone, event);
  }

  /// Show a notification for geofence event
  void _showNotification(SafeZone zone, GeofenceEvent event) {
    // This is a placeholder for actual notification implementation
    // In production, this would use flutter_local_notifications or
    // firebase_messaging to show a notification
    
    final title = event == GeofenceEvent.enter
        ? 'Welcome to ${zone.name}'
        : 'Left ${zone.name}';

    final body = event == GeofenceEvent.enter
        ? 'You have entered your safe zone'
        : 'You have left your safe zone';

    if (kDebugMode) {
      print('Notification: $title - $body');
    }

    // TODO: Implement actual notification using flutter_local_notifications
    // or integrate with existing Firebase notification system
  }

  /// Dispose resources
  void dispose() {
    _geofencingService.dispose();
  }
}
