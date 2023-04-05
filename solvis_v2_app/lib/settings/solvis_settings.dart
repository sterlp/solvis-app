
import 'package:shared_preferences/shared_preferences.dart';

class SolvisSettingsDao {
  final SharedPreferences _preferences;
  SolvisSettingsDao(this._preferences);

  Future<void> setUser (String value) async => _preferences.setString('solvis_user', value);
  String get user => _preferences.getString('solvis_user') ?? '';

  Future<void> setPassword(String value) async => _preferences.setString('solvis_password', value);
  String get password => _preferences.getString('solvis_password') ?? '';

  Future<void> setUrl (String value) async => _preferences.setString('solvis_url', value);
  String get url => _preferences.getString('solvis_url') ?? '';

  bool get hasUrl => url.isNotEmpty;

  bool get isSolvisV2 => _preferences.getBool('solvis_v2') ?? true;
  Future<void> setIsSolvisV2 (bool value) async => _preferences.setBool('solvis_v2', value);
}
