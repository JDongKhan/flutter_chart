import 'package:flutter/foundation.dart';

class TimeLineUtils {
  static final Map<String, TimeMode> _timeMap = {};
  static TimeLineUtils instance = TimeLineUtils._();
  TimeLineUtils._();

  void start(String tag) {
    if (kDebugMode) {
      TimeMode timeMode = TimeMode()..start(tag);
      _timeMap[tag] = timeMode;
    }
  }

  void next(String tag) {
    if (kDebugMode) {
      _timeMap[tag]?.next();
    }
  }

  void end(String tag) {
    if (kDebugMode) {
      _timeMap[tag]?.end();
    }
  }
}

class TimeMode {
  int _startTime = 0;
  int _nextTime = 0;
  String _tag = "";
  void start(String tag) {
    _tag = tag;
    _startTime = DateTime.now().millisecondsSinceEpoch;
    _nextTime = _startTime;
  }

  void next() {
    int next = DateTime.now().millisecondsSinceEpoch;
    debugPrint("[$_tag]耗时:${next - _nextTime}ms");
    _nextTime = next;
  }

  void end() {
    int end = DateTime.now().millisecondsSinceEpoch;
    debugPrint("[$_tag]耗时:${end - _nextTime}ms,总耗时:${end - _startTime}ms");
  }
}
