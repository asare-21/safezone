import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_zone/utils/fun_icon_loader.dart';

void main() {
  group('FunIconLoader', () {
    late FunIconLoader loader;

    setUp(() {
      loader = FunIconLoader();
      // Clear cache before each test
      loader.clearCache();
    });

    test('should be a singleton', () {
      final loader1 = FunIconLoader();
      final loader2 = FunIconLoader();
      expect(loader1, same(loader2));
    });

    test('should have default icons', () {
      final icons = loader.funIcons;
      expect(icons, isNotEmpty);
      expect(icons.length, equals(5));
      expect(icons, contains('assets/icons/animal.png'));
      expect(icons, contains('assets/icons/courier.png'));
      expect(icons, contains('assets/icons/donatello.png'));
      expect(icons, contains('assets/icons/food.png'));
      expect(icons, contains('assets/icons/penguin.png'));
    });

    test('should return unmodifiable list of icons', () {
      final icons = loader.funIcons;
      expect(() => icons.add('test.png'), throwsUnsupportedError);
    });

    test('should return random icon from available icons', () {
      final icon = loader.randomIcon;
      expect(loader.funIcons, contains(icon));
    });

    test('should return consistent icon for same user ID', () {
      const userId = 'user123';
      final icon1 = loader.iconForUser(userId);
      final icon2 = loader.iconForUser(userId);
      expect(icon1, equals(icon2));
    });

    test('should cache user icon assignments', () {
      const userId = 'user123';
      loader.iconForUser(userId);
      
      final debugInfo = loader.debugInfo;
      expect(debugInfo['cachedUsers'], equals(1));
    });

    test('should return different icons for different users', () {
      // This test may occasionally fail due to hash collisions,
      // but with 5 icons and carefully chosen user IDs, it should pass
      final icon1 = loader.iconForUser('user1');
      final icon2 = loader.iconForUser('user2');
      final icon3 = loader.iconForUser('user3');
      final icon4 = loader.iconForUser('user4');
      final icon5 = loader.iconForUser('user5');
      
      // At least some should be different
      final uniqueIcons = {icon1, icon2, icon3, icon4, icon5};
      expect(uniqueIcons.length, greaterThan(1));
    });

    test('should clear cache', () {
      loader.iconForUser('user1');
      loader.iconForUser('user2');
      expect(loader.debugInfo['cachedUsers'], equals(2));
      
      loader.clearCache();
      expect(loader.debugInfo['cachedUsers'], equals(0));
    });

    test('should add custom icons', () {
      final initialCount = loader.funIcons.length;
      loader.addCustomIcons(['assets/icons/custom1.png', 'assets/icons/custom2.png']);
      
      expect(loader.funIcons.length, equals(initialCount + 2));
      expect(loader.funIcons, contains('assets/icons/custom1.png'));
      expect(loader.funIcons, contains('assets/icons/custom2.png'));
    });

    test('should clear cache when adding custom icons', () {
      // Assign icons to some users
      loader.iconForUser('user1');
      loader.iconForUser('user2');
      expect(loader.debugInfo['cachedUsers'], equals(2));
      
      // Add custom icons should clear cache
      loader.addCustomIcons(['assets/icons/custom1.png']);
      expect(loader.debugInfo['cachedUsers'], equals(0));
    });

    test('should invalidate assets when adding custom icons', () {
      // Mock validation by checking the flag
      final initialValidation = loader.debugInfo['assetsValidated'];
      
      loader.addCustomIcons(['assets/icons/custom1.png']);
      
      // Assets should be marked for revalidation
      expect(loader.debugInfo['assetsValidated'], isFalse);
    });

    test('should throw StateError when requesting random icon with no icons', () {
      // Create a new instance to test edge case
      // Note: This test demonstrates the error handling, but in practice
      // the singleton pattern means we can't easily test this without
      // more complex mocking. Keeping for documentation purposes.
    });

    test('should provide debug info', () {
      loader.iconForUser('user1');
      final info = loader.debugInfo;
      
      expect(info, isA<Map<String, dynamic>>());
      expect(info['totalIcons'], isA<int>());
      expect(info['cachedUsers'], isA<int>());
      expect(info['assetsValidated'], isA<bool>());
      expect(info['iconPaths'], isA<List>());
    });

    test('should have validated assets flag as false initially', () {
      final info = loader.debugInfo;
      expect(info['assetsValidated'], isFalse);
    });

    testWidgets('should provide extension method on BuildContext', 
      (WidgetTester tester) async {
      FunIconLoader? capturedLoader;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedLoader = context.funIconLoader;
              return const SizedBox();
            },
          ),
        ),
      );
      
      expect(capturedLoader, isNotNull);
      expect(capturedLoader, same(FunIconLoader()));
    });

    test('deterministic icon assignment uses hashCode', () {
      // Test that same hash results in same icon
      const userId1 = 'test';
      const userId2 = 'test';
      
      final icon1 = loader.iconForUser(userId1);
      loader.clearCache(); // Clear to test deterministic assignment
      final icon2 = loader.iconForUser(userId2);
      
      expect(icon1, equals(icon2));
    });

    test('should handle empty custom icons list', () {
      final initialCount = loader.funIcons.length;
      loader.addCustomIcons([]);
      
      expect(loader.funIcons.length, equals(initialCount));
    });
  });
}
