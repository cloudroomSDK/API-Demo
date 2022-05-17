import 'dart:async';

class Utils {
  static final Map<String, Timer?> _timers = {};

  static void debounce(String evtname, Function callback,
      {Duration? duration}) {
    Timer? _timer = _timers[evtname];
    _timer?.cancel();
    Duration dura = duration ?? const Duration(milliseconds: 300);
    _timers[evtname] = Timer(dura, () {
      callback();
      _timers[evtname] = null;
    });
  }
}
