
import 'package:shared_preferences/shared_preferences.dart';

class SolvisSettingsDao {
  final SharedPreferences _preferences;
  SolvisSettingsDao(this._preferences);

  set user (String value) => _preferences.setString('solvis_user', value);
  String get user => _preferences.getString('solvis_user') ?? '';

  set password (String value) => _preferences.setString('solvis_password', value);
  String get password => _preferences.getString('solvis_password') ?? '';

  set url (String value) => _preferences.setString('solvis_url', value);
  String get url => _preferences.getString('solvis_url') ?? '';

  bool get hasUrl => url.isNotEmpty;

  bool get isSolvisV2 => _preferences.getBool('solvis_v2') ?? true;
  set isSolvisV2 (bool value) => _preferences.setBool('solvis_v2', value);
}
