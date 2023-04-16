import 'dart:async';

import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http_auth/http_auth.dart';
import 'package:solvis_v2_app/settings/solvis_settings.dart';

abstract class SolvisClient with Closeable {

  static const timeout = Duration(seconds: 3);
  final BaseClient _client;
  final SolvisSettingsDao _settings;
  String server;

  SolvisClient.fromSettings(SolvisSettingsDao settings)
    : _client = DigestAuthClient(settings.user, settings.password),
    server = settings.url, _settings = settings;

  bool get hasUrl => server.isNotEmpty;

  Future<Response> getServer() async {
    debugPrint('Testing $server "${_settings.user}" "${_settings.password}"');
    return doGet('http://$server');
  }

  Future<Response> touch(int x, int y) async {
    return doGet('http://$server/Touch.CGI?x=$x&y=$y');
  }

  Future<Response> click(int x, int y) async {
    await doGet('http://$server/Touch.CGI?x=$x&y=$y');
    return confirm();
  }

  Future<Response> info();
  Future<Response> back();
  Future<Response> loadScreen();
  Future<Response> confirm({int delay = 500});

  Future<Response> doDelayed(String url, int timeInMs) {
    if (timeInMs > 0) {
      final result = Completer<Response>();
      Timer(Duration(milliseconds: timeInMs), () => result.complete(doGet(url)),);
      return result.future;
    } else {
      return doGet(url);
    }
  }

  Future<Response> doGet(String url) {
    assert(url.isNotEmpty && url.length > 8, 'GET url in solvis HTTP client is empty or to short: $url');
    Uri uri;
    uri = Uri.parse(url);
    if (kDebugMode) debugPrint('${DateTime.now()} _doGet $url');
    return _client.get(uri).timeout(timeout);
  }

  void dispose() {
    _client.close();
  }

  @override
  Future<void> close() async {
    dispose();
    return;
  }
}
