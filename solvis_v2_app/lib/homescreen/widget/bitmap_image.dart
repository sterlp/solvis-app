import 'dart:math' as math;
import 'dart:ui' as ui show Image;

import 'package:flutter/material.dart';

class ImageEditor extends CustomPainter {
  static final Paint drawPaint = Paint();
  final ui.Image image;
  bool _redraw = true;
  ImageEditor(this.image);
  double _scale = 1.0;

  double get scale => _scale;
  int get width => image.width;
  int get height => image.height;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width > 0) {
      final maxWidth = size.width / image.width;
      final maxHeight = size.height / image.height;
      _scale = math.min(maxWidth, maxHeight);
      // debugPrint('scale: $_scale');
      canvas.scale(_scale, _scale);
      canvas.drawImage(image, Offset.zero, drawPaint);
      _redraw = false;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return _redraw;
  }
}
