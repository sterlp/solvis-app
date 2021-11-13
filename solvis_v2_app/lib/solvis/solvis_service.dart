import 'dart:ui' as ui show Image;
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:solvis_v2_app/solvis/solvis_client.dart';
import 'package:solvis_v2_app/util/retry_template.dart';
import 'package:solvis_v2_app/util/timed_function.dart';

class SolvisService with Closeable {
  final SolvisClient _client;
  bool _autoRefreshScreen = false;
  TimedFunction _timer = TimedFunction(() {});
  final RetryTemplate<Response> _retryTemplate = RetryTemplate(3);
  final ErrorListenerTemplate _errorTemplate = ErrorListenerTemplate();
  final ValueNotifier<ui.Image?> screen = ValueNotifier(null);

  SolvisService(this._client) {
    _timer = TimedFunction(refreshScreen);
    _errorTemplate.listener.addListener(() {
      if (_errorTemplate.listener.value != null) _autoRefreshScreen = false;
    });
  }

  ValueNotifier<Exception?> get errorStatus => _errorTemplate.listener;

  bool autoRefreshScreen() {
    if (_client.hasUrl) {
      _autoRefreshScreen = true;
      _timer.queue();
      debugPrint('autoRefreshScreen enabled.');
      return true;
    }
    return false;
  }
  void stopAutoRefresh() {
    _autoRefreshScreen = false;
    _timer.cancel();
  }

  Future<void> connect() {
    return refreshScreen();
  }

  Future<ui.Image> confirm({int delay = 500}) {
    return _errorTemplate.exec(() async {
      await _retryTemplate.exec(() => _client.confirm(delay: delay));
      _timer.resetDaly();
      return refreshScreen();
    });
  }

  Future<ui.Image> touch(int x, int y) {
    return _errorTemplate.exec(() async {
      await _retryTemplate.exec(() => _client.touch(x, y));
      return refreshScreen();
    });
  }

  Future<ui.Image> refreshScreen() async {
    _timer.cancel();
    final r = await _errorTemplate.exec(() async {
      // debugPrint('refreshScreen: $_autoRefreshScreen');
      final r = await _retryTemplate.exec(() => _client.loadScreen());
      _verifyResponse(r);
      if (_autoRefreshScreen) _timer.queue();
      return r;
    });
    final result = await decodeImageFromList(r.bodyBytes);
    screen.value = result;
    return result;
  }

  Future<void> back() {
    return _errorTemplate.exec(() async {
      final r = await _retryTemplate.exec(() => _client.back());
      _verifyResponse(r);
    });
  }

  void _verifyResponse(Response r) {
    if (r.statusCode == 401) throw Exception('Falscher Benutzername oder Passwort.');
    else if (r.statusCode > 299) throw Exception('${r.statusCode} Verbindung fehlgeschlagen. ${r.body}');
  }

  void dispose() {
    close();
  }

  @override
  Future<void> close() async {
    screen.dispose();
    _errorTemplate.dispose();
    await _client.close();
  }
}
