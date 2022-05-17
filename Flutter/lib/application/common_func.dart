import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CommonFunc {
  int? meetId;

  void initPage(int? confId) {
    meetId = confId;
    CrSDK.instance.enterMeeting(meetId!).then((int sdkErr) {
      if (sdkErr == 0) {
        enterMeetingSuccess();
        EasyLoading.dismiss();
      } else {
        CrErrorDef err = CrErrorDef(sdkErr);
        EasyLoading.showToast(err.message);
        toHomePage();
      }
    }).catchError((err) {
      toHomePage();
      EasyLoading.showToast("进入房间异常");
    });
  }

  void meetingDroppedReEnterMeeting() {
    CrSDK.instance.enterMeeting(meetId!).then((int sdkErr) {
      if (sdkErr != 0) {
        toHomePage();
      }
    }).catchError((err) {
      toHomePage();
    });
  }

  void commonMeetingDropped(CR_MEETING_DROPPED_REASON reason) {
    if (reason == CR_MEETING_DROPPED_REASON.CRVIDEOSDK_DROPPED_TIMEOUT) {
      meetingDroppedReEnterMeeting();
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
      toHomePage();
    }
  }

  toHomePage() {}

  enterMeetingSuccess() {}
}
