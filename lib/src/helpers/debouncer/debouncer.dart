import 'dart:async';

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  run(Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
}

// Usage
// to start
// final _debouncer = Debouncer(delay: Duration(milliseconds: 250));
//
// // and later
// onTextChange(String text) {
//   _debouncer.run(() => print(text));
// }
