import 'dart:async';
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:http_auth/http_auth.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:solvis_v2_app/settings/solvis_settings.dart';

class SolvisClient with Closeable {

  static const timeout = Duration(seconds: 2);
  String server;

  SolvisClient(this._client, this.server);
  SolvisClient.fromSettings(SolvisSettingsDao settings)
    : _client = DigestAuthClient(settings.user, settings.password),
    server = settings.url;

  DigestAuthClient _client;

  void newCredentials(String user, String password) {
    _client.close();
    _client = DigestAuthClient(user, password);
  }

  bool get hasUrl => server.isNotEmpty;
  /*
  void menuWater() async {
    await _client.get(Uri.parse('http://$_server/Touch.CGI?x=46&y=75'));
    await _confirm();
  }
  Future<Response> toggleHeater() async {
    await _client.get(Uri.parse('http://$_server/Touch.CGI?x=443&y=152'));
    await _client.get(Uri.parse('http://$_server/Touch.CGI?x=443&y=152'));
    return _confirm();
  }
  */

  Future<Response> touch(int x, int y) async {
    return _doGet('http://$server/Touch.CGI?x=$x&y=$y');
  }

  Future<Response> click(int x, int y) async {
    await _doGet('http://$server/Touch.CGI?x=$x&y=$y');
    return confirm();
  }

  Future<Response> info() {
    return _doGet('http://$server/Taster.CGI?taste=rechts&i=45507447');
  }
  Future<Response> back() {
    return _doGet('http://$server/Taster.CGI?taste=links&i=49019573');
  }

  Future<Response> loadScreen() {
    return _doGet('http://$server/display.bmp');
  }

  Future<Response> confirm({int delay = 500}) async {
    return _delay('http://$server/Touch.CGI?x=510&y=510', delay);
  }

  Future<Response> _delay(final String url, int timeInMs) {
    if (timeInMs > 0) {
      debugPrint('_delay ($timeInMs): $url');
      final result = Completer<Response>();
      Timer(Duration(milliseconds: timeInMs), () => result.complete(_doGet(url)),);
      return result.future;
    } else {
      return _client.get(Uri.parse(url));
    }
  }

  Future<Response> _doGet(String url) {
    assert(url.isNotEmpty && url.length > 8, 'GET url in solvis HTTP client is empty or to short: $url');
    Uri _uri;
    try {
      _uri = Uri.parse(url);
    } catch (e) {
      Sentry.captureException(e, hint: 'Parse URL');
      rethrow;
    }
    return _client.get(_uri).timeout(timeout);
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
