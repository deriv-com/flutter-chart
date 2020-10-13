import 'package:flutter/material.dart';

/// Paints a horizontal dashed-line for the given parameters.
void paintHorizontalDashedLine(
  Canvas canvas,
  double lineStartX,
  double lineEndX,
  double lineY,
  Color lineColor,
  double lineThickness, {
  double dashWidth = 3,
  double dashSpace = 3,
}) {
  double startX = lineStartX;

  final Paint paint = Paint()
    ..color = lineColor
    ..strokeWidth = lineThickness;

  while (startX <= lineEndX) {
    canvas.drawLine(
      Offset(startX, lineY),
      Offset(startX + dashWidth, lineY),
      paint,
    );
    startX += dashSpace + dashWidth;
  }
}

/// Paints a vertical dashed-line for the given parameters.
void paintVerticalDashedLine(
  Canvas canvas,
  double lineX,
  double lineStartY,
  double lineEndY,
  Color lineColor,
  double lineThickness, {
  double dashWidth = 3,
  double dashSpace = 3,
}) {
  double startY = lineStartY;

  final Paint paint = Paint()
    ..color = lineColor
    ..strokeWidth = lineThickness;

  while (startY <= lineEndY) {
    canvas.drawLine(
      Offset(lineX, startY),
      Offset(lineX, startY + dashWidth),
      paint,
    );
    startY += dashSpace + dashWidth;
  }
}
