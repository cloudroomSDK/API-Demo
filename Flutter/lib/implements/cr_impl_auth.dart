import 'package:cloudroomvideosdk/implements/cr_impl.dart';

extension CrAuthImpl on CrImpl {
  static final _channel = CrImpl.channel;
  static const _addMethods = CrImpl.addMethods;

  // 登录
  Future<Map> login(String loginDat) async {
    String cookie = DateTime.now().millisecondsSinceEpoch.toString();
    await _channel
        .invokeMethod("login", {"loginDat": loginDat, "cookie": cookie});
    return await _addMethods(cookie);
  }

  // 登出
  Future<void> logout() async {
    return await _channel.invokeMethod("logout");
  }
}
