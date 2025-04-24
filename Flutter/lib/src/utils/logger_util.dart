import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:rtcsdk_demo/src/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:common_utils/common_utils.dart';

class Logger {
  static File? _file;
  static bool _writeing = false;
  static String _text = '';
  static String _writeingText = '';

  static Future<File> createFile() async {
    String path = '${(await Utils.storeDirectory())}/apidemo.log';
    File file = File(path);
    if (!await file.exists()) {
      await file.create();
    }
    return file;
  }

  static Future<void> checkFileSize() async {
    if (_file != null) {
      FileStat stat = await _file!.stat();
      int maxFileSize = 1024 * 1024 * 5; // 文件最大5M
      if (stat.size > maxFileSize) {
        // 备份当前
        // 创建一个新的文件
      }
    }
  }

  static void log(String text) {
    if (kDebugMode || kProfileMode) {
      debugPrint(text);
    }
    String now = DateUtil.getNowDateStr();
    _text += '[$now] $text \n';
    // _write();
    _writeInIso();
  }

  static void debug(String text) {
    if (kDebugMode || kProfileMode) {
      log(text);
    }
  }

  static void logPrint(Object? object) {
    if (object is String) {
      log(object);
    }
  }

  static void print(String text, {bool isError = false}) {
    if (isError) {
      log('Getx Error: $text');
    }
  }

  static final Function _writeInIso = Utils.debounce(
    // _writeText
    _writeInIsolate,
    duration: const Duration(seconds: 2),
  );

  static void _writeText() async {
    if (_writeing) return;
    _writeing = true;
    _writeingText = _text;
    _text = '';
    _file ??= await createFile();
    try {
      IOSink sink = _file!.openWrite(mode: FileMode.append);
      sink.write(_writeingText);
      await sink.flush();
      await sink.close();
      _writeing = false;
    } catch (e) {
      debugPrint("write error~~ $e");
    }
  }

  static void _writeInIsolate() async {
    if (_writeing) return;
    _writeing = true;
    _writeingText = _text;
    _text = '';
    _file ??= await createFile();
    Isolate? _isolate;
    final ReceivePort receivePort = ReceivePort();
    receivePort.listen((message) {
      print('receivePort close');
      receivePort.close();
      _isolate?.kill(priority: Isolate.immediate);
      _writeing = false;
    });

    _isolate = await Isolate.spawn(
      writeFileInIsolate,
      {
        'filePath': _file!.path,
        'content': _writeingText,
      },
      onExit: receivePort.sendPort,
    );
  }

  static void writeFileInIsolate(Map<String, dynamic> message) async {
    final String content = message['content'];
    final String filePath = message['filePath'];
    final File file = File(filePath);
    try {
      final raf = await file.open(mode: FileMode.append);
      // 写入内容
      await raf.writeString(content);
      await raf.close();
    } catch (e) {
      print('writeFileInIsolate error：$e');
    }
  }
}
