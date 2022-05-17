// 用ChangeNotifier实现比较flutter
class Observer {
  Map<String, Map<String, List>> subscribes = {};

  void _on(String type, String method, Function callback) {
    final methods = subscribes[method];
    if (methods == null) {
      subscribes[method] = {
        type: [callback]
      };
    } else {
      methods[type]?.add(callback);
    }
  }

  void on(String method, Function callback) {
    _on("on", method, callback);
  }

  void off(String method, Function callback) {
    final Map<String, List>? subs = subscribes[method];
    if (subs != null) {
      final methods = subs["on"];
      methods?.remove(callback);
    }
  }

  void emit(String method, [dynamic config]) {
    final Map<String, List>? subs = subscribes[method];
    if (subs != null) {
      final List? methods = subs["on"];
      methods?.forEach((cb) {
        config != null ? cb(config) : cb();
      });
    }
  }
}

class SubScribeSingleton with Observer {
  SubScribeSingleton._internal();
  static final SubScribeSingleton instance = SubScribeSingleton._internal();
}
