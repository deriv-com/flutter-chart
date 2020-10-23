import 'package:flutter/material.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'marker.dart';

/// Paints marker on the canvas.
void paintMarker(
  Canvas canvas,
  Offset center,
  Offset anchor,
  MarkerDirection direction,
  MarkerStyle style,
) {
  final Color color =
      direction == MarkerDirection.up ? style.upColor : style.downColor;
  final double dir = direction == MarkerDirection.up ? 1 : -1;

  canvas
    ..drawLine(
      anchor,
      center,
      Paint()
        ..color = color
        ..strokeWidth = 1.5,
    )
    ..drawCircle(
      anchor,
      3,
      Paint()..color = color,
    )
    ..drawCircle(
      anchor,
      1.5,
      Paint()..color = Colors.black,
    )
    ..drawCircle(
      center,
      style.radius,
      Paint()..color = color,
    )
    ..drawCircle(
      center,
      style.radius - 2,
      Paint()..color = Colors.black.withOpacity(0.32),
    );
  _drawArrow(canvas, center, const Size(10, 10), dir);
}

void _drawArrow(Canvas canvas, Offset center, Size size, double dir) {
  final Path path = Path();
  canvas
    ..save()
    ..translate(
      center.dx - size.width / 2,
      center.dy - (size.height / 2) * dir,
    )
    // 16x16 is the original svg size.
    ..scale(
      size.width / 16,
      size.height / 16 * dir,
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
