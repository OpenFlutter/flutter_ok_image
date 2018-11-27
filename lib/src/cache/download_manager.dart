import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/io_client.dart' as io_client;
//import 'package:http/http.dart' as http;

Future<File> requestImage(String url, Directory targetDir) async {
  File targetFile = _downloadFilePath(url, targetDir);

  bool isDownloaded() {
    var tmpPath = _getTmpPath(targetFile);
    if (File(tmpPath).existsSync()) {
      return false;
    }
    return targetFile.existsSync();
  }

  if (isDownloaded()) {
    print("文件已下载,直接返回缓存");
    return targetFile;
  }

  io_client.IOClient client = io_client.IOClient(); //确定下载再创建client

  // 先创建一个临时文件,用于告知
  var tmpFile = File(_getTmpPath(targetFile))..createSync();

  try {
    var response = await client.get(url);
    if (response.statusCode == 200 && !response.isRedirect) {
      var bytes = response.bodyBytes;
      print("下载完成");
      // 成功,先写tmp文件中
      await targetFile.writeAsBytes(bytes);
      print("写入完成");
      // 写完后删除临时文件
      tmpFile.deleteSync();
      print("删除临时文件");
      return targetFile;
    } else {
      print("$url 不存在");
      return null;
    }
  } finally {
    client.close();
  }
}

File _downloadFilePath(String url, Directory targetDir) {
  var name = md5.convert(url.codeUnits).toString();
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
  return File(_getTmpPath(targetFile)).existsSync();
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

print(Object obj) {}
