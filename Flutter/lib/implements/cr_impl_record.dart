import 'package:cloudroomvideosdk/implements/cr_impl.dart';

extension CrRecordImpl on CrImpl {
  static final _channel = CrImpl.channel;

  // 本地录制
  // 创建混图器
  Future<int> createLocMixer(
      String mixerID, String mixerCfg, String mixerCotentRects) async {
    final int errCode = await _channel.invokeMethod("createLocMixer", {
      "mixerCfg": mixerCfg,
      "mixerCotentRects": mixerCotentRects,
      "mixerID": mixerID
    });
    return errCode;
  }

  // 更新混图器内容
  Future<int> updateLocMixerContent(
      String mixerID, String mixerCotentRects) async {
    final int errCode = await _channel.invokeMethod("updateLocMixerContent",
        {"mixerCotentRects": mixerCotentRects, "mixerID": mixerID});
    return errCode;
  }

  // 添加输出到录像文件
  Future<int> addLocMixerOutput(String mixerID, String mixerOutPutCfgs) async {
    final int errCode = await _channel.invokeMethod("addLocMixerOutput",
        {"mixerOutPutCfgs": mixerOutPutCfgs, "mixerID": mixerID});
    return errCode;
  }

  // 停止本地录制、直播推流
  Future<void> rmLocMixerOutput(String mixerID, String nameOrUrls) async {
    await _channel.invokeMethod(
        "rmLocMixerOutput", {"mixerID": mixerID, "nameOrUrls": nameOrUrls});
  }

  // 结束录制
  Future<void> destroyLocMixer(String mixerID) async {
    await _channel.invokeMethod("destroyLocMixer", {"mixerID": mixerID});
  }

  // 获取本地混图器状态
  Future<int> getLocMixerState(String mixerID) async {
    return await _channel
        .invokeMethod("getLocMixerState", {"mixerID": mixerID});
  }

  // 云端录制
  // 获取云端录制、云端直播状态
  Future<int> getSvrMixerState() async {
    return await _channel.invokeMethod("getSvrMixerState");
  }

  // 开启云端录制
  Future<int> startSvrMixer(String mutiMixerCfg, String mutiMixerContents,
      String mutiMixerOutput) async {
    final int errCode = await _channel.invokeMethod("startSvrMixer", {
      "mutiMixerCfg": mutiMixerCfg,
      "mutiMixerContents": mutiMixerContents,
      "mutiMixerOutput": mutiMixerOutput
    });
    return errCode;
  }

  // 更新云端录制、云端直播内容
  Future<int> updateSvrMixerContent(String mutiMixerContents) async {
    final int errCode = await _channel.invokeMethod("updateSvrMixerContent", {
      "mutiMixerContents": mutiMixerContents,
    });
    return errCode;
  }

  // 停止云端录制、云端直播
  Future<void> stopSvrMixer() async {
    return await _channel.invokeMethod("stopSvrMixer");
  }
}
