import '/api/cr_api.dart';
import '/implements/cr_impl.dart';
import '/implements/cr_impl_room.dart';
import '/cr_defines.dart';

extension CrRoomApi on CrSDK {
  // 进入房间
  Future<int> enterMeeting(int meetID) async {
    Map result = await CrImpl.instance.enterMeeting(meetID);
    int sdkErr = result["sdkErr"];
    return sdkErr;
  }

  // 创建房间 -> 之后调用enterMeeting
  Future<CrMeetInfo> createMeeting() async {
    final Map result = await CrImpl.instance.createMeeting();
    int sdkErr = result["sdkErr"] ?? 0;
    int? id = result["id"];
    String? pubMeetUrl = result["pubMeetUrl"];
    CrMeetInfo meetInfo =
        CrMeetInfo(confId: id, sdkErr: sdkErr, pubMeetUrl: pubMeetUrl);
    return meetInfo;
  }

  // 销毁视频房间
  Future<Map> destroyMeeting(int meetID) async {
    return await CrImpl.instance.destroyMeeting(meetID);
  }

  // 离开房间
  Future<void> exitMeeting() async {
    return await CrImpl.instance.exitMeeting();
  }
}
