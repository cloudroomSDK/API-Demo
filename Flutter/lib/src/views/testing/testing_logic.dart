import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rtcsdk_demo/src/controller/app_controller.dart';
import 'package:rtcsdk_demo/src/controller/permission_controller.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/routes/navigator.dart';
import 'package:rtcsdk/rtcsdk.dart';
import 'package:get/get.dart';
import 'package:rtcsdk_demo/src/widgets/custom_dialog.dart';

class TestingLogic extends GetxController {
  final appLogic = Get.find<AppController>();
  final rtcLogic = Get.find<RTCController>();
  final permissionLogic = Get.find<PermissionController>();

  late ScrollController controller;
  late TextEditingController calledCtrl;
  RxList<String> logs = <String>[].obs;
  RxBool statusNotify = false.obs;
  RxBool dndType = false.obs;

  @override
  onInit() {
    logs.add('我的UserID: ${rtcLogic.userID}');

    controller = ScrollController();
    calledCtrl = TextEditingController();

    RtcSDK.sdkManager.listener.onNotifyUserStatus = (UserStatus userStatus) {
      log('用户状态变化通知: ${userStatus.toJson()}');
    };

    RtcSDK.callManager.setListener(CallListener(
      onNotifyCallIn: notifyCallIn,
      onNotifyCallAccepted: notifyCallAccept,
      onNotifyCallRejected: notifyCallReject,
      onNotifyCallHangup: notifyCallHangup,
    ));

    RtcSDK.inviteManager.setListener(InviteListener(
      onNotifyInviteIn: notifyInviteIn,
      onNotifyInviteAccepted: notifyInviteAccept,
      onNotifyInviteRejected: notifyInviteReject,
      onNotifyInviteCanceled: notifyInviteCancel,
    ));

    RtcSDK.queueManager.setListener(QueueListener(
      onQueueStatusChanged: queueStatusChanged,
      onQueuingInfoChanged: queuingInfoChanged,
      onAutoAssignUser: autoAssignUser,
      onCancelAssignUser: cancelAssignUser,
    ));

    RtcSDK.transpChannelManager.setListener(TranspChannelListener(
      onSendProgress: sendProgress,
      onNotifyCmdData: notifyCmdData,
      onNotifyBufferData: notifyBufferData,
      onNotifyFileData: notifyFileData,
      onNotifyCancelSend: notifyCancelSend,
    ));

    getMyUserStatus();
    switchUserStatusNotify();
    initQueue();
    super.onInit();
  }

  @override
  onClose() {
    controller.dispose();
    calledCtrl.dispose();
    super.onClose();
  }

  log(String text) {
    logs.add(text);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  // 呼叫相关
  // 选择呼叫用户
  selCallUser() async {
    var userID = await AppNavigator.toMembers(type: 1, action: "呼叫");
    if (userID != null) {
      callUser(userID);
    }
  }

  callUser(String userID) async {
    EasyLoading.show();
    MeetInfo meetInfo = await RtcSDK.roomManager.createMeeting();
    CallResult callResult = await RtcSDK.callManager.call(userID, meetInfo);
    log('呼叫用户$userID');
    Get.dialog(CustomDialog(
      title: '呼叫',
      content: '正在呼叫用户$userID',
      hideRightButton: true,
      leftText: "取消呼叫",
      onTapLeft: () {
        RtcSDK.callManager.hangupCall(callResult.callID);
        log('取消呼叫用户$userID');
        Get.back();
      },
    ));
    EasyLoading.dismiss();
  }

  // 获取项目下用户在线状态
  getUserStatus() async {
    UserStatusListResult result = await RtcSDK.sdkManager.getUserStatus();
    if (result.sdkErr == 0) {
      log(json.encode(result.list));
    }
  }

  getMyUserStatus() async {
    UserStatusListResult result =
        await RtcSDK.sdkManager.getUserStatus(userID: rtcLogic.userID);
    UserStatus item = result.list[0];
    dndType.value = item.DNDType != 0;
  }

  switchUserStatusNotify() async {
    if (statusNotify.value) {
      CommonResult res = await RtcSDK.sdkManager.stopUserStatusNotify();
      if (res.sdkErr == 0) {
        statusNotify.value = false;
        log('关闭用户的状态推送');
      }
    } else {
      CommonResult res = await RtcSDK.sdkManager.startUserStatusNotify();
      if (res.sdkErr == 0) {
        statusNotify.value = true;
        log('开启用户的状态推送');
      }
    }
  }

  switchUserDndType() async {
    int status = dndType.value ? 0 : 1;
    CommonResult res = await RtcSDK.sdkManager.setDNDStatus(status);
    if (res.sdkErr == 0) {
      dndType.toggle();
      log('${dndType.value ? '开启' : '关闭'}用户的状态推送');
    }
  }

  // 队列 -------------------------------------------------------
  bool isInitQueue = false;
  RxBool isSerivceQueueing = false.obs;
  RxBool isQueueing = false.obs;
  initQueue() async {
    if (!isInitQueue) {
      log('开始初始化队列');
      CommonResult initRes = await RtcSDK.queueManager.initQueue();
      if (initRes.sdkErr == 0) {
        isInitQueue = true;
        log('队列初始化成功');
      } else {
        log('队列初始化失败：${initRes.sdkErr}');
      }
    }
  }

  // 开始服务队列（坐席）
  switchServiceQueue() async {
    if (isQueueing.value) {
      EasyLoading.showInfo('请先停止排队');
      return;
    }
    if (!isSerivceQueueing.value) {
      await initQueue();
      var result = await AppNavigator.toQueueList();
      if (result != null) {
        QueueInfo info = result as QueueInfo;
        await RtcSDK.queueManager.startService(info.queID);
        isSerivceQueueing.value = true;
      }
    } else {
      List<int> ids = await RtcSDK.queueManager.getServiceQueues();
      for (int i = 0; i < ids.length; i++) {
        await RtcSDK.queueManager.stopService(ids[i]);
      }
      isSerivceQueueing.value = false;
    }
  }

  getServiceQueues() async {
    List<int> ids = await RtcSDK.queueManager.getServiceQueues();
    log('$ids');
  }

  getQueueStatus() async {
    List<int> ids = await RtcSDK.queueManager.getServiceQueues();
    for (int i = 0; i < ids.length; i++) {
      int qid = ids[i];
      // 获取队列状态
      QueueStatus status = await RtcSDK.queueManager.getQueueStatus(qid);
      log('队列$qid, 状态: ${status.toJson()}');
    }
  }

  // 显示分配用户的弹窗
  showAssignUserDialog(QueueUserInfo userInfo) {
    Get.dialog(CustomDialog(
      title: '分配用户',
      content: '是否服务用户${userInfo.usrID}',
      onTapLeft: () async {
        CommonResult rejResult = await RtcSDK.queueManager
            .rejectAssignUser(userInfo.queID, userInfo.usrID!);
        log('rejectAssignUser: ${rejResult.sdkErr}');
        closeDialog();
      },
      onTapRight: () async {
        CommonResult accResult = await RtcSDK.queueManager
            .acceptAssignUser(userInfo.queID, userInfo.usrID!);
        log('acceptAssignUser: ${accResult.sdkErr}');
        closeDialog();
        // 可以呼这个用户
        callUser(userInfo.usrID!);
      },
    ));
  }

  // 当关闭免打扰时，系统将自动分配客户，无需调用此函数
  // 当开启免打扰时，系统不再自动分配客户，座席如需服务客户可使用此函数分配
  reqAssignUser() async {
    QueueUserInfoResult result = await RtcSDK.queueManager.reqAssignUser();
    if (result.sdkErr == 0) {
      showAssignUserDialog(result.userInfo);
    } else {
      log('sdkErr: ${result.sdkErr} --- userInfo: ${result.userInfo.toJson()}');
    }
  }

  // 排队（客户）
  switchQueue() async {
    if (isSerivceQueueing.value) {
      EasyLoading.showInfo('请先停止服务队列');
      return;
    }
    if (!isQueueing.value) {
      await initQueue();
      var result = await AppNavigator.toQueueList();
      if (result != null) {
        QueueInfo info = result as QueueInfo;
        await RtcSDK.queueManager.startQueuing(info.queID);
        isQueueing.value = true;
      }
    } else {
      await RtcSDK.queueManager.stopQueuing();
      isQueueing.value = false;
    }
  }

  // 获取我的排队信息
  getQueuingInfo() async {
    QueuingInfo info = await RtcSDK.queueManager.getQueuingInfo();
    if (info.queID == -1) {
      log('没有排队');
    } else if (info.queID == -2) {
      log('正在会话中');
    } else {
      log('我的排队信息: ${info.toJson()}');
    }
  }

  // 透明通道-----------------------------------------------------
  sendCmd() async {
    var targetUserId = await AppNavigator.toMembers(type: 1, action: "发送");
    if (targetUserId != null) {
      SendResult result = await RtcSDK.transpChannelManager
          .sendCmd(targetUserId, "Flutter Api Demo 发送点对点消息");
      log('发送点对点消息成功，id: ${result.taskId}');
    }
  }

  sendBuffer() async {
    var targetUserId = await AppNavigator.toMembers(type: 1, action: "发送");
    if (targetUserId != null) {
      String data = '';
      for (int i = 0; i < 1000; i++) {
        data += 'Flutter Api Demo 发送点对点大数据';
      }
      SendResult result =
          await RtcSDK.transpChannelManager.sendBuffer(targetUserId, data);
      log('发送点对点大数据，id: ${result.taskId}');
      //   // 取消发送
      //   RtcSDK.transpChannelManager.cancelSend(result.taskId);
    }
  }

  void closeDialog() {
    Get.isDialogOpen == true ? Get.back() : null;
  }

  enterRoom(
    String callID,
    int confID,
  ) async {
    await permissionLogic.checkPermission([
      Permission.camera,
      Permission.microphone,
      Permission.phone,
      Permission.storage,
    ]);
    EasyLoading.show();
    AppNavigator.toTestRoom(confID)?.then((value) {
      if (value == true) {
        RtcSDK.callManager.hangupCall(callID); // 我主动挂断
      }
    });
    int sdkErr = await rtcLogic.enterMeeting(confID);
    if (sdkErr != 0) {
      if (sdkErr == 807) await rtcLogic.exitMeeting();
    }
    EasyLoading.dismiss();
  }

  // 通知------------------------------------------------

  void notifyCallIn(
      String callID, int confID, String callerID, String usrExtDat) {
    Get.dialog(CustomDialog(
      title: '呼叫请求',
      content: '是否接收来自$callerID的呼叫',
      leftText: '拒绝',
      rightText: '接受',
      onTapLeft: () {
        RtcSDK.callManager.rejectCall(callID);
        closeDialog();
        log('我拒绝呼叫');
      },
      onTapRight: () {
        RtcSDK.callManager.acceptCall(callID, MeetInfo(confId: confID));
        closeDialog();
        enterRoom(callID, confID);
        log('我接受呼叫, 房间$confID');
      },
    ));
  }

  void notifyCallAccept(String callID, int confID, String usrExtDat) async {
    log('$callID接受呼叫, 进房间$confID');
    closeDialog();
    enterRoom(callID, confID);
  }

  void notifyCallReject(String callID, int sdkErr, String usrExtDat) {
    log('$callID拒绝呼叫，sdkErr: $sdkErr');
    closeDialog();
  }

  void notifyCallHangup(String callID, String usrExtDat) {
    log('$callID挂断呼叫');
    closeDialog();
  }

  // 邀请
  void notifyInviteIn(String inviteID, String inviterUsrID, String usrExtDat) {}

  void notifyInviteAccept(String inviteID, String usrExtDat) {}

  void notifyInviteReject(String inviteID, String usrExtDat, int sdkErr) {}

  void notifyInviteCancel(String inviteID, String usrExtDat, int sdkErr) {}

  // 队列状态变化通知
  void queueStatusChanged(QueueStatus queueStatus) {
    log('队列状态变化通知: ${queueStatus.toJson()}');
  }

  // 排队信息变化通知
  void queuingInfoChanged(QueuingInfo queuingInfo) {
    log('排队信息变化通知: ${queuingInfo.toJson()}');
  }

  // 自动分配用户通知
  void autoAssignUser(QueueUserInfo userInfo) {
    log('自动分配用户通知: ${userInfo.toJson()}');
    showAssignUserDialog(userInfo);
  }

  // 分配用户被取消通知
  void cancelAssignUser(int queID, String userID) {
    log('分配用户被取消通知: queID: $queID, userID: $userID');
    closeDialog();
  }

  // 发送数据时，通知发送进度
  void sendProgress(
      String taskId, int sendedLen, int totalLen, String? cookie) {
    log('发送进度: $sendedLen/$totalLen');
  }

  // 通知收到小块数据
  void notifyCmdData(String sourceUserId, String data) {
    log('收到$sourceUserId发送的小块数据: $data');
  }

  // 通知收到大块数据
  void notifyBufferData(String sourceUserId, String data) {
    log('收到$sourceUserId发送的大块数据: $data');
  }

  // 通知收到文件数据
  void notifyFileData(
      String sourceUserId, String tmpFile, String orgFileName) {}

  // 通知取消发送
  void notifyCancelSend(String taskId) {
    log('取消发送: $taskId');
  }
}
