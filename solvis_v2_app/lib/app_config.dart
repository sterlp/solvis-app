import 'package:dependency_container/dependency_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solvis_v2_app/settings/solvis_settings.dart';
import 'package:solvis_v2_app/solvis/solvis_client.dart';
import 'package:solvis_v2_app/solvis/solvis_client_v2.dart';
import 'package:solvis_v2_app/solvis/solvis_client_v3.dart';
import 'package:solvis_v2_app/solvis/solvis_service.dart';

/// Build the app config passing SharedPreferences
/// to be able to mock it later in the test.
Future<AppContainer> buildContext([Future<SharedPreferences>?  pref]) async {
  pref ??= SharedPreferences.getInstance();
  final f = await pref;
  final conf = SolvisSettingsDao(f);
  final result = AppContainer()
    .add(f)
    .add(conf);

  if (conf.isSolvisV2) {
    result.add<SolvisClient>(SolvisClientV2.fromSettings(conf));
  } else {
    result.add<SolvisClient>(SolvisClientV3.fromSettings(conf));
  }
  result.addFactory((c) => SolvisService(c.get<SolvisClient>()));

  return result;
}

void updateSolvisClientInContext(AppContainer container) {
  final conf = container.get<SolvisSettingsDao>();

  SolvisClient client;
  if (conf.isSolvisV2) {
    client = SolvisClientV2.fromSettings(conf);
  } else {
    client = SolvisClientV3.fromSettings(conf);
  }
  container.get<SolvisClient>().dispose();
  container.add<SolvisClient>(client);
  container.get<SolvisService>().solvisClient = client;
}
