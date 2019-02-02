import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:ok_image/src/cache/cache_delegate.dart';
import 'package:ok_image/src/cache/cache_manager.dart';

Future<Uint8List> defaultCache(String url, DefaultFuture createDefaultFuture,
    {bool followRedirects}) async {
  var icm = ImageCacheManager();
  await icm.init();
  return icm.getImageBytes(url);
}

Uint8List getImageBytes(String url) {
  var icm = ImageCacheManager();
  if (!icm.isInit) return null;

  return icm.getImageBytesSync(url);
}

bool isDownloaded(String url) =>
    ImageCacheManager().isInit && ImageCacheManager().isDownload(url);

File getCacheImageFile(String url) {
  if (!isDownloaded(url)) {
    return null;
  }
  return ImageCacheManager().getLocalFile(url);
}
