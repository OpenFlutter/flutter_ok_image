import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/io_client.dart' as io_client;
import 'package:ok_image/src/cache/download_error.dart';
import 'package:ok_image/src/cache/download_future.dart';
import 'package:ok_image/src/util/log.dart';

//import 'package:http/http.dart' as http;

StreamController<String> _downloadStreamController = StreamController<String>();

class DownloadManager {
  static DownloadManager _instance = DownloadManager._();

  List<DownloadFuture> futures = [];

  DownloadManager._() {
    _downloadStreamController.stream.listen(onReceive);
  }

  factory DownloadManager() {
    return _instance;
  }

  bool isDownloading(String url) {
    for (var future in futures) {
      if (future.url == url) {
        return true;
      }
    }
    return false;
  }

  void tryDownload(String url, File targetFile) async {
    io_client.IOClient client = io_client.IOClient(); //确定下载再创建client

    if (isDownloading(url)) {
      return;
    }

    // 先创建一个临时文件,用于告知
    var tmpFile = File(_getTmpPath(targetFile))..createSync();

    try {
      var response = await client.get(url);
      if (response.statusCode == 200 && !response.isRedirect) {
        var bytes = response.bodyBytes;
        Log.log("下载完成");
        // 成功,先写tmp文件中
        await targetFile.writeAsBytes(bytes);
        Log.log("写入完成");
        _downloadStreamController.add(url);
      } else {
        _downloadStreamController.addError(DownloadError(
            "download error", StateError("code = ${response.statusCode}")));
        Log.log("$url 不存在");
      }
    } catch (e) {
      if (e is Exception) {
        _downloadStreamController.addError(e);
      } else {
        _downloadStreamController.addError(DownloadError("download error", e));
      }
    } finally {
      // 写完后删除临时文件
      tmpFile.deleteSync();
      Log.log("删除临时文件");
      client.close();
    }
  }

  void onReceive(String url) {
    futures.toList().forEach((future) {
      if (future.url == url) {
        future.completer.complete(url);
        futures.remove(future);
      }
    });
  }

  void onError(String url, Error error) {
    futures.toList().forEach((future) {
      if (future.url == url) {
        future.completer.completeError(
            DownloadError("download error", error, error.stackTrace));
        futures.remove(future);
      }
    });
  }

  Future<String> waitForDownloadResult(String url, File targetFile) {
    Completer<String> completer = Completer();
    tryDownload(url, targetFile);
    futures.add(DownloadFuture(url, completer));
    return completer.future;
  }
}

Future<File> requestImage(String url, Directory targetDir) async {
  File targetFile = _downloadFilePath(url, targetDir);
  Log.log("下载文件为 $targetFile");

  bool isDownloaded() {
    var tmpPath = _getTmpPath(targetFile);
    if (File(tmpPath).existsSync()) {
      return false;
    }
    return targetFile.existsSync();
  }

  // bool isDownloading() {
  //   return File(_getTmpPath(targetFile)).existsSync();
  // }

  if (isDownloaded()) {
    Log.log("文件已下载,直接返回缓存");
    return targetFile;
  }

  Log.log("图片未下载,加入下载队列");

  await DownloadManager().waitForDownloadResult(url, targetFile);
  return targetFile;
}

File _downloadFilePath(String url, Directory targetDir) {
  var name = md5.convert(url.codeUnits).toString();
  var lastName = url.split("/").last;
  if (!lastName.contains(".")) {
    return File(targetDir.absolute.path + "/" + name);
  }

  var extName = url.split("\.").last;
  var path = targetDir.absolute.path + "/" + "$name.$extName";
  var targetFile = File(path);
  return targetFile;
}

String _getTmpPath(File targetFile) {
  var _pathList = targetFile.absolute.path.split("/");
  var _name = _pathList.last;
  _pathList[_pathList.length - 1] = "tmp_$_name";
  return _pathList.join("/");
}

bool exists(String url, Directory targetDir) {
  File targetFile = _downloadFilePath(url, targetDir);
  return targetFile.existsSync();
}

File getLocalFile(String url, Directory targetDir) {
  var name = md5.convert(url.codeUnits).toString();
  var extName = url.split("\.").last;
  var path = targetDir.absolute.path + "/" + "$name.$extName";
  var targetFile = File(path);
  if (targetFile.existsSync()) {
    return targetFile;
  } else {
    return null;
  }
}

void removeTmpPath(String url, Directory targetDir) {
  try {
    var targetFile = _downloadFilePath(url, targetDir);
    targetFile.deleteSync();
  } catch (e) {} finally {}
}
