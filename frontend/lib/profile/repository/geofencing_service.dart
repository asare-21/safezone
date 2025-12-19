import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_zone/profile/models/safe_zone_model.dart';
import 'package:safe_zone/profile/repository/safe_zone_repository.dart';

/// Callback for geofencing events
typedef GeofenceCallback = void Function(SafeZone zone, GeofenceEvent event);

/// Geofencing event types
enum GeofenceEvent {
  enter,
  exit,
}

/// Service for monitoring geofence events
class GeofencingService {
  GeofencingService({
    SafeZoneRepository? repository,
  }) : _repository = repository ?? SafeZoneRepository();

  final SafeZoneRepository _repository;
  StreamSubscription<Position>? _positionSubscription;
  final Map<String, bool> _zoneStates = {}; // Track if user is inside each zone
  final List<GeofenceCallback> _callbacks = [];

  /// Start monitoring geofences
  Future<void> startMonitoring() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) {
          print('Location services are disabled.');
        }
        return;
      }

      // Check location permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            print('Location permissions are denied');
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print('Location permissions are permanently denied');
        }
        return;
      }

      // Initialize zone states
      final zones = await _repository.loadSafeZones();
      for (final zone in zones) {
        if (zone.isActive) {
          _zoneStates[zone.id] = false;
        }
      }

      // Start listening to position updates
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 50, // Update every 50 meters
      );

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(_onPositionUpdate);
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error starting geofencing: $e');
      }
    }
  }

  /// Stop monitoring geofences
  void stopMonitoring() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _zoneStates.clear();
  }

  /// Register a callback for geofence events
  void onGeofenceEvent(GeofenceCallback callback) {
    _callbacks.add(callback);
  }

  /// Remove a callback
  void removeCallback(GeofenceCallback callback) {
    _callbacks.remove(callback);
  }

  /// Handle position updates
  Future<void> _onPositionUpdate(Position position) async {
    try {
      final zones = await _repository.loadSafeZones();
      final currentLocation = LatLng(position.latitude, position.longitude);

      for (final zone in zones) {
        if (!zone.isActive) continue;

        final wasInside = _zoneStates[zone.id] ?? false;
        final isInside = zone.contains(currentLocation);

        // Check for entry
        if (!wasInside && isInside && zone.notifyOnEnter) {
          _triggerEvent(zone, GeofenceEvent.enter);
        }

        // Check for exit
        if (wasInside && !isInside && zone.notifyOnExit) {
          _triggerEvent(zone, GeofenceEvent.exit);
        }

        _zoneStates[zone.id] = isInside;
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error processing position update: $e');
      }
    }
  }

  /// Trigger geofence event
  void _triggerEvent(SafeZone zone, GeofenceEvent event) {
    for (final callback in _callbacks) {
      callback(zone, event);
    }
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _callbacks.clear();
  }
}
