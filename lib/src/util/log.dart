class Log {
  Log._();

  bool showLog = false;

  static void log(Object msg) {
    print(msg ?? "null");
  }
}
