import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:solvis_v2_app/app_config.dart';
import 'package:solvis_v2_app/settings/server_settings_page.dart';
import 'package:solvis_v2_app/solvis/solvis_client.dart';
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

  MyHomePage({Key? key, required this.title,
      Future<AppContainer>? container}) :
        _container = container ?? buildContext(),
        super(key: key);

  final String title;
  final Future<AppContainer> _container;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    // because Flutter has no way to check by default if the app view is paused!
    // "if we are currently really displayed or not"
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    widget._container.then((value) => value.close());
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
    return FutureBuilder<AppContainer>(
      future: widget._container,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (!snapshot.requireData.get<SolvisClient>().hasUrl) {
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

  Widget _buildMain(AppContainer container) {
    final _solvisClient = container.get<SolvisClient>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => ServerSettingsPage.open(context, container),
          )
        ],
      ),
      body: SolvisWidget(container),
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


