import 'dart:async';

import 'package:http/http.dart';
import 'package:solvis_v2_app/settings/solvis_settings.dart';
import 'package:solvis_v2_app/solvis/solvis_client.dart';

class SolvisClientV2 extends SolvisClient {

  SolvisClientV2.fromSettings(SolvisSettingsDao settings) : super.fromSettings(settings);

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

  @override
  Future<Response> info() {
    return doGet('http://$server/Taster.CGI?taste=rechts&i=45507447');
  }
  @override
  Future<Response> back() {
    return doGet('http://$server/Taster.CGI?taste=links&i=49019573');
  }
  @override
  Future<Response> loadScreen() {
    return doGet('http://$server/display.bmp');
  }
  @override
  Future<Response> confirm({int delay = 500}) async {
    return doDelayed('http://$server/Touch.CGI?x=510&y=510', delay);
  }
}
