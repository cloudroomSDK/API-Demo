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
    String dirPath = '${await Utils.storeDirectory()}/Log';
    Directory dir = Directory(dirPath);
    String logBak = "_apidemo.log.bak";
    if (dir.existsSync()) {
      List<FileSystemEntity> list = dir.listSync();
      for (FileSystemEntity entity in list) {
        if (entity is File) {
          String name = entity.path.split('/').last;
          if (name.endsWith(logBak)) {
            String dateStr = name.replaceAll(logBak, "");
            // 删了超过7天的备份文件
            if (DateTime.now()
                    .difference(DateUtil.getDateTime(dateStr)!)
                    .inDays >
                7) {
              entity.deleteSync();
            }
          }
        }
      }
    } else {
      dir.createSync();
    }

    String path = '$dirPath/apidemo.log';
    File file = File(path);
    bool exists = file.existsSync();

    if (exists) {
      FileStat stat = file.statSync();
      int maxFileSize = 1024 * 1024 * 5; // 超过5M的文件备份一个
      if (stat.size > maxFileSize) {
        // 备份当前
        String now = DateUtil.formatDate(DateTime.now(), format: 'yyyy-MM-dd');
        file.copySync('$dirPath/$now$logBak');
        file.writeAsBytesSync([], mode: FileMode.write);
      }
    } else {
      file.createSync();
    }
    return file;
  }

  static void log(String text) {
    if (kDebugMode || kProfileMode) {
      debugPrint(text);
    }
    String now = DateUtil.getNowDateStr();
    _text += '[$now] $text \n';
    _write();
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

  static final Function _write = Utils.debounce(
    _writeText,
    // _writeInIsolate,
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
      debugPrint('writeFileInIsolate error：$e');
    }
  }
}
