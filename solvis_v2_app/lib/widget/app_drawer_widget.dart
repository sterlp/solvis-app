import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawerWidget extends StatelessWidget {
  final Function()? openMenuFn;

  const AppDrawerWidget({Key? key, this.openMenuFn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        child: Text(
          'Solvis V2 Remote',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.book),
        title: const Text('Solvis V2 Handbuch'),
        onTap: () async {

          final tempDir = await getTemporaryDirectory();
          final tmpV2 = File('${tempDir.path}/Solvis_Remote_Bedienanleitung_v2.pdf');
          if (!(await tmpV2.exists())){
            tmpV2.create();
            final bytes = await rootBundle.load("assets/Solvis_Remote_Bedienanleitung_v2.pdf");
            final list = bytes.buffer.asUint8List();
            tmpV2.writeAsBytesSync(list);
          }

          await Share.shareXFiles(
              [XFile(tmpV2.path,
                  mimeType: 'application/pdf',
                  name: 'Solvis V2 Remote Bedienanleitung'),
              ],);

          tmpV2.delete();

        },
      ),
      ListTile(
        leading: const Icon(Icons.bug_report_outlined),
        title: const Text('Problem melden'),
        onTap: () {
          launchUrl(Uri.parse('https://github.com/sterlp/solvis-app/issues'));
        },
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
