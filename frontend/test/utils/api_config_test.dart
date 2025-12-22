import 'package:flutter_test/flutter_test.dart';
import 'package:safe_zone/utils/api_config.dart';

void main() {
  group('ApiConfig', () {
    test('getBaseUrl returns correct URL based on platform', () {
      // This test verifies the logic of ApiConfig
      // Actual platform detection happens at runtime
      
      final baseUrl = ApiConfig.getBaseUrl();
      
      // In test environment, should return a valid URL
      expect(baseUrl, isNotNull);
      expect(baseUrl, isNotEmpty);
      
      // URL should start with http:// or https://
      expect(baseUrl.startsWith('http://') || baseUrl.startsWith('https://'), 
             isTrue);
      
      // URL should end with port number in development
      if (ApiConfig.isDevelopment) {
        expect(baseUrl.contains(':8000'), isTrue);
      }
    });
    
    test('isDevelopment flag is correct', () {
      // In test mode, should be in development
      expect(ApiConfig.isDevelopment, isTrue);
    });
    
    test('isProduction flag is correct', () {
      // In test mode, should not be in production
      expect(ApiConfig.isProduction, isFalse);
    });
  });
}
