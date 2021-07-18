
import 'package:flutter/material.dart';

typedef FutureCallback = Future<void> Function();

class CircularLoadingButton extends StatefulWidget {
  final Widget label;
  final FutureCallback? onPressed;

  const CircularLoadingButton(this.label,
      {Key? key, this.onPressed}) : super(key: key);

  @override
  _CircularLoadingButtonState createState() => _CircularLoadingButtonState();
}

class _CircularLoadingButtonState extends State<CircularLoadingButton> {
  var _loading = false;
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const CircularProgressIndicator();
    } else {
      return FloatingActionButton.extended(
        onPressed: widget.onPressed == null ? null : _press,
        label: widget.label,
      );
    }
  }

  Future<void> _press() async {
    try {
      setState(() => _loading = true);
      _loading = true;
      await widget.onPressed!();
    } finally {
      setState(() => _loading = false);
    }
  }
}
