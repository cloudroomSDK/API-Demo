import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'cr_api.dart';
import 'package:cloudroomvideosdk/implements/cr_impl.dart';
import 'package:cloudroomvideosdk/implements/cr_impl_video.dart';
import 'package:cloudroomvideosdk/implements/cr_impl_media.dart';
import 'package:cloudroomvideosdk/implements/cr_impl_screen_share.dart';

extension ClouroomPlatformViewUtils on CrSDK {
  Widget? _createView(
      String viewType, Function(int viewID) onPlatformViewCreated,
      {Key? key}) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
          key: key,
          viewType: "cr_flutter_sdk_view",
          creationParams: {"viewType": viewType},
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: onPlatformViewCreated);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
          key: key,
          viewType: "cr_flutter_sdk_view",
          creationParams: {"viewType": viewType},
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: onPlatformViewCreated);
    }
    return null;
  }

  // 创建视频视图
  Widget? createPlatformView(Function(int viewID) onViewCreated, {Key? key}) {
    return _createView("platformview", onViewCreated, key: key);
  }

  // 销毁视频视图
  Future<bool> destroyPlatformView(int viewID) async {
    return await CrImpl.instance.destroyPlatformView(viewID);
  }

  // 创建屏幕共享视图
  Widget? createScreenShareView(Function(int viewID) onViewCreated,
      {Key? key}) {
    return _createView("screenshareview", onViewCreated, key: key);
  }

  // 销毁屏幕共享视图
  Future<bool> destroyScreenShareView(int viewID) async {
    return await CrImpl.instance.destroyScreenShareView(viewID);
  }

  // 创建屏幕共享视图
  Widget? createMediaView(Function(int viewID) onViewCreated, {Key? key}) {
    return _createView("mediaview", onViewCreated, key: key);
  }

  // 销毁屏幕共享视图
  Future<bool> destroyMediaView(int viewID) async {
    return await CrImpl.instance.destroyMediaView(viewID);
  }
}
