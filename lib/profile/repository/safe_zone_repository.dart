import 'dart:convert';

import 'package:safe_zone/profile/models/safe_zone_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing safe zones persistence
class SafeZoneRepository {
  SafeZoneRepository({SharedPreferences? sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  final SharedPreferences? _sharedPreferences;
  SharedPreferences? _cachedPreferences;

  static const String _safeZonesKey = 'safe_zones';

  /// Get SharedPreferences instance (cached)
  Future<SharedPreferences> _getPreferences() async {
    if (_sharedPreferences != null) return _sharedPreferences;
    _cachedPreferences ??= await SharedPreferences.getInstance();
    return _cachedPreferences!;
  }

  /// Load all safe zones
  Future<List<SafeZone>> loadSafeZones() async {
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
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  /// Save all safe zones
  Future<void> saveSafeZones(List<SafeZone> safeZones) async {
    try {
      final prefs = await _getPreferences();
      final jsonList = safeZones.map((zone) => zone.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString(_safeZonesKey, jsonString);
    } catch (e) {
      // Fail silently
      rethrow;
    }
  }

  /// Add a new safe zone
  Future<void> addSafeZone(SafeZone safeZone) async {
    final zones = await loadSafeZones();
    zones.add(safeZone);
    await saveSafeZones(zones);
  }

  /// Update an existing safe zone
  Future<void> updateSafeZone(SafeZone safeZone) async {
    final zones = await loadSafeZones();
    final index = zones.indexWhere((zone) => zone.id == safeZone.id);
    if (index != -1) {
      zones[index] = safeZone;
      await saveSafeZones(zones);
    }
  }

  /// Delete a safe zone
  Future<void> deleteSafeZone(String id) async {
    final zones = await loadSafeZones();
    zones.removeWhere((zone) => zone.id == id);
    await saveSafeZones(zones);
  }

  /// Clear all safe zones
  Future<void> clearSafeZones() async {
    final prefs = await _getPreferences();
    await prefs.remove(_safeZonesKey);
  }
}
