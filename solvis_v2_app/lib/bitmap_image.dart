import 'package:flutter/material.dart';
import 'dart:math' as Math;
import 'dart:ui' as ui show Image;

class ImageEditor extends CustomPainter {
  final Offset offset = const Offset(0.0, 0.0);
  final ui.Image image;
  bool _redraw = true;
  ImageEditor(this.image);
  double _scale = 1.0;

  double get scale => this._scale;
  int get width => this.image.width;
  int get height => this.image.height;

  @override
  void paint(Canvas canvas, Size size) {
    //var data = image.toByteData();
    // debugPrint('paint-> height: ${size.height} width: ${size.width}');
    if (size.width > 0) {
      final maxWidth = size.width / image.width;
      final maxHeight = size.height / image.height;
      _scale = Math.min(maxWidth, maxHeight);
      // debugPrint('scale: $_scale');
      canvas.scale(_scale, _scale);
    }
    canvas.drawImage(image, offset, Paint());
    _redraw = false;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return _redraw; // always repaint
  }
}