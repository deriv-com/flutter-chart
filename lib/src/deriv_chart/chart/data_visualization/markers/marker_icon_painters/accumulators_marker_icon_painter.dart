import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

import 'marker_icon_painter.dart';

/// Icon painter for Accumulators trade type
class AccumulatorsMarkerIconPainter extends MarkerIconPainter {
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
    ..moveTo(8.5,7.5)
    ..lineTo(0.5,7.5)
    ..lineTo(0.5,8.5)
    ..lineTo(8.5,8.5)
    ..lineTo(8.5,7.5)
    ..close()

    ..moveTo(8.5,0.5)
    ..lineTo(0.5,0.5)
    ..lineTo(0.5,1.5)
    ..lineTo(8.5,1.5)
    ..lineTo(8.5,0.5)
    ..close()

    ..moveTo(3.01,6.6501)
    ..lineTo(1.36,5.0001)
    ..lineTo(0.5,5.0001)
    ..lineTo(0.5,4.0001)
    ..lineTo(1.775,4.0001)
    ..lineTo(2.905,5.1301)
    ..lineTo(4.99,2.3501)
    ..lineTo(6.64,4.0001)
    ..lineTo(8.5,4.0001)
    ..lineTo(8.5,5.0001)
    ..lineTo(6.225,5.0001)
    ..lineTo(5.095,3.8701)
    ..lineTo(3.01,6.6501)
    ..close();

    canvas
      ..drawPath(path, Paint()..color = Colors.white)
      ..restore();
  }
}
