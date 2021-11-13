import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:solvis_v2_app/homescreen/solvis_widget.dart';
import 'package:solvis_v2_app/settings/server_settings_page.dart';
import 'package:solvis_v2_app/solvis/solvis_client.dart';
import 'package:solvis_v2_app/solvis/solvis_service.dart';
import 'package:solvis_v2_app/widget/loading_button.dart';

class SolvisHomePage extends StatefulWidget {

  const SolvisHomePage(this._container, {Key? key, required this.title}) : super(key: key);

  final String title;
  final AppContainer _container;

  @override
  _SolvisHomePageState createState() => _SolvisHomePageState();
}

class _SolvisHomePageState extends State<SolvisHomePage> {

  @override
  void initState() {
    super.initState();
    final client = widget._container.get<SolvisClient>();
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      if (!client.hasUrl) ServerSettingsPage.open(context, widget._container);
    });
  }

  @override
  void dispose() {
    widget._container.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final container = widget._container;
    final _solvisService = container.get<SolvisService>();
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
      floatingActionButton: _buildReturnFloatingButton(_solvisService),
    );
  }

  Widget? _buildReturnFloatingButton(SolvisService _solvisService) {
    return ValueListenableBuilder(
      valueListenable: _solvisService.errorStatus,
      builder: (context, value, child) {
        if (value == null) {
          return CircularLoadingButton(
            icon: const Icon(Icons.arrow_back_ios),
            label: const Text('Zurück'),
            onPressed: _solvisService.back,
          );
        } else {
          return Container();
        }
      },
    );
  }
}
