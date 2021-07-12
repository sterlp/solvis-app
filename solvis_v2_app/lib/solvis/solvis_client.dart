import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:http_auth/http_auth.dart';
import 'package:solvis_v2_app/settings/solvis_settings.dart';

import 'package:http_auth/http_auth.dart' as http_auth;

class SolvisClient extends ValueNotifier<String> {

  SolvisClient(this._client, String _server) : super(_server);
  SolvisClient.fromSettings(SolvisSettingsDao settings)
    : _client = http_auth.DigestAuthClient(settings.user, settings.password),
    super(settings.url);

  DigestAuthClient _client;

  void newCredentials(String user, String password) {
    _client = http_auth.DigestAuthClient(user, password);
    notifyListeners();
  }

  bool get hasUrl => value.isNotEmpty;
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
    return _client.get(Uri.parse('http://$value/Touch.CGI?x=$x&y=$y'));
  }

  Future<Response> click(int x, int y) async {
    await _client.get(Uri.parse('http://$value/Touch.CGI?x=$x&y=$y'));
    return confirm();
  }

  Future<Response> back() {
    return _client.get(Uri.parse('http://$value/Taster.CGI?taste=links&i=49019573'));
  }

  Future<Response> loadScreen() {
    final uri = Uri.parse('http://$value/display.bmp');
    debugPrint('loadScreen $uri ...');
    return _client.get(uri);
  }

  Future<Response> confirm({int delay = 500}) async {
    return _delay('http://$value/Touch.CGI?x=510&y=510', delay);
  }

  Future<Response> _delay(final String url, int timeInMs) {
    if (timeInMs > 0) {
      debugPrint('_delay ($timeInMs): $url');
      final result = Completer<Response>();
      Timer(Duration(milliseconds: timeInMs),
              () => result.complete(
              _client.get(Uri.parse(url)))
      );
      return result.future;
    } else {
      return _client.get(Uri.parse(url));
    }
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}