import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';

class MenuItemModel {
  String title;
  int value;

  MenuItemModel(this.title, this.value);
}

class PopupMenuComponent extends StatefulWidget {
  const PopupMenuComponent({
    Key? key,
    required this.child,
    this.menuItems = const [],
    this.onTap,
  }) : super(key: key);

  final Widget child;
  final List<MenuItemModel> menuItems;
  final Function(MenuItemModel item)? onTap;

  @override
  State<PopupMenuComponent> createState() => _PopupMenuComponentState();
}

class _PopupMenuComponentState extends State<PopupMenuComponent> {
  CustomPopupMenuController controller = CustomPopupMenuController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenu(
      controller: controller,
      verticalMargin: 0,
      pressType: PressType.longPress,
      child: widget.child,
      menuBuilder: () => ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          color: const Color(0xFF4C4C4C),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widget.menuItems
                  .map(
                    (item) => GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        controller.hideMenu();
                        widget.onTap?.call(item);
                      },
                      child: Container(
                        height: 40,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: Text(
                                  item.title,
                                  style: PageStyle.ts_12cffffff,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
