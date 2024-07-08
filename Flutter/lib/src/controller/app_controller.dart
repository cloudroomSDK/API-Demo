// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'dart:async';
import 'package:rtcsdk_demo/src/config/config.dart';
import 'package:rtcsdk_demo/src/models/app_config.dart';
import 'package:rtcsdk_demo/src/utils/store.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class AppController extends GetxController {
  late AppConfig appConfig;
  bool isRunningBackground = false;
  PublishSubject<bool> backgroundSubject = PublishSubject<bool>();

  @override
  onInit() {
    super.onInit();
    getAppConfig();
  }

  void runningBackground(bool run) {
    isRunningBackground = run;
    backgroundSubject.sink.add(run);
  }

  AppConfig resetAppConfig() {
    return AppConfig.fromJson({
      "serverAddr": Config.serverAddr,
      "appId": Config.appId,
      "appSecret": Config.appSecret,
    });
  }

  getAppConfig() async {
    AppConfig? _appConfig = RTCStorage.getAppConfig();
    if (_appConfig == null) {
      _appConfig = resetAppConfig();
      await RTCStorage.setAppConfig(_appConfig);
    }
    appConfig = _appConfig;
  }

  Future<bool?> saveAppConfig(
      String serverAddr, String appId, String appSecret) async {
    Map<String, dynamic> map = {
      "serverAddr": serverAddr,
      "appId": appId,
      "appSecret": appSecret,
    };
    AppConfig _appConfig = AppConfig.fromJson(map);
    bool? setAppConfigSucc = await RTCStorage.setAppConfig(_appConfig);
    appConfig = _appConfig;
    return setAppConfigSucc;
  }
}
