import 'package:cloudroomvideosdk/implements/cr_impl.dart';

extension CrChatImpl on CrImpl {
  static final _channel = CrImpl.channel;
  static const _addMethods = CrImpl.addMethods;

  // 发送消息
  Future<Map> sendMeetingCustomMsg(String text) async {
    String cookie = DateTime.now().millisecondsSinceEpoch.toString();
    await _channel
        .invokeMethod("sendMeetingCustomMsg", {"text": text, "cookie": cookie});
    // final Future future = _addMethods(cookie);
    final Future future = _addMethods("sendMeetingCustomMsgRslt");
    return await future;
  }
}
