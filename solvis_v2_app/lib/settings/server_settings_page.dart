import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solvis_v2_app/settings/solvis_settings.dart';
import 'package:solvis_v2_app/solvis/solvis_client.dart';
import 'package:solvis_v2_app/solvis/solvis_service.dart';
import 'package:solvis_v2_app/widget/loading_button.dart';

class ServerSettingsPage extends StatefulWidget {
  static Future<void> open(BuildContext context, AppContainer _container) {
    HapticFeedback.mediumImpact();
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ServerSettingsPage(_container)),
    );
  }

  final AppContainer _container;
  const ServerSettingsPage(this._container, {Key? key}) : super(key: key);

  @override
  _ServerSettingsPageState createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends State<ServerSettingsPage> {
  final _userNameCtrl = TextEditingController();
  final _userPasswordCtrl = TextEditingController();
  final _serverUrlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initEditController(widget._container.get<SolvisSettingsDao>());
  }
  void _initEditController(SolvisSettingsDao settings) {
    _userNameCtrl.text = settings.user;
    _userPasswordCtrl.text = settings.password;
    if (settings.url.isEmpty) _serverUrlCtrl.text = 'solvisremote-19c555';
    else _serverUrlCtrl.text = settings.url;
  }

  @override
  void dispose() {
    _userNameCtrl.dispose();
    _serverUrlCtrl.dispose();
    _userPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Solvis V2 Einstellungen"),
      ),
      body: _buildSettingsView(),
    );
  }

  ListView _buildSettingsView() {
    return ListView(
      children: [
        ListTile(
          title: TextField(controller: _userNameCtrl,),
          subtitle: const Text('Benutzername'),
        ),
        ListTile(
          title: TextField(
            controller: _userPasswordCtrl,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
          ),
          subtitle: const Text('Passwort'),
        ),
        ListTile(
          title: TextField(controller: _serverUrlCtrl,),
          subtitle: const Text('Server Adresse z.B. 192.168.178.35'),
        ),
        ListTile(
          title: CircularLoadingButton(
            label: const Text('Einstellungen testen'),
            onPressed: _testServerConnection,
          ),
        ),
      ],
    );
  }

  Future<void> _testServerConnection() async {
    final settings = widget._container.get<SolvisSettingsDao>();
    final _solvisClient = widget._container.get<SolvisClient>();
    final _solvisService = widget._container.get<SolvisService>();

    settings.url = _serverUrlCtrl.text;
    settings.password = _userPasswordCtrl.text;
    settings.user = _userNameCtrl.text;

    try {
      _solvisClient.server = _serverUrlCtrl.text;
      _solvisClient.newCredentials(_userNameCtrl.text, _userPasswordCtrl.text);

      await _solvisService.connect();
      _solvisService.autoRefreshScreen();

      AwesomeDialog(
        context: context,
        dialogType: DialogType.SUCCES,
        animType: AnimType.RIGHSLIDE,
        headerAnimationLoop: false,
        title: 'Erfolg',
        desc: 'Verbindung erfolgreich.',
        btnOkOnPress: () => Navigator.pop(context),
        btnOkIcon: Icons.check_circle,
        btnOkText: 'Schließen',
        btnOkColor: Colors.green,
      ).show();
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.RIGHSLIDE,
        headerAnimationLoop: false,
        title: 'Verbindungsfehler',
        desc: e.toString(),
        btnOkOnPress: () {},
        btnOkText: 'Einstellungen ändern',
        btnOkIcon: Icons.cancel,
        btnOkColor: Colors.red,
      ).show();
    }
  }
}
