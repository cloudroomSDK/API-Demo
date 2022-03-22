import 'dart:async';
import 'dart:convert';

import '/implements/cr_impl.dart';
import '/cr_defines.dart';
import '/cr_observer.dart';

class CrSDK {
  CrSDK._internal();
  static final CrSDK instance = CrSDK._internal();
  factory CrSDK() => instance;

  // 发布订阅
  static Function(String method, [dynamic data]) emit =
      SubScribeSingleton.instance.emit;

  static Function(String method, Function callback) on =
      SubScribeSingleton.instance.on;

  static Function(String method, Function callback) off =
      SubScribeSingleton.instance.off;

  static const version = "1.0.5.2";

  // Future<String> getExternalStorageDir() async {
  //   return await CrImpl.instance.getExternalStorageDir();
  // }

  // 获取版本号
  Future<String> getVersion() async {
    return await CrImpl.instance.cloudroomVideoSDKVer();
  }

  // 初始化
  Future<int> init(CrSdkInitDat config) async {
    String sdkInitDat = json.encode(config.toJson());
    return await CrImpl.instance.init(sdkInitDat);
  }

  // 反初始化
  Future<void> uninit() async {
    return CrImpl.instance.uninit();
  }

  // 获取服务器地址
  Future<String> getServerAddr() async {
    return await CrImpl.instance.getServerAddr();
  }

  // 设置服务器地址
  Future<void> setServerAddr(String serverAddr) async {
    return await CrImpl.instance.setServerAddr(serverAddr);
  }
}
