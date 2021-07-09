import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solvis_v2_app/settings/server_settings_page.dart';
import 'package:solvis_v2_app/settings/solvis_settings.dart';
import 'package:solvis_v2_app/solvis_client.dart';
import 'package:solvis_v2_app/homescreen/solvis_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solvis V2 Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Solvis V2 Control'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {

  final Future<SolvisClient> _settings = SharedPreferences.getInstance()
      .then((value) => SolvisClient.fromSettings(SolvisSettings(value)));

  @override
  void initState() {
    super.initState();
    // because Flutter is shit we have to play around with a state observer to
    // if we are currently really displayed or not
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _settings.then((value) {
      value.dispose();
    });
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SolvisClient>(
      future: _settings,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (!snapshot.requireData.hasUrl) {
            ServerSettingsPage.open(context, snapshot.requireData);
          }
          return _buildMain(snapshot.requireData);
        } else {
          return Scaffold(
            appBar: AppBar(title: Text(widget.title)),
            body: const Center(child: CircularProgressIndicator())
          );
        }
      });
  }

  Widget _buildMain(SolvisClient _solvisClient) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => ServerSettingsPage.open(context, _solvisClient),
          )
        ],
      ),
      body: SolvisWidget(_solvisClient),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _solvisClient.back();
          HapticFeedback.heavyImpact();
        },
        label: const Text('Zurück'),
      ),
    );
  }
}


