library net_image;

import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'download_manager.dart' as dm hide print;

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
}
