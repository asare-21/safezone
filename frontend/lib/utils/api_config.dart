import 'dart:io';

import 'package:flutter/foundation.dart';

/// API configuration for different platforms and environments
class ApiConfig {
  /// Get the appropriate base URL based on the platform
  /// 
  /// - Android Emulator: Uses 10.0.2.2 to reach host machine
  /// - iOS Simulator/Web/Desktop: Uses 127.0.0.1
  /// - Production: Should use actual server URL
  static String getBaseUrl() {
    // In production, use environment variable or actual server URL
    if (kReleaseMode) {
      // TODO: Replace with actual production API URL
      const productionUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://api.safezone.com',
      );
      return productionUrl;
    }

    // Development mode - use platform-specific localhost
    if (!kIsWeb && Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to reach host machine
      return 'http://10.0.2.2:8000';
    }

    // iOS simulator, web, desktop, and other platforms use 127.0.0.1
    return 'http://127.0.0.1:8000';
  }

  /// Check if running on Android emulator
  static bool get isAndroidEmulator {
    return !kIsWeb && Platform.isAndroid;
  }

  /// Check if in development mode
  static bool get isDevelopment {
    return kDebugMode || kProfileMode;
  }

  /// Check if in production mode
  static bool get isProduction {
    return kReleaseMode;
  }
}
