
import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

class TimedFunction {
  VoidCallback fn;
  Timer? _timer;
  int _time;
  final int _minRefreshTime;
  final int _maxRefreshTime;

  TimedFunction(this.fn, {int minRefreshTime = 1000, int maxRefreshTime = 1500})
      : _minRefreshTime = minRefreshTime, _time = minRefreshTime, _maxRefreshTime = maxRefreshTime;

  void queue() {
    cancel();
    // debugPrint('queue $_time');
    _timer ??= Timer(Duration(milliseconds: _time), _runFn);
    if (_time < _maxRefreshTime) _time += 100;
  }
  Future<void> _runFn() async {
    _timer = null;
    return fn();
  }
  void resetDaly() {
    _time = _minRefreshTime;
  }
  void cancel() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }
}
