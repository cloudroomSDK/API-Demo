import "dart:async";
import "package:flutter/services.dart";
import 'cr_notify.dart';

class CrImpl {
  // Singleton
  CrImpl._internal();
  static final CrImpl instance = CrImpl._internal();
  factory CrImpl() => instance;

  static get channel => _channel;

  static const MethodChannel _channel = MethodChannel("cr_flutter_sdk");
  static const EventChannel _event =
      EventChannel("cr_flutter_sdk_event_handler");

  /// Used to receive the native event stream
  static StreamSubscription<dynamic>? _streamSubscription;

  static Map<String, Completer> _methods = {};
  static const List<String> _specialmethods = [
    "enterMeetingRslt",
    "startScreenShareRslt",
    "stopScreenShareRslt",
    "setNickNameRsp",
    "openVideoRslt",
    "sendMeetingCustomMsgRslt"
  ];

  static void _registerMethodHandler() {
    _methods = {};
    _streamSubscription =
        _event.receiveBroadcastStream().listen(_eventListener);
  }

  static void _unregisterEventHandler() async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  static Future addMethods(String unique) {
    final Completer com = Completer();
    _methods[unique] = com;
    return com.future;
  }

  // 消费队列
  static void consumeMethods(String unique, Map args) {
    Completer? com;
    com = _methods[unique];
    _methods.remove(unique);
    if (com != null) {
      args["sdkErr"] = args["sdkErr"] ?? 0;
      // sdkErr == 0 ? com.complete(args) : com.completeError(sdkErr);
      com.complete(args);
    } else {
      print("$unique ___ notfound");
    }
  }

  static void _eventListener(arguments) async {
    if (arguments != null) {
      final String method = arguments["method"];
      String? cookie = arguments["cookie"];
      if (_specialmethods.contains(method)) {
        cookie = method;
      }
      if (cookie != null) {
        consumeMethods(cookie, arguments);
      } else {
        CrNotify.instance.notify(method, arguments);
      }
    }
  }

  // Future<String> getExternalStorageDir() async {
  //   return await _channel.invokeMethod("getExternalStorageDir");
  // }

  // 获取版本号
  Future<String> cloudroomVideoSDKVer() async {
    return await _channel.invokeMethod("GetCloudroomVideoSDKVer");
  }

  // 初始化
  Future<int> init(String sdkInitDat) async {
    _registerMethodHandler();
    return await _channel.invokeMethod("init", {"sdkInitDat": sdkInitDat});
  }

  // 反初始化
  Future<void> uninit() async {
    _unregisterEventHandler();
    return await _channel.invokeMethod("uninit");
  }

  // 获取服务器地址
  Future<String> getServerAddr() async {
    return await _channel.invokeMethod("getServerAddr");
  }

  // 设置服务器地址
  Future<void> setServerAddr(String serverAddr) async {
    return await _channel
        .invokeMethod("setServerAddr", {"serverAddr": serverAddr});
  }
}
