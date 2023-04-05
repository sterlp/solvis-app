import 'dart:ui' as ui show Image;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solvis_v2_app/app_config.dart';
import 'package:solvis_v2_app/settings/solvis_settings.dart';
import 'package:solvis_v2_app/solvis/solvis_service.dart';
import 'package:solvis_v2_app/widget/loading_button.dart';

class ServerSettingsPage extends StatefulWidget {
  static Future<ui.Image?> open(BuildContext context, AppContainer container) {
    HapticFeedback.mediumImpact();
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ServerSettingsPage(container)),
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
    final settings = widget._container.get<SolvisSettingsDao>();
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
        /*
        SwitchListTile(
          title: Text(settings.isSolvisV2 ? 'Solvis V2' : 'Solvis V3'),
          value: settings.isSolvisV2,
          onChanged: (bool value) {
            setState(() => settings.isSolvisV2 = value);
          },
          secondary: const Icon(Icons.question_mark),
        ),
        */
        ListTile(
          title: CircularLoadingButton(
            label: const Text('Einstellungen testen'),
            onPressed: _testServerConnection,
          ),
        ),
        ListTile(
          title: CircularLoadingButton(
            label: const Text('Solvis SC2 "solvis/solvis" verwenden'),
            onPressed: () async {
              setState(() async {
                await settings.setIsSolvisV2(true);
                _userNameCtrl.text = "solvis";
                _userPasswordCtrl.text = "solvis";
              });
            },
          ),
        ),
        /*
        ListTile(
          title: CircularLoadingButton(
            label: const Text('Solvis SC3 "Solvis/RCSC3!" verwenden'),
            onPressed: () async {
              settings.isSolvisV2 = false;
              _userNameCtrl.text = "Solvis";
              _userPasswordCtrl.text = "RCSC3!";
              setState(() {});
              await _testServerConnection();
            },
          ),
        ),
        */
      ],
    );
  }

  Future<void> _testServerConnection() async {
    final settings = widget._container.get<SolvisSettingsDao>();


    await settings.setUrl(_serverUrlCtrl.text);
    await settings.setUser(_userNameCtrl.text);
    await settings.setPassword(_userPasswordCtrl.text);

    updateSolvisClientInContext(widget._container);

    final solvisService = widget._container.get<SolvisService>();
    final result = await solvisService.connect();

    if (mounted) {
      if (solvisService.errorStatus.value == null) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.topSlide,
          headerAnimationLoop: false,
          title: settings.isSolvisV2 ? 'Solvis V2 Erfolg' : 'Solvis V3 Erfolg',
          desc: 'Verbindung erfolgreich.',
          btnOkOnPress: () => Navigator.pop(context, result),
          btnOkIcon: Icons.check_circle,
          btnOkText: 'Schließen',
          btnOkColor: Colors.green,
        ).show();
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.topSlide,
          headerAnimationLoop: false,
          title: settings.isSolvisV2 ? 'Solvis V2 Fehler' : 'Solvis V3 Fehler',
          desc: solvisService.errorStatus.value.toString(),
          btnOkOnPress: () {},
          btnOkText: 'Einstellungen ändern',
          btnOkIcon: Icons.cancel,
          btnOkColor: Colors.red,
        ).show();
      }
    }
  }
}
