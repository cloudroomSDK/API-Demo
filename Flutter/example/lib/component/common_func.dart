import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';
import 'package:cloudroomvideosdk_example/application/application.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wakelock/wakelock.dart';

class CommonFunc {
  BuildContext? _context;
  int? _level;

  void addSDKAuthObserver(ob) {
    _context = ob.context;
    CrSDK.on("meetingDropped", meetingDropped);
    CrSDK.on("netStateChanged", netStateChanged);
  }

  void removeSDKAuthObserver() {
    _context = null;
    CrSDK.off("meetingDropped", meetingDropped);
    CrSDK.off("netStateChanged", netStateChanged);
  }

  netStateChanged(int level) {
    _level = level;
  }

  Future enterMeeting() {
    EasyLoading.show(status: '进入房间');
    return sdkEnterMeeting().then((int sdkErr) {
      if (sdkErr == 0) {
        Wakelock.enable();
        EasyLoading.dismiss();
      } else {
        CrErrorDef error = CrErrorDef(sdkErr);
        EasyLoading.showToast(error.message);
        toFunctionsPage();
        return Future.error(error.message);
      }
    });
  }

  void meetingDropped(CR_MEETING_DROPPED_REASON reason) {
    if (reason == CR_MEETING_DROPPED_REASON.CRVIDEOSDK_DROPPED_TIMEOUT) {
      if (_level == 0) {
        toFunctionsPage();
      } else {
        meetingDroppedReEnterMeeting();
      }
    } else {
      if (reason == CR_MEETING_DROPPED_REASON.CRVIDEOSDK_DROPPED_KICKOUT) {
        EasyLoading.showToast('您已被请出房间');
      } else if (reason ==
          CR_MEETING_DROPPED_REASON.CRVIDEOSDK_DROPPED_BALANCELESS) {
        EasyLoading.showToast('余额不足');
      } else if (reason ==
          CR_MEETING_DROPPED_REASON.CRVIDEOSDK_DROPPED_TOKENINVALID) {
        EasyLoading.showToast('token过期');
      }
      toFunctionsPage();
    }
  }

  // 判断用户是否在房间中
  void isUserInMeeting() {
    CrSDK.instance
        .isUserInMeeting(GlobalConfig.instance.userID)
        .then((bool _isUserInMeeting) {});
  }

  void meetingDroppedReEnterMeeting() {
    EasyLoading.showToast('房间掉线，正在重连');
    sdkEnterMeeting().then((int sdkErr) {
      if (sdkErr == 0) {
        EasyLoading.dismiss();
      } else {
        EasyLoading.showToast('重连失败');
        toFunctionsPage();
      }
    });
  }

  Future<int> sdkEnterMeeting() {
    int? confId = GlobalConfig.instance.confID;
    return CrSDK.instance.enterMeeting(confId!);
  }

  Future exitMeeting() {
    Future.delayed(const Duration(milliseconds: 10), () {
      Wakelock.disable();
      CrSDK.instance.exitMeeting();
    });
    return toFunctionsPage();
  }

  Future toFunctionsPage() {
    return Application.router.navigateTo(_context!, "/",
        replace: true,
        transitionDuration: const Duration(milliseconds: 0),
        clearStack: true);
  }
}
