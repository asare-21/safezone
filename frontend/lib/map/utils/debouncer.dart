import 'dart:async';

/// A utility class that debounces function calls.
/// Useful for preventing excessive function executions
/// during rapid user input (like search).
class Debouncer {
  Debouncer({required this.milliseconds});

  final int milliseconds;
  Timer? _timer;

  /// Runs the provided action after the debounce delay.
  /// Cancels any previously scheduled action.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancels any pending debounced action.
  void dispose() {
    _timer?.cancel();
  }
}
