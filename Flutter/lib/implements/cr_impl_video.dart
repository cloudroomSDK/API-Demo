import 'package:cloudroomvideosdk/implements/cr_impl.dart';

extension CrVideoImpl on CrImpl {
  static final _channel = CrImpl.channel;
  static const _addMethods = CrImpl.addMethods;

  // 获取用户所有的摄像头信息
  Future<String> getAllVideoInfo(String userID) async {
    return await _channel.invokeMethod("getAllVideoInfo", {"userID": userID});
  }

  // 获取摄像头参数配置
  Future<String> getVideoCfg() async {
    return await _channel.invokeMethod("getVideoCfg");
  }

  // 设置摄像头参数配置
  Future<void> setVideoCfg(String cfg) async {
    return await _channel.invokeMethod("setVideoCfg", {"videoCfg": cfg});
  }

  // 获取房间内所有可观看的摄像头
  Future<String> getWatchableVideos() async {
    return await _channel.invokeMethod("getWatchableVideos");
  }

  // 打开用户的摄像头，以便本地、远端显示视频图像
  Future<Map> openVideo(String userID) async {
    await _channel.invokeMethod("openVideo", {"userID": userID});
    return await _addMethods("openVideoRslt");
  }

  // 关闭用户的摄像头
  Future<void> closeVideo(String userID) async {
    return await _channel.invokeMethod("closeVideo", {"userID": userID});
  }

  // 获取指定用户的默认摄像头 ，如果用户没有摄像头，返回0
  Future<int> getDefaultVideo(String userID) async {
    return await _channel.invokeMethod("getDefaultVideo", {"userID": userID});
  }

  // 设置默认的摄像头 ，videoID 应该从getAllVideoInfo返回值中获取
  Future<void> setDefaultVideo(String userID, int videoID) async {
    return await _channel.invokeMethod(
        "setDefaultVideo", {"userID": userID, "videoID": videoID});
  }

  // 开始预览
  Future<void> setUsrVideoId(int viewID, String usrVideoId) async {
    return await _channel.invokeMethod(
        "setUsrVideoId", {"viewID": viewID, "usrVideoId": usrVideoId});
  }

  // 销毁视频容器
  Future<bool> destroyPlatformView(int viewID) async {
    return await _channel
        .invokeMethod("destroyPlatformView", {"viewID": viewID});
  }

  // 获取视频比例
  Future<int> getScaleType(int viewID) async {
    return await _channel.invokeMethod("getScaleType", {"viewID": viewID});
  }

  // 设置视频比例
  Future<void> setScaleType(int viewID, int scaleType) async {
    return await _channel.invokeMethod(
        "setScaleType", {"viewID": viewID, "scaleType": scaleType});
  }
}
