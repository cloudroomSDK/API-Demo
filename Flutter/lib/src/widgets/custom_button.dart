// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';

enum BUTTON_TYPE {
  primary,
  danger,
}

enum BUTTON_SIZE {
  large,
  medium,
  small,
}

class CustomButton extends StatelessWidget {
  final BUTTON_TYPE type;
  final BUTTON_SIZE size;
  final Widget? child;
  final void Function()? onPressed;

  const CustomButton({
    Key? key,
    this.type = BUTTON_TYPE.primary,
    this.size = BUTTON_SIZE.medium,
    this.child,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: BUTTON_TYPE.primary == type
            ? PageStyle.mainColor
            : PageStyle.dangerColor,
        disabledBackgroundColor: BUTTON_TYPE.primary == type
            ? PageStyle.mainColor.withOpacity(0.6)
            : PageStyle.dangerColor.withOpacity(0.6),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
