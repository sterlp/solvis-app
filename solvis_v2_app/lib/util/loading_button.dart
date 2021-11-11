import 'package:flutter/material.dart';

typedef FutureCallback = Future<void> Function();

class CircularLoadingButton extends StatefulWidget {
  final Widget label;
  final Widget? icon;
  final FutureCallback? onPressed;

  const CircularLoadingButton({Key? key,
    required this.label, this.onPressed, this.icon,})
      : super(key: key);

  @override
  _CircularLoadingButtonState createState() => _CircularLoadingButtonState();
}

class _CircularLoadingButtonState extends State<CircularLoadingButton> {
  var _loading = false;
  @override
  Widget build(BuildContext context) {
    Widget result;
    if (_loading) {
      result = ElevatedButton.icon(onPressed: null,
        icon: Container(margin: const EdgeInsets.all(5), height: 24, width: 24, child: const CircularProgressIndicator()),
        label: widget.label,
      );
    } else {
      if (widget.icon == null) {
        result = ElevatedButton(
          onPressed: widget.onPressed == null ? null : _press,
          child: widget.label,
        );
      } else {
        result = ElevatedButton.icon(
          icon: widget.icon!,
          onPressed: widget.onPressed == null ? null : _press,
          label: widget.label,
        );
      }
    }
    return result;
  }

  Future<void> _press() async {
    Feedback.forTap(context);
    try {
      setState(() => _loading = true);
      await widget.onPressed!();
    } finally {
      setState(() => _loading = false);
    }
  }
}
