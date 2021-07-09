import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solvis_v2_app/settings/solvis_settings.dart';
import 'package:solvis_v2_app/solvis_client.dart';

class ServerSettingsPage extends StatefulWidget {
  static Future<void> open(BuildContext context, SolvisClient _solvisClient) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ServerSettingsPage(_solvisClient)),
    );
  }

  final SolvisClient _solvisClient;
  const ServerSettingsPage(this._solvisClient, {Key? key}) : super(key: key);

  @override
  _ServerSettingsPageState createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends State<ServerSettingsPage> {
  final _userNameCtrl = TextEditingController();
  final _userPasswordCtrl = TextEditingController();
  final _serverUrlCtrl = TextEditingController();
  final Future<SolvisSettings> _settings = SharedPreferences.getInstance()
      .then((value) => SolvisSettings(value));

  void _initEditController(SolvisSettings settings) {
    _userNameCtrl.text = settings.user;
    _userPasswordCtrl.text = settings.password;
    _serverUrlCtrl.text = settings.url;
  }

  @override
  void initState() {
    super.initState();
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
      body: FutureBuilder<SolvisSettings>(
        future: _settings,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildSettingsView(snapshot.requireData);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        })
    );
  }

  ListView _buildSettingsView(SolvisSettings settings) {
    _initEditController(settings);
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
          title: ElevatedButton(
              onPressed: () => _testServerConnection(settings),
              child: const Text('Einstellungen testen')),
        )
      ],
    );
  }

  void _testServerConnection(SolvisSettings settings) async {
    settings.url = _serverUrlCtrl.text;
    settings.password = _userPasswordCtrl.text;
    settings.user = _userNameCtrl.text;

    try {
      widget._solvisClient.value = _serverUrlCtrl.text;
      widget._solvisClient.newCredentials(_userNameCtrl.text, _userPasswordCtrl.text);

      final r = await widget._solvisClient.loadScreen();
      if (r.statusCode == 401) throw 'Falscher Benutzername oder Passwort.';
      else if (r.statusCode > 299) throw Exception('${r.statusCode} Verbindung fehlgeschlagen. ${r.body}');

      AwesomeDialog(
          context: context,
          dialogType: DialogType.SUCCES,
          animType: AnimType.RIGHSLIDE,
          headerAnimationLoop: false,
          title: 'Erfolg',
          desc: 'Verbindung war erfolgreich.',
          btnOkOnPress: () => Navigator.pop(context),
          btnOkIcon: Icons.check_circle,
          btnOkText: 'Schließen',
          btnOkColor: Colors.green)
          .show();
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
          btnOkColor: Colors.red)
      .show();
    }
  }
}
