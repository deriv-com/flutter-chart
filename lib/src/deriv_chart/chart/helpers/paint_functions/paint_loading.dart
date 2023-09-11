import 'dart:math';

import 'package:flutter/material.dart';

/// Paints loading animation from screen left edge to [loadingRightBoundX].
void paintLoadingAnimation({
  required Canvas canvas,
  required Size size,
  required double loadingAnimationProgress,
  required double loadingRightBoundX,
  Color? color,
}) {
  final Paint loadingPaint = Paint()
    ..color = color ?? Colors.white12
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  const int numberOfBars = 32;
  final double rectWidth = max(size.width, size.height);
  final double barWidthAndSpace = rectWidth / numberOfBars;
  final double barWidth = barWidthAndSpace / 2;

  double convertToLoadingRange(double x) =>
      x - (rectWidth - loadingRightBoundX);

  final Path topLeftPath = Path();
  final Path bottomRightPath = Path();

  double barX = 0;

  for (int i = 0; i < numberOfBars; i++) {
    final double barPosition = convertToLoadingRange(
      (barX + (loadingAnimationProgress * rectWidth)) % rectWidth,
    );

    topLeftPath.reset();
    bottomRightPath.reset();

    double startPointX, startPointY;

    if (barPosition >= 0) {
      if (barPosition > size.height) {
        startPointX = barPosition - size.height;
        startPointY = size.height;
      } else {
        startPointX = 0;
        startPointY = barPosition;
      }

      // A bar in top-left triangle
      topLeftPath
        ..moveTo(startPointX, startPointY)
        ..lineTo(barPosition, 0);

      if (barPosition + barWidth < loadingRightBoundX) {
        topLeftPath.lineTo(barPosition + barWidth, 0);
      } else {
        final double barEndJutOut = barPosition + barWidth - loadingRightBoundX;
        topLeftPath
          ..lineTo(barPosition + barWidth - barEndJutOut, 0)
          ..lineTo(barPosition + barWidth - barEndJutOut, barEndJutOut);
      }
      topLeftPath.lineTo(startPointX, startPointY + barWidth);

      canvas.drawPath(topLeftPath, loadingPaint);
    }

    startPointY = rectWidth + barPosition;

    if (startPointY > size.height) {
      startPointX = (loadingRightBoundX * (size.height - startPointY)) /
          (rectWidth - loadingRightBoundX + barPosition - startPointY);
      startPointY = size.height;
    } else {
      startPointX = 0;
    }

    if (startPointX <= loadingRightBoundX) {
      // A bar in bottom-right triangle
      bottomRightPath
        ..moveTo(startPointX, startPointY)
        ..lineTo(
          loadingRightBoundX,
          rectWidth - (loadingRightBoundX - barPosition),
        )
        ..lineTo(loadingRightBoundX,
            rectWidth - (loadingRightBoundX - barPosition) + barWidth)
        ..lineTo(startPointX, startPointY + barWidth);

      canvas.drawPath(bottomRightPath, loadingPaint);
    }

    barX += barWidthAndSpace;
  }
}
