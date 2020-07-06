import 'dart:ui';

import 'package:flutter/material.dart';

void paintLoadingAnimation({
  @required Canvas canvas,
  @required Size size,
  @required double loadingAnimationProgress,
  @required double loadingRightBoundEpoch,
}) {
  final _loadingPaint = Paint()
    ..color = Colors.white12
    ..style = PaintingStyle.fill;

  final invisibleRectWidth = size.height - loadingRightBoundEpoch;

  double convertToLoadingRange(double x) => x - invisibleRectWidth;

  final barWidthAndSpace = 8.0;
  _loadingPaint.strokeWidth = barWidthAndSpace / 2;

  double barX = 0;
  while (barX < size.height) {
    final xBeforeConversion =
        (barX + (loadingAnimationProgress * size.height)) % size.height;

    final xPos = convertToLoadingRange(xBeforeConversion);

    canvas.drawLine(
      Offset(xPos, size.height),
      Offset(loadingRightBoundEpoch,
          size.height - (loadingRightBoundEpoch - xPos)),
      _loadingPaint,
    );

    canvas.drawLine(Offset(0, xPos), Offset(xPos, 0), _loadingPaint);

    barX += (2 * barWidthAndSpace);
  }
}
