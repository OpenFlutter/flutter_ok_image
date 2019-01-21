class Log {
  Log._();

  static bool showLog = false;

  static void log(Object msg) {
    if (showLog == true) print(msg ?? "null");
  }
}
