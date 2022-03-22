import 'package:cloudroomvideosdk/implements/cr_impl.dart';

extension CrRoomImpl on CrImpl {
  static final _channel = CrImpl.channel;
  static const _addMethods = CrImpl.addMethods;

  // 创建视频房间
  Future<Map> createMeeting() async {
    String cookie = DateTime.now().millisecondsSinceEpoch.toString();
    await _channel.invokeMethod("createMeeting", {"cookie": cookie});
    return await _addMethods(cookie);
  }

  // 销毁视频房间
  Future<Map> destroyMeeting(int meetID) async {
    String cookie = DateTime.now().millisecondsSinceEpoch.toString();
    await _channel
        .invokeMethod("destroyMeeting", {"meetID": meetID, "cookie": cookie});
    return await _addMethods(cookie);
  }

  // 进入房间 // 没有cookie、、、
  Future<Map> enterMeeting(int meetID) async {
    String cookie = DateTime.now().millisecondsSinceEpoch.toString();
    await _channel
        .invokeMethod("enterMeeting", {"meetID": meetID, "cookie": cookie});
    return await _addMethods("enterMeetingRslt");
  }

  // 离开房间
  Future<void> exitMeeting() async {
    return await _channel.invokeMethod("exitMeeting");
  }
}
