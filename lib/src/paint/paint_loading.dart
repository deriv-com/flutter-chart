import 'dart:ui';

import 'package:flutter/material.dart';

void paintLoadingAnimation({
  @required Canvas canvas,
  @required Size size,
  @required double loadingAnimationProgress,
  @required double loadingRightBoundX,
}) {

  final animationProgress = 0.0;
  final loadingPaint = Paint()
    ..color = Colors.white12
    ..style = PaintingStyle.fill;

  final invisibleRectWidth = (size.height - loadingRightBoundX);

  canvas.drawLine(Offset(loadingRightBoundX, 0),
      Offset(loadingRightBoundX, size.height), loadingPaint);

  double convertToLoadingRange(double x) => x - invisibleRectWidth;

  final int numberOfBars = 36;

  final barWidthAndSpace = size.height / numberOfBars;

  loadingPaint.strokeWidth = barWidthAndSpace / 2;

  double barX = 0;

  for (int i = 0; i < numberOfBars; i++) {
    final xBeforeConversion =
        (barX + (animationProgress * size.height)) % size.height;

    final xPos = convertToLoadingRange(xBeforeConversion);

    canvas.drawLine(Offset(0, xPos), Offset(xPos, 0), loadingPaint);

//    canvas.drawLine(
//      Offset(xPos, size.height),
//      Offset(loadingRightBoundX, size.height - (loadingRightBoundX - xPos)),
//      loadingPaint,
//    );

    barX += barWidthAndSpace;
  }
}
