class AppConfig {
  String serverAddr;
  String appId;
  String appSecret;

  AppConfig.fromJson(Map map)
      : serverAddr = map["serverAddr"],
        appId = map["appId"],
        appSecret = map["appSecret"];

  toJson() =>
      {"serverAddr": serverAddr, "appId": appId, "appSecret": appSecret};
}
