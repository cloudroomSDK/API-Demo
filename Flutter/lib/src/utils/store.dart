import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rtcsdk_demo/src/models/app_config.dart';

class RTCStorage {
  RTCStorage._();

  static RTCStorage? _singleton;
  static late SharedPreferences spre;

  static Future<RTCStorage> init() async {
    if (_singleton == null) {
      RTCStorage singleton = RTCStorage._();
      spre = await SharedPreferences.getInstance();
      _singleton = singleton;
    }
    return _singleton!;
  }

  static AppConfig? getAppConfig() {
    String? appConfigStr = spre.getString("appConfig");
    if (appConfigStr != null) {
      return AppConfig.fromJson(json.decode(appConfigStr));
    }
    return null;
  }

  static Future<bool?> setAppConfig(AppConfig appConfig) {
    Map appConfigJson = appConfig.toJson();
    return spre.setString("appConfig", json.encode(appConfigJson));
  }

  static String? getNickName() => spre.getString("nickName");

  static Future<bool?> setNickName(String nickname) =>
      spre.setString("nickName", nickname);

  static int? getConfID() => spre.getInt("confId");

  static Future<bool?> setConfID(int confId) => spre.setInt("confId", confId);
}
