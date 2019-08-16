import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ok_image/src/cache/cache_delegate.dart';
import 'package:ok_image/src/util/log.dart';
import 'package:rxdart/rxdart.dart';

class RequestHelper {
  static Future<Uint8List> requestImage(
    String url,
    int retry,
    Duration duration, {
    bool followRedirects = false,
    CacheDelegate cacheDelegate,
  }) async {
    Log.log("准备获取图片: $url");
    Completer<Uint8List> completer = Completer();

    Observable.retry(
      () {
        Log.log("$url 试一下");
        return _createStream(url, followRedirects, cacheDelegate);
      },
      retry,
    ).timeout(
      duration,
      onTimeout: (sink) {
        Log.log("超时了");
        completer.completeError(TimeoutError());
        sink.close();
      },
    ).listen(
      (data) {
        Log.log("获取成功  图片大小 ${data.length}");
        completer.complete(data);
      },
      onError: (err) {
        if (err is ImageCodeError) {
          Log.log("获取图片出错 $err");
          completer.completeError(err);
        } else if (err is RetryError) {
          Log.log("获取图片出错 重试$retry次后 \n ${err.errors.last}");
          completer.completeError(err.errors.last);
        } else {
          Log.log("获取图片出错 $err");
          completer.completeError(err);
        }
      },
      onDone: () {},
    );

    return completer.future;
  }

  static Stream<Uint8List> _createStream(
      String url, bool followRedirects, CacheDelegate cacheDelegate) {
    Future<Uint8List> future;

    Future<Uint8List> createDefault() {
      return _requestImage(
        url,
        followRedirects: followRedirects,
      );
    }

    if (cacheDelegate != null) {
      future = cacheDelegate(
        url,
        createDefault,
        followRedirects: followRedirects,
      );
    } else {
      future = createDefault();
    }

    return Stream.fromFuture(future);
  }

  static Future<Uint8List> _requestImage(
    String url, {
    ProgressHandler handler,
    bool followRedirects,
  }) async {
    Log.log("真实下载请求开始 $url");
    var completer = Completer<Uint8List>();
    var baseRequest = http.Request("GET", Uri.parse(url));
    baseRequest.followRedirects = followRedirects;
    var streamResponse = await baseRequest.send();

    await Future.delayed(Duration(seconds: 2));

    if (streamResponse.statusCode != 200) {
      Log.log("真实下载出错 $url, 响应码 ${streamResponse.statusCode}");
      completer.completeError(ImageCodeError(streamResponse.statusCode));
      return completer.future;
      // throw ImageCodeError(streamResponse.statusCode);
    }
    var maxLength = streamResponse.contentLength;
    List<int> content = [];
    streamResponse.stream.asBroadcastStream().listen((data) {
      content.addAll(data);
      var progress = content.length / maxLength;
      handler?.call(progress);
      if (progress == 1.0) {
        completer.complete(Uint8List.fromList(content));
      }
    });
    return completer.future;
  }
}

class TimeoutError extends Error {
  TimeoutError();
}

class ImageCodeError extends Error {
  int code;

  ImageCodeError(this.code);

  @override
  String toString() {
    return "ImageCodeError{ code : $code}";
  }
}

typedef ProgressHandler(double progress);