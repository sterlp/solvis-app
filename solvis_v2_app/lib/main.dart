import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:solvis_v2_app/app_config.dart';
import 'package:solvis_v2_app/homescreen/solvis_home_page.dart';

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
  final Future<AppContainer> _container;

  MyApp({Key? key, Future<AppContainer>? container}) :
        _container = container ?? buildContext(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<AppContainer>(
        future: _container,
        builder: (context, snapshot) {
          // load the first page or your page router
          if (snapshot.hasData) return SolvisHomePage(snapshot.requireData, title: title);
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
