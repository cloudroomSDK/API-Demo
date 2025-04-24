import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:rtcsdk/rtcsdk.dart';
import 'package:rtcsdk_demo/src/controller/rtc_controller.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';
import 'package:rtcsdk_demo/src/widgets/custom_appbar.dart';
import 'package:rtcsdk_demo/src/widgets/popup_menu_component.dart';

import 'members_logic.dart';

class MembersView extends GetView<MembersLogic> {
  MembersView({Key? key}) : super(key: key);

  final rtcLogic = Get.find<RTCController>();
  final logic = Get.find<MembersLogic>();

  Widget _buildItemView(MemberInfo mem) => PopupMenuComponent(
        menuItems: logic.menuItems,
        onTap: (item) {
          logic.tapMenu(item, mem);
        },
        child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                color: PageStyle.borderColor,
              )),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    mem.nickName,
                    textAlign: TextAlign.start,
                    style: PageStyle.ts_14c333333,
                  ),
                ),
              ],
            )),
      );

  Widget _buildUserStatusItemView(UserStatus us) => Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(
          color: PageStyle.borderColor,
        )),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              us.userID,
              textAlign: TextAlign.start,
              style: PageStyle.ts_14c333333,
            ),
          ),
          // Text(
          //   '${us.userStatus}',
          //   style: PageStyle.ts_14c333333,
          // ),
          if (rtcLogic.userID != us.userID)
            GestureDetector(
              onTap: () {
                logic.call(us);
              },
              child: Text(
                logic.action.value,
                textAlign: TextAlign.end,
                style: PageStyle.ts_14c3981fc,
              ),
            )
        ],
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: logic.title),
      body: Obx(
        () => ListView.builder(
          itemCount:
              logic.type.value == 0 ? logic.members.length : logic.users.length,
          itemBuilder: (_, index) => logic.type.value == 0
              ? _buildItemView(logic.members[index])
              : _buildUserStatusItemView(logic.users[index]),
        ),
      ),
    );
  }
}
