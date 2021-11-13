import 'package:dependency_container/dependency_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solvis_v2_app/settings/solvis_settings.dart';
import 'package:solvis_v2_app/solvis/solvis_client.dart';
import 'package:solvis_v2_app/solvis/solvis_service.dart';

/// Build the app config passing SharedPreferences
/// to be able to mock it later in the test.
Future<AppContainer> buildContext([Future<SharedPreferences>?  pref]) async {
  pref ??= SharedPreferences.getInstance();
  final f = await pref;
  return AppContainer()
      .add(f)
      .add(SolvisSettingsDao(f))
      .addFactory((c) => SolvisClient.fromSettings(c.get<SolvisSettingsDao>()))
      .addFactory((c) => SolvisService(c.get<SolvisClient>()));
}