import 'dart:ui' as ui show Image;

import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:solvis_v2_app/homescreen/widget/bitmap_image.dart';
import 'package:solvis_v2_app/homescreen/widget/connection_error_widget.dart';
import 'package:solvis_v2_app/homescreen/widget/solvis_image_widget.dart';
import 'package:solvis_v2_app/settings/server_settings_page.dart';
import 'package:solvis_v2_app/settings/solvis_settings.dart';
import 'package:solvis_v2_app/solvis/solvis_service.dart';
import 'package:solvis_v2_app/util/timed_function.dart';
import 'package:solvis_v2_app/widget/app_drawer_widget.dart';
import 'package:solvis_v2_app/widget/loading_button.dart';
import 'package:solvis_v2_app/widget/loading_widget.dart';

class SolvisHomePage extends StatefulWidget {

  const SolvisHomePage(this._container, {super.key, required this.title});

  final String title;
  final AppContainer _container;

  @override
  _SolvisHomePageState createState() => _SolvisHomePageState();
}

class _SolvisHomePageState extends State<SolvisHomePage> with WidgetsBindingObserver {
  late final SolvisService solvisService;

  late final TimedFunction _autoRefresh;
  ImageEditor? screen;

  @override
  void initState() {
    super.initState();
    solvisService = widget._container.get<SolvisService>();
    _autoRefresh = TimedFunction(() async {
      if (mounted) {
        _updateSolvisScreen(await solvisService.refreshScreen());
        // debugPrint('${ModalRoute.of(context)?.isCurrent}');
        if (mounted && solvisService.errorStatus.value == null) _autoRefresh.queue();
      }
    });

    // because Flutter is shit we have to play around with a state observer to
    // see if we are currently really displayed or not
    WidgetsBinding.instance.addObserver(this);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!widget._container.get<SolvisSettingsDao>().hasUrl) _doOpenSettingsPage();
      else _refreshScreen();
    });
  }

  Future<void> _refreshScreen() async {
    _updateSolvisScreen(await solvisService.refreshScreen());
    _autoRefresh.resetDaly();
    if (mounted) _autoRefresh.queue();
    if (solvisService.errorStatus.value != null) setState(() {});
  }

  void _updateSolvisScreen(ui.Image? image) {
    if (image != null) {
      screen = ImageEditor(image);
      if (mounted) setState(() => screen = ImageEditor(image));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoRefresh.cancel();
    widget._container.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kDebugMode) debugPrint('$this new status $state');
    if (state == AppLifecycleState.resumed) {
      _autoRefresh.queue();
      setState(() {});
    } else _autoRefresh.cancel();
  }


  @override
  Widget build(BuildContext context) {
    final container = widget._container;
    final solvisService = container.get<SolvisService>();
    return Scaffold(
      drawer: AppDrawerWidget(openMenuFn: _doOpenSettingsPage),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _buildBody(),
      //floatingActionButton: _buildReturnFloatingButton(solvisService),
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder(
      valueListenable: solvisService.errorStatus,
      builder: (context, value, child) {
        if (value != null) {
          return _buildErrorScreen(solvisService.errorStatus.value!, solvisService);
        } else if (screen != null) {
          final widgets = [
            Expanded(child: _buildSolvisScreen(screen!, solvisService)),
            _buildReturnFloatingButton(solvisService),
          ];
          return  OrientationBuilder(
            builder: (context, orientation) {
              if (orientation == Orientation.portrait) {
                return Column(children: widgets,);
              } else {
              return Row(children: widgets,);
              }
            },);
        } else {
          return const LoadingWidget();
        }
      },);
  }

  // ensure 500ms between the touch and the confirm REST calls
  // static const tabDetectionDelayMs = 500;
  int? _tapDownTime;

  Widget _buildSolvisScreen(ImageEditor image, SolvisService solvisService) {

    return SolvisImageWidget(
      image: image,
      onTabDown: (p) async {
        _tapDownTime = DateTime.now().millisecondsSinceEpoch - 150;
        await solvisService.touch(p.x, p.y);
        HapticFeedback.mediumImpact();
        _tapDownTime = DateTime.now().millisecondsSinceEpoch;
      },
      onTabUp: () async {
        if (_tapDownTime != null) {
          // ensure 500ms between the touch and the confirm
          var delay = DateTime.now().millisecondsSinceEpoch - _tapDownTime!;
          if (delay < 500) delay = 500 - delay;
          else delay = 0;
          if (kDebugMode) debugPrint('Solvis screen finger up min delay $delay');

          HapticFeedback.mediumImpact();
          await solvisService.confirm(delay: delay);
          _refreshScreen();
          _tapDownTime = null;
        }
      },
    );
  }

  Widget _buildErrorScreen(Exception error, SolvisService solvisService) {
    return  ConnectionErrorWidget(
      error: error,
      retryFn: () {
        HapticFeedback.mediumImpact();
        _refreshScreen();
      },
      openSettingsFn: _doOpenSettingsPage,
    );
  }

  Future<void> _doOpenSettingsPage() async {
    _autoRefresh.cancel();
    _updateSolvisScreen(await ServerSettingsPage.open(context, widget._container));
    if (mounted) _autoRefresh.queue();
  }

  Widget _buildReturnFloatingButton(SolvisService solvisService) {
    return ValueListenableBuilder(
      valueListenable: solvisService.errorStatus,
      builder: (context, value, child) {
        if (value == null) {
          final widgets = [
            Expanded(child: Container()),
            CircularLoadingButton(
              icon: const Icon(Icons.arrow_back_ios),
              label: const Text('Zurück'),
              onPressed: () async {
                await solvisService.back();
                _refreshScreen();
              },
            ),
            Expanded(child: Container()),
            Expanded(child: Container()),
            Expanded(child: Container()),
            CircularLoadingButton(
              icon: const Icon(Icons.question_mark),
              label: const Text('Hilfe'),
              onPressed: () async {
                await solvisService.info();
                _refreshScreen();
              },
            ),
            Expanded(child: Container()),
          ];
          return OrientationBuilder(
            builder: (context, orientation) {
                if (orientation == Orientation.portrait) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: Row(children: widgets,),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                    child: Column(children: widgets,),
                  );
                }
              },
          );
        } else {
          return Container();
        }
      },
    );
  }
}
