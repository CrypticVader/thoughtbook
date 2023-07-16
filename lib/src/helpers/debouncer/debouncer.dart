import 'dart:async';

/// Helper class that can be used to debounce events
///
/// To start,
///```
/// final _debouncer = Debouncer(delay: Duration(milliseconds: 250));
///```
/// and later,
/// ```
/// onTextChange(String text) {
///   _debouncer.run(() => print(text));
/// }
/// ```
class Debouncer {
  final Duration delay;
  Timer? _timer;

  /// Helper class that can be used to debounce events
  ///
  /// To start,
  ///```
  /// final _debouncer = Debouncer(delay: Duration(milliseconds: 250));
  ///```
  /// and later,
  /// ```
  /// onTextChange(String text) {
  ///   _debouncer.run(() => print(text));
  /// }
  /// ```
  /// This constructor creates a [Debouncer] with the specified delay
  Debouncer({required this.delay});

  run(Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
}
