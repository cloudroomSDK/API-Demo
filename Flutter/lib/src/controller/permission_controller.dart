import 'dart:io';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rtcsdk_demo/src/utils/logger_util.dart';

class PermissionController extends GetxController {
  @override
  void onInit() async {
    super.onInit();
  }

  Future<bool> checkPermission(List<Permission> permissions,
      {Function(Map<Permission, PermissionStatus> status)?
          onGrantedFail}) async {
    List<Permission> applyPermissions = [];
    for (var i = 0; i < permissions.length; i++) {
      Permission per = permissions[i];
      bool isGranted = await per.isGranted;
      if (!isGranted) {
        applyPermissions.add(per);
      }
    }

    if (applyPermissions.isNotEmpty) {
      bool flag = true;
      Map<Permission, PermissionStatus> statuses =
          await applyPermissions.request();
      statuses.forEach((Permission per, PermissionStatus status) {
        Logger.log("Permission: $per __ isGranted: ${status.isGranted}");
        if (!status.isGranted) flag = false;
      });
      if (!flag) onGrantedFail?.call(statuses);
      return flag;
    }

    return true;
  }

  storage(Function() onGranted, [Function()? onGrantedFail]) async {
    bool isGranted = await checkPermission([Permission.storage]);
    isGranted ? onGranted() : onGrantedFail?.call();
  }

  camera(Function() onGranted, [Function()? onGrantedFail]) async {
    bool isGranted = await checkPermission([Permission.camera]);
    isGranted ? onGranted() : onGrantedFail?.call();
  }

  microphone(Function() onGranted, [Function()? onGrantedFail]) async {
    bool isGranted = await checkPermission(Platform.isAndroid
        ? [Permission.microphone, Permission.phone]
        : [Permission.microphone]);
    isGranted ? onGranted() : onGrantedFail?.call();
  }
}
