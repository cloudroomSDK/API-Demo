import 'package:cloudroomvideosdk/implements/cr_impl.dart';

extension CrMemberImpl on CrImpl {
  static final _channel = CrImpl.channel;
  static const _addMethods = CrImpl.addMethods;

  // 获取自己的UserID
  Future<String> getMyUserID() async {
    return await _channel.invokeMethod("getMyUserID");
  }

  // 获取房间所有成员的列表
  Future<String> getAllMembers() async {
    return await _channel.invokeMethod("getAllMembers");
  }

  // 获取某个用户的信息
  Future<String> getMemberInfo(String userID) async {
    return await _channel.invokeMethod("getMemberInfo", {"userID": userID});
  }

  // 获取某个用户的昵称
  Future<String> getNickName(String userID) async {
    return await _channel.invokeMethod("getNickName", {"userID": userID});
  }

  // 设置某个用户的昵称
  Future<Map> setNickName(String userID, String nickName) async {
    await _channel
        .invokeMethod("setNickName", {"userID": userID, "nickName": nickName});
    return await _addMethods("setNickNameRsp");
  }

  // 判断某个用户是否在房间中
  Future<bool> isUserInMeeting(String userID) async {
    return await _channel.invokeMethod("isUserInMeeting", {"userID": userID});
  }
}
