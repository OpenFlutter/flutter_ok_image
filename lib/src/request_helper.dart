import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:rxdart/rxdart.dart';

var client = IOClient();

class RequestHelper {
  static Future<Uint8List> requestImage(
    String url,
    int retry,
    Duration duration, {
    bool followRedirects = false,
  }) async {
    Completer<Uint8List> completer = Completer();

    Observable.retry(
      () {
        return Stream.fromFuture(
          _requestImage(
            url,
            followRedirects: followRedirects,
          ),
        );
      },
      retry,
    ).timeout(
      duration,
      onTimeout: (sink) {
        _log("超时了");
        completer.completeError(TimeoutError());
        sink.close();
      },
    ).listen(
      (data) {
        _log("获取成功  图片大小 ${data.length}");
        completer.complete(data);
      },
      onError: (err) {
        _log("获取图片出错  $err");
        if (err is ImageCodeError) {
          completer.completeError(err);
        } else {
          completer.completeError(err);
        }
      },
      onDone: () {},
    );

    return completer.future;
  }

  static Future<Uint8List> _requestImage(
    String url, {
    ProgressHandler handler,
    bool followRedirects,
  }) async {
    var completer = Completer<Uint8List>();
    var baseRequest = http.Request("GET", Uri.parse(url));
    baseRequest.followRedirects = followRedirects;
    var streamResponse = await client.send(baseRequest);

    await Future.delayed(Duration(seconds: 2));

    if (streamResponse.statusCode != 200) {
      throw ImageCodeError(streamResponse.statusCode);
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
}

typedef ProgressHandler(double progress);

_log(Object msg) {
  print(msg ?? "null");
}
