import 'dart:async';
import 'dart:math';

import 'package:http/http.dart';
import 'package:solvis_v2_app/solvis/solvis_client.dart';

class SolvisClientV2 extends SolvisClient {

  final random = Random();

  SolvisClientV2.fromSettings(super.settings) : super.fromSettings();

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

  int _nextRandom() {
    return random.nextInt(99999999);
  }

  @override
  Future<Response> info() {
    return doGet('http://$server/Taster.CGI?taste=rechts&i=${_nextRandom()}');
  }
  @override
  Future<Response> back() {
    return doGet('http://$server/Taster.CGI?taste=links&i=${_nextRandom()}');
  }
  @override
  Future<Response> loadScreen() {
    return doGet('http://$server/display.bmp?${_nextRandom()}');
  }
  @override
  Future<Response> confirm({int delay = 500}) async {
    return doDelayed('http://$server/Touch.CGI?x=510&y=510', delay);
  }
}
