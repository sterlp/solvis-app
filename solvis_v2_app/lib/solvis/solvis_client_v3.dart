import 'package:http/http.dart';
import 'package:solvis_v2_app/settings/solvis_settings.dart';
import 'package:solvis_v2_app/solvis/solvis_client.dart';

class SolvisClientV3 extends SolvisClient {

  SolvisClientV3.fromSettings(SolvisSettingsDao settings) : super.fromSettings(settings);

  int _displaySuffix = 1;

  @override
  Future<Response> info() {
    return doGet('http://$server/Taster.CGI?taste=rechts');
  }
  @override
  Future<Response> back() {
    return doGet('http://$server/Taster.CGI?taste=links');
  }
  @override
  Future<Response> loadScreen() {
    _rotateDisplaySuffix();
    return doGet('http://$server/display$_displaySuffix.bmp');
  }

  void _rotateDisplaySuffix() {
    if (_displaySuffix == 0) _displaySuffix = 1;
    else _displaySuffix = 0;
  }
  @override
  Future<Response> confirm({int delay = 500}) async {
    return doDelayed('http://$server/Touch.CGI?x=1020&y=1020', delay);
  }
}
