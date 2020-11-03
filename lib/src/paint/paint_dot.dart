import 'package:flutter/material.dart';

/// Paints a blinking opaque dot.
void paintBlinkingDot(
  Canvas canvas,
  Offset center,
  double animationProgress,
  Color color,
) =>
    canvas.drawCircle(
      center,
      12 * animationProgress,
      Paint()..color = color.withAlpha(50),
    );

/// Paints a dot on [center]
void paintIntersectionDot(
  Canvas canvas,
  Offset center,
  Color color,
) =>
    canvas.drawCircle(
      center,
      3,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..strokeWidth = 1,
    );
