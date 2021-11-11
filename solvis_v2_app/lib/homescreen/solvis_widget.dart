import 'dart:async';
import 'dart:math';
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solvis_v2_app/homescreen/bitmap_image.dart';
import 'package:solvis_v2_app/settings/server_settings_page.dart';
import 'package:solvis_v2_app/solvis/solvis_client.dart';
import 'package:solvis_v2_app/util/event_counter.dart';
import 'package:solvis_v2_app/util/timed_function.dart';

class SolvisWidget extends StatefulWidget {
  final AppContainer _container;

  const SolvisWidget(this._container, {Key? key}) : super(key: key);

  @override
  _SolvisWidgetState createState() => _SolvisWidgetState();

}

class _SolvisWidgetState extends State<SolvisWidget> with WidgetsBindingObserver {
  static const maxWidth = 480;
  static const maxHeight = 256;
  // ensure 500ms between the touch and the confirm REST calls
  // static const tabDetectionDelayMs = 500;

  final _errorCounter = EventCounter(5);
  TimedFunction _timer = TimedFunction(() {});
  ImageEditor? _image;
  int? _tapDownTime;

  @override
  Widget build(BuildContext context) {
    final solvisClient = widget._container.get<SolvisClient>();
    if (_errorCounter.isMaxReached) {
      _timer.cancel();

      return Padding(padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Solvis Heizung nicht erreicht.', style: Theme.of(context).textTheme.headline6),
              Text(_errorCounter.event?.toString() ?? ''),
              ElevatedButton.icon(onPressed: Feedback.wrapForTap(refresh, context),
                icon: const Icon(Icons.refresh),
                label: const Text('Nochmal versuchen'),),
              ElevatedButton.icon(onPressed: () => ServerSettingsPage.open(context, widget._container),
                icon: const Icon(Icons.settings),
                label: const Text('Einstellungen'),),
            ],
          ),
        );
    } else if (_image == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            Text('Laden, ${_errorCounter.eventCount + 1} Versuch ...', style: Theme.of(context).textTheme.headline6)
          ],
        ),
      );
    } else {
      return _buildSolvisScreen(solvisClient);
    }
  }

  GestureDetector _buildSolvisScreen(SolvisClient solvisClient) {
    return GestureDetector(
      onTapDown: (d) async {
        final p = _point(d.localPosition);
        _tapDownTime = null; // default off screen
        if (p.x < maxWidth && p.y < maxHeight) {
          _tapDownTime = DateTime.now().millisecondsSinceEpoch;
          HapticFeedback.mediumImpact();

          await solvisClient.touch(p.x, p.y);
          _tapDownTime = DateTime.now().millisecondsSinceEpoch;
        }
      },
      onTapUp: (d) async {
        if (_tapDownTime != null) {
          int delay = DateTime.now().millisecondsSinceEpoch - _tapDownTime!;

          // ensure 500ms between the touch and the confirm
          if (delay < 500) delay = 500 - delay;
          else delay = 0;

          HapticFeedback.mediumImpact();
          await solvisClient.confirm(delay: delay);
          if (mounted) {
            _timer.resetDaly();
            _timer.queue();
          }
        }
      },
      child: SizedBox.expand(child: CustomPaint(painter: _image)),
    );
  }

  Point<int> _point(Offset tabPosition) {
    if (_image != null) {
      // 480 x 256
      final x = (tabPosition.dx * 2 / _image!.scale).round();
      final y = (tabPosition.dy * 2 / _image!.scale).round();
      // debugPrint('x: $x');
      // debugPrint('y: $y');
      return Point(x, y);
    } else {
      return const Point(999, 999); // out of screen
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = _timer = TimedFunction(refresh);
    // because Flutter is shit we have to play around with a state observer to
    // if we are currently really displayed or not
    WidgetsBinding.instance!.addObserver(this);
    widget._container.get<SolvisClient>().addListener(refresh);
    refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _timer.cancel();
    widget._container.get<SolvisClient>().removeListener(refresh);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _errorCounter.reset();
      refresh();
    } else _timer.cancel();
  }

  Future<void> refresh() async {
    _timer.cancel();
    if (!mounted) return;

    final client  = widget._container.get<SolvisClient>();
    if (client.hasUrl) {
      if (kDebugMode) debugPrint('${DateTime.now()}: refresh screen image, error count: ${_errorCounter.eventCount} ...');
      try {
        final r = await widget._container.get<SolvisClient>().loadScreen();
        if (r.statusCode < 299) {
          _errorCounter.reset();
          _timer.queue();
          return decodeImageFromList(r.bodyBytes).then((i) {
            if (mounted) setState(() => _image = ImageEditor(i));
          });
        } else {
          if (r.statusCode == 401) {
            _errorCounter.maxReached('HTTP 401: Falscher Benutzername oder Password!');
          } else {
            throw '${r.statusCode}: ${r.body}';
          }
          return;
        }
      } catch (e) {
        if (_errorCounter.count(e).isMaxNotReached) {
          _timer.queue();
        }
      }
    } else {
      _errorCounter.maxReached('Kein URL für den Zugriff auf die Heizung konfiguriert!');
    }

    if (mounted) setState(() {});
  }
}
