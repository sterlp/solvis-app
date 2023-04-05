import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solvis_v2_app/homescreen/widget/bitmap_image.dart';

@immutable
class SolvisImageWidget extends StatelessWidget {
  static const maxV2ImageSize = Size(480, 256);

  final ImageEditor image;
  final Function(Point<int> fingerPosition) onTabDown;
  final Function() onTabUp;

  const SolvisImageWidget({
    Key? key,
    required this.image,
    required this.onTabDown,
    required this.onTabUp,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTapDown: (d) async {
        final p = _point(d.localPosition, image);
        if (p.x < maxV2ImageSize.width && p.y < maxV2ImageSize.height) {
          onTabDown(p);
        }
      },
      onTapUp: (d) => onTabUp(),
      child: SizedBox.expand(child: CustomPaint(painter: image)),
    );
  }

  Point<int> _point(Offset tabPosition, ImageEditor image) {
    // 480 x 256
    final x = (tabPosition.dx * 2 / image.scale).round();
    final y = (tabPosition.dy * 2 / image.scale).round();
    return Point(x, y);
  }
}
