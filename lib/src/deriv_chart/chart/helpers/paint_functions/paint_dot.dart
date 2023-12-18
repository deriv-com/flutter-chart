import 'package:flutter/material.dart';

/// Paints a blinking semi-transparent glow around [center].
void paintBlinkingGlow(
  Canvas canvas,
  Offset center,
  double animationProgress,
  Color color, {
  int fullSize = 12,
  int alpha = 50,
}) =>
    canvas.drawCircle(
      center,
      fullSize * animationProgress,
      Paint()..color = color.withAlpha(alpha),
    );

/// Paints a dot on [center].
void paintDot(
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
