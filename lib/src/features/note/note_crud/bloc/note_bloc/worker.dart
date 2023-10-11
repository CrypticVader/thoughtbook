// ignore_for_file: avoid_web_libraries_in_flutter, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:isolate_manager/isolate_manager.dart';
import 'package:js/js.dart' as pjs;
import 'package:js/js_util.dart' as js_util;

@pjs.JS('self')
external dynamic get globalScopeSelf;

/// dart compile js worker.dart -o worker.js -O4

/// In most cases you don't need to modify this function
main() {
  callbackToStream('onmessage', (html.MessageEvent e) {
    return js_util.getProperty(e, 'data');
  }).listen((message) async {
    final Completer completer = Completer();
    completer.future.then(
          (value) => jsSendMessage(value),
      onError: (err, stack) => jsSendMessage(IsolateException(err, stack).toJson()),
    );
    try {
      completer.complete(worker(message));
    } catch (err, stack) {
      jsSendMessage(IsolateException(err, stack).toJson());
    }
  });
}

/// TODO: Modify your function here:
///
///  Do this if you need to throw an exception
///
///  You should only throw the `message` instead of a whole Object because it may
///  not show as expected when sending back to the main app.
///
/// ``` dart
///  return throw 'This is an error that you need to catch in your main app';
/// ```
FutureOr<dynamic> worker(dynamic message) {
  // Best way to use this method is encoding the result to JSON
  // before sending to the main app, then you can decode it back to
  // the return type you want with `workerConverter`.
  return jsonEncode(message);
}

/// Internal function
Stream<T> callbackToStream<J, T>(String name, T Function(J jsValue) unwrapValue) {
  var controller = StreamController<T>.broadcast(sync: true);
  js_util.setProperty(js.context['self'], name, js.allowInterop((J event) {
    controller.add(unwrapValue(event));
  }));
  return controller.stream;
}

/// Internal function
void jsSendMessage(dynamic m) {
  js.context.callMethod('postMessage', [m]);
}