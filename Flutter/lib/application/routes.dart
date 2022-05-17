import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:cloudroomvideosdk_example/functions.dart';
import 'package:cloudroomvideosdk_example/setting.dart';
import 'package:cloudroomvideosdk_example/join_room.dart';
import 'package:cloudroomvideosdk_example/audio_channel.dart';
import 'package:cloudroomvideosdk_example/video_channel.dart';
import 'package:cloudroomvideosdk_example/video_config.dart';
import 'package:cloudroomvideosdk_example/screen_sharing.dart';
import 'package:cloudroomvideosdk_example/remote_record.dart';
import 'package:cloudroomvideosdk_example/local_record.dart';
import 'package:cloudroomvideosdk_example/video_player.dart';
import 'package:cloudroomvideosdk_example/chat.dart';
import 'package:cloudroomvideosdk_example/not_found.dart';

class Routes {
  static void configureRoutes(FluroRouter router) {
    router = router;
    // 未发现对应route
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const NotFound();
    });

    router.define("/", handler: Handler(handlerFunc: (context, params) {
      // final args = context.settings.arguments as MyArgumentsDataClass;
      return const Functions();
    }));

    router.define("/setting", handler: Handler(handlerFunc: (context, params) {
      return const Setting();
    }));

    router.define("/joinroom", handler: Handler(handlerFunc: (context, params) {
      String? target = params["target"]?.first;
      if (target != null) {
        return JoinRoom(target: target);
      }
      return const NotFound();
    }));

    router.define("/audiochannel",
        handler: Handler(handlerFunc: (context, params) {
      return const AudioChannel();
    }));

    router.define("/videochannel",
        handler: Handler(handlerFunc: (context, params) {
      return const VideoChannel();
    }));

    router.define("/videoconfig",
        handler: Handler(handlerFunc: (context, params) {
      return const VideoConfig();
    }));

    router.define("/screensharing",
        handler: Handler(handlerFunc: (context, params) {
      return const ScreenSharing();
    }));

    router.define("/remoterecord",
        handler: Handler(handlerFunc: (context, params) {
      return const RemoteRecord();
    }));

    router.define("/localrecord",
        handler: Handler(handlerFunc: (context, params) {
      return const LocalRecord();
    }));

    router.define("/videoplayer",
        handler: Handler(handlerFunc: (context, params) {
      return const VideoPlayer();
    }));

    router.define("/chat", handler: Handler(handlerFunc: (context, params) {
      return const Chat();
    }));
  }
}
