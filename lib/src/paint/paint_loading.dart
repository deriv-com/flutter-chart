import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

/// Paints loading animation from screen left edge to [loadingRightBoundX]
void paintLoadingAnimation({
  @required Canvas canvas,
  @required Size size,
  @required double loadingAnimationProgress,
  @required double loadingRightBoundX,
}) {
  final loadingPaint = Paint()
    ..color = Colors.white12
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  final numberOfBars = 32;
  final rectWidth = max(size.width, size.height);
  final barWidthAndSpace = rectWidth / numberOfBars;
  final barWidth = barWidthAndSpace / 2;

  double convertToLoadingRange(double x) =>
      x - (rectWidth - loadingRightBoundX);

  final topLeftPath = Path();
  final bottomRightPath = Path();

  var barX = 0.0;

  for (var i = 0; i < numberOfBars; i++) {
    final barPosition = convertToLoadingRange(
      (barX + (loadingAnimationProgress * rectWidth)) % rectWidth,
    );

    topLeftPath.reset();
    bottomRightPath.reset();

    // A bar in top-left triangle
    topLeftPath.moveTo(0, barPosition);
    topLeftPath.lineTo(barPosition, 0);
    if (barPosition + barWidth < loadingRightBoundX) {
      topLeftPath.lineTo(barPosition + barWidth, 0);
    } else {
      final barEndJutOut = barPosition + barWidth - loadingRightBoundX;
      topLeftPath.lineTo(barPosition + barWidth - barEndJutOut, 0);
      topLeftPath.lineTo(barPosition + barWidth - barEndJutOut, barEndJutOut);
    }
    topLeftPath.lineTo(0, barPosition + barWidth);

    canvas.drawPath(topLeftPath, loadingPaint);

    // A bar in bottom-right triangle
    bottomRightPath.moveTo(barPosition, rectWidth);
    bottomRightPath.lineTo(
        loadingRightBoundX, rectWidth - (loadingRightBoundX - barPosition));
    bottomRightPath.lineTo(loadingRightBoundX,
        rectWidth - (loadingRightBoundX - barPosition) + barWidth);
    bottomRightPath.lineTo(barPosition, rectWidth + barWidth);

    canvas.drawPath(bottomRightPath, loadingPaint);

    barX += barWidthAndSpace;
  }
}
