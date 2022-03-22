import 'dart:convert';

import '/api/cr_api.dart';
import '/implements/cr_impl.dart';
import '/implements/cr_impl_record.dart';
import '/cr_defines.dart';

extension CrRecordApi on CrSDK {
  // 创建混图器
  Future<int> createLocMixer(
    String mixerID,
    CrMixerCfg mixerCfg,
    List<CrMixerCotentRect> mixerCotentRect,
  ) async {
    final String mixerCotentRects = mixerCotentRect
        .map((rect) => json.encode(rect.toJson()))
        .toList()
        .toString();
    return await CrImpl.instance.createLocMixer(
        mixerID, json.encode(mixerCfg.toLocalMixJson()), mixerCotentRects);
  }

  // 添加输出到录像文件
  Future<int> addLocMixerOutput(
      String mixerID, List<CrMixerOutPutCfg> mixerOutPutCfgs) async {
    final String mixerOutPutCfgsJson = mixerOutPutCfgs
        .map((cfg) => json.encode(cfg.toJson()))
        .toList()
        .toString();
    return CrImpl.instance.addLocMixerOutput(mixerID, mixerOutPutCfgsJson);
  }

  // 更新混图器
  Future<int> updateLocMixerContent(
      String mixerID, List<CrMixerCotentRect> mixerCotentRects) async {
    final String mixerCotentRectsStr = mixerCotentRects
        .map((rect) => json.encode(rect.toJson()))
        .toList()
        .toString();
    return CrImpl.instance.updateLocMixerContent(mixerID, mixerCotentRectsStr);
  }

  // 销毁混图器，结束录制
  Future<void> destroyLocMixer(String mixerID) async {
    return CrImpl.instance.destroyLocMixer(mixerID);
  }

  // 获取云端录制、云端直播状态
  Future<CR_MIXER_STATE> getSvrMixerState() async {
    final int stateidx = await CrImpl.instance.getSvrMixerState();
    return CR_MIXER_STATE.values[stateidx]; 
  }

  // 获取本地混图器状态
  Future<CR_MIXER_STATE> getLocMixerState(String mixerID) async {
    final int stateidx = await CrImpl.instance.getLocMixerState(mixerID);
    return CR_MIXER_STATE.values[stateidx];
  }

  // 开启云端录制
  Future<int> startSvrMixer(
      List<CrMutiMixerCfg> mutiMixerCfgs,
      List<CrMutiMixerContents> mutiMixerContents,
      List<CrMutiMixerOutput> mutiMixerOutputs) async {
    final String mutiMixerCfgStr = mutiMixerCfgs
        .map((item) => json.encode(item.toJson()))
        .toList()
        .toString();
    final String mutiMixerContentStr = mutiMixerContents
        .map((item) => json.encode(item.toJson()))
        .toList()
        .toString();
    final String mutiMixerOutputStr = mutiMixerOutputs
        .map((item) => json.encode(item.toJson()))
        .toList()
        .toString();
    return await CrImpl.instance.startSvrMixer(
        mutiMixerCfgStr, mutiMixerContentStr, mutiMixerOutputStr);
  }

  // 更新云端录制、云端直播内容
  Future<int> updateSvrMixerContent(
      List<CrMutiMixerContents> mutiMixerContents) async {
    final String mutiMixerContentsStr = mutiMixerContents
        .map((item) => json.encode(item.toJson()))
        .toList()
        .toString();
    return await CrImpl.instance.updateSvrMixerContent(mutiMixerContentsStr);
  }

  // 停止云端录制、云端直播
  Future<void> stopSvrMixer() async {
    return await CrImpl.instance.stopSvrMixer();
  }
}
