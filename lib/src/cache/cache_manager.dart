library net_image;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'download_manager.dart' as dm;

class ImageCacheManager {
  static ImageCacheManager _instance;

  ImageCacheManager._();

  factory ImageCacheManager() {
    if (_instance == null) {
      _instance = ImageCacheManager._();
    }
    return _instance;
  }

  Future init() async {
    imgDir = await _imgDir;
  }

  bool get isInit => imgDir != null;

  Future<Uint8List> getImageBytes(String url) async {
    var targetDir = imgDir;
    var file = await dm.requestImage(url, targetDir);
    if (file == null || file.lengthSync() == 0) {
      return null;
    }
    return Uint8List.fromList(file.readAsBytesSync());
  }

  bool isDownload(String url) {
    return dm.exists(url, imgDir);
  }

  Directory imgDir;

  Future<Directory> get _imgDir async {
    var dir = await getTemporaryDirectory();
    dir.createSync();
    var imgDir = Directory(dir.absolute.path + "/.tmp_img")..createSync();
    return imgDir;
  }

  File getLocalFile(String url) {
    return dm.getLocalFile(url, imgDir);
  }

  Uint8List getImageBytesSync(String url) {
    if (!isDownload(url)) {
      return null;
    }

    return Uint8List.fromList(getLocalFile(url).readAsBytesSync());
  }

  Future clearAllCache({Duration duration}) async {
    await init();
    if (duration != null) {
      var now = DateTime.now();
      for (var file in imgDir.listSync()) {
        var stat = file.statSync();
        var compareDateTime = now.subtract(duration);
        if (compareDateTime.isAfter(stat.accessed)) {
          file.deleteSync(recursive: true);
        }
      }
    } else {
      for (var file in imgDir.listSync()) {
        file.deleteSync(recursive: true);
      }
    }
  }

  /// remove file cache with url.
  ///
  /// If you load the specified URL at the same time, unexpected errors may occur
  Future removeCache(String url) async {
    await init();
    var file = getLocalFile(url);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }
}
