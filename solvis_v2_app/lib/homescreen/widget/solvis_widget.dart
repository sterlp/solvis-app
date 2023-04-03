import 'dart:math';
import 'dart:ui' as ui show Image;

import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solvis_v2_app/homescreen/widget/bitmap_image.dart';
import 'package:solvis_v2_app/settings/server_settings_page.dart';
import 'package:solvis_v2_app/solvis/solvis_service.dart';

class SolvisWidget extends StatefulWidget {
  final AppContainer _container;

  const SolvisWidget(this._container, {Key? key}) : super(key: key);

  @override
  _SolvisWidgetState createState() => _SolvisWidgetState();

}

class _SolvisWidgetState extends State<SolvisWidget> with WidgetsBindingObserver {
  // max for v2
  static const maxWidth = 480;
  static const maxHeight = 256;
  // ensure 500ms between the touch and the confirm REST calls
  // static const tabDetectionDelayMs = 500;

  int? _tapDownTime;

  Widget _buildErrorScreen(Exception error, SolvisService solvisService) {
    return Padding(padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Solvis Heizung nicht erreicht.', style: Theme.of(context).textTheme.headline6),
          Text(error.toString()),
          ElevatedButton.icon(
            onPressed: () {
              solvisService.autoRefreshScreen();
              solvisService.refreshScreen();
              HapticFeedback.mediumImpact();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Nochmal versuchen'),),
          ElevatedButton.icon(onPressed: () async {
            widget._container.get<SolvisService>().stopAutoRefresh();
            await ServerSettingsPage.open(context, widget._container);
            widget._container.get<SolvisService>().autoRefreshScreen();
            setState(() {});
          },
            icon: const Icon(Icons.settings),
            label: const Text('Einstellungen'),),
        ],
      ),
    );
  }

  Widget _loadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          Text('Laden ...', style: Theme.of(context).textTheme.headline6)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final solvisService = widget._container.get<SolvisService>();

    return AnimatedBuilder(
      animation: Listenable.merge([solvisService.screen, solvisService.errorStatus]),
      builder: (context, child) {
        if (solvisService.errorStatus.value == null) {
          if (solvisService.screen.value == null) return _loadingScreen();

          final image = ImageEditor(solvisService.screen.value!);
          return _buildSolvisScreen(image, solvisService);
        } else {
          return _buildErrorScreen(solvisService.errorStatus.value!, solvisService);
        }
      },
    );

    return ValueListenableBuilder<Exception?>(
      valueListenable: solvisService.errorStatus,
      builder: (context, value, child) {
        if (value == null) {
          return ValueListenableBuilder<ui.Image?>(
            valueListenable: solvisService.screen,
            builder: (context, value, child) {
              if (value == null) return _loadingScreen();
              final image = ImageEditor(value);
              return _buildSolvisScreen(image, solvisService);
            },
          );
        } else {
          return _buildErrorScreen(value, solvisService);
        }
      },
    );
  }

  GestureDetector _buildSolvisScreen(ImageEditor image, SolvisService solvisService) {
    return GestureDetector(
      onTapDown: (d) async {
        final p = _point(d.localPosition, image);
        _tapDownTime = null; // default off screen
        if (p.x < maxWidth && p.y < maxHeight) {
          _tapDownTime = DateTime.now().millisecondsSinceEpoch;

          await solvisService.touch(p.x, p.y);
          _tapDownTime = DateTime.now().millisecondsSinceEpoch;
          if (mounted) HapticFeedback.mediumImpact();
        }
      },
      onTapUp: (d) async {
        if (_tapDownTime != null) {
          int delay = DateTime.now().millisecondsSinceEpoch - _tapDownTime!;

          // ensure 500ms between the touch and the confirm
          if (delay < 500) delay = 500 - delay;
          else delay = 0;

          HapticFeedback.mediumImpact();
          await solvisService.confirm(delay: delay);
          if (mounted) solvisService.autoRefreshScreen();
        }
      },
      child: SizedBox.expand(child: CustomPaint(painter: image)),
    );
  }

  Point<int> _point(Offset tabPosition, ImageEditor image) {
    // 480 x 256
    final x = (tabPosition.dx * 2 / image.scale).round();
    final y = (tabPosition.dy * 2 / image.scale).round();
    return Point(x, y);
  }

  @override
  void initState() {
    super.initState();
    // because Flutter is shit we have to play around with a state observer to
    // see if we are currently really displayed or not
    WidgetsBinding.instance.addObserver(this);
    widget._container.get<SolvisService>().autoRefreshScreen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget._container.get<SolvisService>().stopAutoRefresh();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kDebugMode) debugPrint('new status $state');
    if (state == AppLifecycleState.resumed) {
      widget._container.get<SolvisService>().autoRefreshScreen();
    } else widget._container.get<SolvisService>().stopAutoRefresh();

    setState(() {});
  }
}
