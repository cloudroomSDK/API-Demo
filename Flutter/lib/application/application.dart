import 'dart:io';
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:fluro/fluro.dart';
import 'observer.dart';
export 'utils.dart';

class Application {
  static late final FluroRouter router;

  // 发布订阅
  static Function(String method, [dynamic data]) emit =
      SubScribeSingleton.instance.emit;

  static Function(String method, Function callback) on =
      SubScribeSingleton.instance.on;

  static Function(String method, Function callback) off =
      SubScribeSingleton.instance.off;
}

class CrColors {
  static const Color primary = Color(0xff3981fc);
  // 字的颜色
  static const Color textPrimary = Color(0xff333333);
  static const Color textRegular = Color(0xff666666);
  static const Color textSecondary = Color(0xff999999);
  static const Color textPlaceholder = Color(0xffe5e5e5);
  // 边框颜色
  static const Color borderColor = Color(0xffd2d2d2);
  // 背景颜色
  static const Color backgroundColor = Color(0xfff2f2f2);
}

enum INIT_STATUS { unknown, init, uninit }
enum LOGIN_STATUS { unknown, login, unlogin }

class GlobalConfig {
  INIT_STATUS initStatus = INIT_STATUS.unknown;
  LOGIN_STATUS loginStatus = LOGIN_STATUS.unknown;

  // 初始化时传入的，日志的保存路径。该Demo的录制存储文件位置也会使用这个
  String sdkDatSavePath = "";

  String serverAddr = "";
  String appId = "";
  String appSecret = "";

  String nickName = "";
  String userID = "";
  int? confID;

  GlobalConfig._internal() {
    resetDefaultSetting();
    int _random = Random().nextInt(9999);
    String randomstr =
        _random < 1000 ? (_random + 1000).toString() : _random.toString();
    if (Platform.isAndroid) {
      nickName = "Android_$randomstr";
    } else if (Platform.isIOS) {
      nickName = "IOS_$randomstr";
    } else {
      nickName = "FlutterDemo";
    }
  }
  static final GlobalConfig instance = GlobalConfig._internal();
  factory GlobalConfig() => instance;

  resetDefaultSetting() {
    serverAddr = "sdk.cloudroom.com";
    appId = "demo@cloudroom.com";
    appSecret = "123456";
  }
}
