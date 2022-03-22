
import 'dart:io';
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:fluro/fluro.dart';

class Application {
  static late final FluroRouter router;
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

enum LOGIN_STATUS { login, unlogin }
enum LINE_STATUS { online, offline }

class GlobalConfig {
  LOGIN_STATUS loginStatus = LOGIN_STATUS.unlogin;
  LINE_STATUS lineStatue = LINE_STATUS.offline;

  // 初始化时传入的，日志的保存路径。该Demo的录制存储文件位置也会使用这个
  String sdkDatSavePath = "";

  String serverAddr = "sdk.cloudroom.com";
  String appId = "demo@cloudroom.com";
  String appSecret = "123456";

  String nickName = "FlutterDemo";
  String userID = "";
  int? confID;

  GlobalConfig._internal() {
    String random = Random().nextInt(9999).toString();
    if (Platform.isAndroid) {
      nickName = "Android_$random";
    } else if (Platform.isIOS) {
      nickName = "IOS_$random";
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
