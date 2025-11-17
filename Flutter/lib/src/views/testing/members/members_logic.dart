import 'package:get/get.dart';
import 'package:rtcsdk/rtcsdk.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/routes/navigator.dart';
import 'package:rtcsdk_demo/src/widgets/custom_dialog.dart';
import 'package:rtcsdk_demo/src/widgets/popup_menu_component.dart';

class MembersLogic extends GetxController {
  final rtcLogic = Get.find<RTCController>();

  var type = 0.obs;
  var title = "";
  var action = "".obs;
  var members = [].obs;
  var users = [].obs;
  List<MenuItemModel> menuItems = [
    MenuItemModel('查看大小流', 0),
    MenuItemModel('踢出会议', 1),
  ];

  @override
  void onInit() {
    type.value = Get.arguments['type'];
    action.value = Get.arguments['action'];
    if (type.value == 0) {
      title = "成员列表";
      getMembers();
    } else {
      title = "用户列表";
      getUsers();
    }

    super.onInit();
  }

  getMembers() async {
    List<MemberInfo> mems = await RtcSDK.memberManager.getAllMembers();
    members.value = mems.where((mem) => mem.userId != rtcLogic.userID).toList();
    // String myUserID = await RtcSDK.memberManager.getMyUserID();
    // debugPrint('myUserID: $myUserID');
  }

  getUsers() async {
    UserStatusListResult result = await RtcSDK.sdkManager.getUserStatus();
    if (result.sdkErr == 0) {
      users.value =
          result.list.where((mem) => mem.userID != rtcLogic.userID).toList();
    }
  }

  call(UserStatus us) async {
    Get.back(result: us.userID);
  }

  kickout(MemberInfo mem) async {
    bool? confirm = await Get.dialog(CustomDialog(
      title: "是否将${mem.nickName}踢出房间",
    ));
    if (confirm == true) {
      int sdkErr = await RtcSDK.roomManager.kickout(mem.userId);
      if (sdkErr == 0) {
        members.remove(mem);
      }
    }
  }

  tapMenu(MenuItemModel item, MemberInfo mem) {
    switch (item.value) {
      case 0:
        AppNavigator.toVideoStream(mem.userId);
        break;
      case 1:
        kickout(mem);
        break;
      default:
    }
  }
}
