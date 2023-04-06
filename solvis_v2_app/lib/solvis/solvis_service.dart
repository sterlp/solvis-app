import 'dart:ui' as ui show Image;

import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:solvis_v2_app/solvis/solvis_client.dart';
import 'package:solvis_v2_app/util/retry_template.dart';

class SolvisService with Closeable {
  SolvisClient _client;
  final RetryTemplate<Response> _retryTemplate = RetryTemplate(3);
  final ErrorListenerTemplate _errorTemplate = ErrorListenerTemplate();

  SolvisService(this._client);

  set solvisClient(SolvisClient client) => _client = client;

  ValueNotifier<Exception?> get errorStatus => _errorTemplate.listener;

  Future<ui.Image?> connect() async {
    _errorTemplate.clearError();
    await _client.getServer();
    // debugPrint('head connect $r ${r.statusCode} ${r.headers['www-authenticate']}');
    return refreshScreen();
  }

  Future<ui.Image?> confirm({int delay = 500}) {
    return _errorTemplate.exec<ui.Image?>(() async {
      await _retryTemplate.exec(() => _client.confirm(delay: delay));
      return refreshScreen();
    });
  }

  Future<ui.Image?> touch(int x, int y) {
    return _errorTemplate.exec<ui.Image?>(() async {
      await _retryTemplate.exec(() => _client.touch(x, y));
      return refreshScreen();
    });
  }

  Future<ui.Image?> refreshScreen() async {
    final r = await _errorTemplate.exec(() async {
      // debugPrint('refreshScreen: $_autoRefreshScreen');
      final r = await _retryTemplate.exec(() => _client.loadScreen());
      _verifyResponse(r);
      return r;
    });
    ui.Image? result;
    if (r != null &&  r.statusCode <= 299) {
      result = await decodeImageFromList(r.bodyBytes);
      _errorTemplate.clearError();
    }
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
    _errorTemplate.dispose();
    await _client.close();
  }
}
