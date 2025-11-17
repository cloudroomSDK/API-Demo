import 'package:rtcsdk_demo/src/routes/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: const IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: AppNavigator.back,
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(50.h);
}
