import 'package:flutter/material.dart';
import 'package:solvis_v2_app/help/manual_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawerWidget extends StatelessWidget {
  final Function()? openMenuFn;

  const AppDrawerWidget({Key? key, this.openMenuFn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      DrawerHeader(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Text(
          'Solvis V2 Remote',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontSize: 24,
          ),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.book),
        title: const Text('Solvis V2 Handbuch'),
        onTap: () => openManualPage(context),
      ),
      ListTile(
        leading: const Icon(Icons.bug_report_outlined),
        title: const Text('Problem melden'),
        onTap: () => launchUrl(Uri.parse('https://github.com/sterlp/solvis-app/issues')),
      ),
    ];
    if (openMenuFn != null) {
      items.add(
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Einstellungen'),
          onTap: openMenuFn,
        ),
      );
    }
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: items,
      ),
    );
  }
}
