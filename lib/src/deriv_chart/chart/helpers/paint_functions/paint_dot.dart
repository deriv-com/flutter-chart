import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
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

/// Paints a dot at [center]. If [hasGlow] is true, a semi-transparent glow is
/// drawn around the dot. [dotRadius] and [glowRadius] control their sizes.
void paintDotWithGlow(
  Canvas canvas,
  Offset center, {
  Paint? paint,
  double dotRadius = 3,
  Color? color,
  bool hasGlow = false,
  double? glowRadius,
  bool visible = true,
}) {
  if (!visible) {
    return;
  }

  // Use default paint if none provided
  paint ??= Paint()
    ..style = PaintingStyle.fill
    ..strokeWidth = 1;

  // Set color if specified
  if (color != null) {
    paint.color = color;
  }

  // Draw the dot
  canvas.drawCircle(center, dotRadius, paint);

  if (hasGlow) {
    // Set glow radius, default to 2x dot size if not specified
    glowRadius ??= dotRadius * 2;

    // // Create a semi-transparent glow paint
    final Paint glowPaint = Paint()
      ..color = paint.color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Draw the glow
    canvas.drawCircle(center, glowRadius, glowPaint);
  }
}

/// Paints a blinking dot on [center].
void paintBlinkingDot(
  Canvas canvas,
  double dotX,
  double y,
  AnimationInfo animationInfo,
  Color color,
) {
  paintDotWithGlow(canvas, Offset(dotX, y), color: color);

  paintBlinkingGlow(
    canvas,
    Offset(dotX, y),
    animationInfo.blinkingPercent,
    color,
  );
}
