import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safe_zone/profile/models/user_score_model.dart';
import 'package:safe_zone/profile/repository/scoring_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Callback for nearby incident detection
typedef NearbyIncidentCallback = void Function(NearbyIncident incident);

/// Service for monitoring user location and detecting nearby incidents
class IncidentProximityService {
  IncidentProximityService({
    ScoringRepository? repository,
    String? deviceId,
  })  : _repository = repository,
        _deviceId = deviceId;

  final ScoringRepository? _repository;
  final String? _deviceId;
  StreamSubscription<Position>? _positionSubscription;
  final List<NearbyIncidentCallback> _callbacks = [];
  final Set<int> _promptedIncidents = {}; // Track incidents we've already prompted about
  
  static const String _promptedIncidentsKey = 'prompted_incidents';
  static const double _defaultRadiusKm = 0.5; // 500 meters
  static const int _checkIntervalSeconds = 30; // Check every 30 seconds
  Timer? _checkTimer;
  Position? _lastPosition;
  bool _isMonitoring = false;

  /// Start monitoring for nearby incidents
  Future<void> startMonitoring({
    required ScoringRepository repository,
    required String deviceId,
    double radiusKm = _defaultRadiusKm,
  }) async {
    if (_isMonitoring) {
      return;
    }

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

      // Load previously prompted incidents
      await _loadPromptedIncidents();

      _isMonitoring = true;

      // Start listening to position updates
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 100, // Update every 100 meters
      );

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((position) {
        _lastPosition = position;
        _checkNearbyIncidents(
          repository: repository,
          deviceId: deviceId,
          radiusKm: radiusKm,
        );
      });

      // Also start a periodic timer to check even if location hasn't changed much
      _checkTimer = Timer.periodic(
        const Duration(seconds: _checkIntervalSeconds),
        (_) {
          if (_lastPosition != null) {
            _checkNearbyIncidents(
              repository: repository,
              deviceId: deviceId,
              radiusKm: radiusKm,
            );
          }
        },
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error starting incident proximity monitoring: $e');
      }
    }
  }

  /// Stop monitoring for nearby incidents
  void stopMonitoring() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _checkTimer?.cancel();
    _checkTimer = null;
    _isMonitoring = false;
  }

  /// Register a callback for nearby incident detection
  void onNearbyIncident(NearbyIncidentCallback callback) {
    _callbacks.add(callback);
  }

  /// Remove a callback
  void removeCallback(NearbyIncidentCallback callback) {
    _callbacks.remove(callback);
  }

  /// Check for nearby incidents
  Future<void> _checkNearbyIncidents({
    required ScoringRepository repository,
    required String deviceId,
    required double radiusKm,
  }) async {
    if (_lastPosition == null) return;

    try {
      final incidents = await repository.getNearbyIncidents(
        latitude: _lastPosition!.latitude,
        longitude: _lastPosition!.longitude,
        deviceId: deviceId,
        radiusKm: radiusKm,
      );

      // Trigger callbacks for incidents we haven't prompted about yet
      for (final incident in incidents) {
        if (!_promptedIncidents.contains(incident.id)) {
          _promptedIncidents.add(incident.id);
          await _savePromptedIncidents();
          _triggerIncidentDetected(incident);
        }
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error checking nearby incidents: $e');
      }
    }
  }

  /// Trigger incident detected event
  void _triggerIncidentDetected(NearbyIncident incident) {
    for (final callback in _callbacks) {
      callback(incident);
    }
  }

  /// Load previously prompted incidents from local storage
  Future<void> _loadPromptedIncidents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final promptedList = prefs.getStringList(_promptedIncidentsKey) ?? [];
      _promptedIncidents.clear();
      // Use tryParse for safer parsing
      for (final idStr in promptedList) {
        final id = int.tryParse(idStr);
        if (id != null) {
          _promptedIncidents.add(id);
        }
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error loading prompted incidents: $e');
      }
    }
  }

  /// Save prompted incidents to local storage
  Future<void> _savePromptedIncidents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _promptedIncidentsKey,
        _promptedIncidents.map((id) => id.toString()).toList(),
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error saving prompted incidents: $e');
      }
    }
  }

  /// Clear prompted incidents history (useful for testing or resetting)
  Future<void> clearPromptedIncidents() async {
    _promptedIncidents.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_promptedIncidentsKey);
  }

  /// Mark an incident as prompted (manually)
  Future<void> markIncidentAsPrompted(int incidentId) async {
    _promptedIncidents.add(incidentId);
    await _savePromptedIncidents();
  }

  /// Check if monitoring is active
  bool get isMonitoring => _isMonitoring;

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _callbacks.clear();
  }
}
