import 'package:cloudroomvideosdk/implements/cr_impl.dart';

extension CrAudioImpl on CrImpl {
  static final _channel = CrImpl.channel;

  // 获取麦克风参数配置
  Future<String> getAudioCfg() async {
    return await _channel.invokeMethod("getAudioCfg");
  }

  // 获取麦克风参数配置
  Future<void> setAudioCfg(String audioCfg) async {
    return await _channel.invokeMethod("setAudioCfg", {"audioCfg": audioCfg});
  }

  // 获取麦克风状态
  Future<int> getAudioStatus(String userID) async {
    return await _channel.invokeMethod("getAudioStatus", {"userID": userID});
  }

  // 打开麦克风
  Future<void> openMic(String userID) async {
    return await _channel.invokeMethod("openMic", {"userID": userID});
  }

  // 关闭麦克风
  Future<void> closeMic(String userID) async {
    return await _channel.invokeMethod("closeMic", {"userID": userID});
  }

  // 获取麦克风音量大小
  Future<int> getMicVolume() async {
    return await _channel.invokeMethod("getMicVolume");
  }

  // 获取本地扬声器音量
  Future<int> getSpeakerVolume() async {
    return await _channel.invokeMethod("getSpeakerVolume");
  }

  // 设置本地扬声器音量
  Future<bool> setSpeakerVolume(int speakerVolume) async {
    return await _channel
        .invokeMethod("setSpeakerVolume", {"speakerVolume": speakerVolume});
  }

  // 获取外放状态
  Future<bool> getSpeakerOut() async {
    return await _channel.invokeMethod("getSpeakerOut");
  }

  // 设置外放状态
  Future<bool> setSpeakerOut(bool speakerOut) async {
    return await _channel
        .invokeMethod("setSpeakerOut", {"speakerOut": speakerOut});
  }
}
