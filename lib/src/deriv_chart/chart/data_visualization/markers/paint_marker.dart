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
  String productType,
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

  /// Icon size without circle
  Size size;

  ///Divider for width an height
  int divider;

  if (productType == 'multipliers') {
    size = Size(10, 10);
    divider = 2;
  } else if (productType == 'options') {
    size = Size(20, 20);
    divider = 4;
  } else {
    size = Size(20, 20);
    divider = 4;
  }

  _drawArrow(canvas, center, size, dir, divider, productType);
}

void _drawArrow(Canvas canvas, Offset center, Size size, double dir,
    int divider, String productType) {
  final Path path = Path();

  if (productType == 'multipliers') {
    canvas
      ..save()
      ..translate(
        center.dx - size.width / divider,
        center.dy - (size.height / divider) * dir,
      )
      // 16x16 is the original svg size.
      ..scale(
        size.width / 16,
        size.height / 16 * dir,
      );

    //This path was generated with http://demo.qunee.com/svg2canvas/.
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
  } else if (productType == 'options') {
    canvas
      ..save()
      ..translate(
        center.dx - size.width / divider,
        center.dy - (size.height / divider) * dir,
      )
      // 16x16 is the original svg size.
      ..scale(
        size.width / 16,
        size.height / 16 * dir,
      );
    //This path was generated with http://demo.qunee.com/svg2canvas/.
    path
      ..moveTo(7, 0)
      ..lineTo(4.5, 0)
      ..lineTo(4.5, 0.005)
      ..cubicTo(4.5, 0.554523, 4.94548, 1, 5.495, 1)
      ..lineTo(6.295, 1)
      ..lineTo(2, 5.293)
      ..lineTo(2, 6.707)
      ..lineTo(7, 1.707)
      ..lineTo(7, 2.507)
      ..cubicTo(7.0011, 3.05574, 7.44626, 3.5, 7.995, 3.5)
      ..lineTo(8, 3.5)
      ..lineTo(8, 1)
      ..cubicTo(8, 0.447715, 7.55228, 0, 7, 0)
      ..close()
      ..moveTo(0.707, 8)
      ..lineTo(0, 8)
      ..lineTo(0, 7)
      ..lineTo(1, 7)
      ..lineTo(1.707, 7)
      ..lineTo(1, 7.707)
      ..lineTo(0.707, 8)
      ..close();
  }
  canvas
    ..drawPath(path, Paint()..color = Colors.white)
    ..restore();
}
