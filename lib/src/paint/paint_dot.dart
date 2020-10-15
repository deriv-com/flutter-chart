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
      4 * style.radius * animationProgress,
      Paint()..color = style.color.withAlpha(50),
    );

/// Paints a dot on [center]
void paintIntersectionDot(
  Canvas canvas,
  Offset center,
  IntersectionDotStyle style,
) =>
    canvas.drawCircle(
      center,
      style.radius,
      Paint()
        ..color = style.color
        ..style = style.isFilled ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 1,
    );
