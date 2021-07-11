import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solvis_v2_app/homescreen/bitmap_image.dart';
import 'package:solvis_v2_app/settings/server_settings_page.dart';
import 'package:solvis_v2_app/solvis/solvis_client.dart';
import 'package:solvis_v2_app/util/event_counter.dart';

class SolvisWidget extends StatefulWidget {
  final SolvisClient _solvisClient;

  const SolvisWidget(this._solvisClient, {Key? key}) : super(key: key);

  @override
  _SolvisWidgetState createState() => _SolvisWidgetState();

}

class _SolvisWidgetState extends State<SolvisWidget> with WidgetsBindingObserver {
  static const maxWidth = 480;
  static const maxHeight = 256;
  // ensure 500ms between the touch and the confirm REST calls
  // static const tabDetectionDelayMs = 500;

  final _errorCounter = EventCounter(5);
  Timer? _refreshTimer;
  ImageEditor? _image;
  int _tapDownTime = DateTime.now().millisecondsSinceEpoch;

  @override
  Widget build(BuildContext context) {
    if (_errorCounter.isMaxReached) {
      cancelAutoRefresh();
      return Padding(padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Solvis Heizung nicht erreicht.', style: Theme.of(context).textTheme.headline6),
              Text(_errorCounter.event?.toString() ?? ''),
              ElevatedButton.icon(onPressed: refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Nochmal versuchen')),
              ElevatedButton.icon(onPressed: () => ServerSettingsPage.open(context, widget._solvisClient),
                icon: const Icon(Icons.settings),
                label: const Text('Einstellungen')),
            ]
          )
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
      return _buildSolvisScreen();
    }
  }

  GestureDetector _buildSolvisScreen() {
    return GestureDetector(
      onTapDown: (d) async {
        final p = _point(d.localPosition);
        _tapDownTime = DateTime.now().millisecondsSinceEpoch;
        if (p.x < maxWidth && p.y < maxHeight) {
          await widget._solvisClient.touch(p.x, p.y);
          _tapDownTime = DateTime.now().millisecondsSinceEpoch;
          HapticFeedback.lightImpact();
        }
      },
      onTapUp: (d) async {
        int delay = DateTime.now().millisecondsSinceEpoch - _tapDownTime;

        // ensure 500ms between the touch and the confirm
        if (delay < 500) delay = 500 - delay;
        else delay = 0;

        await widget._solvisClient.confirm(delay: delay);
        HapticFeedback.lightImpact();
        refresh();
      },
      child: SizedBox.expand(child: CustomPaint(painter: _image)),
      /*
      onTap: () async {
        if (_tabPosition != null && _image != null) {
          // 480 x 256
          debugPrint('tab scale: ${_image!.scale} x: ${_tabPosition!.dx} y: ${_tabPosition!.dy}');
          final x = (_tabPosition!.dx * 2 / _image!.scale).round();
          final y = (_tabPosition!.dy * 2 / _image!.scale).round();
          debugPrint('x: $x');
          debugPrint('y: $y');

          if (x < 480 && y < 256) {
            HapticFeedback.lightImpact();
            await widget._solvisClient.click(x, y);
            Timer(const Duration(milliseconds: 250), () async {
              await refresh();
              HapticFeedback.lightImpact();
            });
          }
        }
      },*/
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
      return const Point(480, 256); // out of screen
    }
  }

  @override
  void initState() {
    super.initState();
    // because Flutter is shit we have to play around with a state observer to
    // if we are currently really displayed or not
    WidgetsBinding.instance!.addObserver(this);
    widget._solvisClient.addListener(refresh);
    refresh();
    autoRefresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    cancelAutoRefresh();
    widget._solvisClient.removeListener(refresh);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _errorCounter.reset();
      autoRefresh();
    } else cancelAutoRefresh();
  }

  void autoRefresh() {
    cancelAutoRefresh();
    _refreshTimer = Timer(const Duration(milliseconds: 1500), refresh);
  }
  void cancelAutoRefresh() {
    if (_refreshTimer != null) {
      _refreshTimer?.cancel();
      _refreshTimer = null;
    }
  }

  Future<void> refresh() async {
    // debugPrint('refresh screen image ...');
    try {
      final r = await widget._solvisClient.loadScreen();
      if (r.statusCode < 299) {
        _errorCounter.reset();
        autoRefresh();
        return decodeImageFromList(r.bodyBytes).then((i) =>
            setState(() => _image = ImageEditor(i)));
      } else {
        if (r.statusCode == 401) {
          const problem = 'HTTP 401: Falscher Benutzername oder Password!';
          setState(() => _errorCounter.maxReached(problem));
        } else {
          throw '${r.statusCode}: ${r.body}';
        }
        return;
      }
    } catch (e) {
      if (_errorCounter.count(e).isMaxNotReached) {
        autoRefresh();
      }
      setState(() {});
    }
  }
}
