import '/api/cr_api.dart';
import '/implements/cr_impl.dart';
import '/implements/cr_impl_im.dart';

extension CrImApi on CrSDK {
  // 发送文本聊天
  Future<int> sendMeetingCustomMsg(String text) async {
    Map result = await CrImpl.instance.sendMeetingCustomMsg(text);
    int sdkErr = result["sdkErr"];
    return sdkErr;
  }
}
