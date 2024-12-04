import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:rtcsdk_demo/src/models/video_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';

class Utils {
  static Future<String> storeDirectory() async {
    return Platform.isAndroid
        ? '${(await getExternalStorageDirectory())?.path}'
        : (await getApplicationDocumentsDirectory()).path;
  }

  // 保存到movies文件夹
  static Future<String> moviesStorageDirectories() {
    return externalStorageDirectories(type: StorageDirectory.movies);
  }

  // 保存到某种类型文件夹
  static Future<String> externalStorageDirectories(
      {StorageDirectory? type}) async {
    if (Platform.isAndroid) {
      List<Directory>? lists = await getExternalStorageDirectories(type: type);
      if (lists != null && lists.isNotEmpty) {
        return lists.first.path;
      }
      return '';
    }
    return (await getApplicationDocumentsDirectory()).path;
  }

  static Future<String> applicationCacheDirectories() async {
    if (Platform.isAndroid) {
      Directory dir = await getApplicationCacheDirectory();
      return dir.path;
    }
    return (await getApplicationDocumentsDirectory()).path;
  }

  // 返回一个不重复的10000以内的数字
  static final List randoms = [];
  static String getRandom() {
    int random = Random().nextInt(9999);
    if (!randoms.contains(random)) {
      randoms.add(random);
      return random.toString();
    } else {
      return getRandom();
    }
  }

  static Function debounce(Function func, {Duration? duration}) {
    Timer? timer;
    Duration dura = duration ?? const Duration(milliseconds: 300);
    return ([Object? t]) {
      timer?.cancel();
      timer = Timer(dura, () {
        if (t != null) {
          func(t);
        } else {
          func();
        }
        timer = null;
      });
    };
  }

  static String dateProp2Str(int n) => n < 10 ? '0$n' : '$n';

  static String dateFormat(DateTime dt,
      {String format = "yyyy-MM-dd hh:mm:ss"}) {
    DateTime dateTime = DateTime.now();
    Map<String, String> dateProps = {
      "yyyy": "${dateTime.year}",
      "M": "${dateTime.month}",
      "MM": dateProp2Str(dateTime.month),
      "d": "${dateTime.day}",
      "dd": dateProp2Str(dateTime.day),
      "h": "${dateTime.hour}",
      "hh": dateProp2Str(dateTime.hour),
      "m": "${dateTime.minute}",
      "mm": dateProp2Str(dateTime.minute),
      "s": "${dateTime.second}",
      "ss": dateProp2Str(dateTime.second),
    };
    return format.replaceAllMapped(RegExp(r"(yyyy|MM?|dd?|hh?|mm?|ss?)"),
        (match) {
      String? cap = match.group(0);
      if (cap != null && dateProps.containsKey(cap)) {
        return dateProps[cap]!;
      }
      return "";
    });
  }

  static void loading({
    String? status,
  }) {
    EasyLoading.show(status: status);
  }

  // 计算小视频位置 vNum（竖着的个数） hNum（横着的个数）
  static List<VideoPosition> getVideoPosition(
      {required BuildContext ctx, int vNum = 3, int hNum = 3}) {
    int maxVideoNum = vNum * hNum;
    double padding = 100;
    double screenWidth = MediaQuery.of(ctx).size.width;
    double screenHeight = MediaQuery.of(ctx).size.height;
    double gscreenWidth = screenWidth - padding;
    double gscreenHeight = screenHeight - padding;
    double height = gscreenHeight / vNum; // 小视频的高度
    double cwidth = height / 16 * 9; // 小视频根据高度算出来的宽度
    double width = gscreenWidth / hNum; // 小视频的宽度
    double cheight = width / 9 * 16; // 小视频根据宽度算出来的高度
    if (width > cwidth) {
      width = cwidth;
    } else {
      height = cheight;
    }
    double pwidth = width / screenWidth; // 宽度百分比
    double pheight = height / screenHeight; // 高度百分比
    int initialTop = 20; // 初始顶部距离
    int initialRight = 10; // 初始右边距离
    int gutterTop = 20; // 每个item的paddingTop
    int gutterRight = 20; // 每个item的paddingRight
    // 竖着从右到左排vNum * hNum个
    return List.generate(maxVideoNum, (index) {
      final int idx = index + 1;
      final int tmod = index % vNum;
      double top = (height + gutterTop) * tmod + initialTop;
      double left = screenWidth -
          ((idx / hNum).ceil() * (width + gutterRight)) +
          (gutterRight - initialRight);
      double ptop = top / screenHeight;
      double pleft = left / screenWidth;

      return VideoPosition(
          top: top,
          left: left,
          height: height,
          width: width,
          pheight: pheight,
          pwidth: pwidth,
          ptop: ptop,
          pleft: pleft);
    });
  }
}
