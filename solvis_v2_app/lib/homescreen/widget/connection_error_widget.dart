import 'package:flutter/material.dart';

class ConnectionErrorWidget extends StatelessWidget {
  final Exception error;
  final Function() retryFn;
  final Function() openSettingsFn;

  const ConnectionErrorWidget({super.key,
    required this.error,
    required this.retryFn,
    required this.openSettingsFn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text('Solvis Heizung nicht erreicht.', style: Theme.of(context).textTheme.titleLarge),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(error.toString(), style: Theme.of(context).textTheme.titleSmall),
            ),
            ListTile(
              title: OutlinedButton.icon(
                onPressed: retryFn,
                icon: const Icon(Icons.refresh),
                label: const Text('Nochmal versuchen'),),
            ),
            ListTile(
              title: OutlinedButton.icon(
                onPressed: openSettingsFn,
                icon: const Icon(Icons.settings),
                label: const Text('Einstellungen'),),
            ),
          ],
        ),
      ),
    );
  }
}
