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
  final Paint paint = Paint()
    ..color = lineColor
    ..strokeWidth = lineThickness;

  if (lineStartX < lineEndX) {
    _paintLTRDashedLine(
      lineStartX,
      lineEndX,
      canvas,
      lineY,
      paint,
      dashWidth,
      dashSpace,
    );
  } else {
    _paintRTLDashedLine(
      lineEndX,
      lineStartX,
      canvas,
      lineY,
      paint,
      dashWidth,
      dashSpace,
    );
  }
}

void _paintLTRDashedLine(
  double leftX,
  double rightX,
  Canvas canvas,
  double lineY,
  Paint paint,
  double dashWidth,
  double dashSpace,
) {
  double startX = leftX;

  while (startX <= rightX) {
    canvas.drawLine(
      Offset(startX, lineY),
      Offset(startX + dashWidth, lineY),
      paint,
    );
    startX += dashSpace + dashWidth;
  }
}

void _paintRTLDashedLine(
  double leftX,
  double rightX,
  Canvas canvas,
  double lineY,
  Paint paint,
  double dashWidth,
  double dashSpace,
) {
  double startX = rightX;

  while (startX >= leftX) {
    canvas.drawLine(
      Offset(startX, lineY),
      Offset(startX - dashWidth, lineY),
      paint,
    );
    startX -= dashSpace + dashWidth;
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
