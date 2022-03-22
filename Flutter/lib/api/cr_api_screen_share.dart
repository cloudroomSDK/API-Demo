import 'dart:convert';

import '/api/cr_api.dart';
import '/implements/cr_impl.dart';
import '/implements/cr_impl_screen_share.dart';
import '/cr_defines.dart';

extension CrScreenShareApi on CrSDK {
// 获取屏幕共享是否已开启
  Future<bool> isScreenShareStarted() async {
    return await CrImpl.instance.isScreenShareStarted();
  }

  // 获取屏幕共享配置
  Future<CrScreenShareCfg> getScreenShareCfg() async {
    final String cfg = await CrImpl.instance.getScreenShareCfg();
    final Map data = json.decode(cfg);
    return CrScreenShareCfg(maxBps: data["maxBps"], maxFps: data["maxFps"]);
  }

  // 设置屏幕共享配置
  Future<void> setScreenShareCfg(CrScreenShareCfg screenShareCfg) async {
    return await CrImpl.instance.setScreenShareCfg(json.encode(screenShareCfg));
  }

  // 开启屏幕共享
  Future<int> startScreenShare() async {
    return await CrImpl.instance.startScreenShare();
  }

  // 停止屏幕共享
  Future<int> stopScreenShare() async {
    return await CrImpl.instance.stopScreenShare();
  }
}
