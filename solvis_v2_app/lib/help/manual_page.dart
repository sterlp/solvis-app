import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';

const manualV2Name = "Solvis_Remote_Bedienanleitung_v2.pdf";
const manualV2Path = "assets/$manualV2Name";

Future<void> shareManualV2() async {
  final tempDir = await getTemporaryDirectory();
  final tmpV2 = File('${tempDir.path}/$manualV2Name');

  if (!tmpV2.existsSync() || tmpV2.lengthSync() < 1) {
    if (tmpV2.existsSync()) tmpV2.delete();
    tmpV2.create();
    final bytes = await rootBundle.load(manualV2Path);
    final list = bytes.buffer.asUint8List();
    tmpV2.writeAsBytesSync(list);
  }

  await Share.shareXFiles(
    [
      XFile(tmpV2.path, name: 'Solvis V2 Remote Bedienanleitung'),
    ],
  );
}

Future<void> openManualPage(BuildContext context) {
  HapticFeedback.mediumImpact();
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ManualPage()),
  );
}

class ManualPage extends StatefulWidget {
  const ManualPage({Key? key}) : super(key: key);

  @override
  State<ManualPage> createState() => _ManualPageState();
}

class _ManualPageState extends State<ManualPage> {
  final pdfPinchController = PdfControllerPinch(
    document: PdfDocument.openAsset(manualV2Path),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solvis V2 Handbuch'),
        actions: const [
           IconButton(onPressed: shareManualV2, icon: Icon(Icons.share)),
        ],
      ),
      // not supported on windows
      body: PdfViewPinch(
        controller: pdfPinchController,
      ),
    );
  }
}
