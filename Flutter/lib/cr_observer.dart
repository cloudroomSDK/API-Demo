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

  // once(String method, Function callback) {
  //   _on("once", method, callback);
  // }

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
      // final onceMethods = subs["once"];
      // onceMethods?.forEach((cb) {
      //   cb(config);
      // });
      // subs["once"] = [];
    }
  }
}

class SubScribeSingleton with Observer {
  SubScribeSingleton._internal();
  static final SubScribeSingleton instance = SubScribeSingleton._internal();
}
