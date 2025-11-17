import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:rtcsdk_demo/src/resources/styles.dart';

class LoadingView {
  static final LoadingView singleton = LoadingView._();

  factory LoadingView() => singleton;

  LoadingView._();

  OverlayState? _overlayState;
  OverlayEntry? _overlayEntry;
  bool _isVisible = false;

  Future<T> wrap<T>({
    required Future<T> Function() asyncFunction,
    bool showing = true,
    String? text,
  }) async {
    if (showing) show(text: text);
    T data;
    try {
      data = await asyncFunction();
    } on Exception catch (_) {
      rethrow;
    } finally {
      dismiss();
    }
    return data;
  }

  void show({
    String? text,
  }) async {
    if (_isVisible) return;
    _overlayState = Overlay.of(Get.overlayContext!);
    _overlayEntry = OverlayEntry(
      // opaque: true, // 是否不透明
      // maintainState: true, // 如果您需要在OverlayEntry中使用有状态的小部件，那么您需要将maintainState设置为true，以便小部件可以保持其状态并接收生命周期方法。
      builder: (BuildContext context) => Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.transparent,
        child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SpinKitCircle(color: PageStyle.mainColor),
          const SizedBox(height: 10),
          if (text != null)
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            )
        ])),
      ),
    );
    _isVisible = true;
    _overlayState?.insert(_overlayEntry!);
  }

  dismiss() async {
    if (!_isVisible) return;
    _overlayEntry?.remove();
    _isVisible = false;
  }
}
