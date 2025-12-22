import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:safe_zone/profile/models/safe_zone_model.dart';
import 'package:safe_zone/user_settings/services/safe_zone_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing safe zones persistence
class SafeZoneRepository {
  SafeZoneRepository({
    SharedPreferences? sharedPreferences,
    SafeZoneApiService? apiService,
  })  : _sharedPreferences = sharedPreferences,
        _apiService = apiService;

  final SharedPreferences? _sharedPreferences;
  final SafeZoneApiService? _apiService;
  SharedPreferences? _cachedPreferences;

  static const String _safeZonesKey = 'safe_zones';
  static const String _deviceIdKey = 'device_id';

  /// Get SharedPreferences instance (cached)
  Future<SharedPreferences> _getPreferences() async {
    if (_sharedPreferences != null) return _sharedPreferences;
    _cachedPreferences ??= await SharedPreferences.getInstance();
    return _cachedPreferences!;
  }

  /// Get device ID from shared preferences
  Future<String?> _getDeviceId() async {
    final prefs = await _getPreferences();
    return prefs.getString(_deviceIdKey);
  }

  /// Load all safe zones
  /// Tries to load from backend first, falls back to local storage
  Future<List<SafeZone>> loadSafeZones() async {
    try {
      // Try to load from backend if API service is available and device is registered
      final apiService = _apiService;
      if (apiService != null) {
        final deviceId = await _getDeviceId();
        if (deviceId != null) {
          try {
            final zones = await apiService.getSafeZones(deviceId);
            // Cache the zones locally
            await _saveSafeZonesLocally(zones);
            return zones;
          } catch (e) {
            if (kDebugMode) {
              print('Failed to load from backend, using local cache: $e');
            }
            // Fall through to local storage
          }
        }
      }

      // Load from local storage
      return _loadSafeZonesLocally();
    } on Exception catch (e) {
      // Return empty list on error
      if (kDebugMode) {
        print(e);
      }
      return [];
    }
  }

  /// Load safe zones from local storage only
  Future<List<SafeZone>> _loadSafeZonesLocally() async {
    try {
      final prefs = await _getPreferences();
      final jsonString = prefs.getString(_safeZonesKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => SafeZone.fromJson(json as Map<String, dynamic>))
          .toList();
    } on Exception catch (e) {
      // Return empty list on error
      if (kDebugMode) {
        print(e);
      }
      return [];
    }
  }

  /// Save safe zones to local storage only
  Future<void> _saveSafeZonesLocally(List<SafeZone> safeZones) async {
    final prefs = await _getPreferences();
    final jsonList = safeZones.map((zone) => zone.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await prefs.setString(_safeZonesKey, jsonString);
  }

  /// Save all safe zones
  Future<void> saveSafeZones(List<SafeZone> safeZones) async {
    await _saveSafeZonesLocally(safeZones);
  }

  /// Add a new safe zone
  Future<void> addSafeZone(SafeZone safeZone) async {
    // Try to sync with backend if available
    final apiService = _apiService;
    if (apiService != null) {
      final deviceId = await _getDeviceId();
      if (deviceId != null) {
        try {
          final createdZone = await apiService.createSafeZone(
            deviceId: deviceId,
            safeZone: safeZone,
          );
          // Update local storage with backend response
          final zones = await _loadSafeZonesLocally();
          zones.add(createdZone);
          await _saveSafeZonesLocally(zones);
          return;
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync with backend, saving locally: $e');
          }
          // Fall through to local save
        }
      }
    }

    // Save locally only
    final zones = await _loadSafeZonesLocally();
    zones.add(safeZone);
    await _saveSafeZonesLocally(zones);
  }

  /// Update an existing safe zone
  Future<void> updateSafeZone(SafeZone safeZone) async {
    // Try to sync with backend if available
    final apiService = _apiService;
    if (apiService != null) {
      final deviceId = await _getDeviceId();
      if (deviceId != null) {
        try {
          final updatedZone = await apiService.updateSafeZone(
            deviceId: deviceId,
            safeZone: safeZone,
          );
          // Update local storage with backend response
          final zones = await _loadSafeZonesLocally();
          final index = zones.indexWhere((zone) => zone.id == updatedZone.id);
          if (index != -1) {
            zones[index] = updatedZone;
            await _saveSafeZonesLocally(zones);
          }
          return;
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync with backend, saving locally: $e');
          }
          // Fall through to local save
        }
      }
    }

    // Save locally only
    final zones = await _loadSafeZonesLocally();
    final index = zones.indexWhere((zone) => zone.id == safeZone.id);
    if (index != -1) {
      zones[index] = safeZone;
      await _saveSafeZonesLocally(zones);
    }
  }

  /// Delete a safe zone
  Future<void> deleteSafeZone(String id) async {
    // Try to sync with backend if available
    final apiService = _apiService;
    if (apiService != null) {
      final deviceId = await _getDeviceId();
      if (deviceId != null) {
        try {
          await apiService.deleteSafeZone(id);
          // Update local storage after successful backend deletion
          final zones = await _loadSafeZonesLocally();
          zones.removeWhere((zone) => zone.id == id);
          await _saveSafeZonesLocally(zones);
          return;
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync with backend, deleting locally: $e');
          }
          // Fall through to local delete
        }
      }
    }

    // Delete locally only
    final zones = await _loadSafeZonesLocally();
    zones.removeWhere((zone) => zone.id == id);
    await _saveSafeZonesLocally(zones);
  }

  /// Clear all safe zones
  Future<void> clearSafeZones() async {
    final prefs = await _getPreferences();
    await prefs.remove(_safeZonesKey);
  }
}
