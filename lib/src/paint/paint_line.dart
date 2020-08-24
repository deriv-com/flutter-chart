import 'dart:ui' as ui;

import 'package:flutter/material.dart';

void paintLine(
  Canvas canvas,
  Size size, {
  @required List<double> xCoords,
  @required List<double> yCoords,
}) {
  assert(xCoords.isNotEmpty);
  assert(yCoords.isNotEmpty);
  assert(xCoords.length == yCoords.length);

  final path = Path();
  path.moveTo(xCoords[0], yCoords[0]);

  for (var i = 1; i < xCoords.length; i++) {
    path.lineTo(xCoords[i], yCoords[i]);
  }

  final linePaint = Paint()
    ..color = Colors.white.withOpacity(0.8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  canvas.drawPath(path, linePaint);

  _paintLineArea(
    canvas,
    size,
    linePath: path,
    lineStartX: xCoords[0],
    lineEndX: xCoords.last,
  );
}

void _paintLineArea(
  Canvas canvas,
  Size size, {
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
        Colors.white.withOpacity(0.2),
        Colors.white.withOpacity(0.01),
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
