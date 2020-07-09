import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

void paintLoadingAnimation({
  @required Canvas canvas,
  @required Size size,
  @required double loadingAnimationProgress,
  @required double loadingRightBoundX,
}) {
  final loadingPaint = Paint()
    ..color = Colors.white12
    ..style = PaintingStyle.fill;

  final numberOfBars = 48;
  final rectWidth = max(size.width, size.height);
  final barWidthAndSpace = rectWidth / numberOfBars;

  loadingPaint.strokeWidth = barWidthAndSpace / 2;

  double convertToLoadingRange(double x) =>
      x - (rectWidth - loadingRightBoundX);

  double barX = 0;

  for (int i = 0; i < numberOfBars; i++) {
    final barPosition = convertToLoadingRange(
      (barX + (loadingAnimationProgress * rectWidth)) % rectWidth,
    );

    // A line in top-left triangle
    canvas.drawLine(
      Offset(0, barPosition),
      Offset(barPosition, 0),
      loadingPaint,
    );

    // A line in bottom-right triangle
    canvas.drawLine(
      Offset(barPosition, rectWidth),
      Offset(
        loadingRightBoundX,
        rectWidth - (loadingRightBoundX - barPosition),
      ),
      loadingPaint,
    );

    barX += barWidthAndSpace;
  }
}
