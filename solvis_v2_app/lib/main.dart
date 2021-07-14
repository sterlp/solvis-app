import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:solvis_v2_app/app_config.dart';
import 'package:solvis_v2_app/settings/server_settings_page.dart';
import 'package:solvis_v2_app/solvis/solvis_client.dart';
import 'package:solvis_v2_app/homescreen/solvis_widget.dart';

Future<void> main() async {
  await SentryFlutter.init(
        (options) {
      options.dsn = 'https://c6f8f92f1f3949edb4ee00ae3147be80@o918803.ingest.sentry.io/5862420';
    },
    appRunner: () => runApp(MyApp())
  );
}

const title = 'Solvis V2 Control';

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<AppContainer>(
        future: buildContext(),
        builder: (context, snapshot) {
          // load the first page or your page router
          if (snapshot.hasData) return MyHomePage(snapshot.requireData, title: title);
          else if (snapshot.hasError) {
            // error screen
            Sentry.captureException(snapshot.error, hint: 'main start');
            return Scaffold(
                appBar: AppBar(title: const Text(title)),
                body: Center(child: Text(snapshot.error.toString()))
            );
          } else {
            // Loading screen
            return Scaffold(
                appBar: AppBar(title: const Text(title)),
                body: const Center(child: CircularProgressIndicator())
            );
          }
        }
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage(this._container, {Key? key, required this.title}) : super(key: key);

  final String title;
  final AppContainer _container;

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
    widget._container.close();
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
    if (!widget._container.get<SolvisClient>().hasUrl) ServerSettingsPage.open(context, widget._container);

    return _buildMain(widget._container);
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


