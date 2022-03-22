import 'dart:convert';

import '/api/cr_api.dart';
import '/implements/cr_impl.dart';
import '/implements/cr_impl_media.dart';
import '/cr_defines.dart';

extension CrMediaApi on CrSDK {
// 正在播放的影音信息
  Future<CrMediaInfo> getMediaInfo() async {
    String mediaInfoStr = await CrImpl.instance.getMediaInfo();
    Map mediaInfoJson = json.decode(mediaInfoStr);
    final int stateidx = mediaInfoJson["state"];
    CrMediaInfo mediaInfo = CrMediaInfo(
      userID: mediaInfoJson["userID"] ?? "",
      state: CR_MEDIA_STATE.values[stateidx],
      mediaName: mediaInfoJson["mediaName"] ?? "",
    );
    return mediaInfo;
  }

  // 获取影音信息配置
  Future<CrVideoCfg> getMediaCfg() async {
    final String result = await CrImpl.instance.getMediaCfg();
    Map data = json.decode(result);
    return CrVideoCfg(
        size: CrSize(
            width: data["size"]["width"], height: data["size"]["height"]),
        fps: data["fps"],
        maxbps: data["maxbps"],
        qp_min: data["qp_min"],
        qp_max: data["qp_max"]);
  }

  // 设置影音信息配置
  Future<void> setMediaCfg(CrVideoCfg cfg) async {
    String cfgJson = json.encode(cfg.toJson());
    return await CrImpl.instance.setMediaCfg(cfgJson);
  }

  // 开始播放，如果不需要远端需要观看配合bLocPlay为true
  Future<void> startPlayMedia(String videoSrc, [bool bLocPlay = false]) async {
    return await CrImpl.instance.startPlayMedia(videoSrc, bLocPlay);
  }

  // 暂停、继续播放
  Future<void> pausePlayMedia(bool pause) async {
    return await CrImpl.instance.pausePlayMedia(pause);
  }

  // 停止当前播放
  Future<void> stopPlayMedia() async {
    return await CrImpl.instance.stopPlayMedia();
  }

  // 设置播放进度
  Future<void> setMediaPlayPos(int pos) async {
    return await CrImpl.instance.setMediaPlayPos(pos);
  }
}
