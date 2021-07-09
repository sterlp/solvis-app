
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WrongServerSettingsDialog {

  static Future<void> show(BuildContext context, String text) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Solvis Server Einstellungen'),
          content: Text(text),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Okay'),
            ),
          ],
        );
      },
    );
  }
}