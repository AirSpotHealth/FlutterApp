// it is a singleton class that is used to call a function after a delay
import 'dart:async';

class DelayedFunctionCaller {
  static const int _delay = 1000;
  static final DelayedFunctionCaller _instance =
      DelayedFunctionCaller._internal();

  factory DelayedFunctionCaller() {
    return _instance;
  }

  DelayedFunctionCaller._internal();

  Timer? _timer;

  void call(Function function, {int delay = DelayedFunctionCaller._delay}) {
    _timer?.cancel();

    _timer = Timer(Duration(milliseconds: delay), () {
      function();

      _timer?.cancel();
      _timer = null;
    });
  }
}
