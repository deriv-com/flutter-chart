import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

import 'marker_icon_painter.dart';

/// Icon painter for Multipliers trade type
class MultipliersMarkerIconPainter extends MarkerIconPainter {
  @override
  void paintMarker(
    Canvas canvas,
    Offset center,
    Offset anchor,
    MarkerDirection direction,
    MarkerStyle style,
  ) {
    paintCircle(canvas, center, anchor, direction, style);

    final double dir = direction == MarkerDirection.up ? 1 : -1;

    final Path path = Path();

    canvas
      ..save()
      ..translate(
        center.dx - const Size(10, 10).width / 2,
        center.dy - (const Size(10, 10).height / 2) * dir,
      )

      // 16x16 is the original svg size.
      ..scale(
        const Size(10, 10).width / 16,
        const Size(10, 10).height / 16 * dir,
      );

    // This path was generated with http://demo.qunee.com/svg2canvas/.
    path
      ..moveTo(9, 0)
      ..lineTo(14, 0)
      ..cubicTo(15.1046, 0, 16, 0.89543, 16, 2)
      ..lineTo(16, 7)
      ..cubicTo(14.8954, 7, 14, 6.10457, 14, 5)
      ..lineTo(14, 3.415)
      ..lineTo(1.5, 16)
      ..lineTo(0, 16)
      ..lineTo(0, 14.5)
      ..lineTo(12.6, 2)
      ..lineTo(11, 2)
      ..cubicTo(9.89543, 2, 9, 1.10457, 9, 0)
      ..close()
      ..moveTo(16, 14.5)
      ..lineTo(10.5, 9)
      ..lineTo(9, 10.5)
      ..lineTo(14.5, 16)
      ..lineTo(16, 16)
      ..lineTo(16, 14.5)
      ..close()
      ..moveTo(7, 5.5)
      ..lineTo(1.5, 0)
      ..lineTo(0, 0)
      ..lineTo(0, 1.5)
      ..lineTo(5.5, 7)
      ..lineTo(7, 5.5)
      ..close();

    canvas
      ..drawPath(path, Paint()..color = Colors.white)
      ..restore();
  }
}
