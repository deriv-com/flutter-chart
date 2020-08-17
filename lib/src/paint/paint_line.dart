import 'dart:ui' as ui;

import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

void paintLine(
  Canvas canvas,
  Size size, {
  @required List<double> xCoords,
  @required List<double> yCoords,
  @required LineStyle style,
}) {
  assert(xCoords.isNotEmpty);
  assert(yCoords.isNotEmpty);
  assert(xCoords.length == yCoords.length);

  Path path = Path();
  path.moveTo(xCoords[0], yCoords[0]);

  for (int i = 1; i < xCoords.length; i++) {
    path.lineTo(xCoords[i], yCoords[i]);
  }

  final linePaint = Paint()
    ..color = style.color
    ..style = PaintingStyle.stroke
    ..strokeWidth = style.thickness;

  canvas.drawPath(path, linePaint);

  if (style.areaColor != null) {
    _paintLineArea(
      canvas,
      size,
      linePath: path,
      lineStartX: xCoords[0],
      lineEndX: xCoords.last,
      style: style,
    );
  }
}

void _paintLineArea(
  Canvas canvas,
  Size size, {
  @required LineStyle style,
  Path linePath,
  double lineStartX,
  double lineEndX,
}) {
  final areaPaint = Paint()
    ..style = PaintingStyle.fill
    ..shader = ui.Gradient.linear(
      Offset(0, 0),
      Offset(0, size.height),
      [
        style.areaColor.withOpacity(0.2),
        style.areaColor.withOpacity(0.01),
      ],
    );

  linePath.lineTo(
    lineEndX,
    size.height,
  );
  linePath.lineTo(lineStartX, size.height);

  canvas.drawPath(
    linePath,
    areaPaint,
  );
}
