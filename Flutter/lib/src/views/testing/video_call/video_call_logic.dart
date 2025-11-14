import 'dart:async';

import 'package:get/get.dart';

// enum CallState {
//   calling,
//   called,
// }

class VideoCallLogic extends GetxController {
  // final meetLogic = Get.find<MeetController>();

  // Rx<CalledInfo> called = CalledInfo(
  //   userID: "",
  //   nickname: "",
  // ).obs;
  Rx<bool> isCaller = false.obs;
  // TimeWait? timeWait;
  // RxString duration = "".obs;
  // Invitation? invitation;
  Timer? timeout;

  @override
  void onInit() {
    isCaller.value = Get.arguments['isCaller'];
    // invitation = Get.arguments['invitation'];
    // called.value = isCaller.value
    //     ? (Get.arguments['calleds'] as List).cast<CalledInfo>().toList().first
    //     : Get.arguments['caller'] as CalledInfo;

    startTimeoutWait();
    // if (isCaller.value) {
    //   Utils.outgoingSound.playRing();
    // } else {
    //   Utils.incomingSound.playRing();
    // }
    super.onInit();
  }

  @override
  void onClose() {
    timeout?.cancel();
    // if (isCaller.value) {
    //   Utils.outgoingSound.stopSound();
    // } else {
    //   Utils.incomingSound.stopSound();
    // }
    super.onClose();
  }

  void startTimeoutWait() {
    // if (isCaller.value) {
    //   timeout = Timer(Duration(seconds: invitation!.timeout ?? 30), () {
    //     // Get.back(result: 'timeout');
    //     Get.back(result: 'cancel');
    //   });
    // }
  }

  void onCancelCall() {
    Get.back(result: isCaller.value ? 'cancel' : 'reject');
  }

  void onAcceptCall() async {
    // LoadingView.singleton.wrap(asyncFunction: () async {
    //   await meetLogic.inviteeJoinMeeting(
    //     isCaller: isCaller.value,
    //     invitation: invitation!,
    //     callback: () {
    //       Get.back(result: 'accept');
    //     },
    //   );
    // });
  }

  void onHangupCall() {
    Get.back(result: 'hangup');
  }
}
