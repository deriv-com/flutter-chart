import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

/// Paints a blinking opaque dot.
void paintBlinkingDot(
  Canvas canvas,
  Offset center,
  double animationProgress,
  IntersectionDotStyle style,
) =>
    canvas.drawCircle(
      center,
      12 * animationProgress,
      Paint()..color = style.color.withAlpha(50),
    );

/// Paints a dot on [center]
void paintIntersectionDot(
  Canvas canvas,
  Offset center,
  IntersectionDotStyle style, {
  double radius = 3,
}) =>
    canvas.drawCircle(
      center,
      3,
      Paint()
        ..color = style.color
        ..style = style.isFilled ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = style.radius,
    );
