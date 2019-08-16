class DownloadError extends Error {
  String msg;
  Error originError;
  StackTrace stackTrace;
  String url;

  DownloadError(this.url, this.msg, this.originError, [this.stackTrace]);
}
