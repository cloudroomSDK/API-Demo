import 'dart:convert';

import 'package:cloudroomvideosdk/cr_defines.dart';

import '/api/cr_api.dart';
import '/implements/cr_impl.dart';
import '/implements/cr_impl_audio.dart';

extension CrAudioApi on CrSDK {
  // 查询麦克风状态
  Future<CR_ASTATUS> getAudioStatus(String userID) async {
    int astatus = await CrImpl.instance.getAudioStatus(userID);
    return CR_ASTATUS.values[astatus];
  }

  // 打开麦克风
  Future<void> openMic(String userID) async {
    return await CrImpl.instance.openMic(userID);
  }

  // 关闭麦克风
  Future<void> closeMic(String userID) async {
    return await CrImpl.instance.closeMic(userID);
  }

  // 获取外放状态
  Future<bool> getSpeakerOut() async {
    return await CrImpl.instance.getSpeakerOut();
  }

  // 设置外放状态
  Future<bool> setSpeakerOut(bool speakerOut) async {
    return await CrImpl.instance.setSpeakerOut(speakerOut);
  }

  // 获取麦克风参数配置
  Future<CrAudioCfg> getAudioCfg() async {
    String cfgJson = await CrImpl.instance.getAudioCfg();
    Map<String, dynamic> data = json.decode(cfgJson);
    CrAudioCfg cfg = CrAudioCfg(
        micName: data["_micName"],
        speakerName: data["_speakerName"],
        agc: data["agc"],
        ans: data["ans"],
        aec: data["aec"]);
    return cfg;
  }

  // 设置麦克风参数配置
  Future<void> setAudioCfg(CrAudioCfg cfg) async {
    return await CrImpl.instance.setAudioCfg(json.encode(cfg.toJson()));
  }

  // 获取麦克风音量大小
  Future<int> getMicVolume() async {
    return await CrImpl.instance.getMicVolume();
  }

  // 获取本地扬声器音量
  Future<int> getSpeakerVolume() async {
    return await CrImpl.instance.getSpeakerVolume();
  }

  // 设置本地扬声器音量
  Future<bool> setSpeakerVolume(int speakerVolume) async {
    return await CrImpl.instance.setSpeakerVolume(speakerVolume);
  }
}
