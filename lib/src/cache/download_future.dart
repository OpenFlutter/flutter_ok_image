import 'dart:async';

class DownloadFuture {
  String url;
  Completer completer;

  DownloadFuture(this.url, this.completer);
}
