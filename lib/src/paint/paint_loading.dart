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

  final int numberOfBars = 48;
  final rectWidth = max(size.width, size.height);

  final invisibleRectWidth = (rectWidth - loadingRightBoundX);

  double convertToLoadingRange(double x) => x - invisibleRectWidth;

  final barWidthAndSpace = rectWidth / numberOfBars;

  loadingPaint.strokeWidth = barWidthAndSpace / 2;

  double barX = 0;

  for (int i = 0; i < numberOfBars; i++) {
    final barPosition = convertToLoadingRange(
        (barX + (loadingAnimationProgress * rectWidth)) % rectWidth);

    // Top-left triangle
    canvas.drawLine(
        Offset(0, barPosition), Offset(barPosition, 0), loadingPaint);

    // Bottom-right triangle
    canvas.drawLine(
      Offset(barPosition, rectWidth),
      Offset(
          loadingRightBoundX, rectWidth - (loadingRightBoundX - barPosition)),
      loadingPaint,
    );

    barX += barWidthAndSpace;
  }
}
