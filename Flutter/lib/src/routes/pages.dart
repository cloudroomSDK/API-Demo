// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:rtcsdk_demo/src/views/functions/functions_view.dart';
import 'package:rtcsdk_demo/src/views/functions/functions_binding.dart';
import 'package:rtcsdk_demo/src/views/joinroom/joinroom_view.dart';
import 'package:rtcsdk_demo/src/views/joinroom/joinroom_binding.dart';
import 'package:rtcsdk_demo/src/views/setting/setting_view.dart';
import 'package:rtcsdk_demo/src/views/setting/setting_binding.dart';
import 'package:rtcsdk_demo/src/views/audiochannel/audiochannel_view.dart';
import 'package:rtcsdk_demo/src/views/audiochannel/audiochannel_binding.dart';
import 'package:rtcsdk_demo/src/views/videochannel/videochannel_view.dart';
import 'package:rtcsdk_demo/src/views/videochannel/videochannel_binding.dart';
import 'package:rtcsdk_demo/src/views/videoconfig/videoconfig_view.dart';
import 'package:rtcsdk_demo/src/views/videoconfig/videoconfig_binding.dart';
import 'package:rtcsdk_demo/src/views/screensharing/screensharing_view.dart';
import 'package:rtcsdk_demo/src/views/screensharing/screensharing_binding.dart';
import 'package:rtcsdk_demo/src/views/localrecord/localrecord_view.dart';
import 'package:rtcsdk_demo/src/views/localrecord/localrecord_binding.dart';
import 'package:rtcsdk_demo/src/views/localrecord/recordlist/record_list_view.dart';
import 'package:rtcsdk_demo/src/views/localrecord/recordlist/record_list_binding.dart';
import 'package:rtcsdk_demo/src/views/remoterecord/remoterecord_view.dart';
import 'package:rtcsdk_demo/src/views/remoterecord/remoterecord_binding.dart';
import 'package:rtcsdk_demo/src/views/media/media_view.dart';
import 'package:rtcsdk_demo/src/views/media/media_binding.dart';
import 'package:rtcsdk_demo/src/views/chat/chat_view.dart';
import 'package:rtcsdk_demo/src/views/chat/chat_binding.dart';
import 'package:rtcsdk_demo/src/views/testing/testing_view.dart';
import 'package:rtcsdk_demo/src/views/testing/testing_binding.dart';
import 'package:rtcsdk_demo/src/views/testing/test_room/test_room_view.dart';
import 'package:rtcsdk_demo/src/views/testing/test_room/test_room_binding.dart';
import 'package:rtcsdk_demo/src/views/testing/members/members_view.dart';
import 'package:rtcsdk_demo/src/views/testing/members/members_binding.dart';
import 'package:rtcsdk_demo/src/views/testing/video_stream/video_stream_view.dart';
import 'package:rtcsdk_demo/src/views/testing/video_stream/video_stream_binding.dart';
import 'package:rtcsdk_demo/src/views/testing/video_call/video_call_view.dart';
import 'package:rtcsdk_demo/src/views/testing/video_call/video_call_binding.dart';
import 'package:rtcsdk_demo/src/views/testing/queue_list/queue_list_view.dart';
import 'package:rtcsdk_demo/src/views/testing/queue_list/queue_list_binding.dart';

import 'router.dart';

class AppPages {
  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.FUNCTIONS,
      page: () => Functions(),
      binding: FunctionsBinding(),
    ),
    GetPage(
      name: AppRoutes.JOINROOM,
      page: () => JoinRoom(),
      binding: JoinRoomBinding(),
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => Settings(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.AUDIOCHANNEL,
      page: () => AudioChannel(),
      binding: AudioChannelBinding(),
      // middlewares: [
      //   InterceptorMiddleware(),
      // ],
    ),
    GetPage(
      name: AppRoutes.VIDEOCHANNEL,
      page: () => VideoChannel(),
      binding: VideoChannelBinding(),
      // middlewares: [
      //   InterceptorMiddleware(),
      // ],
    ),
    GetPage(
      name: AppRoutes.VIDEOCONFIG,
      page: () => VideoConfig(),
      binding: VideoConfigBinding(),
      // middlewares: [
      //   InterceptorMiddleware(),
      // ],
    ),
    GetPage(
      name: AppRoutes.VIDEOSTREAM,
      page: () => VideoStreamView(),
      binding: VideoStreamBinding(),
      // middlewares: [
      //   InterceptorMiddleware(),
      // ],
    ),
    GetPage(
      name: AppRoutes.SCREENSHARING,
      page: () => ScreenSharing(),
      binding: ScreenSharingBinding(),
      // middlewares: [
      //   InterceptorMiddleware(),
      // ],
    ),
    GetPage(
      name: AppRoutes.LOCALRECORED,
      page: () => LocalRecord(),
      binding: LocalRecordBinding(),
      // middlewares: [
      //   InterceptorMiddleware(),
      // ],
    ),
    GetPage(
      name: AppRoutes.LOCALRECOREDLIST,
      page: () => RecordList(),
      binding: RecordListBinding(),
      // middlewares: [
      //   InterceptorMiddleware(),
      // ],
    ),
    GetPage(
      name: AppRoutes.REMOTERECORD,
      page: () => RemoteRecord(),
      binding: RemoteRecordBinding(),
      // middlewares: [
      //   InterceptorMiddleware(),
      // ],
    ),
    GetPage(
      name: AppRoutes.MEDIA,
      page: () => Media(),
      binding: MediaBinding(),
      // middlewares: [
      //   InterceptorMiddleware(),
      // ],
    ),
    GetPage(
      name: AppRoutes.CHAT,
      page: () => Chat(),
      binding: ChatBinding(),
      // middlewares: [
      //   InterceptorMiddleware(),
      // ],
    ),
    GetPage(
      name: AppRoutes.TESTING,
      page: () => Testing(),
      binding: TestingBinding(),
      // middlewares: [
      //   InterceptorMiddleware(),
      // ],
    ),
    GetPage(
      name: AppRoutes.MEMBERS,
      page: () => MembersView(),
      binding: MembersBinding(),
    ),
    GetPage(
      name: AppRoutes.VIDEOCALL,
      page: () => VideoCallPage(),
      binding: VideoCallBinding(),
    ),
    GetPage(
      name: AppRoutes.TESTROOM,
      page: () => TestRoomView(),
      binding: TestRoomBinding(),
    ),
    GetPage(
      name: AppRoutes.QUEUELIST,
      page: () => QueueListView(),
      binding: QueueListBinding(),
    ),
  ];
}
