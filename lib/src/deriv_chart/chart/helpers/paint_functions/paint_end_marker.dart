import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

/// Paints expiry/end tick marker
void paintEndMarker(
    Canvas canvas, ChartTheme theme, Offset center, MarkerStyle style) {
  canvas
    ..save()
    ..translate(
      center.dx,
      center.dy,
    )
    ..scale(1);

  final Paint paint = Paint()
    ..style = PaintingStyle.fill
    ..color = theme.base08Color.withOpacity(1);

  // This path was generated with http://demo.qunee.com/svg2canvas/.
  final Path path = Path()
    ..moveTo(2, 2)
    ..lineTo(18, 2)
    ..lineTo(18, 12)
    ..lineTo(2, 12)
    ..close();

  final Path flagPath = Path()
    ..moveTo(2, 0)
    ..lineTo(2, 1)
    ..lineTo(19, 1)
    ..lineTo(19, 12)
    ..lineTo(2, 12)
    ..lineTo(2, 20)
    ..lineTo(1, 20)
    ..lineTo(1, 0)
    ..lineTo(2, 0)
    ..close()
    ..moveTo(18, 8)
    ..lineTo(15, 8)
    ..lineTo(15, 11)
    ..lineTo(18, 11)
    ..lineTo(18, 8)
    ..close()
    ..moveTo(12, 8)
    ..lineTo(9, 8)
    ..lineTo(9, 11)
    ..lineTo(12, 11)
    ..lineTo(12, 8)
    ..close()
    ..moveTo(6, 8)
    ..lineTo(3, 8)
    ..lineTo(3, 11)
    ..lineTo(6, 11)
    ..lineTo(6, 8)
    ..close()
    ..moveTo(15, 5)
    ..lineTo(12, 5)
    ..lineTo(12, 8)
    ..lineTo(15, 8)
    ..lineTo(15, 5)
    ..close()
    ..moveTo(9, 5)
    ..lineTo(6, 5)
    ..lineTo(6, 8)
    ..lineTo(9, 8)
    ..lineTo(9, 5)
    ..close()
    ..moveTo(6, 2)
    ..lineTo(3, 2)
    ..lineTo(3, 5)
    ..lineTo(6, 5)
    ..lineTo(6, 2)
    ..close()
    ..moveTo(18, 2)
    ..lineTo(15, 2)
    ..lineTo(15, 5)
    ..lineTo(18, 5)
    ..lineTo(18, 2)
    ..close()
    ..moveTo(12, 2)
    ..lineTo(9, 2)
    ..lineTo(9, 5)
    ..lineTo(12, 5)
    ..lineTo(12, 2)
    ..close()
    ..fillType = PathFillType.evenOdd;

  final Paint flagPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = style.backgroundColor.withOpacity(1);

  canvas
    ..drawPath(path, paint)
    ..drawPath(flagPath, flagPaint)
    ..restore();
}
