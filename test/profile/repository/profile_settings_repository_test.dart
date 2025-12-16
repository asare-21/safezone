import 'package:flutter_test/flutter_test.dart';
import 'package:safe_zone/profile/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ProfileSettingsRepository', () {
    late ProfileSettingsRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = ProfileSettingsRepository(prefs);
    });

    test('getAnonymousReporting returns true by default', () {
      expect(repository.getAnonymousReporting(), isTrue);
    });

    test('setAnonymousReporting saves value to preferences', () async {
      await repository.setAnonymousReporting(false);
      expect(repository.getAnonymousReporting(), isFalse);
    });

    test('setAnonymousReporting persists true value', () async {
      await repository.setAnonymousReporting(true);
      expect(repository.getAnonymousReporting(), isTrue);
    });

    test('getAnonymousReporting retrieves saved value', () async {
      await repository.setAnonymousReporting(false);
      
      // Create a new instance to verify persistence
      final prefs = await SharedPreferences.getInstance();
      final newRepository = ProfileSettingsRepository(prefs);
      
      expect(newRepository.getAnonymousReporting(), isFalse);
    });
  });
}
