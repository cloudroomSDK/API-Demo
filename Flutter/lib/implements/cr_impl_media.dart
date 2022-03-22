import 'package:cloudroomvideosdk/implements/cr_impl.dart';

extension CrMediaImpl on CrImpl {
  static final _channel = CrImpl.channel;

  // 获取影音共享信息
  Future<String> getMediaInfo() async {
    return await _channel.invokeMethod("getMediaInfo");
  }

  // 获取影音共享配置
  Future<String> getMediaCfg() async {
    return await _channel.invokeMethod("getMediaCfg");
  }

  // 设置影音共享配置
  Future<void> setMediaCfg(String cfg) async {
    return await _channel.invokeMethod("setMediaCfg", {"mediaCfg": cfg});
  }

  // 创建MediaUI视图容器
  Future<void> createMediaView(int viewID, String usrVideoId) async {
    return await _channel.invokeMethod(
        "createMediaView", {"viewID": viewID, "usrVideoId": usrVideoId});
  }

  // 销毁MediaUI视图容器
  Future<bool> destroyMediaView(int viewID) async {
    return await _channel.invokeMethod("destroyMediaView", {"viewID": viewID});
  }

  // 开始播放，如果不需要远端需要观看配合bLocPlay为true
  Future<void> startPlayMedia(String videoSrc, bool bLocPlay) async {
    return await _channel.invokeMethod(
        "startPlayMedia", {"videoSrc": videoSrc, "bLocPlay": bLocPlay});
  }

  // 暂停、继续播放
  Future<void> pausePlayMedia(bool pause) async {
    return await _channel.invokeMethod("pausePlayMedia", {"pause": pause});
  }

  // 停止当前播放
  Future<void> stopPlayMedia() async {
    return await _channel.invokeMethod("stopPlayMedia");
  }

  // 设置播放进度
  Future<void> setMediaPlayPos(int pos) async {
    return await _channel.invokeMethod("setMediaPlayPos", {"pos": pos});
  }

  // 读取影音播放的音量
  Future<int> getMediaVolume() async {
    return await _channel.invokeMethod("getMediaVolume");
  }

  // 设置影音播放的音量
  Future<void> setMediaVolume(int volume) async {
    return await _channel.invokeMethod("getMediaVolume", {"volume": volume});
  }
}
