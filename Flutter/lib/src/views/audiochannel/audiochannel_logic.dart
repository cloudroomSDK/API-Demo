import 'dart:async';

import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:get/get.dart';
import 'package:rtcsdk_demo/src/models/mic_energy.dart';
import 'package:rtcsdk_demo/src/routes/navigator.dart';

class AudioChannelLogic extends GetxController {
  final rtcLogic = Get.find<RTCController>();
  final String confId = Get.arguments['confId'];
  String nickName = "";
  RxString remoteNickName = "".obs;
  RxDouble localVolume = 0.0.obs;
  RxDouble remoteVolume = 0.0.obs;

  List<StreamSubscription> subs = [];

  @override
  onInit() {
    nickName = rtcLogic.nickName;
    initEvt();
    super.onInit();
  }

  @override
  onClose() {
    rtcLogic.exitMeeting();
    for (StreamSubscription sub in subs) {
      sub.cancel();
    }
    super.onClose();
  }

  initEvt() async {
    // 麦克风强度
    subs.addAll([
      rtcLogic.onAudioDevChanged.listen((_) async {
        await rtcLogic.openMic();
        rtcLogic.setSpeakerOut(true);
      }),
      rtcLogic.onMicEnergyUpdate.listen((MicEnergy micEnergy) {
        if (rtcLogic.userID == micEnergy.userId) {
          localVolume.value = micEnergy.newLevel.toDouble();
          remoteNickName.value = '';
          remoteVolume.value = 0.0;
        } else {
          remoteNickName.value = micEnergy.userId;
          remoteVolume.value = micEnergy.newLevel.toDouble();
        }
      })
    ]);
  }

  void exit() {
    AppNavigator.toMain();
  }
}
