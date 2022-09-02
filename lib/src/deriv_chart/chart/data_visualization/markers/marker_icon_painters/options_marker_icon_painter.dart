import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

import 'marker_icon_painter.dart';

/// Icon painter for Options trade type
class OptionsMarkerIconPainter extends MarkerIconPainter {
  @override
  void paintMarker(Canvas canvas,
      Offset center,
      Offset anchor,
      MarkerDirection direction,
      MarkerStyle style,) {
    paintCircle(canvas, center, anchor, direction, style);

    final double dir = direction == MarkerDirection.up ? 1 : -1;

    final Path path = Path();

    canvas
      ..save()
      ..translate(
        center.dx - const Size(20, 20).width / 4,
        center.dy - (const Size(20, 20).height / 4) * dir,
      )

    // 16x16 is the original svg size.
      ..scale(
        const Size(20, 20).width / 16,
        const Size(20, 20).height / 16 * dir,
      );

    // This path was generated with http://demo.qunee.com/svg2canvas/.
    path
      ..moveTo(7, 0)
      ..lineTo(4.5, 0)..lineTo(4.5, 0.005)
      ..cubicTo(4.5, 0.554523, 4.94548, 1, 5.495, 1)
      ..lineTo(6.295, 1)..lineTo(2, 5.293)..lineTo(2, 6.707)..lineTo(
        7, 1.707)..lineTo(7, 2.507)
      ..cubicTo(7.0011, 3.05574, 7.44626, 3.5, 7.995, 3.5)
      ..lineTo(8, 3.5)..lineTo(8, 1)
      ..cubicTo(8, 0.447715, 7.55228, 0, 7, 0)
      ..close()
      ..moveTo(0.707, 8)
      ..lineTo(0, 8)..lineTo(0, 7)..lineTo(1, 7)..lineTo(1.707, 7)..lineTo(
        1, 7.707)..lineTo(0.707, 8)
      ..close();

    canvas
      ..drawPath(path, Paint()
        ..color = Colors.white)
      ..restore();
  }
}
