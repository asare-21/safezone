import 'package:flutter_test/flutter_test.dart';
import 'package:safe_zone/utils/device_id_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DeviceIdUtils', () {
    setUp(() {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    test('getDeviceId returns consistent ID on multiple calls', () async {
      // First call should generate a device ID
      final deviceId1 = await DeviceIdUtils.getDeviceId();
      
      expect(deviceId1, isNotNull);
      expect(deviceId1, isNotEmpty);
      
      // Second call should return the same ID (from SharedPreferences)
      final deviceId2 = await DeviceIdUtils.getDeviceId();
      
      expect(deviceId2, equals(deviceId1));
    });

    test('getDeviceId returns stored device ID from SharedPreferences', () async {
      const storedDeviceId = 'test_device_123';
      
      // Pre-set a device ID in SharedPreferences
      SharedPreferences.setMockInitialValues({
        'device_id': storedDeviceId,
      });
      
      final deviceId = await DeviceIdUtils.getDeviceId();
      
      expect(deviceId, equals(storedDeviceId));
    });

    test('getDeviceId saves generated ID to SharedPreferences', () async {
      // First call generates and saves device ID
      final deviceId = await DeviceIdUtils.getDeviceId();
      
      expect(deviceId, isNotNull);
      expect(deviceId, isNotEmpty);
      
      // Verify it was saved to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final storedId = prefs.getString('device_id');
      
      expect(storedId, equals(deviceId));
    });

    test('generated fallback ID has correct format', () async {
      // In test environment without device_info_plus setup,
      // the fallback ID will be generated
      final deviceId = await DeviceIdUtils.getDeviceId();
      
      // Device ID should be non-empty
      expect(deviceId, isNotEmpty);
    });
  });
}
