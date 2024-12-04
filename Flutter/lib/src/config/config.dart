import 'package:flutter/foundation.dart';

class Config {
  static String serverAddr =
      kDebugMode ? "crlab.cloudroom.com:543" : "sdk.cloudroom.com";
  static String appId = "demo@cloudroom.com";
  static String appSecret = "123456";
}
