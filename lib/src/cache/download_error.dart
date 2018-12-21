class DownloadError extends Error {
  String msg;
  Error originError;
  StackTrace stackTrace;

  DownloadError(this.msg, this.originError, [this.stackTrace]);
}
