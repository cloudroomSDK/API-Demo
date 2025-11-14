import 'package:rtcsdk_demo/src/config/config.dart';

class AppConfig {
  String serverAddr;
  String appId;
  String appSecret;

  String get showAppId => appId == Config.appId ? '默认' : appId;

  AppConfig.fromJson(Map map)
      : serverAddr = map["serverAddr"],
        appId = map["appId"] == '默认' ? Config.appId : map["appId"],
        appSecret = map["appSecret"];

  toJson() =>
      {"serverAddr": serverAddr, "appId": appId, "appSecret": appSecret};
}
