import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

/// Paints a blinking opaque dot.
void paintBlinkingDot(
  Canvas canvas, {
  @required Offset center,
  @required double animationProgress,
  @required IntersectionDotStyle style,
}) {
  canvas.drawCircle(
    center,
    12 * animationProgress,
    Paint()..color = style.color.withAlpha(50),
  );
//  canvas.drawCircle(
//    center,
//    3,
//    Paint()..color = style.color,
//  );
}

/// Paints a dot on [x] and [y]
void paintIntersectionDot(
  Canvas canvas,
  double x,
  double y,
  IntersectionDotStyle style, {
  double radius = 3,
}) {
  canvas.drawCircle(
    Offset(x, y),
    3,
    Paint()
      ..color = style.color
      ..style = style.isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = style.radius,
  );
}
