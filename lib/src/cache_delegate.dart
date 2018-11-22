import 'dart:typed_data';

typedef Future<Uint8List> CacheDelegate(String url, {bool followRedirects});
