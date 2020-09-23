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

  double barX = 0;

  for (int i = 0; i < numberOfBars; i++) {
    final barPosition = convertToLoadingRange(
      (barX + (loadingAnimationProgress * rectWidth)) % rectWidth,
    );

    topLeftPath.reset();
    bottomRightPath.reset();

    double startPointX, startPointY;

    if (barPosition >= 0) {
      // A bar in top-left triangle
      startPointX = 0;
      startPointY = barPosition;

      if (barPosition > size.height) {
        startPointX = barPosition - size.height;
        startPointY = size.height;
      }

      topLeftPath.moveTo(startPointX, startPointY);
      topLeftPath.lineTo(barPosition, 0);
      if (barPosition + barWidth < loadingRightBoundX) {
        topLeftPath.lineTo(barPosition + barWidth, 0);
      } else {
        final barEndJutOut = barPosition + barWidth - loadingRightBoundX;
        topLeftPath.lineTo(barPosition + barWidth - barEndJutOut, 0);
        topLeftPath.lineTo(barPosition + barWidth - barEndJutOut, barEndJutOut);
      }
      topLeftPath.lineTo(startPointX, startPointY + barWidth);

      canvas.drawPath(topLeftPath, loadingPaint);
    }

    startPointX = 0;
    startPointY = rectWidth + barPosition;

    if (startPointY > size.height) {
      startPointX = (loadingRightBoundX * (size.height - startPointY)) /
          (rectWidth - loadingRightBoundX + barPosition - startPointY);
      startPointY = size.height;
    }

    if (startPointX <= loadingRightBoundX) {
      // A bar in bottom-right triangle
      bottomRightPath.moveTo(startPointX, startPointY);
      bottomRightPath.lineTo(
          loadingRightBoundX, rectWidth - (loadingRightBoundX - barPosition));
      bottomRightPath.lineTo(loadingRightBoundX,
          rectWidth - (loadingRightBoundX - barPosition) + barWidth);
      bottomRightPath.lineTo(startPointX, startPointY + barWidth);

      canvas.drawPath(bottomRightPath, loadingPaint);
    }

    barX += barWidthAndSpace;
  }
}
