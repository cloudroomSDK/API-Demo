import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/models/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:rtcsdk_demo/src/routes/navigator.dart';

class SettingsLogic extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController serverAddrController;
  late TextEditingController appIdController;
  late TextEditingController appSecretController;
  final appLogic = Get.find<AppController>();
  final rtcLogic = Get.find<RTCController>();

  @override
  onInit() {
    serverAddrController =
        TextEditingController(text: appLogic.appConfig.serverAddr);
    appIdController = TextEditingController(text: appLogic.appConfig.appId);
    appSecretController =
        TextEditingController(text: appLogic.appConfig.appSecret);
    super.onInit();
  }

  @override
  onClose() {
    serverAddrController.dispose();
    appIdController.dispose();
    appSecretController.dispose();
    super.onClose();
  }

  String? validator(String? value, String field) {
    if (value!.isEmpty) {
      String val = "";
      switch (field) {
        case "serverAddr":
          val = "请输入服务器地址";
          break;
        case "appId":
          val = "请输入appID";
          break;
        case "appSecret":
          val = "请输入appSecret";
          break;
      }
      return val;
    }
    return null;
  }

  resetAppConfig() {
    AppConfig config = appLogic.resetAppConfig();
    serverAddrController.text = config.serverAddr;
    appIdController.text = config.appId;
    appSecretController.text = config.appSecret;
  }

  saveAppConfig() async {
    String serverAddr = serverAddrController.text;
    String appId = appIdController.text;
    String appSecret = appSecretController.text;
    try {
      await rtcLogic.logout();
      await rtcLogic.setServerAddr(serverAddr);
      await rtcLogic.login();
      await appLogic.saveAppConfig(serverAddr, appId, appSecret);
      EasyLoading.showToast("保存设置成功！");
      AppNavigator.toMain();
    } catch (e) {
      EasyLoading.showToast("保存设置失败！");
    }
  }
}
