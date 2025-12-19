import 'package:flutter_test/flutter_test.dart';
import 'package:safe_zone/map/utils/debouncer.dart';

void main() {
  group('Debouncer', () {
    test('executes action after delay', () async {
      final debouncer = Debouncer(milliseconds: 100);
      var executed = false;

      debouncer.run(() {
        executed = true;
      });

      // Should not execute immediately
      expect(executed, isFalse);

      // Wait for debounce delay
      await Future<void>.delayed(const Duration(milliseconds: 150));

      // Should have executed
      expect(executed, isTrue);

      debouncer.dispose();
    });

    test('cancels previous action when called again', () async {
      final debouncer = Debouncer(milliseconds: 100);
      var firstExecuted = false;
      var secondExecuted = false;

      debouncer.run(() {
        firstExecuted = true;
      });

      // Call again before first executes
      await Future<void>.delayed(const Duration(milliseconds: 50));
      debouncer.run(() {
        secondExecuted = true;
      });

      // Wait for second to execute
      await Future<void>.delayed(const Duration(milliseconds: 150));

      // Only second should have executed
      expect(firstExecuted, isFalse);
      expect(secondExecuted, isTrue);

      debouncer.dispose();
    });

    test('dispose cancels pending action', () async {
      final debouncer = Debouncer(milliseconds: 100);
      var executed = false;

      debouncer
        ..run(() {
          executed = true;
        })
        // Dispose before execution
        ..dispose();

      // Wait longer than delay
      await Future<void>.delayed(const Duration(milliseconds: 150));

      // Should not have executed
      expect(executed, isFalse);
    });
  });
}
