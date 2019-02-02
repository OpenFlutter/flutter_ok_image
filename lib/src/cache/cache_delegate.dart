import 'dart:async';
import 'dart:typed_data';

typedef Future<Uint8List> DefaultFuture();

typedef Future<Uint8List> CacheDelegate(
    String url, DefaultFuture createDefaultFuture,
    {bool followRedirects});
