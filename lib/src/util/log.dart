import 'package:flutter/foundation.dart';

class Log {
  Log._();

  static bool showLog = false;

  static void log(Object msg) {
    if (showLog == true) debugPrint(msg ?? "null", wrapWidth: 900);
  }
}
