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
    final xBeforeConversion =
        (barX + (loadingAnimationProgress * rectWidth)) % rectWidth;

    final xPos = convertToLoadingRange(xBeforeConversion);

    canvas.drawLine(Offset(0, xPos), Offset(xPos, 0), loadingPaint);

    canvas.drawLine(
      Offset(xPos, rectWidth),
      Offset(loadingRightBoundX, rectWidth - (loadingRightBoundX - xPos)),
      loadingPaint,
    );

    barX += barWidthAndSpace;
  }
}
