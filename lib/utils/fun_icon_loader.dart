import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Loads and manages fun icons for user location markers
class FunIconLoader {
  static final FunIconLoader _instance = FunIconLoader._internal();

  factory FunIconLoader() => _instance;

  FunIconLoader._internal() {
    _initialize();
  }

  static const List<String> _defaultIconPaths = [
    'assets/icons/animal.png',
    'assets/icons/courier.png',
    'assets/icons/donatello.png',
    'assets/icons/food.png',
    'assets/icons/penguin.png',
  ];

  late List<String> _availableIcons;
  final Random _random = Random();
  final Map<String, String> _userIconCache = {};
  bool _assetsValidated = false;

  void _initialize() {
    _availableIcons = List.unmodifiable(_defaultIconPaths);
  }

  /// Get all available icon paths
  List<String> get funIcons => _availableIcons;

  /// Add custom icons to the available set
  void addCustomIcons(List<String> customIconPaths) {
    _availableIcons = List.unmodifiable([
      ..._availableIcons,
      ...customIconPaths,
    ]);
  }

  /// Get a random icon
  String get randomIcon {
    if (_availableIcons.isEmpty) {
      throw StateError('No icons available');
    }
    return _availableIcons[_random.nextInt(_availableIcons.length)];
  }

  /// Get a deterministic icon for a user ID
  String iconForUser(String userId) {
    return _userIconCache.putIfAbsent(
      userId,
      () => _deterministicIcon(userId),
    );
  }

  String _deterministicIcon(String userId) {
    final hash = userId.hashCode.abs();
    return _availableIcons[hash % _availableIcons.length];
  }

  /// Validate all icon assets exist
  Future<bool> validateAssets() async {
    if (_assetsValidated) return true;

    for (final path in _availableIcons) {
      try {
        await rootBundle.load(path);
      } catch (e) {
        debugPrint('❌ Missing icon asset: $path');
        return false;
      }
    }

    _assetsValidated = true;
    debugPrint('✅ All ${_availableIcons.length} icon assets validated');
    return true;
  }

  /// Preload icons for immediate use
  Future<void> preload(BuildContext context) async {
    try {
      for (final path in _availableIcons) {
        final provider = AssetImage(path);
        await precacheImage(provider, context);

        // Check if image is actually in cache
        final key = await provider.obtainKey(const ImageConfiguration());
        final imageStream = provider.resolve(const ImageConfiguration());

        final completer = Completer<void>();
        final listener = ImageStreamListener(
          (info, synchronousCall) => completer.complete(),
          onError: (error, stackTrace) {
            debugPrint('Failed to preload $path: $error');
            completer.complete();
          },
        );

        imageStream.addListener(listener);
        await completer.future;
        imageStream.removeListener(listener);
      }

      debugPrint('🎨 ${_availableIcons.length} icons preloaded');
    } catch (e) {
      debugPrint('⚠️ Icon preloading failed: $e');
    }
  }

  /// Clear user icon cache (useful for testing or logout)
  void clearCache() {
    _userIconCache.clear();
  }

  /// Get icon info for debugging
  Map<String, dynamic> get debugInfo {
    return {
      'totalIcons': _availableIcons.length,
      'cachedUsers': _userIconCache.length,
      'assetsValidated': _assetsValidated,
      'iconPaths': _availableIcons,
    };
  }
}

/// Extension for easier usage with widgets
extension FunIconLoaderExtension on BuildContext {
  FunIconLoader get funIconLoader => FunIconLoader();
}
